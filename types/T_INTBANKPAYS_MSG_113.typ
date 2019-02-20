create or replace type T_INTBANKPAYS_MSG_113 FORCE UNDER t_intbankpays_msg_103
(   
    OVERRIDING MEMBER FUNCTION GET_GROUND_REXP RETURN VARCHAR,
    MEMBER PROCEDURE CHECK_RUB_PAYMENT,
    MEMBER PROCEDURE fill_corr_bank_data(SELF IN OUT T_INTBANKPAYS_MSG_113, p_raise BOOLEAN DEFAULT TRUE),
    OVERRIDING MEMBER FUNCTION check_data_before_feeupdating(SELF IN OUT T_INTBANKPAYS_MSG_113) RETURN BOOLEAN,
    OVERRIDING MEMBER PROCEDURE set_ground(p_var IN VARCHAR2),
    OVERRIDING MEMBER PROCEDURE set_currency(p_var IN INTEGER),
    OVERRIDING MEMBER PROCEDURE CHECK_RECEIVER_TAX,
    OVERRIDING MEMBER PROCEDURE CHECKING_PAYMENT(p_state IN INT DEFAULT NULL),
    OVERRIDING MEMBER PROCEDURE CHECK_FOR_STATE_VERIFICATION ,
    OVERRIDING MEMBER FUNCTION get_main_operation_ground RETURN VARCHAR,
    OVERRIDING MEMBER FUNCTION get_receiver_id(SELF IN OUT T_INTBANKPAYS_MSG_113) RETURN INTEGER,
    OVERRIDING MEMBER FUNCTION get_fee_payer_id(SELF IN OUT T_INTBANKPAYS_MSG_113) RETURN INTEGER,
    OVERRIDING MEMBER FUNCTION get_ground_max_lines_count RETURN INTEGER,
    --MEMBER FUNCTION normalize(p_text VARCHAR2, p_chr_per_line INTEGER, p_max_line INTEGER) RETURN VARCHAR2,
    MEMBER PROCEDURE CHECK_OPERACTION_CODE,
    MEMBER PROCEDURE CHECK_CORR_BANK,
    MEMBER PROCEDURE CHECK_BENEFICIAR_BANK,
    MEMBER PROCEDURE CHECK_AMOUNT_ENOUGHT(p_acc_rest NUMBER, p_acc VARCHAR),
    OVERRIDING MEMBER PROCEDURE CHECK_AMOUNT_ENOUGHT,
    MEMBER PROCEDURE CHECK_INTBANK_ACCOUNT,
    MEMBER PROCEDURE update_payer_additional,
    MEMBER PROCEDURE update_receiver_additional,
    MEMBER PROCEDURE update_beneficiar_additional,
    MEMBER PROCEDURE update_intbank_additional,
    OVERRIDING MEMBER PROCEDURE update_attribute_trigger(p_attr IN t_intbankpays_attr, p_is_delete BOOLEAN),
    OVERRIDING  MEMBER PROCEDURE set_beneficiar_bank_name (p_var IN VARCHAR2),
    OVERRIDING MEMBER PROCEDURE set_beneficiar_bank_swift(p_var IN VARCHAR2, p_alt_swift IN VARCHAR2 DEFAULT NULL),
    OVERRIDING MEMBER PROCEDURE CHECK_ADDITIONAL_INFO,
    OVERRIDING MEMBER PROCEDURE set_payer_account(p_var IN VARCHAR2),
    OVERRIDING MEMBER PROCEDURE set_receiver_name(p_var IN VARCHAR2),
    OVERRIDING MEMBER PROCEDURE set_receiver_iban (p_var IN VARCHAR2),
     OVERRIDING MEMBER PROCEDURE set_receiver_tax (p_var IN VARCHAR2),
    OVERRIDING MEMBER PROCEDURE set_system_id(p_var IN INTEGER),
    OVERRIDING MEMBER PROCEDURE onCreate,
    CONSTRUCTOR FUNCTION T_INTBANKPAYS_MSG_113 RETURN SELF AS RESULT ,
    CONSTRUCTOR FUNCTION T_INTBANKPAYS_MSG_113(pobj IN OUT NOCOPY t_interbankpayments_extend) RETURN SELF AS RESULT
) NOT FINAL
/
create or replace type body T_INTBANKPAYS_MSG_113 IS
    OVERRIDING MEMBER FUNCTION GET_GROUND_REXP RETURN VARCHAR IS BEGIN RETURN '^[A-Za-z0-9[:space:]()'',./-]*$'; END;

    MEMBER PROCEDURE fill_corr_bank_data(SELF IN OUT T_INTBANKPAYS_MSG_113, p_raise BOOLEAN DEFAULT TRUE)IS
        l_swift         VARCHAR(100) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_CORR_BANK_SWIFT).value_str;
        l_corr_acc_type VARCHAR(100) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_CORR_BANK_ACC_TYPE).value_str;
        l_mt113_cor_acc t_mt113_corr_bank_acc DEFAULT jui_interbankpayments_tools.get_bank_corr_account(l_swift,
                                                                                                              SELF.obj.CURRENCY,
                                                                                                              l_corr_acc_type);
    BEGIN
        IF p_raise AND (l_mt113_cor_acc IS NULL OR l_mt113_cor_acc.id  IS NULL )
            THEN 
                const_exceptions.raise_exception(const_exceptions.MT_113_UNKNOW_CB_ACC, 
                                                 p_val1 => l_swift,
                                                 p_val2 => ibs.api_currency.get_iso_name(SELF.obj.CURRENCY),
                                                 p_val3 => l_corr_acc_type); 
        END IF;
        
        SELF.update_attribute(T_INTBANKPAYS_ATTR(CONST_INTERBANKPAYMENTS.ATTR_113_CORR_BANK_ACC,
                                                              value_int => NULL,    
                                                              value_str => l_mt113_cor_acc.account), FALSE);
        SELF.update_attribute(T_INTBANKPAYS_ATTR(CONST_INTERBANKPAYMENTS.ATTR_113_CORR_BANK_NAME,
                                                  value_int => NULL,     
                                                  value_str => l_mt113_cor_acc.bank_name), FALSE);
        SELF.update_attribute(T_INTBANKPAYS_ATTR(CONST_INTERBANKPAYMENTS.ATTR_113_CORR_BANK_ID,     
                                                  value_int => NULL,
                                                  value_str => l_mt113_cor_acc.bank_list_id), FALSE);  
        SELF.update_attribute(T_INTBANKPAYS_ATTR(CONST_INTERBANKPAYMENTS.ATTR_113_CORR_BANK_ACC_BOB,     
                                                  value_int => NULL,
                                                  value_str => l_mt113_cor_acc.account_bob), FALSE);
    END;


    OVERRIDING MEMBER FUNCTION check_data_before_feeupdating(SELF IN OUT T_INTBANKPAYS_MSG_113) RETURN BOOLEAN IS
    BEGIN
        IF  SELF.OBJ.PAYER_ACCOUNT IS NULL OR 
            SELF.obj.AMOUNT IS NULL OR 
            SELF.obj.CURRENCY IS NULL
        THEN
            api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                           p_action => 'T_INTBANKPAYS_MSG.update_fee_collection',
                           p_result => 'Can not calculate fee - one of important fields is empty',
                           p_additional => 'PAYER ACCOUNT : ' || SELF.OBJ.PAYER_ACCOUNT || chr(10) ||
                                           'AMOUNT : ' || SELF.OBJ.AMOUNT || chr(10) ||
                                           'CURRENCY : ' || SELF.OBJ.CURRENCY || chr(10) ||
                                           'BENEFICIAR_BANK_SWIFT : ' || SELF.OBJ.BENEFICIAR_BANK_SWIFT);
                
            RETURN FALSE; 
        END IF;
        CHECK_AMOUNT_ENOUGHT();
        RETURN TRUE;
    END;
    
    OVERRIDING MEMBER FUNCTION get_ground_max_lines_count RETURN INTEGER IS
    BEGIN RETURN const_interbankpayments.CFG_MT113_DEF_GROUND_MAXLINES; END;
    
    OVERRIDING MEMBER PROCEDURE set_ground(p_var IN VARCHAR2) IS 
        l_var VARCHAR2(5000) DEFAULT jui_interbankpayments_tools.TRIMMING(p_var);
    BEGIN
        SELF.obj.GROUND := SELF.full_normalize(l_var, 4);
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                               p_action => 'set_ground', 
                               p_autonomus => TRUE,
                               p_result => SQLERRM || '',
                               p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;


    OVERRIDING MEMBER PROCEDURE CHECKING_PAYMENT(p_state IN INT DEFAULT NULL) IS
    BEGIN (SELF AS T_INTBANKPAYS_MSG).CHECKING_PAYMENT(p_state); END;
    
    OVERRIDING MEMBER PROCEDURE set_currency(p_var IN INTEGER) IS
        l_temp BOOLEAN;
        l_swift         VARCHAR(100) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_CORR_BANK_SWIFT).value_str;
        l_corr_acc_type VARCHAR(100) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_CORR_BANK_ACC_TYPE).value_str;
        l_mt113_cor_acc t_mt113_corr_bank_acc DEFAULT jui_interbankpayments_tools.get_bank_corr_account(l_swift,
                                                                                                              SELF.obj.CURRENCY,
                                                                                                              l_corr_acc_type);
    BEGIN 
        (SELF AS T_INTBANKPAYS_MSG).set_currency(p_var);
        IF l_swift IS NOT NULL AND l_corr_acc_type IS NOT NULL AND l_mt113_cor_acc IS NOT NULL THEN
            fill_corr_bank_data;
        END IF;
        
        IF p_var = ibs.const_currency.CURRENCY_RUB THEN
            SELF.update_attribute(p_attr_id => const_interbankpayments.ATTR_113_OPERATION_CODE, 
                                  p_value_str => const_interbankpayments.CFG_MT113_OPERCODE_OUR);
        END IF;
    END;
    
    
    OVERRIDING MEMBER PROCEDURE CHECK_RECEIVER_TAX IS BEGIN 
        NULL;
        /*IF SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_UNCHECK_REC_TAX_NULL) THEN
           api_interbankpayments.add_payment_change(SELF.obj, 
                           p_action => 't_interbankpayments.check_receiver_iban', 
                           p_additional => 'Uncheck attribute for checking receiver tax is null'); 
        ELSIF SELF.obj.RECEIVER_TAX IS NULL OR trim(SELF.obj.RECEIVER_TAX) = '' THEN
            raise_application_error(const_exceptions.RECEIVERTAX_NO.integ, const_exceptions.RECEIVERTAX_NO.str);
        ELSIF SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_UNCHECK_REC_TAX) THEN
           api_interbankpayments.add_payment_change(SELF.obj, 
                                                    p_action => 't_interbankpayments.check_receiver_iban', 
                                                    p_additional => 'Uncheck attribute for checking receiver tax');
        ELSIF   (length(SELF.obj.RECEIVER_TAX) <> 7 AND 
                length(SELF.obj.RECEIVER_TAX) <> 10) OR 
                not regexp_like(SELF.obj.RECEIVER_TAX, SELF.GET_RECEIVER_TAX_REXP) THEN
            raise_application_error(const_exceptions.RECEIVERTAX_WRONG.integ, const_exceptions.format(const_exceptions.RECEIVERTAX_WRONG.str, 
                                                                                                    TO_CHAR(SELF.obj.RECEIVER_TAX),
                                                                                                    TO_CHAR(length(SELF.obj.RECEIVER_TAX))));  
        END IF;*/
    END;
    
    MEMBER PROCEDURE CHECK_CORR_BANK IS
        l_corr_bank_swift   VARCHAR(500) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_CORR_BANK_SWIFT).value_str;
        l_corr_bank_name    VARCHAR(500) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_CORR_BANK_NAME).value_str;
        l_corr_bank_acc_bob VARCHAR(500) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_CORR_BANK_ACC_BOB).value_str;
        l_corr_bank_acc     VARCHAR(500) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_CORR_BANK_ACC).value_str;
    BEGIN
        CASE 
             WHEN l_corr_bank_swift IS NULL THEN  const_exceptions.raise_exception(const_exceptions.CORR_BANK_SWIFT_ISNULL);
             WHEN l_corr_bank_name IS NULL THEN  const_exceptions.raise_exception(const_exceptions.CORR_BANK_NAME_ISNULL);
             WHEN l_corr_bank_acc_bob IS NULL THEN  const_exceptions.raise_exception(const_exceptions.CORR_BANK_ACCBOB_ISNULL);
             WHEN l_corr_bank_acc IS NULL THEN  const_exceptions.raise_exception(const_exceptions.CORR_BANK_IBAN_ISNULL);
             ELSE RETURN;
        END CASE;
    END;
    MEMBER PROCEDURE CHECK_RUB_PAYMENT IS
        l_n4    VARCHAR2(5000) DEFAULT obj.get_attribute_val(const_interbankpayments.ATTR_113_RUB_NN4).value_str;
        l_n5    VARCHAR2(5000) DEFAULT obj.get_attribute_val(const_interbankpayments.ATTR_113_RUB_NN5).value_str;
        l_n8    VARCHAR2(5000) DEFAULT obj.get_attribute_val(const_interbankpayments.ATTR_113_RUB_NN8).value_str;
        l_flag  INTEGER DEFAULT 0;
    BEGIN
        IF l_n4 IS NOT NULL THEN l_flag := l_flag + 1; END IF;
        IF l_n5 IS NOT NULL THEN l_flag := l_flag + 1; END IF;
        IF l_n8 IS NOT NULL THEN l_flag := l_flag + 1; END IF;
        
        IF l_flag NOT IN (0,3) THEN const_exceptions.raise_exception(const_exceptions.MT113_RUB_NN_MUSTNNULL); END IF;
    END;
    
    MEMBER PROCEDURE CHECK_BENEFICIAR_BANK IS
    BEGIN
        CASE 
             WHEN SELF.obj.BENEFICIAR_BANK_NAME IS NULL THEN  const_exceptions.raise_exception(const_exceptions.NO_BENB_NAME);
             --WHEN SELF.obj.BENEFICIAR_BANK_SWIFT IS NULL THEN  const_exceptions.raise_exception(const_exceptions.NO_BENB_SWIFT);
             ELSE RETURN;
        END CASE;
    END;
    
    MEMBER PROCEDURE CHECK_OPERACTION_CODE IS
        l_op_code VARCHAR(100) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_OPERATION_CODE).value_str;
    BEGIN
        CASE 
             WHEN l_op_code IS NULL 
                THEN  const_exceptions.raise_exception(const_exceptions.MT113_NO_OPCODE);
             WHEN l_op_code NOT IN (const_interbankpayments.CFG_MT113_OPERCODE_BEN, 
                                    const_interbankpayments.CFG_MT113_OPERCODE_OUR,
                                    const_interbankpayments.CFG_MT113_OPERCODE_SHA)
                THEN const_exceptions.raise_exception(const_exceptions.MT113_UNKONW_OPCODE);
             ELSE RETURN;
        END CASE;
    END;
    
    OVERRIDING MEMBER PROCEDURE CHECK_FOR_STATE_VERIFICATION IS 
    BEGIN
        SELF.CHECK_MSGTYPE;
        SELF.CHECK_CORR_BANK;
        SELF.CHECK_BENEFICIAR_BANK;
        SELF.CHECK_RECEIVER_NAME;
        SELF.CHECK_RECEIVER_IBAN;
       -- SELF.CHECK_PAYER_ACCOUNT;
        SELF.CHECK_OPERACTION_CODE;
        SELF.CHECK_GROUND;
        IF SELF.obj.CURRENCY = ibs.const_currency.CURRENCY_RUB THEN
            SELF.CHECK_RUB_PAYMENT;
        END IF;
    END;

    OVERRIDING MEMBER FUNCTION get_main_operation_ground RETURN VARCHAR IS
    BEGIN
        RETURN 'Köçürmə ' || SELF.obj.PAYER_NAME || ' ' || SELF.obj.AMOUNT || ' ' || SELF.obj.CURRENCY_CODE;
    END;
    
    OVERRIDING MEMBER FUNCTION get_receiver_id(SELF IN OUT T_INTBANKPAYS_MSG_113) RETURN INTEGER IS
    BEGIN
        return ibs.api_account.get_account_for_settelment_id(jui_interbankpayments_tools.get_bank_corr_account(SELF.obj.GET_ATTRIBUTE_VAL(const_interbankpayments.ATTR_113_CORR_BANK_SWIFT).value_str,
                                                                                                                     SELF.obj.CURRENCY,
                                                                                                                     SELF.obj.GET_ATTRIBUTE_VAL(const_interbankpayments.ATTR_113_CORR_BANK_ACC_TYPE).value_str).account_bob);
    END;

    OVERRIDING MEMBER FUNCTION get_fee_payer_id(SELF IN OUT T_INTBANKPAYS_MSG_113) RETURN INTEGER
    IS BEGIN 
        IF obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_113_FEE_ACCOUNT) THEN
            RETURN ibs.api_account.get_account_for_settelment_id(obj.get_attribute_val(CONST_INTERBANKPAYMENTS.ATTR_113_FEE_ACCOUNT).value_str);
        ELSE  RETURN SELF.get_payer_id;
        END IF;
    END;
    
    MEMBER PROCEDURE CHECK_AMOUNT_ENOUGHT(p_acc_rest NUMBER, p_acc VARCHAR) IS
    BEGIN
        IF p_acc_rest < SELF.Obj.FEE_SUM_AMOUNT THEN
            const_exceptions.raise_exception(p_raise_msg => const_exceptions.MT113_FEE_ACC_ENOUGHT, 
                                             p_val1 => p_acc,
                                             p_val2 => p_acc_rest,
                                             p_val3 => SELF.Obj.FEE_SUM_AMOUNT);
         END IF;
    END;
    
    OVERRIDING MEMBER PROCEDURE CHECK_AMOUNT_ENOUGHT IS
        l_fee_acc   ibs.account%rowtype;
        l_acc_attr  t_intbankpays_attr DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_FEE_ACCOUNT);
        l_converted_plan NUMBER;
    BEGIN
         IF l_acc_attr.value_str IS NOT NULL THEN
             l_fee_acc := ibs.api_account.read_account(l_acc_attr.value_str);
             l_converted_plan := ibs.api_exchange.convert_amount(p_rate_kind_id => ibs.const_exchange.CUR_EXCH_RATE_KIND_CBAR,
                                                                 p_amount => l_fee_acc.rest_plan ,
                                                                 p_from_currency_id => l_fee_acc.currency_id ,
                                                                 p_to_currency_id => SELF.obj.CURRENCY);
             CHECK_AMOUNT_ENOUGHT(l_converted_plan, l_fee_acc.account_number);
         END IF;
    END;
    MEMBER PROCEDURE CHECK_INTBANK_ACCOUNT IS
        l_acc_attr      t_intbankpays_attr DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_INTBANK_ACC);
        l_swift_attr    t_intbankpays_attr DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_INTBANK_SWIFT);
    BEGIN
        IF NOT jui_interbankpayments_tools.ISVALID_IBANKACCOUNT(P_IBANACCOUNT => l_acc_attr.value_str, P_SWIFT => l_swift_attr.value_str) THEN
            const_exceptions.raise_exception(p_raise_msg => const_exceptions.MT113_IB_IBAN_WRONG,p_val1 => l_acc_attr.value_str);
        END IF;
    END;
    
    -- Возможно не нужно!
    OVERRIDING MEMBER PROCEDURE CHECK_ADDITIONAL_INFO IS
        attr_ref_acc  t_intbankpays_attr DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_REFLECTING_ACCOUNT);
        attr_add_info t_intbankpays_attr DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_ADDITIONAL_INFO);
    BEGIN
        IF attr_ref_acc.value_str = 'XXXXXXXX' AND
           attr_add_info.value_str IS NULL OR trim(attr_add_info.value_str) = '' THEN
            const_exceptions.raise_exception(const_exceptions.NO_REF_ACC_ADD);
        END IF;
    END;
    
    /**************************************** Overridings ****************************************/
    OVERRIDING MEMBER PROCEDURE set_receiver_name(p_var IN VARCHAR2) IS
    BEGIN 
        (SELF AS t_intbankpays_msg).set_receiver_name(p_var);
        update_receiver_additional;                                              
    END;
     
    OVERRIDING MEMBER PROCEDURE set_receiver_iban (p_var IN VARCHAR2) IS 
    BEGIN 
        (SELF AS t_intbankpays_msg).set_receiver_iban(p_var);
        update_receiver_additional;                                        
    END;
    
    OVERRIDING MEMBER PROCEDURE set_receiver_tax (p_var IN VARCHAR2) IS
    BEGIN
        (SELF AS t_intbankpays_msg).set_receiver_tax(p_var);
        update_receiver_additional;                                               
    END;

    OVERRIDING MEMBER PROCEDURE set_payer_account(p_var IN VARCHAR2) IS 
    BEGIN 
        (SELF AS t_intbankpays_msg).set_payer_account(p_var);
        update_payer_additional;
    END;
    
    OVERRIDING MEMBER PROCEDURE onCreate IS BEGIN 
        SELF.set_payer_branch_id(ibs.api_context.get_def_branch);
        --SELF.obj.CURRENCY := ibs.const_currency.CURRENCY_USD;
        SELF.obj.SYSTEM_ID := const_interbankpayments.PAYMENT_SYSTEM_ID_SWIFT;
        SELF.update_attribute(p_attr_id => const_interbankpayments.ATTR_113_OPERATION_CODE,
                              p_value_str => const_interbankpayments.CFG_MT113_OPERCODE_OUR);
        SELF.update_attribute(p_attr_id => const_interbankpayments.ATTR_113_CORR_BANK_ACC_TYPE,
                              p_value_str => const_interbankpayments.CFG_MT113_ACCTYPE_NOSTRO);                      
        SELF.update_attribute(p_attr_id => const_interbankpayments.ATTR_UNCHECK_IBAN);
    END;
    
    OVERRIDING MEMBER PROCEDURE set_system_id(p_var IN INTEGER)
    IS BEGIN 
        (SELF AS T_INTBANKPAYS_MSG).set_system_id(p_var);
        IF p_var NOT IN (const_interbankpayments.PAYMENT_SYSTEM_ID_XOHKS) THEN
            SELF.remove_attribute(const_interbankpayments.ATTR_IS_SUPPORT_BATCHING);
        ELSE 
            IF NOT SELF.obj.isset_attribute(const_interbankpayments.ATTR_IS_SUPPORT_BATCHING) THEN
                SELF.obj.update_attr_val(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_IS_SUPPORT_BATCHING,
                                                             value_str => NULL,
                                                             value_int => NULL));
            END IF;
        END IF;
    END;
    OVERRIDING  MEMBER PROCEDURE set_beneficiar_bank_name (p_var IN VARCHAR2) IS 
        l_var           VARCHAR2(100) DEFAULT jui_interbankpayments_tools.TRIMMING(p_var);
        l_banks_list    bank_list%ROWTYPE;
    BEGIN 
        obj.BENEFICIAR_BANK_NAME := l_var;
        
        IF obj.BENEFICIAR_BANK_SWIFT IS NOT NULL THEN
            l_banks_list := jui_interbankpayments_tools.find_in_banks_list_by_swift(obj.BENEFICIAR_BANK_SWIFT);
            SELF.remove_attribute(const_interbankpayments.ATTR_113_BENEFBANK_IN_AG, FALSE);
            IF l_banks_list.ID IS NULL THEN
                l_banks_list.bank_swift := obj.BENEFICIAR_BANK_SWIFT;
                l_banks_list.bank_name := p_var;
                jui_interbankpayments_tools.add_to_bank_list(l_banks_list);
                api_interbankpayments.add_payment_change(mobj => obj, 
                       p_action => 'update_attribute_trigger', 
                       p_additional => 'Банк ' || l_banks_list.bank_swift || ' отсутствовал в списке - добавлен автоматически');
            END IF;
        END IF;
        
        api_interbankpayments.add_payment_change(mobj => obj, 
                           p_action => 'set_beneficiar_bank_name', 
                           p_additional => l_var);
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                               p_action => 'set_beneficiar_bank_name', 
                               p_autonomus => TRUE,
                               p_result => SQLERRM || '',
                               p_additional => dbms_utility.format_error_backtrace);
            RAISE;    
    END;
    
    OVERRIDING MEMBER PROCEDURE set_beneficiar_bank_swift(p_var IN VARCHAR2, p_alt_swift IN VARCHAR2 DEFAULT NULL) IS 
        l_var       VARCHAR2(50) DEFAULT TRIM(p_var);
        l_bank_list bank_list%rowtype;
    BEGIN
       IF l_var IS NOT NULL THEN
           (SELF as t_intbankpays_msg).set_beneficiar_bank_swift(p_var, p_alt_swift);
           l_bank_list := jui_interbankpayments_tools.find_in_banks_list_by_swift(l_var);
           IF l_bank_list.bank_swift IS NOT NULL THEN
               api_interbankpayments.add_payment_change(mobj => obj, 
                                                           p_action => 'set_beneficiar_bank_swift', 
                                                           p_additional => 'Автоматическое заполнение полей банка бенефициатра по свифту');
               SELF.obj.BENEFICIAR_BANK_NAME := l_bank_list.bank_name;
               SELF.obj.BENEFICIAR_BANK_TAX := l_bank_list.voen;
               SELF.obj.BENEFICIAR_BANK_CORR_ACCOUNT := l_bank_list.corr_acc;
               SELF.update_attribute(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_113_BENEFBANK_IN_AG,
                                                                 value_str => NULL,
                                                                 value_int => 1), FALSE);
           END IF;
           api_interbankpayments.add_payment_change(mobj => obj, 
                           p_action => 'set_beneficiar_bank_swift', 
                           p_additional => l_var);
           update_beneficiar_additional;
       ELSE
            SELF.obj.BENEFICIAR_BANK_SWIFT := NULL;
            IF SELF.obj.isset_attribute(const_interbankpayments.ATTR_113_BENEFBANK_IN_AG) THEN
                SELF.obj.BENEFICIAR_BANK_NAME := NULL;
                SELF.obj.BENEFICIAR_BANK_TAX := NULL;
                SELF.obj.BENEFICIAR_BANK_CORR_ACCOUNT := NULL;
                api_interbankpayments.add_payment_change(mobj => obj, 
                               p_action => 'set_beneficiar_bank_swift', 
                               p_additional => 'Передано пустое значение Swift. Произведена очистка полей');
                SELF.remove_attribute(const_interbankpayments.ATTR_113_BENEFBANK_IN_AG, FALSE);
            END IF;
       END IF;    
       
       
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                               p_action => 'set_beneficiar_bank_swift', 
                               p_autonomus => TRUE,
                               p_result => SQLERRM || '',
                               p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;
    
    MEMBER PROCEDURE update_payer_additional IS
        l_tax           VARCHAR(500)    DEFAULT SELF.obj.PAYER_TAX_NUMBER;
        l_padditional   VARCHAR(500)    DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_PAYER_ADDINFO).value_str;
        l_line_count    INTEGER         DEFAULT 3;
    BEGIN
        IF l_tax IS NOT NULL THEN l_line_count := l_line_count - 1; END IF;    
        
        SELF.update_attribute(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_113_PAYER_ADDINFO,
                                                 value_str => SELF.full_normalize(l_padditional, l_line_count),
                                                 value_int => NULL),
                              FALSE);
    END;
    
    MEMBER PROCEDURE update_intbank_additional IS
        l_padditional   VARCHAR(500)    DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_INTBANK_ADDINFO).value_str;
        l_line_count    INTEGER         DEFAULT 3;
    BEGIN
            
    
    
    
        SELF.update_attribute(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_113_INTBANK_ADDINFO,
                                                 value_str => SELF.full_normalize(l_padditional, l_line_count),
                                                 value_int => NULL),
                              FALSE);
    END;
    
    MEMBER PROCEDURE update_beneficiar_additional IS
        l_padditional   VARCHAR(500)    DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_BENEFBANK_ADDINFO).value_str;
        l_line_count    INTEGER         DEFAULT 3;
    BEGIN
        SELF.update_attribute(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_113_BENEFBANK_ADDINFO,
                                                 value_str => SELF.full_normalize(l_padditional, l_line_count),
                                                 value_int => NULL),
                              FALSE);
    END;
    
    MEMBER PROCEDURE update_receiver_additional IS
        l_tax           VARCHAR(500)    DEFAULT SELF.obj.RECEIVER_TAX;
        l_padditional   VARCHAR(500)    DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_RECIVER_ADDINFO).value_str;
        l_line_count    INTEGER         DEFAULT 3;
    BEGIN
        IF l_tax IS NOT NULL THEN l_line_count := l_line_count - 1; END IF;    
        SELF.update_attribute(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_113_RECIVER_ADDINFO,
                                                 value_str => SELF.full_normalize(l_padditional, l_line_count),
                                                 value_int => NULL),
                              FALSE);
    END;
    
    OVERRIDING MEMBER PROCEDURE update_attribute_trigger(p_attr IN t_intbankpays_attr, p_is_delete BOOLEAN) IS 
        l_fee_col       ibs.t_fee_amount_collection;
        l_banks_list    bank_list%rowtype;
        l_acc           ibs.account%rowtype;
        l_inbnak_swift  VARCHAR(100);
        l_corr_acc_type VARCHAR(100) DEFAULT nvl(SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_CORR_BANK_ACC_TYPE).value_str,
                                                 const_interbankpayments.CFG_MT113_ACCTYPE_NOSTRO);
        l_attr          t_intbankpays_attr DEFAULT p_attr;
        l_coll          ibs.t_clob_collection;
        l_ind           INTEGER;
        l_var           VARCHAR2(5000);
    BEGIN
        l_attr.value_str := jui_interbankpayments_tools.TRIMMING(l_attr.value_str);
        
        CASE WHEN   l_attr.id_attr = const_interbankpayments.ATTR_113_INTBANK_SWIFT THEN 
                    
                    IF p_is_delete THEN
                        IF SELF.obj.isset_attribute(const_interbankpayments.ATTR_113_INTBANK_IN_AG) THEN
                            SELF.remove_attribute(const_interbankpayments.ATTR_113_INTBANK_IN_AG, FALSE);
                            SELF.remove_attribute(const_interbankpayments.ATTR_113_INTBANK_NAME, FALSE);
                            SELF.remove_attribute(const_interbankpayments.ATTR_113_INTBANK_ACC, FALSE);
                        END IF;
                        RETURN;
                    ELSE
                        l_banks_list := jui_interbankpayments_tools.find_in_banks_list_by_swift(l_attr.value_str);
                        SELF.update_attribute(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_113_INTBANK_IN_AG,
                                                                 value_str => NULL,
                                                                 value_int => 1), FALSE);
                        SELF.update_attribute(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_113_INTBANK_NAME,
                                                                 value_str => l_banks_list.bank_name,
                                                                 value_int => NULL), FALSE);
                        SELF.update_attribute(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_113_INTBANK_ACC,
                                                                 value_str => l_banks_list.corr_acc,
                                                                 value_int => NULL), FALSE);
                    END IF;
                    update_intbank_additional;
              WHEN l_attr.id_attr = const_interbankpayments.ATTR_113_INTBANK_ACC THEN
                  SELF.remove_attribute(const_interbankpayments.ATTR_113_INTBANK_IN_AG, FALSE);
              WHEN l_attr.id_attr = const_interbankpayments.ATTR_113_INTBANK_NAME THEN 
                     SELF.remove_attribute(const_interbankpayments.ATTR_113_INTBANK_IN_AG, FALSE);
                     
                     IF NOT p_is_delete THEN
                         -- Если отсутсвует банк в списке, то пытаемся его добавить
                         l_inbnak_swift := SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_INTBANK_SWIFT).value_str;
                         l_banks_list := jui_interbankpayments_tools.find_in_banks_list_by_swift(l_inbnak_swift);
                         IF l_banks_list.ID IS NULL THEN
                            l_banks_list.bank_swift := l_inbnak_swift;
                            l_banks_list.bank_name := l_attr.value_str;
                            jui_interbankpayments_tools.add_to_bank_list(l_banks_list);
                            api_interbankpayments.add_payment_change(mobj => obj, 
                                   p_action => 'update_attribute_trigger', 
                                   p_additional => 'Банк ' || l_banks_list.bank_swift || ' отсутствовал в списке - добавлен автоматически');
                         END IF;
                     END IF;
             WHEN l_attr.id_attr = const_interbankpayments.ATTR_113_FEE_ACCOUNT THEN
                 IF NOT p_is_delete THEN
                     l_acc := ibs.api_account.read_account(l_attr.value_str);
                     CHECK_AMOUNT_ENOUGHT(l_acc.rest_plan,l_acc.account_number);
                 END IF;
             WHEN l_attr.id_attr = const_interbankpayments.ATTR_113_CORR_BANK_ACC_TYPE THEN
                IF NOT p_is_delete AND SELF.obj.isset_attribute(const_interbankpayments.ATTR_113_CORR_BANK_SWIFT) THEN
                    fill_corr_bank_data;            
                END IF;
             WHEN l_attr.id_attr IN (const_interbankpayments.ATTR_ADDITIONAL_INFO) THEN 
                 IF NOT p_is_delete THEN
                     l_coll := ibs.regexp_get_by_lines(l_attr.value_str);
                     
                     IF SUBSTR(l_attr.value_str,0,1) <> '/' THEN
                         raise_application_error(-20000, 'Для данного рода платежей доп. основание должно начинаться с кода /КОД/ ');
                     END IF;
                     
                     IF l_coll.count > 0 THEN
                        l_ind := l_coll.First;
                        WHILE l_ind IS NOT NULL
                        LOOP
                            IF l_ind <> l_coll.First AND SUBSTR(l_coll(l_ind),0,1) <> '/' THEN
                                l_var :=  l_var || '//' || l_coll(l_ind);
                            ELSE l_var := l_var || l_coll(l_ind);
                            END IF;
                            IF l_ind <> l_coll.LAST THEN l_var := l_var || chr(10); END IF;
                            l_ind := l_coll.NEXT(l_ind);
                        END LOOP;
                     END IF;

                     SELF.obj.update_attr_val(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_ADDITIONAL_INFO,
                                                                  value_str => SELF.full_normalize(l_var, 6),
                                                                  value_int => NULL));
                 END IF;                                             
             WHEN l_attr.id_attr IN (const_interbankpayments.ATTR_113_PAYER_ADDINFO)    THEN update_payer_additional;
             WHEN l_attr.id_attr IN (const_interbankpayments.ATTR_113_RECIVER_ADDINFO)  THEN update_receiver_additional;
             WHEN l_attr.id_attr IN (const_interbankpayments.ATTR_113_BENEFBANK_ADDINFO)THEN update_beneficiar_additional;
             WHEN l_attr.id_attr IN (const_interbankpayments.ATTR_113_INTBANK_SWIFT,
                                     const_interbankpayments.ATTR_113_INTBANK_NAME,
                                     const_interbankpayments.ATTR_113_INTBANK_ACC,
                                     const_interbankpayments.ATTR_113_INTBANK_ADDINFO)  THEN update_intbank_additional;   
             WHEN l_attr.id_attr IN (const_interbankpayments.ATTR_113_CORR_BANK_SWIFT) THEN
                 IF NOT p_is_delete THEN fill_corr_bank_data;
                 ELSE
                     SELF.remove_attribute(const_interbankpayments.ATTR_113_CORR_BANK_SWIFT, FALSE);
                     SELF.remove_attribute(const_interbankpayments.ATTR_113_CORR_BANK_ACC, FALSE);
                     SELF.remove_attribute(const_interbankpayments.ATTR_113_CORR_BANK_NAME, FALSE);
                     SELF.remove_attribute(const_interbankpayments.ATTR_113_CORR_BANK_ID, FALSE);
                     SELF.remove_attribute(const_interbankpayments.ATTR_113_CORR_BANK_ACC_ID, FALSE);
                     SELF.remove_attribute(const_interbankpayments.ATTR_113_CORR_BANK_ACC_BOB, FALSE);
                 END IF;
             WHEN l_attr.id_attr IN (const_interbankpayments.ATTR_113_PAYER_BANK_SWIFT) THEN
                 IF NOT p_is_delete THEN
                     l_banks_list := jui_interbankpayments_tools.find_in_banks_list_by_swift(l_attr.value_str, TRUE);
                     SELF.update_attribute(T_INTBANKPAYS_ATTR(CONST_INTERBANKPAYMENTS.ATTR_113_PAYER_BANK_NAME, 	
                                                              value_int => NULL,
                                                              value_str => l_banks_list.bank_name));
                 ELSE SELF.remove_attribute(const_interbankpayments.ATTR_113_PAYER_BANK_SWIFT, FALSE);
                      SELF.remove_attribute(const_interbankpayments.ATTR_113_PAYER_BANK_NAME, FALSE);   
                 END IF;
             ELSE (SELF as t_intbankpays_msg).update_attribute_trigger(l_attr,p_is_delete);
        END CASE;
    END;
    
    CONSTRUCTOR FUNCTION T_INTBANKPAYS_MSG_113 RETURN SELF AS RESULT 
    IS BEGIN RETURN; END;
    
    CONSTRUCTOR FUNCTION T_INTBANKPAYS_MSG_113(pobj IN OUT NOCOPY t_interbankpayments_extend) RETURN SELF AS RESULT 
    IS BEGIN  SELF.obj := pobj; RETURN; END;
end; 
/
