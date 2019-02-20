create or replace type T_INTBANKPAYS_MSG_205 UNDER t_intbankpays_msg
(   
    OVERRIDING MEMBER FUNCTION get_operation_object_id RETURN INTEGER,
    OVERRIDING MEMBER FUNCTION get_main_operation_ground RETURN VARCHAR,
    OVERRIDING MEMBER PROCEDURE pay_fee,
    OVERRIDING MEMBER PROCEDURE CHECK_AMOUNT_ENOUGHT,
    OVERRIDING MEMBER PROCEDURE CHECK_PAYER_ACCOUNT,
    OVERRIDING MEMBER PROCEDURE set_ground(p_var IN VARCHAR2),
    MEMBER FUNCTION GET_GROUND RETURN VARCHAR2,
    --OVERRIDING MEMBER PROCEDURE set_ground(p_var IN VARCHAR2),
    MEMBER PROCEDURE CHECK_REFLECTING_ACCOUNT,
    MEMBER FUNCTION get_fee_payer_account_id(SELF IN OUT T_INTBANKPAYS_MSG_205) RETURN INTEGER,
    MEMBER FUNCTION get_fee_receiver_account_id RETURN INTEGER,
    OVERRIDING MEMBER FUNCTION get_payer_id(SELF IN OUT T_INTBANKPAYS_MSG_205)  RETURN INTEGER,
    OVERRIDING MEMBER FUNCTION get_receiver_id(SELF IN OUT T_INTBANKPAYS_MSG_205) RETURN INTEGER,
    OVERRIDING MEMBER PROCEDURE ONCREATE,
    OVERRIDING MEMBER FUNCTION generate_fee_ground(p_fee ibs.t_fee_amount) RETURN VARCHAR,
    OVERRIDING MEMBER PROCEDURE update_attribute_trigger(p_attr IN t_intbankpays_attr, p_is_delete BOOLEAN),
    OVERRIDING  MEMBER PROCEDURE set_currency(p_var IN INTEGER),
    OVERRIDING MEMBER PROCEDURE set_beneficiar_bank_corr_acc(p_var IN VARCHAR2),
    OVERRIDING MEMBER PROCEDURE set_bn_corr_acc(p_cor IN VARCHAR2 DEFAULT NULL),
    OVERRIDING MEMBER FUNCTION get_account_tpl_lgform(p_lg_form INTEGER DEFAULT NULL) RETURN VARCHAR2,
    CONSTRUCTOR FUNCTION T_INTBANKPAYS_MSG_205(pobj IN OUT NOCOPY t_interbankpayments_extend) RETURN SELF AS RESULT
)
/
create or replace type body T_INTBANKPAYS_MSG_205 IS
    OVERRIDING MEMBER FUNCTION get_main_operation_ground RETURN VARCHAR IS
    BEGIN
        RETURN (SELF AS t_intbankpays_msg).get_main_operation_ground || ' ' ||
                SELF.obj.RECEIVER_NAME;
    END;
    
    OVERRIDING MEMBER PROCEDURE CHECK_AMOUNT_ENOUGHT IS BEGIN NULL; END;    
    OVERRIDING MEMBER PROCEDURE CHECK_PAYER_ACCOUNT IS  BEGIN NULL; END;
    
    MEMBER FUNCTION GET_GROUND RETURN VARCHAR2 IS
        l_attr t_intbankpays_attr DEFAULT obj.get_attribute_val(const_interbankpayments.ATTR_REFLECTING_ACCOUNT);
    BEGIN
        IF l_attr IS NULL THEN RETURN NULL; END IF;
        CASE  WHEN l_attr.value_str = '10520000100002' THEN RETURN const_interbankpayments.CFG_MT205_REFLEC_ACCISSPEC_GRN;
             ELSE RETURN SELF.obj.GROUND;
        END CASE;
    END;
    
    OVERRIDING MEMBER FUNCTION get_operation_object_id RETURN INTEGER IS
        l_attr t_intbankpays_attr DEFAULT obj.get_attribute_val(const_interbankpayments.ATTR_REFLECTING_ACCOUNT);
    BEGIN
        RETURN ibs.api_account.get_account_id(l_attr.value_str);
    END;

    MEMBER PROCEDURE CHECK_REFLECTING_ACCOUNT IS
        l_attr t_intbankpays_attr;
    BEGIN
        IF NOT obj.isset_attribute(const_interbankpayments.ATTR_REFLECTING_ACCOUNT) THEN
            const_exceptions.raise_exception(const_exceptions.NO_REF_ACC);
        END IF;
    END;
    
    MEMBER FUNCTION get_fee_payer_account_id(SELF IN OUT T_INTBANKPAYS_MSG_205) RETURN INTEGER IS
    BEGIN
        RETURN ibs.api_account.get_account_id(CASE WHEN SELF.obj.CURRENCY = ibs.const_currency.CURRENCY_USD 
                                                        THEN 'XXXXXXXX0001'
                                                   WHEN SELF.obj.CURRENCY = ibs.const_currency.CURRENCY_AZN
                                                        THEN 'XXXXXXXX0001'
                                                   WHEN SELF.obj.CURRENCY = ibs.const_currency.CURRENCY_EUR 
                                                        THEN'XXXXXXXX0001' END);
    END;
    
    MEMBER FUNCTION get_fee_receiver_account_id RETURN INTEGER IS
    BEGIN
        RETURN NULL;--ibs.api_account.get_account_id(get_payment_cor_acc(p_src_row.payment_system_id, p_src_row.currency_id));
    END;
    
    OVERRIDING MEMBER PROCEDURE pay_fee IS 
        l_operation_chain_id INTEGER DEFAULT obj.get_attribute_val(CONST_INTERBANKPAYMENTS.ATTR_SETTELMENT_OPER_CHAIN).value_int;
    BEGIN 
        IF obj.FEE_COLLECTION IS NOT NULL AND obj.FEE_COLLECTION.count > 0 THEN
            FOR indx IN obj.FEE_COLLECTION.first .. obj.FEE_COLLECTION.last
                LOOP
                    ibs.api_settlement.settlement_transaction(  get_fee_payer_account_id(),
                                                                SELF.get_receiver_id(),
                                                                ibs.t_amount(obj.FEE_COLLECTION(indx).FEE_AMOUNT, 
                                                                             obj.FEE_COLLECTION(indx).currency_id),
                                                                NULL,
                                                                NULL,
                                                                SELF.obj.OPERATION_ID,
                                                                obj.get_attribute_val(CONST_INTERBANKPAYMENTS.ATTR_SETTELMENT_OPER_CHAIN).value_int,
                                                                'Nağd vəsaitin gətirilməsinə görə komissiya',
                                                                NULL,
                                                                NULL);
                END LOOP;
        END IF;
    END;
    
    
    OVERRIDING MEMBER FUNCTION generate_fee_ground(p_fee ibs.t_fee_amount) RETURN VARCHAR IS
    BEGIN RETURN 'Nağd vəsaitin gətirilməsinə görə komissiya'; END;
    
    OVERRIDING MEMBER PROCEDURE update_attribute_trigger(p_attr IN t_intbankpays_attr, p_is_delete BOOLEAN) IS 
        l_fee_col   ibs.t_fee_amount_collection;
        l_ground    VARCHAR2(5000);
        l_attr      t_intbankpays_attr DEFAULT p_attr;
    BEGIN
        CASE WHEN l_attr.id_attr = const_interbankpayments.ATTR_REFLECTING_ACCOUNT THEN
                l_attr.value_str := jui_interbankpayments_tools.TRIMMING(l_attr.value_str);
                
                IF l_attr.value_str IS NOT NULL THEN 
                    CHECK_REFLECTING_ACCOUNT; 
                    SELF.obj.update_attr_val(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_REFLECTING_ACCOUNT_IBAN,
                                                                value_str => ibs.api_account.get_IBAN(l_attr.value_str),
                                                                value_int => NULL));
                ELSE
                    SELF.obj.remove_attr(const_interbankpayments.ATTR_REFLECTING_ACCOUNT_IBAN);
                END IF;
                
                CASE WHEN l_attr.value_str IS NOT NULL AND l_attr.value_str = 'XXXXXXXX00001'
                        THEN (SELF AS T_INTBANKPAYS_MSG).update_attribute(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_IS_WITHOUT_FEE,
                                                                                                value_str => NULL,
                                                                                                value_int => NULL));
                     WHEN l_attr.value_str IS NOT NULL AND l_attr.value_str IN ('XXXXXXXX00001','XXXXXXXX00001','1XXXXXXXX0001')
                        THEN (SELF AS T_INTBANKPAYS_MSG).remove_attribute(const_interbankpayments.ATTR_IS_WITHOUT_FEE);    
                     WHEN l_attr.value_str IS NOT NULL AND l_attr.value_str = '10XXXXXXXX002'
                        THEN 
                           (SELF AS T_INTBANKPAYS_MSG).update_attribute(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_IS_WITHOUT_FEE,
                                                                                                value_str => NULL,
                                                                                                value_int => NULL));
                     ELSE NULL;
                END CASE;
                SELF.set_ground(SELF.GET_GROUND());
            ELSE (SELF AS T_INTBANKPAYS_MSG).update_attribute_trigger(l_attr, p_is_delete);
        END CASE;
    END;

    OVERRIDING MEMBER FUNCTION get_payer_id(SELF IN OUT T_INTBANKPAYS_MSG_205)  RETURN INTEGER IS
        l_attr t_intbankpays_attr;
    BEGIN
        SELF.CHECK_REFLECTING_ACCOUNT();
        l_attr := obj.get_attribute_val(const_interbankpayments.ATTR_REFLECTING_ACCOUNT);
        RETURN ibs.api_account.get_account_id(l_attr.value_str);
    END;

    OVERRIDING MEMBER FUNCTION get_receiver_id(SELF IN OUT T_INTBANKPAYS_MSG_205) RETURN INTEGER IS
        l_attr t_intbankpays_attr;
    BEGIN
        IF NOT obj.isset_attribute(const_interbankpayments.ATTR_REFLECTING_ACCOUNT) THEN
            const_exceptions.raise_exception(const_exceptions.NO_REF_ACC);
        END IF;
        l_attr := obj.get_attribute_val(const_interbankpayments.ATTR_REFLECTING_ACCOUNT);
        CASE WHEN l_attr.value_str = '2XXXXXXXX000001' THEN RETURN ibs.api_account.get_account_id('1XXXXXXXX01');
             WHEN l_attr.value_str IN ('1XXXXXXXX0001','10120010000001','1XXXXXXXX001') THEN
                        IF l_attr.value_str = 'XXXXXXXX00001' THEN RETURN ibs.api_account.get_account_id('1XXXXXXXX0001');
                        ELSIF l_attr.value_str = 'XXXXXXXX001' THEN RETURN ibs.api_account.get_account_id('10XXXXXXXX0001');
                        ELSIF l_attr.value_str = '1XXXXXXXX001' THEN RETURN ibs.api_account.get_account_id('1XXXXXXXX00001');
                        END IF;
             WHEN l_attr.value_str = 'XXXXXXXX00002' THEN RETURN ibs.api_account.get_account_id('XXXXXXXX100001');
             ELSE RETURN (SELF as T_INTBANKPAYS_MSG).get_receiver_id();
        END CASE;
    END;
    
    OVERRIDING  MEMBER PROCEDURE set_currency(p_var IN INTEGER) IS
    BEGIN
        (SELF AS T_INTBANKPAYS_MSG).set_currency(p_var);
        SELF.obj.RECEIVER_IBAN := NULL;
    END;
    
    OVERRIDING MEMBER PROCEDURE set_ground(p_var IN VARCHAR2) IS
        l_var           VARCHAR2(5000) DEFAULT p_var;
        l_attr_ref_acc  t_intbankpays_attr DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_REFLECTING_ACCOUNT);
    BEGIN
        IF l_attr_ref_acc.value_str IN (const_interbankpayments.CFG_MT205_REFLEC_ACCISSPEC) THEN
           l_var := GET_GROUND();
        ELSIF SUBSTR(l_var, 0, LENGTH(const_interbankpayments.CFG_MT205_GROUND_PREFIX_CODE)) <> const_interbankpayments.CFG_MT205_GROUND_PREFIX_CODE
        THEN l_var := const_interbankpayments.CFG_MT205_GROUND_PREFIX_CODE || l_var;
        END IF;

        SELF.obj.GROUND := CASE WHEN l_var IS NOT NULL THEN 
                                    SELF.full_normalize(jui_interbankpayments_tools.add_chr_tostart('//', l_var, 2), SELF.get_ground_max_lines_count()) 
                                ELSE NULL END;

        IF l_var IS NOT NULL THEN SELF.CHECK_GROUND(); END IF;
        api_interbankpayments.add_payment_change(mobj => obj, 
                           p_action => 'set_ground', 
                           p_additional => l_var);
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                               p_action => 'set_ground', 
                               p_autonomus => TRUE,
                               p_result => SQLERRM || '',
                               p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;

    OVERRIDING MEMBER PROCEDURE set_beneficiar_bank_corr_acc(p_var IN VARCHAR2) IS
        l_var VARCHAR2(100) DEFAULT jui_interbankpayments_tools.TRIMMING(p_var);
    BEGIN
        IF SELF.obj.BENEFICIAR_BANK_CODE IS NOT NULL THEN
            SELF.obj.BENEFICIAR_BANK_CORR_ACCOUNT := jui_interbankpayments_tools.get_bank_correspondent_account(p_code => SELF.obj.BENEFICIAR_BANK_CODE, 
                                                                                                            p_currency => SELF.obj.currency);
        ELSE (SELF AS T_INTBANKPAYS_MSG).set_beneficiar_bank_corr_acc(l_var);
        END IF;
    END;

    OVERRIDING MEMBER PROCEDURE ONCREATE IS
    BEGIN
        SELF.SET_EMITENT_BANK_CODE(ibs.const_subject.OUR_BANK_CODE);
        (SELF AS T_INTBANKPAYS_MSG).update_attribute(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_IS_WITHOUT_FREEZE_AMOUNT,
                                                                                        value_str => NULL,
                                                                                        value_int => NULL));
        SELF.obj.SYSTEM_ID := const_interbankpayments.PAYMENT_SYSTEM_ID_NPS;
        SELF.obj.GROUND := const_interbankpayments.CFG_MT205_GROUND_PREFIX_CODE;
    END;
    
    OVERRIDING MEMBER PROCEDURE set_bn_corr_acc(p_cor IN VARCHAR2 DEFAULT NULL) IS 
    BEGIN
        IF obj.RECEIVER_IBAN IS NOT NULL THEN obj.BENEFICIAR_BANK_CORR_ACCOUNT := obj.RECEIVER_IBAN;
        ELSE (SELF AS T_INTBANKPAYS_MSG).set_bn_corr_acc(p_cor);
        END IF;
    END;

    OVERRIDING MEMBER FUNCTION get_account_tpl_lgform(p_lg_form INTEGER DEFAULT NULL) RETURN VARCHAR2
    IS BEGIN RETURN 17; END;
   
    CONSTRUCTOR FUNCTION T_INTBANKPAYS_MSG_205(pobj IN OUT NOCOPY t_interbankpayments_extend) RETURN SELF AS RESULT 
    IS BEGIN  SELF.obj := pobj; RETURN; END;
        
end;
/
