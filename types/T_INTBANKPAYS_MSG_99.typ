create or replace type T_INTBANKPAYS_MSG_99 UNDER t_intbankpays_msg
(   
    OVERRIDING MEMBER PROCEDURE set_ground(p_var IN VARCHAR2),
    OVERRIDING MEMBER PROCEDURE set_system_id(p_var IN INTEGER),
    OVERRIDING MEMBER PROCEDURE CHECK_PAYER_ACCOUNT,
    MEMBER PROCEDURE CHECK_BENEFICIAR_BANK_SWIFT,
    OVERRIDING MEMBER PROCEDURE ONCREATE,
    OVERRIDING MEMBER FUNCTION get_fee_payer_id(SELF IN OUT T_INTBANKPAYS_MSG_99) RETURN INTEGER,
    OVERRIDING MEMBER PROCEDURE create_operation,
    OVERRIDING MEMBER PROCEDURE CHECK_SYSTEM_ID,
    OVERRIDING MEMBER PROCEDURE set_beneficiar_bank_swift(p_var IN VARCHAR2, p_alt_swift IN VARCHAR2 DEFAULT NULL),
    MEMBER FUNCTION GET_GROUND RETURN VARCHAR2,
    OVERRIDING MEMBER FUNCTION GET_GROUND_REXP RETURN VARCHAR,
    OVERRIDING MEMBER FUNCTION GET_GROUND_LENGTH RETURN INT,
    OVERRIDING MEMBER PROCEDURE CHECK_FOR_STATE_VERIFICATION,
    OVERRIDING MEMBER PROCEDURE set_payer_account(p_var IN VARCHAR2),
    OVERRIDING MEMBER PROCEDURE genereate_fees_by_rules(l_fee_kind IN OUT ibs.t_integer_collection, p_special_fee OUT ibs.t_fee_amount),
    OVERRIDING MEMBER PROCEDURE update_attribute_trigger(p_attr IN t_intbankpays_attr, p_is_delete BOOLEAN),
    CONSTRUCTOR FUNCTION T_INTBANKPAYS_MSG_99(pobj IN OUT NOCOPY t_interbankpayments_extend) RETURN SELF AS RESULT
)
/
create or replace type body T_INTBANKPAYS_MSG_99 IS
    
    OVERRIDING MEMBER PROCEDURE set_ground(p_var IN VARCHAR2) IS 
    BEGIN
        SELF.obj.GROUND := p_var;--api_interbankpayments.translit_to_swift(p_var);
    END;
    
    OVERRIDING MEMBER PROCEDURE ONCREATE IS BEGIN 
        SELF.set_system_id(const_interbankpayments.PAYMENT_SYSTEM_ID_SWIFT); 
        SELF.remove_attribute(const_interbankpayments.ATTR_USE_FILE_PROV_QUEE);
    END;

    OVERRIDING MEMBER FUNCTION GET_GROUND_REXP RETURN VARCHAR IS BEGIN RETURN '^([A-Za-z0-9[:space:]:;\+\?\(\)'',\.\/-])*$'; END;
    OVERRIDING MEMBER FUNCTION GET_GROUND_LENGTH RETURN INT IS BEGIN RETURN 1750; END;
    
    MEMBER FUNCTION GET_GROUND RETURN VARCHAR2 IS
        l_ground_date t_intbankpays_attr DEFAULT obj.get_attribute_val(const_interbankpayments.ATTR_FREE_FORMAT_DATE);
        l_ground_amount t_intbankpays_attr DEFAULT obj.get_attribute_val(const_interbankpayments.ATTR_FREE_FORMAT_AMOUNT);
    BEGIN
        RETURN CASE WHEN l_ground_date.value_str IS NOT NULL OR l_ground_date.value_str <> '' THEN l_ground_date.value_str || ' tarixli ' 
             ELSE ''
        END ||  
        l_ground_amount.value_str || ' ' || ibs.api_currency.read_currency(SELF.obj.CURRENCY).iso_name
                                    || ' meblegli odenis tapsirigina edilen duzelise gore tutulan komissiya.';
    END;
    
    OVERRIDING MEMBER PROCEDURE genereate_fees_by_rules(l_fee_kind IN OUT ibs.t_integer_collection, p_special_fee OUT ibs.t_fee_amount) IS
        l_sender_deposit_row    ibs.deposit_contract%rowtype;
        l_deposit_id            INTEGER DEFAULT ibs.api_deposit.get_contract_id(SELF.obj.PAYER_ACCOUNT);
        l_dag                   NUMBER; 
        l_ala                   NUMBER DEFAULT  nvl(SELF.obj.get_attribute_val(const_interbankpayments.ATTR_FREE_FORMAT_PAGE_COUNT).value_int, 0);
        l_currency              INTEGER DEFAULT nvl(SELF.OBJ.CURRENCY, 0);
        l_ground_date           VARCHAR2(100) DEFAULT obj.get_attribute_val(const_interbankpayments.ATTR_FREE_FORMAT_DATE).value_str;
    BEGIN
        l_sender_deposit_row := ibs.api_deposit.read_deposit_contract(l_deposit_id, FALSE);
        IF NOT l_sender_deposit_row.id IS NULL THEN
            l_dag := 1;
            p_special_fee := ibs.api_tariff.get_fee(ibs.const_deposit.FEE_KIND_INTERNAL_TRANSFER,
                                                 l_deposit_id,
                                                 l_sender_deposit_row.product_id,
                                                 l_sender_deposit_row.client_id,
                                                 1,
                                                 l_sender_deposit_row.currency_id,
                                                 null);
            
            IF l_ala > 0 THEN p_special_fee.fee_amount := l_ala*5;
            ELSE
                p_special_fee.fee_amount := CASE WHEN l_currency = ibs.const_currency.CURRENCY_AZN  THEN nvl(l_dag,0)*5
                                            ELSE nvl(l_dag, 0)*35
                                         END;
            END IF;
            p_special_fee.fee_amount:=round(ibs.api_exchange.convert_amount(ibs.const_exchange.CUR_EXCH_RATE_KIND_CBAR,
                                               p_special_fee.fee_amount,
                                               ibs.const_currency.CURRENCY_AZN,
                                               l_sender_deposit_row.currency_id
                                               ),2); 
            p_special_fee.account_id:=CASE WHEN ibs.api_subject.get_subject_legal_form(l_sender_deposit_row.client_id)=2 AND l_currency<>0 
                                            THEN ibs.api_account.get_account_id('XXXXXXXX'||ibs.api_currency.get_code_in_account(l_currency)||'0000003'||upper(ibs.api_branch.get_code_in_account(l_sender_deposit_row.branch_id)))
                                           WHEN ibs.api_subject.get_subject_legal_form(l_sender_deposit_row.client_id)=2 AND l_currency=0 
                                            THEN ibs.api_account.get_account_id('XXXXXXXX'||upper(ibs.api_branch.get_code_in_account(l_sender_deposit_row.branch_id)))
                                           WHEN ibs.api_subject.get_subject_legal_form(l_sender_deposit_row.client_id)<>2 AND l_currency<>0 
                                            THEN ibs.api_account.get_account_id('XXXXXXXX'||ibs.api_currency.get_code_in_account(l_currency)||'0000001'||upper(ibs.api_branch.get_code_in_account(l_sender_deposit_row.branch_id)))
                                   
                    WHEN ibs.api_subject.get_subject_legal_form(l_sender_deposit_row.client_id)<>2 AND l_currency=0 
                                            THEN ibs.api_account.get_account_id('XXXXXXXX'||upper(ibs.api_branch.get_code_in_account(l_sender_deposit_row.branch_id)))
                                      END;

            p_special_fee.ground := SELF.GET_GROUND;
            /*
            [‎10/‎17/‎2016 4:49 PM] Nargiz M. Salimzade: 
            BU SOZLER HEC LAZIM DEYIL
            ONLARI SOVSEM SILMEK LAZIMDI
            MEN YAZDIGIM FORMA OLMALIDI
            ele olur? yoxsa imenno bu sozler kececek?
            CASE WHEN l_dag>0 THEN trunc(SYSDATE)|| ' tarixli dəqiqləşdirmə '
                 ELSE trunc(SYSDATE)|| 'tarixli təyinata əlavə '
            END || 'üzrə komissiya'*/
            --11.10.16 tar 240.00 AZN meblegli odenis tapsirigina edilen duzelise gore tutulan komissiya
        END IF;
    END;
    
    OVERRIDING MEMBER PROCEDURE set_system_id(p_var IN INTEGER)
    IS BEGIN 
        (SELF AS T_INTBANKPAYS_MSG).set_system_id(p_var);
        IF p_var IN (const_interbankpayments.PAYMENT_SYSTEM_ID_SWIFT) THEN
            SELF.remove_attribute(const_interbankpayments.ATTR_USE_FILE_PROV_QUEE);
        END IF;
    END;
    
    OVERRIDING MEMBER PROCEDURE set_beneficiar_bank_swift(p_var IN VARCHAR2, p_alt_swift IN VARCHAR2 DEFAULT NULL) IS
    BEGIN
        (SELF AS T_INTBANKPAYS_MSG).set_beneficiar_bank_swift(p_var,p_alt_swift);
        SELF.obj.BENEFICIAR_BANK_NAME := jui_interbankpayments_tools.find_in_banks_list_by_swift(p_var).bank_name;
    END;
    
    OVERRIDING MEMBER PROCEDURE create_operation IS
    BEGIN
        IF SELF.obj.FEE_SUM_AMOUNT > 0 THEN
            SELF.burn_operation();
            SELF.pay_fee();
            IBS.API_OPERATION.COMPLETE_OPERATION_CHAIN(SELF.OBJ.get_attribute_val(CONST_INTERBANKPAYMENTS.ATTR_SETTELMENT_OPER_CHAIN).value_int);
        END IF;
    END;
    
    OVERRIDING MEMBER FUNCTION get_fee_payer_id(SELF IN OUT T_INTBANKPAYS_MSG_99) RETURN INTEGER IS
    BEGIN RETURN ibs.api_account.get_account_id(obj.PAYER_ACCOUNT); END;
    
    OVERRIDING MEMBER PROCEDURE CHECK_FOR_STATE_VERIFICATION IS 
    BEGIN 
        SELF.CHECK_PAYER_ACCOUNT();
        --SELF.CHECK_BENEFICIAR_BANK_SWIFT();
    END;
    
    OVERRIDING MEMBER PROCEDURE CHECK_PAYER_ACCOUNT IS
    BEGIN
        IF SELF.obj.isset_attribute(const_interbankpayments.ATTR_FREE_FORMAT_PAGE_COUNT)
           AND  obj.PAYER_ACCOUNT IS NULL THEN
           const_exceptions.raise_exception(const_exceptions.FEE_SET_ACC_NO);
        END IF;
    END;
     
    MEMBER PROCEDURE CHECK_BENEFICIAR_BANK_SWIFT IS
    BEGIN
        IF SELF.obj.BENEFICIAR_BANK_SWIFT IS NULL THEN const_exceptions.raise_exception(const_exceptions.NO_BENB_SWIFT); END IF;
    END;
    
    OVERRIDING MEMBER PROCEDURE CHECK_SYSTEM_ID IS 
    BEGIN
        IF SELF.obj.SYSTEM_ID NOT IN (const_interbankpayments.PAYMENT_SYSTEM_ID_SWIFT, 
                                      const_interbankpayments.PAYMENT_SYSTEM_ID_XOHKS) 
        THEN
            const_exceptions.raise_exception(const_exceptions.WR_PS_99);
        ELSE (SELF AS T_INTBANKPAYS_MSG).CHECK_SYSTEM_ID;
        END IF;
    END;
    
    OVERRIDING MEMBER PROCEDURE set_payer_account(p_var IN VARCHAR2) IS
    BEGIN
        (SELF AS t_intbankpays_msg).set_payer_account(p_var);
        SELF.obj.remove_attr(const_interbankpayments.ATTR_IS_WITHOUT_FEE);
        SELF.update_fee_collection();
    END;
    
    CONSTRUCTOR FUNCTION T_INTBANKPAYS_MSG_99(pobj IN OUT NOCOPY t_interbankpayments_extend) RETURN SELF AS RESULT 
    IS BEGIN  SELF.obj := pobj; RETURN; END;
    
    OVERRIDING MEMBER PROCEDURE update_attribute_trigger(p_attr IN t_intbankpays_attr, p_is_delete BOOLEAN) IS 
    BEGIN
        CASE WHEN p_attr.id_attr = const_interbankpayments.ATTR_IS_WITHOUT_FEE THEN
                SELF.obj.remove_attr(const_interbankpayments.ATTR_FREE_FORMAT_FEE_ACCOUNT);
                SELF.obj.remove_attr(const_interbankpayments.ATTR_FREE_FORMAT_PAGE_COUNT);
                SELF.update_fee_collection();
             WHEN p_attr.id_attr = const_interbankpayments.ATTR_FREE_FORMAT_PAGE_COUNT THEN
                SELF.obj.remove_attr(const_interbankpayments.ATTR_IS_WITHOUT_FEE);
                SELF.obj.remove_attr(const_interbankpayments.ATTR_FREE_FORMAT_FEE_ACCOUNT);
                IF SELF.obj.PAYER_ACCOUNT IS NOT NULL THEN
                    SELF.update_fee_collection();
                END IF;
             ELSE (SELF AS T_INTBANKPAYS_MSG).update_attribute_trigger(p_attr, p_is_delete);
        END CASE;
        NULL;
    END;
end;
/
