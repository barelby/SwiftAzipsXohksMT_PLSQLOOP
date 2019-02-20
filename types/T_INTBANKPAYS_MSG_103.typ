create or replace type T_INTBANKPAYS_MSG_103 FORCE UNDER t_intbankpays_msg
(
    OVERRIDING MEMBER FUNCTION GET_GROUND_LENGTH RETURN INT,
    OVERRIDING MEMBER FUNCTION get_main_operation_ground RETURN VARCHAR,
    OVERRIDING MEMBER PROCEDURE set_payer_account(p_var IN VARCHAR2),
    OVERRIDING MEMBER PROCEDURE set_system_id(p_var IN INTEGER),
    OVERRIDING MEMBER PROCEDURE onCreate,
    OVERRIDING MEMBER FUNCTION get_ground_max_lines_count RETURN INTEGER,
    OVERRIDING MEMBER FUNCTION get_addinfo_max_lines_count RETURN INTEGER,
    OVERRIDING MEMBER PROCEDURE update_attribute_trigger(p_attr IN t_intbankpays_attr, p_is_delete BOOLEAN),
    --OVERRIDING MEMBER PROCEDURE set_currency(p_var IN INTEGER),
    
    MEMBER PROCEDURE CHECK_ADDITIONAL_INFO,
    MEMBER  FUNCTION get_additionalinfo_value(p_val VARCHAR2) RETURN VARCHAR2,

    CONSTRUCTOR FUNCTION T_INTBANKPAYS_MSG_103 RETURN SELF AS RESULT ,
    CONSTRUCTOR FUNCTION T_INTBANKPAYS_MSG_103(pobj IN OUT NOCOPY t_interbankpayments_extend) RETURN SELF AS RESULT
)   NOT FINAL
/
create or replace type body T_INTBANKPAYS_MSG_103 is
    OVERRIDING MEMBER FUNCTION GET_GROUND_LENGTH  RETURN INT IS
    BEGIN
        IF SELF.obj.isset_attribute(const_interbankpayments.ATTR_BUDGET_DESTINATION)
           OR SELF.obj.isset_attribute(const_interbankpayments.ATTR_BUDGET_LEVEL) THEN
           RETURN 70;
        END IF;
        RETURN (SELF AS T_INTBANKPAYS_MSG).GET_GROUND_LENGTH();
    END;

    -- �������� �� �����!
    MEMBER PROCEDURE CHECK_ADDITIONAL_INFO IS
        attr_ref_acc  t_intbankpays_attr DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_REFLECTING_ACCOUNT);
        attr_add_info t_intbankpays_attr DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_ADDITIONAL_INFO);
    BEGIN
        IF attr_ref_acc.value_str = 'XXXXXXXX' AND
           attr_add_info.value_str IS NULL OR trim(attr_add_info.value_str) = '' THEN
            const_exceptions.raise_exception(const_exceptions.NO_REF_ACC_ADD);
        END IF;
    END;
    
    /**************************************** Overridings ****************************************/
    OVERRIDING MEMBER FUNCTION get_addinfo_max_lines_count RETURN INTEGER IS
    BEGIN RETURN const_interbankpayments.CFG_MT103_DEF_ADDI_MAXLINES; END;
    
    OVERRIDING MEMBER FUNCTION get_ground_max_lines_count RETURN INTEGER IS
        l_b_dest  t_intbankpays_attr DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_BUDGET_DESTINATION);
        l_b_level t_intbankpays_attr DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_BUDGET_LEVEL);
    BEGIN 
        RETURN CASE WHEN l_b_dest IS NOT NULL OR l_b_level IS NOT NULL THEN 
                        const_interbankpayments.CFG_MT103_DEF_GROUND_MAXLINES - 2
                    ELSE const_interbankpayments.CFG_MT103_DEF_GROUND_MAXLINES
               END; 
    END;
    
    OVERRIDING MEMBER FUNCTION get_main_operation_ground RETURN VARCHAR IS
    BEGIN
        RETURN (SELF AS t_intbankpays_msg).get_main_operation_ground || ' ' ||
                SELF.obj.RECEIVER_NAME;
    END;
    
    OVERRIDING MEMBER PROCEDURE set_payer_account(p_var IN VARCHAR2) IS 
        l_var   VARCHAR2(5000) DEFAULT jui_interbankpayments_tools.TRIMMING(p_var);
        l_acc   ibs.account%ROWTYPE;
    BEGIN 
        IF l_var IS NOT NULL THEN
            IF  ibs.api_object.get_object_code(p_object_id => ibs.API_ACCOUNT.READ_ACCOUNT(l_var).owner_id,
                                              p_code_kind_id => ibs.const_subject.CODE_KIND_CODE) = ibs.const_subject.OUR_BANK_CODE 
            THEN
                api_interbankpayments.add_payment_change(mobj => obj, 
                                                   p_action => 'set_payer_account',
                                                   p_desc => 'Our bank detected - fee for 103 payments must be null'
                                                   );
                SELF.update_attribute(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_IS_WITHOUT_FEE,
                                                         value_str => NULL,
                                                         value_int => NULL));    
            END IF;
            
            IF SELF.obj.SYSTEM_ID <> const_interbankpayments.PAYMENT_SYSTEM_ID_XOHKS THEN
                l_acc := ibs.api_account.read_account(l_var);
                SELF.set_currency(l_acc.currency_id);
            END IF;
            
        END IF;
        (SELF AS t_intbankpays_msg).set_payer_account(l_var);
    END;
    
    OVERRIDING MEMBER PROCEDURE onCreate IS BEGIN 
        SELF.set_payer_branch_id(ibs.api_context.get_def_branch);
        SELF.obj.system_id := const_interbankpayments.PAYMENT_SYSTEM_ID_NPS;
    END;
    
    OVERRIDING MEMBER PROCEDURE set_system_id(p_var IN INTEGER)
    IS BEGIN 
        (SELF AS T_INTBANKPAYS_MSG).set_system_id(p_var);
        SELF.obj.update_attr_val(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_ADDITIONAL_INFO,
                                                            value_str => get_additionalinfo_value(SELF.obj.get_attribute_val(const_interbankpayments.ATTR_ADDITIONAL_INFO).value_str),
                                                            value_int => NULL)
                                         );   
        IF p_var IN (const_interbankpayments.PAYMENT_SYSTEM_ID_XOHKS) THEN
            SELF.obj.update_attr_val(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_IS_SUPPORT_BATCHING,
                                                             value_str => NULL,
                                                             value_int => NULL));
            SELF.obj.update_attr_val(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_USE_FILE_PROV_QUEE,
                                                             value_str => NULL,
                                                             value_int => NULL));
        ELSE 
            SELF.obj.remove_attr(const_interbankpayments.ATTR_IS_SUPPORT_BATCHING);
        END IF;
    END;
    
    MEMBER FUNCTION get_additionalinfo_value(p_val VARCHAR2) RETURN VARCHAR2 IS
        l_var       VARCHAR2(5000) DEFAULT p_val;
        l_np_code   VARCHAR(10) DEFAULT '/REC/';
    BEGIN
        IF l_var IS NULL THEN RETURN NULL; END IF;
        RETURN CASE WHEN SELF.obj.SYSTEM_ID = const_interbankpayments.PAYMENT_SYSTEM_ID_NPS THEN
                            SELF.full_normalize(
                                jui_interbankpayments_tools.add_chr_tostart(p_chr => '//',
                                    p_text =>  CASE WHEN SUBSTR(l_var, 0, LENGTH(l_np_code)) <> l_np_code THEN l_np_code || l_var ELSE l_var END,
                                    p_from_line => 2),
                                4)
                    WHEN SELF.obj.SYSTEM_ID = const_interbankpayments.PAYMENT_SYSTEM_ID_XOHKS THEN
                        SELF.Full_Normalize(p_val, 4)
                    ELSE l_var    
               END;
    END;
    
    /*OVERRIDING MEMBER PROCEDURE set_currency(p_var IN INTEGER) IS
        l_bank bank_list%ROWTYPE;
    BEGIN 
        IF p_var <> ibs.const_currency.CURRENCY_AZN 
            AND SELF.obj.SYSTEM_ID IN(const_interbankpayments.PAYMENT_SYSTEM_ID_AZIPS,const_interbankpayments.PAYMENT_SYSTEM_ID_NPS) 
        THEN
            const_exceptions.raise_exception(const_exceptions.MT_103_NOT_AZN);
        END IF;
        (SELF AS T_INTBANKPAYS_MSG).set_currency(p_var);
    END;*/

    OVERRIDING MEMBER PROCEDURE update_attribute_trigger(p_attr IN t_intbankpays_attr, p_is_delete BOOLEAN) IS 
        l_fee_col ibs.t_fee_amount_collection;
        l_attr    t_intbankpays_attr DEFAULT p_attr;
    BEGIN
        CASE WHEN   l_attr.id_attr = const_interbankpayments.ATTR_BUDGET_DESTINATION 
                    OR l_attr.id_attr = const_interbankpayments.ATTR_BUDGET_LEVEL  THEN 
                IF SELF.obj.GROUND IS NOT NULL THEN
                    SELF.obj.GROUND := SELF.Full_Normalize(SELF.obj.GROUND, const_interbankpayments.CFG_MT103_DEF_GROUND_MAXLINES-2);
                END IF;
             WHEN l_attr.id_attr = const_interbankpayments.ATTR_ADDITIONAL_INFO THEN
                IF NOT p_is_delete THEN
                    l_attr.value_str := get_additionalinfo_value(l_attr.value_str);
                    SELF.obj.update_attr_val(l_attr);
                END IF;
             ELSE (SELF AS T_INTBANKPAYS_MSG).update_attribute_trigger(l_attr, p_is_delete);
        END CASE;
    END;

    CONSTRUCTOR FUNCTION T_INTBANKPAYS_MSG_103 RETURN SELF AS RESULT 
    IS BEGIN 
        RETURN; 
    END;
    
    CONSTRUCTOR FUNCTION T_INTBANKPAYS_MSG_103(pobj IN OUT NOCOPY t_interbankpayments_extend) RETURN SELF AS RESULT 
    IS BEGIN  SELF.obj := pobj; RETURN; END;
end;
/
