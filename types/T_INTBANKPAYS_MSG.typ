create or replace type T_INTBANKPAYS_MSG FORCE AS OBJECT
(
    obj             t_interbankpayments_extend,
    p_related_obj   t_interbankpayments_ext_col,
  -- POBJ t_interbankpayments,
  -- Member functions and procedures

  /******* Setters *******/
  MEMBER FUNCTION  set_state(SELF IN OUT T_INTBANKPAYS_MSG, p_var IN INTEGER) RETURN BOOLEAN ,
  MEMBER PROCEDURE set_payment_date(p_var IN DATE),
  MEMBER PROCEDURE set_system_id(p_var IN INTEGER),
  MEMBER PROCEDURE set_message_type(p_var IN INTEGER),
  MEMBER PROCEDURE set_amount(p_var IN NUMBER),
  MEMBER PROCEDURE set_currency(p_var IN INTEGER),
  MEMBER PROCEDURE set_fee( p_var IN ibs.t_fee_amount),
  MEMBER PROCEDURE set_ground(p_var IN VARCHAR2),
  MEMBER PROCEDURE set_operation_id(p_var IN INTEGER),
  MEMBER PROCEDURE set_payer_branch_id(p_var IN INTEGER),
  MEMBER PROCEDURE set_payer_account(p_var IN VARCHAR2),
  MEMBER PROCEDURE set_receiver_name(p_var IN VARCHAR2),
  MEMBER PROCEDURE set_receiver_iban(p_var IN VARCHAR2),
  MEMBER PROCEDURE set_receiver_tax(p_var IN VARCHAR2),
  MEMBER PROCEDURE set_emitent_bank_code(p_var IN VARCHAR2,p_auto_branch_id BOOLEAN DEFAULT TRUE),
  MEMBER PROCEDURE set_emitent_bank_corr_acc(p_var IN VARCHAR2),
  MEMBER PROCEDURE set_beneficiar_bank_name(p_var IN VARCHAR2),
  MEMBER PROCEDURE set_beneficiar_bank_code(p_var IN VARCHAR2),
  MEMBER PROCEDURE set_beneficiar_bank_swift(p_var IN VARCHAR2, p_alt_swift IN VARCHAR2 DEFAULT NULL),
  MEMBER PROCEDURE set_beneficiar_bank_tax(p_var IN VARCHAR2),
  MEMBER PROCEDURE set_bn_corr_acc(p_cor IN VARCHAR2 DEFAULT NULL),
  MEMBER FUNCTION normalize(p_text VARCHAR2, p_chr_per_line INTEGER, p_max_line INTEGER) RETURN VARCHAR2,
  MEMBER FUNCTION get_ground_max_lines_count RETURN INTEGER,
  MEMBER FUNCTION get_addinfo_max_lines_count RETURN INTEGER,
  MEMBER FUNCTION full_normalize(p_text VARCHAR2, 
                                 p_max_line INTEGER, 
                                 p_chr_per_line INTEGER DEFAULT 35, 
                                 p_swift_chr VARCHAR DEFAULT 'x')  RETURN VARCHAR2,
  MEMBER PROCEDURE update_attribute_trigger(p_attr IN t_intbankpays_attr, p_is_delete BOOLEAN),
  --MEMBER PROCEDURE update_attribute_trigger(p_attr IN t_intbankpays_attr),
  MEMBER PROCEDURE update_attribute(p_attr_id IN INTEGER,p_value_str   IN VARCHAR DEFAULT NULL,p_value_int   IN INTEGER DEFAULT NULL, p_use_trigger BOOLEAN DEFAULT TRUE),
  MEMBER PROCEDURE update_attribute(p_attr IN t_intbankpays_attr, p_use_trigger BOOLEAN DEFAULT TRUE),
  MEMBER PROCEDURE remove_attribute(p_attr_id IN INTEGER, p_use_trigger BOOLEAN DEFAULT TRUE),
  MEMBER procedure default_check_state_error(p_new_state in integer),
  MEMBER PROCEDURE refresh_reference,
  -- Ð¤ÑƒÐ½ÐºÑ†Ð¸Ñ Ð½ÑƒÐ¶Ð½Ð° Ð´Ð»Ñ Ð°Ð²Ñ‚Ð¾Ð¼Ð°Ñ‚Ð¸Ñ‡ÐµÑÐºÐ¾Ð³Ð¾ Ð¾Ð¿Ñ€ÐµÐ´ÐµÐ»ÐµÐ½Ð¸Ñ ÐºÐ¾Ñ€ ÑÑ‡ÐµÑ‚ Ð±ÐµÐ½ÐµÑ„Ð¸Ñ†Ð¸Ð°Ñ‚Ñ€Ð°
  MEMBER PROCEDURE set_beneficiar_bank_corr_acc(p_var IN VARCHAR2),
  MEMBER PROCEDURE update_to_correct_bank_date(p_var DATE DEFAULT NULL),
  MEMBER FUNCTION get_operation_object_id RETURN INTEGER,
  /******* State changer *******/
  
  MEMBER PROCEDURE state_to_complete(p_related_obj IN OUT NOCOPY t_interbankpayments_ext_col),
  MEMBER PROCEDURE STATE_TO_COMPLETE,
  
  MEMBER PROCEDURE STATE_TO_VERIFICATION,
  MEMBER PROCEDURE STATE_TO_AUTHORIZATION,
  MEMBER PROCEDURE STATE_TO_CHANGING,
  MEMBER PROCEDURE STATE_TO_CANCEL,
  MEMBER PROCEDURE STATE_TO_CHANGING_AUTH,
  MEMBER PROCEDURE ERASE,
  MEMBER PROCEDURE get_corr_acc_id  (p_corr_id IN OUT INTEGER),
  MEMBER FUNCTION get_fee_payer_id (SELF IN OUT T_INTBANKPAYS_MSG) RETURN INTEGER,
    
  MEMBER PROCEDURE genereate_fees_by_rules(l_fee_kind IN OUT ibs.t_integer_collection, p_special_fee OUT ibs.t_fee_amount),
  MEMBER PROCEDURE pay_fee, 
  MEMBER PROCEDURE burn_operation,
  MEMBER PROCEDURE create_operation,
  
  MEMBER FUNCTION get_payer_id(SELF IN OUT T_INTBANKPAYS_MSG) RETURN INTEGER,
  MEMBER FUNCTION get_receiver_id(SELF IN OUT T_INTBANKPAYS_MSG) RETURN INTEGER,
  MEMBER FUNCTION get_account_id (SELF IN OUT T_INTBANKPAYS_MSG, p_raise BOOLEAN DEFAULT FALSE) RETURN INTEGER, 
  MEMBER FUNCTION get_account_tpl_lgform(p_lg_form INTEGER DEFAULT NULL) RETURN VARCHAR2,
  MEMBER FUNCTION cat_acc_tpl_parse(p_blns VARCHAR2, 
                                    p_cur VARCHAR2, 
                                    p_lgform VARCHAR2, 
                                    p_branch VARCHAR2, 
                                    p_tt VARCHAR2 DEFAULT NULL) RETURN VARCHAR2,
  MEMBER FUNCTION get_main_operation_ground RETURN VARCHAR,     
  MEMBER PROCEDURE complete_operation_chain(p_operation_chain_id INTEGER DEFAULT NULL),                         
  /******************************* checkers ******************************/
  MEMBER PROCEDURE CHECKING_PAYMENT(p_state IN INT DEFAULT NULL),
  MEMBER PROCEDURE CHECK_GROUND,
  MEMBER PROCEDURE CHECK_BENEFICIAR_BANK_CODE,
  MEMBER PROCEDURE CHECK_DATE,
  MEMBER PROCEDURE CHECK_PAYMENT_SYSTEM,
  MEMBER PROCEDURE CHECK_MSGTYPE,
  MEMBER PROCEDURE CHECK_SYSTEM_ID,
  -- Payer checking
  MEMBER PROCEDURE CHECK_PAYER_ACCOUNT,
  MEMBER PROCEDURE CHECK_BRANCH_ID,
  -- Fin checking
  MEMBER PROCEDURE CHECK_AMOUNT,
  MEMBER PROCEDURE CHECK_AMOUNT_ENOUGHT,
  MEMBER PROCEDURE CHECK_CURRENCY,
  MEMBER PROCEDURE CHECK_MANUAL_OPID,
  -- Receiver checking
  MEMBER PROCEDURE CHECK_RECEIVER_TAX,
  MEMBER PROCEDURE CHECK_RECEIVER_IBAN,
  MEMBER PROCEDURE CHECK_RECEIVER_NAME,
  -- State verifications
  MEMBER PROCEDURE CHECK_FOR_STATE_VERIFICATION,
  MEMBER PROCEDURE CHECK_FOR_STATE_AUTHORIZATION,
  MEMBER PROCEDURE CHECK_FOR_STATE_IB_WAITING,
  MEMBER PROCEDURE CHECK_BUDGET,
  /******* Getters *******/
  MEMBER FUNCTION GET_SYSTEM_ID(SELF IN OUT T_INTBANKPAYS_MSG) RETURN INTEGER,
  MEMBER FUNCTION GET_GROUND_REXP RETURN VARCHAR,
  MEMBER FUNCTION GET_GROUND_LENGTH RETURN INT,
  MEMBER FUNCTION GET_RECEIVER_NAME_REXP RETURN VARCHAR,
  MEMBER FUNCTION GET_RECEIVER_TAX_REXP RETURN VARCHAR,
  MEMBER FUNCTION GET_IBAN_LENGTH RETURN INT,
  MEMBER PROCEDURE SET_FEE_COLLECTION (p_fee_kind INTEGER),
  MEMBER PROCEDURE UPDATE_FEE_COLLECTION,
  MEMBER PROCEDURE CHECK_STATE(p_new_state IN INTEGER),
  MEMBER FUNCTION generate_fee_ground(p_fee ibs.t_fee_amount) RETURN VARCHAR,
  /******************/
  MEMBER PROCEDURE ONCREATE,
  MEMBER PROCEDURE ONCOMPLETE,
  MEMBER PROCEDURE CREATEFILE(p_id IN INTEGER),
  MEMBER PROCEDURE COLLECT_FEE,
  MEMBER PROCEDURE SET_OBJ(pobj IN OUT NOCOPY t_interbankpayments_extend),
  MEMBER FUNCTION  GET_OBJ RETURN t_interbankpayments_extend,
  ---
  MEMBER FUNCTION check_data_before_feeupdating(SELF IN OUT T_INTBANKPAYS_MSG) RETURN BOOLEAN,
  MEMBER FUNCTION is_incountry_payment(SELF IN OUT T_INTBANKPAYS_MSG) RETURN BOOLEAN,
  MEMBER FUNCTION is_outcountry_payment(SELF IN OUT T_INTBANKPAYS_MSG) RETURN BOOLEAN,
  ---
  CONSTRUCTOR FUNCTION T_INTBANKPAYS_MSG(pobj IN OUT NOCOPY t_interbankpayments_extend) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION T_INTBANKPAYS_MSG(pid IN INTEGER) RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION T_INTBANKPAYS_MSG RETURN SELF AS RESULT
) NOT FINAL
/
create or replace type body T_INTBANKPAYS_MSG AS
    /******************** Checkers ********************/
	MEMBER PROCEDURE CHECKING_PAYMENT(p_state IN INT DEFAULT NULL)
    IS l_state INT DEFAULT nvl(p_state, SELF.OBJ.STATE);
    BEGIN
        IF l_state = const_interbankpayments.STATE_VERIFICATION THEN
            SELF.CHECK_FOR_STATE_VERIFICATION;
        ELSIF l_state = const_interbankpayments.STATE_AUTHORIZATION THEN
            SELF.CHECK_FOR_STATE_AUTHORIZATION;
        ELSIF l_state = const_interbankpayments.STATE_IB_WAITING THEN
            SELF.CHECK_FOR_STATE_IB_WAITING;
        END IF;
    END;
    
    MEMBER PROCEDURE CHECK_AMOUNT IS BEGIN
        IF SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_UNCHECK_PANULL_SETAMOUNT) THEN
           api_interbankpayments.add_payment_change(SELF.obj, 
                           p_action => 't_interbankpayments.check_receiver_iban', 
                           p_additional => 'Uncheck attribute for checking amount is null'); 
        ELSIF SELF.obj.AMOUNT IS NULL THEN
            raise_application_error(const_exceptions.SUM_NOT_SET.integ, const_exceptions.SUM_NOT_SET.str);
        END IF;
    END;
    
    MEMBER PROCEDURE CHECK_PAYMENT_SYSTEM IS BEGIN
        IF NOT SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_UNCHECK_PAYSYS_NULL) THEN 
            IF SELF.obj.SYSTEM_ID IS NULL THEN
                 const_exceptions.raise_exception(const_exceptions.PAYSYS_NOT_SET);
            END IF;
        ELSE
            api_interbankpayments.add_payment_change(SELF.obj, 
                           p_action => 't_interbankpayments.check_payment_system', 
                           p_additional => 'Uncheck attribute for payment system have setted');
        END IF;
    END;

    MEMBER PROCEDURE CHECK_DATE
    IS  
    BEGIN
        IF SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_UNCHECK_PAYDATE_NULL) THEN
             api_interbankpayments.add_payment_change(SELF.obj, 
                           p_action => 't_interbankpayments.check_date', 
                           p_additional => 'Uncheck attribute {ATTR_UNCHECK_PAYDATE_NULL} for payment date have setted');
        ELSIF SELF.obj.PAYMENT_DATE IS NULL THEN
            raise_application_error(IBS.CONST_EXCEPTION.GENERAL_ERROR, 'Дата платежа не может быть пустой');
        END IF;
        
        IF NOT SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_UNCHECK_PAY_DATE) 
        THEN
            IF IBS.API_CALENDAR.IS_WORK_DAY(SELF.obj.PAYMENT_DATE) = 0 THEN
                raise_application_error(const_exceptions.NO_BANK_DATE.integ, const_exceptions.NO_BANK_DATE.str);  
            END IF;
        ELSE
           api_interbankpayments.add_payment_change(SELF.obj, 
                           p_action => 't_interbankpayments.check_date', 
                           p_additional => 'Uncheck attribute for payment date have setted');
        END IF;
    END;

    MEMBER PROCEDURE CHECK_GROUND IS 
        l_len INT DEFAULT LENGTH(SELF.obj.GROUND);
    BEGIN
        IF SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_UNCHECK_GROUND_EMPTY) 
            AND  SELF.obj.GROUND IS NULL OR TRIM(SELF.obj.GROUND) = '' THEN
            api_interbankpayments.add_payment_change(SELF.obj, 
                           p_action => 't_interbankpayments.CHECK_GROUND', 
                           p_additional => 'Uncheck attribute for checking ground to null');
        ELSIF SELF.obj.isset_attribute(const_interbankpayments.ATTR_BUDGET_DESTINATION) 
              AND SELF.obj.isset_attribute(const_interbankpayments.ATTR_BUDGET_LEVEL)
              AND l_len > 70 THEN
              const_exceptions.raise_exception(const_exceptions.GROUND_WRONG_LENGTH, 
                                               to_char(l_len), 
                                               to_char(SELF.GET_GROUND_LENGTH)); 
        ELSIF SELF.obj.GROUND IS NULL OR TRIM(SELF.obj.GROUND) = '' THEN
            raise_application_error(const_exceptions.NO_GROUND.integ, const_exceptions.NO_GROUND.str);  
        ELSIF NOT regexp_like(SELF.obj.GROUND, SELF.GET_GROUND_REXP()) THEN
            raise_application_error(const_exceptions.GROUND_WRONG_SYM.integ, const_exceptions.GROUND_WRONG_SYM.str);  
        ELSIF l_len > SELF.GET_GROUND_LENGTH() THEN
            const_exceptions.raise_exception(const_exceptions.GROUND_WRONG_LENGTH, 
                                               to_char(l_len), 
                                               to_char(SELF.GET_GROUND_LENGTH));
        END IF; 
    END;
    
    MEMBER PROCEDURE CHECK_BENEFICIAR_BANK_CODE IS BEGIN
        IF SELF.obj.BENEFICIAR_BANK_CODE IS NULL AND NOT SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_UNCHECK_BFC_BANKCODE_NULL) 
        THEN 
            raise_application_error(const_exceptions.NO_BENBANK_CODE.integ, const_exceptions.NO_BENBANK_CODE.str);
        END IF;
    END;
    MEMBER PROCEDURE CHECK_CURRENCY IS BEGIN
        IF SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_UNCHECK_CURRENCY_NULL) THEN
            api_interbankpayments.add_payment_change(SELF.obj, 
                           p_action => 't_interbankpayments.check_receiver_iban', 
                           p_additional => 'Uncheck attribute for checking currency is null'); 
        ELSIF SELF.obj.CURRENCY IS NULL THEN
            const_exceptions.raise_exception(const_exceptions.NO_CURRENCY);
        ELSIF IBS.API_CURRENCY.READ_CURRENCY(SELF.obj.CURRENCY,false).ID IS NULL THEN
            raise_application_error(const_exceptions.CURRENCY_WRONG.integ, const_exceptions.format(const_exceptions.CURRENCY_WRONG.str, 
                                                                                                    to_char(SELF.obj.CURRENCY)));
        END IF;
    END;
    MEMBER PROCEDURE CHECK_AMOUNT_ENOUGHT
    IS l_account        ibs.account%rowtype DEFAULT ibs.API_ACCOUNT.READ_ACCOUNT(SELF.obj.PAYER_ACCOUNT, TRUE);
       l_sum            NUMBER DEFAULT SELF.obj.AMOUNT + nvl(SELF.obj.get_fee_sum, 0.0);
       l_freezed_amoun  NUMBER DEFAULT 0.0;
    BEGIN
        IF SELF.obj.PAYER_ACCOUNT IS NOT NULL THEN
            l_freezed_amoun := ibs.api_attribute.get_num_attribute_value(SELF.obj.PAYER_ACCOUNT_ID,
                                                                         ibs.const_account.OP_TYPE_BLOCK_AMOUNT);
        END IF;
        IF l_account.account_type = ibs.const_account.TYPE_ACTIVE THEN
            api_interbankpayments.add_payment_change(SELF.obj, 
                           p_action => 'CHECK_AMOUNT_ENOUGHT', 
                           p_additional => 'Unchecking amount enought for active account');
        ELSIF NOT SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_UNCHECK_ENOUGH_ACC_AMOUNT) THEN
            IF l_account.rest_plan < l_sum THEN
                raise_application_error(const_exceptions.AMOUNT_NO_ENOUGHT.integ, const_exceptions.format(const_exceptions.AMOUNT_NO_ENOUGHT.str, 
                                                                                                    SELF.obj.PAYER_ACCOUNT,
                                                                                                    l_account.rest_plan || '',
                                                                                                    SELF.obj.ID || '',
                                                                                                    l_sum || ' ' || IBS.API_CURRENCY.GET_ISO_NAME(SELF.obj.CURRENCY),
                                                                                                    SELF.obj.AMOUNT || '',
                                                                                                    SELF.obj.FEE_SUM_AMOUNT || ''
                                                                                                    ));                                        
            END IF;
        ELSE api_interbankpayments.add_payment_change(SELF.obj, 
                           p_action => 'CHECK_AMOUNT_ENOUGHT', 
                           p_additional => 'Uncheck attribute for amount enough have setted');
        END IF;
    END;
    
    MEMBER PROCEDURE CHECK_RECEIVER_NAME IS BEGIN
        IF NOT SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_UNCHECK_REC_NAME) THEN
            IF  length(SELF.obj.RECEIVER_NAME) > 34 OR NOT regexp_like(SELF.obj.RECEIVER_NAME, SELF.GET_RECEIVER_NAME_REXP())
            THEN
                raise_application_error(const_exceptions.RECEIVERNAME_WRONG.integ, const_exceptions.format(const_exceptions.RECEIVERNAME_WRONG.str, 
                                                                                                    SELF.obj.RECEIVER_NAME));  
            END IF;
        ELSE
            api_interbankpayments.add_payment_change(SELF.obj, 
                           p_action => 't_interbankpayments.check_receiver_name', 
                           p_additional => 'Uncheck attribute for checking receiver name');
        END IF;
    END;
    MEMBER PROCEDURE CHECK_MANUAL_OPID IS BEGIN
        IF IBS.API_OPERATION.READ_OPERATION(SELF.obj.OPERATION_ID, false).ID IS NULL THEN
            raise_application_error(const_exceptions.OPERATION_NOEXS.integ, 
                                    const_exceptions.format(const_exceptions.OPERATION_NOEXS.str, 
                                                            SELF.obj.OPERATION_ID)); 
        END IF;
    END;
    MEMBER PROCEDURE CHECK_BRANCH_ID 
    IS 
        l_br  ibs.branch%ROWTYPE DEFAULT IBS.API_BRANCH.READ_BRANCH(SELF.obj.PAYER_BRANCH_ID, FALSE);
    BEGIN
        IF SELF.obj.PAYER_BRANCH_ID IS NULL AND NOT SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_UNCHECK_PAYER_BRANCH) THEN
            raise_application_error(const_exceptions.NO_PAYER_BRANCH.integ, const_exceptions.NO_PAYER_BRANCH.str);
        ELSIF l_br.branch_state = 1 THEN
            raise_application_error(const_exceptions.BRANCH_CLOSED.integ, 
                                    const_exceptions.format(const_exceptions.BRANCH_CLOSED.str, 
                                                            SELF.obj.PAYER_BRANCH_ID || '')); 
        ELSIF l_br.Id IS NULL THEN
            const_exceptions.raise_exception(const_exceptions.BRANCH_UNKNOWN,  SELF.obj.PAYER_BRANCH_ID || '');
        END IF;
    END;
    
    MEMBER PROCEDURE CHECK_RECEIVER_TAX IS BEGIN    
        IF SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_UNCHECK_REC_TAX_NULL) THEN
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
        END IF;
    END;
    
    MEMBER PROCEDURE CHECK_RECEIVER_IBAN IS
       l_msg    VARCHAR(100);
    BEGIN
        IF SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_UNCHECK_REC_IBAN_NULL) THEN
           api_interbankpayments.add_payment_change(SELF.obj, 
                           p_action => 't_interbankpayments.check_receiver_iban', 
                           p_additional => 'Uncheck attribute for checking receiver iban is null');
        ELSIF SELF.obj.RECEIVER_IBAN IS NULL OR trim(SELF.obj.RECEIVER_IBAN) = '' THEN
            raise_application_error(const_exceptions.RECEIVERIBAN_NO.integ, const_exceptions.RECEIVERIBAN_NO.str);
        ELSIF NOT SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_UNCHECK_IBAN) THEN
            IF length(SELF.obj.RECEIVER_IBAN) != SELF.GET_IBAN_LENGTH THEN
                raise_application_error(const_exceptions.RECEIVERIBAN_L_WR.integ, const_exceptions.format(const_exceptions.RECEIVERIBAN_L_WR.str, 
                                                                                                    TO_CHAR(length(SELF.obj.RECEIVER_IBAN)),
                                                                                                    SELF.obj.RECEIVER_IBAN));
            END IF;
            IF SELF.obj.BENEFICIAR_BANK_SWIFT IS NOT NULL AND NOT jui_interbankpayments_tools.ISVALID_IBANKACCOUNT(SELF.obj.RECEIVER_IBAN, SELF.obj.BENEFICIAR_BANK_SWIFT) THEN
                raise_application_error(const_exceptions.RECEIVERIBAN_WRONG.integ, const_exceptions.format(const_exceptions.RECEIVERIBAN_WRONG.str,
                                                                                                    SELF.obj.RECEIVER_IBAN));
            END IF;
        ELSE
            api_interbankpayments.add_payment_change(SELF.obj, 
                           p_action => 't_interbankpayments.check_receiver_iban', 
                           p_additional => 'Uncheck attribute for checking receiver iban');
        END IF;
    END;
    MEMBER PROCEDURE CHECK_PAYER_ACCOUNT IS
        l_account   ibs.account%ROWTYPE; 
    BEGIN
        IF SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_UNCHECK_PAY_ACCOUNT_NULL) 
            AND SELF.obj.PAYER_ACCOUNT IS NULL OR TRIM(SELF.obj.PAYER_ACCOUNT) = '' THEN
            api_interbankpayments.add_payment_change(SELF.obj, 
                       p_action => 't_interbankpayments.CHECK_PAYER_ACCOUNT', 
                       p_additional => 'Uncheck attribute for checking  payer account'); 
        ELSIF SELF.obj.PAYER_ACCOUNT IS NULL OR TRIM(SELF.obj.PAYER_ACCOUNT) = '' OR ibs.API_ACCOUNT.READ_ACCOUNT(SELF.obj.PAYER_ACCOUNT, FALSE).ID IS NULL THEN
            const_exceptions.raise_exception(const_exceptions.PAYER_ACC_NO);
        END IF;
        
        l_account := ibs.api_account.read_account(SELF.obj.PAYER_ACCOUNT);
        IF l_account.currency_id <> obj.CURRENCY THEN
            const_exceptions.raise_exception(const_exceptions.ACC_CURENCY_DIF_PCURRENCY, 
                                            p_val1 => ibs.api_currency.get_iso_name(l_account.currency_id),
                                            p_val2 => ibs.api_currency.get_iso_name(obj.CURRENCY));
        END IF;
    END;
    MEMBER PROCEDURE CHECK_MSGTYPE IS BEGIN
        IF SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_UNCHECK_MSGTYPE_NULL) AND SELF.obj.MESSAGE_TYPE IS NULL THEN
            api_interbankpayments.add_payment_change(SELF.obj, 
                           p_action => 't_interbankpayments.CHECK_MSGTYPE', 
                           p_additional => 'Uncheck attribute for checking message type is null');
        ELSIF SELF.obj.MESSAGE_TYPE IS NULL THEN
            const_exceptions.raise_exception(const_exceptions.NO_MSG_TYPE);
        ELSIF SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_UNCHECK_MSGTYPE) THEN
            api_interbankpayments.add_payment_change(SELF.obj, 
                               p_action => 't_interbankpayments.CHECK_MSGTYPE', 
                               p_additional => 'Uncheck attribute for checking message type');
        ELSIF NOT JUI_INTERBANKPAYMENTS_TOOLS.is_known_msgtype(SELF.obj.MESSAGE_TYPE) THEN
            const_exceptions.raise_exception(const_exceptions.MSG_TYPE_WRONG, SELF.obj.MESSAGE_TYPE || '');
        END IF;  
    END;
    
    MEMBER PROCEDURE CHECK_SYSTEM_ID IS 
    BEGIN
        IF SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_UNCHECK_PAY_SYS_NULL) AND SELF.obj.SYSTEM_ID IS NULL THEN
            api_interbankpayments.add_payment_change(SELF.obj, 
                           p_action => 't_interbankpayments.CHECK_SYSTEM_ID', 
                           p_additional => 'Uncheck attribute for checking payment system is null');
        ELSIF SELF.obj.SYSTEM_ID IS NULL THEN
            const_exceptions.raise_exception(const_exceptions.PAYSYS_NOT_SET);
        ELSIF SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_UNCHECK_PAY_SYS) THEN
            api_interbankpayments.add_payment_change(SELF.obj, 
                               p_action => 't_interbankpayments.CHECK_SYSTEM_ID', 
                               p_additional => 'Uncheck attribute for checking payment system');
        ELSIF NOT JUI_INTERBANKPAYMENTS_TOOLS.is_known_payment_system(SELF.obj.SYSTEM_ID) THEN
            const_exceptions.raise_exception(const_exceptions.PAYSYS_WRONG, SELF.obj.SYSTEM_ID || '');
        END IF;
    END;
    
    MEMBER PROCEDURE CHECK_BUDGET IS
      	attr_budget_level VARCHAR2(250) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_BUDGET_LEVEL).value_str;
        attr_budget_dest  VARCHAR2(250) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_BUDGET_DESTINATION).value_str;  
    BEGIN
        IF (attr_budget_level IS NULL AND attr_budget_dest IS NOT NULL) 
            OR (attr_budget_level IS NOT NULL AND attr_budget_dest IS NULL)
        THEN
            const_exceptions.raise_exception(const_exceptions.BOTH_BUDGET_WILLFILL);
        END IF;
    END;
    
    MEMBER PROCEDURE CHECK_FOR_STATE_VERIFICATION IS BEGIN
        CHECK_MSGTYPE;
        CHECK_DATE;
        CHECK_BRANCH_ID;
        CHECK_PAYER_ACCOUNT;
        CHECK_AMOUNT;
        CHECK_AMOUNT_ENOUGHT;
        CHECK_CURRENCY;
        CHECK_GROUND;
        CHECK_BENEFICIAR_BANK_CODE;
        CHECK_BUDGET;
    END;



    MEMBER PROCEDURE CHECK_FOR_STATE_AUTHORIZATION IS BEGIN NULL; END;
    
    MEMBER PROCEDURE CHECK_FOR_STATE_IB_WAITING IS BEGIN
        NULL;
    END;
    /**************************************** /Checkers ****************************************/
    
    /**************************************** DEFAULT GETTERS ****************************************/
    MEMBER FUNCTION GET_GROUND_REXP RETURN VARCHAR IS BEGIN RETURN '^[A-Za-z0-9[:space:],./-]*$'; END;
    MEMBER FUNCTION GET_GROUND_LENGTH RETURN INT IS BEGIN RETURN 140; END;
    MEMBER FUNCTION GET_IBAN_LENGTH RETURN INT IS BEGIN RETURN 28; END;
    MEMBER FUNCTION GET_RECEIVER_NAME_REXP RETURN VARCHAR IS BEGIN RETURN '^[A-Za-z0-9[:space:].()-]*$'; END;
    MEMBER FUNCTION GET_RECEIVER_TAX_REXP RETURN VARCHAR IS BEGIN RETURN '[0-9]'; END;
    /**************************************** /DEFAULT GETTERS ****************************************/
    
    /**************************************** STATES ****************************************/
    MEMBER PROCEDURE state_to_verification IS
    BEGIN 
        CHECKING_PAYMENT(const_interbankpayments.STATE_VERIFICATION);
        IF set_state(CONST_INTERBANKPAYMENTS.STATE_VERIFICATION) THEN
            --JUI_INTERBANKPAYMENTS_TOOLS.FREEZE_AMOUNT(SELF);
            api_interbankpayments.add_payment_change(mobj => obj, p_action => 'state_to_verification');
        END IF;
    /*EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                                                       p_action => 'state_to_verification', 
                                                       p_autonomus => TRUE,
                                                       p_result => SQLERRM || '',
                                                       p_additional => dbms_utility.format_error_backtrace);
            RAISE;*/
    END;

    MEMBER PROCEDURE state_to_complete(p_related_obj IN OUT NOCOPY t_interbankpayments_ext_col) IS
        l_index         INTEGER;
        l_rel_attr      INTEGER;
        l_parent_attr   INTEGER;
        l_struct        t_MESSAGE_STRUCT;
        l_msg           t_intbankpays_msg;
        l               t_interbankpayments_extend;
        l_errors        CLOB DEFAULT NULL;
        l_rel_status    INTEGER;
        l_temp          BOOLEAN;
    BEGIN
        CHECKING_PAYMENT(const_interbankpayments.STATE_COMPLETED);
        
        IF p_related_obj.count > 0 AND p_related_obj IS NOT NULL THEN
            IF jui_interbankpayments_tools.is_struct_type_exist(p_obj => SELF.obj, p_postfix => '_BATCH') THEN
                l_index := p_related_obj.FIRST;
                l_parent_attr := obj.get_attribute_val(const_interbankpayments.ATTR_BATCH_PAYMENT_NUM).value_int;
                
                WHILE (l_index IS NOT NULL)
                LOOP
                    BEGIN
                        l_msg := api_interbankpayments.getMessageTypeObject(p_related_obj(l_index));
                        l_rel_attr := p_related_obj(l_index).get_attribute_val(const_interbankpayments.ATTR_BATCH_PAYMENT_NUM).value_int;
                        IF l_rel_attr <> l_parent_attr THEN
                            api_interbankpayments.add_payment_change(mobj => p_related_obj(l_index), 
                                                                    p_action => 'state_to_complete',
                                                                    p_additional => 'Исключен из пакетной обработки, т.к. атрибут‚ ATTR_BATCH_PAYMENT_NUM {'|| l_rel_attr ||
                                                                        '} отличен от атрибута родительского платежа {' || l_parent_attr ||'}');    
                            CONTINUE;
                        END IF;
                        
                        
                        IF SELF.obj.isset_attribute(const_interbankpayments.ATTR_USE_FILE_PROV_QUEE) THEN
                            l_rel_status := const_interbankpayments.STATE_PROVIDER_IN_QUEEE;
                        ELSE l_rel_status := const_interbankpayments.STATE_COMPLETED;
                        END IF;
                        
                        
                        
                        l_msg.obj.SET_STATE(l_rel_status);
                        p_related_obj(l_index) := l_msg.GET_OBJ;
                        p_related_obj(l_index).update_attr_val(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_IS_BATCH_RELATED_MSG,
                                                                                  value_str => NULL,
                                                                                  value_int => SELF.obj.ID));
                                                                                  
                   EXCEPTION
                        WHEN OTHERS THEN 
                            api_interbankpayments.add_payment_change(mobj => p_related_obj(l_index), 
                                                               p_action => 'state_to_complete', 
                                                               p_autonomus => TRUE,
                                                               p_result => SQLERRM || '',
                                                               p_additional => dbms_utility.format_error_backtrace);
                            l_errors := l_errors || '#' || p_related_obj(l_index).id || ' : ' || SQLERRM || '<br>' || chr(10);
                   END;
                   l_index := p_related_obj.NEXT(l_index); 
                END LOOP;
                --raise_application_error(-20000, SELF.obj.STATE);
                IF p_related_obj.count > 0 THEN
                    SELF.update_attribute(p_attr_id => const_interbankpayments.ATTR_IS_BATCH_PARENT_MSG);
                    
                    IF SELF.obj.isset_attribute(const_interbankpayments.ATTR_USE_FILE_PROV_QUEE) THEN
                        l_rel_status  :=   const_interbankpayments.STATE_PROVIDER_IN_QUEEE;
                    ELSE l_rel_status := const_interbankpayments.STATE_COMPLETED;
                    END IF;
                    
                    --SELF.obj.set_state(const_interbankpayments.STATE_PROVIDER_IN_QUEEE);
                    SELF.OBJ.SET_STATE(l_rel_status);
                    p_related_obj.extend;
                    p_related_obj(p_related_obj.last) := SELF.obj;
                    l_struct := api_interbankpayments.get_message_struct(p_related_obj);
                    api_interbankpayments.add_payment_change(mobj => obj, 
                                                                    p_action => 'state_to_complete',
                                                                    p_additional => 'Batch Message Struct - generated');
                    
                    l_temp := l_struct.COMPLETE();
                    -- Ð½Ð°Ð´Ð¾ Ð¿ÐµÑ€ÐµÐ´ÐµÐ»Ð°Ñ‚ÑŒ \Ñ‚Ð¾ Ñ€ÐµÑˆÐµÐ½Ð¸Ðµ - Ð¾Ð½Ð¾ ÐºÐ°ÐºÐ¾Ðµ-Ñ‚Ð¾ Ð½ÐµÐºÑ€Ð°ÑÐ¸Ð²Ð¾Ðµ
                    api_interbankpayments.add_payment_change(mobj => obj, 
                                                                    p_action => 'state_to_complete',
                                                                    p_additional => 'Добавлено в очередь сообщений на отправку провайдеру');
                    
                ELSE SELF.state_to_complete();                    
                END IF;
           ELSE
               api_interbankpayments.add_payment_change(mobj => obj, 
                                                        p_action => 'state_to_complete',
                                                        p_additional => 'Message struct file is not exist');
               SELF.state_to_complete();
           END IF;
        ELSE
            const_exceptions.raise_exception(const_exceptions.NO_RELATED_MSG);
        END IF;
        
        IF l_errors IS NOT NULL THEN
            raise_application_error(-20000, l_errors);
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                                                       p_action => 'state_to_complete', 
                                                       p_autonomus => TRUE,
                                                       p_result => SQLERRM || '',
                                                       p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;

    MEMBER PROCEDURE state_to_complete IS
	    l                   t_MESSAGE_STRUCT; 
        l_batch_num         NUMBER DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_BATCH_PAYMENT_NUM).value_int;
        l_batch_msgs_col    t_intbankpays_msg_collection;
        l_batch_msgs_p      t_interbankpayments_ext_col DEFAULT t_interbankpayments_ext_col();
        l_index             INTEGER;
        l_result            CLOB;
    BEGIN
        --IF set_state(CONST_INTERBANKPAYMENTS.STATE_COMPLETED) THEN
            api_interbankpayments.add_payment_change(mobj => obj, p_action => 'state_to_complete');
            IF NOT obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_IS_WITHOUT_REM_TRANSFER) THEN
                l := api_interbankpayments.get_message_struct(SELF);
                api_interbankpayments.add_payment_change(mobj => obj, 
                                                            p_action => 'state_to_complete',
                                                            p_additional => 'Message Struct - generated');
                IF l.COMPLETE() THEN
                    CHECKING_PAYMENT(const_interbankpayments.STATE_PROVIDER_IN_QUEEE);
                    SELF.obj.set_state(const_interbankpayments.STATE_PROVIDER_IN_QUEEE);   
                    api_interbankpayments.add_payment_change(mobj => obj, 
                                                            p_action => 'state_to_complete',
                                                            p_additional => 'Добавлено в очередь'); 
                ELSE
                    l_result := l.TRANSPORTER_TO_PROVIDER();
                    CHECKING_PAYMENT(const_interbankpayments.STATE_PROVIDER_SENT);
                    SELF.obj.set_state(const_interbankpayments.STATE_PROVIDER_SENT); 
                    api_interbankpayments.add_payment_change(mobj => obj, 
                                                            p_action => 'state_to_complete',
                                                            p_additional => 'Message Struct - transported to provider');
                END IF; 
            END IF;
        --END IF;
    /*EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                                                       p_action => 'state_to_complete', 
                                                       p_autonomus => TRUE,
                                                       p_result => SQLERRM || '',
                                                       p_additional => dbms_utility.format_error_backtrace);
            RAISE;*/
    END;
    
    MEMBER PROCEDURE state_to_authorization IS 
        l_res BOOLEAN;
    BEGIN 
        CHECKING_PAYMENT(const_interbankpayments.STATE_AUTHORIZATION);
        
        IF SELF.obj.STATE < const_interbankpayments.STATE_AUTHORIZATION --IN (const_interbankpayments.STATE_VERIFICATION, const_interbankpayments.STATE_CHANGINGFROMAUTH)
        THEN
            IF set_state(CONST_INTERBANKPAYMENTS.STATE_AUTHORIZATION) THEN
                CREATE_OPERATION();
                api_interbankpayments.add_payment_change(mobj => obj, p_action => 'state_to_authorization');
            END IF;
        ELSE l_res := set_state(CONST_INTERBANKPAYMENTS.STATE_AUTHORIZATION);
        END IF;
    /*EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                                                       p_action => 'state_to_authorization', 
                                                       p_autonomus => TRUE,
                                                       p_result => SQLERRM || '',
                                                       p_additional => dbms_utility.format_error_backtrace);
            RAISE;*/
    END;
    
    MEMBER PROCEDURE state_to_changing IS 
    BEGIN 
        IF set_state(CONST_INTERBANKPAYMENTS.STATE_CHANGING) THEN
            JUI_INTERBANKPAYMENTS_TOOLS.UNFREEZE_AMOUNT(SELF);
            api_interbankpayments.add_payment_change(mobj => obj, p_action => 'state_to_changing');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                                                       p_action => 'state_to_changing', 
                                                       p_autonomus => TRUE,
                                                       p_result => SQLERRM || '',
                                                       p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;
    
    MEMBER PROCEDURE STATE_TO_CHANGING_AUTH IS 
        l_operation ibs.operation%ROWTYPE DEFAULT ibs.api_operation.read_operation(p_operation_id => SELF.obj.OPERATION_ID,
                                                                                   p_is_raise_ndf => false);
        
    BEGIN 
        IF set_state(CONST_INTERBANKPAYMENTS.STATE_CHANGINGFROMAUTH) THEN
            IF l_operation.id IS NOT NULL AND l_operation.is_delete <> 1 THEN
                jui_interbankpayments_tools.roll_back_operation(SELF);
            END IF;
            SELF.obj.OPERATION_ID := NULL;
            api_interbankpayments.add_payment_change(mobj => obj, p_action => 'STATE_TO_CHANGING_AUTH');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                                                       p_action => 'state_to_cancel', 
                                                       p_autonomus => TRUE,
                                                       p_result => SQLERRM || '',
                                                       p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;
    
    MEMBER PROCEDURE STATE_TO_CANCEL IS l_operation ibs.operation%ROWTYPE;
    BEGIN 
        IF set_state(CONST_INTERBANKPAYMENTS.STATE_CANCELED) THEN NULL; END IF;
        
        JUI_INTERBANKPAYMENTS_TOOLS.UNFREEZE_AMOUNT(SELF);
        jui_interbankpayments_tools.roll_back_operation(SELF);
        api_interbankpayments.add_payment_change(mobj => obj, p_action => 'state_to_cancel');
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                                                       p_action => 'state_to_cancel', 
                                                       p_autonomus => TRUE,
                                                       p_result => SQLERRM || '',
                                                       p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;
    
    MEMBER PROCEDURE ERASE IS 
    BEGIN
        api_interbankpayments_access.has_grand(const_interbankpayments.ACCESS_DELETE, SELF.OBJ.MESSAGE_TYPE);
        IF set_state(const_interbankpayments.STATE_DELETED) THEN NULL; END IF;
        DELETE FROM INTERBANKPAYMENTS t WHERE t.id = SELF.obj.ID;
    END;
    
    /**************************************** /STATES ****************************************/
    MEMBER PROCEDURE refresh_reference IS
    BEGIN
        SELF.obj.REFERENCE := jui_interbankpayments_tools.get_next_reference();
    END;

    MEMBER FUNCTION get_operation_object_id RETURN INTEGER IS
    BEGIN RETURN SELF.obj.PAYER_ACCOUNT_ID; END;    

    MEMBER PROCEDURE burn_operation IS
        l_operation_chain_id	INTEGER	DEFAULT ibs.api_operation.create_operation_chain(CONST_INTERBANKPAYMENTS.OCT_OUTBANK_PAYMENT);
    BEGIN
        obj.OPERATION_ID := ibs.api_operation.create_operation(SELF.get_operation_object_id,
                                                             CONST_INTERBANKPAYMENTS.OT_OUTBANK_PAYMENT,
                                                             l_operation_chain_id,
                                                             obj.GROUND,
                                                             null,
                                                             null);
        update_attribute(T_INTBANKPAYS_ATTR(CONST_INTERBANKPAYMENTS.ATTR_SETTELMENT_OPER_CHAIN, p_value_int => l_operation_chain_id));
        api_interbankpayments.add_payment_change(mobj => obj, 
                                                   p_action => 'create_operation',
                                                   p_desc => 'New operation has been created',
                                                   p_additional => obj.OPERATION_ID
                                                   );
    END;
    
    MEMBER FUNCTION get_main_operation_ground RETURN VARCHAR IS
    BEGIN
        RETURN REPLACE(obj.GROUND || CASE WHEN jui_interbankpayments_tools.is_IB_payment(SELF.obj) THEN '(Internet Banking)'
                                 ELSE ''
                             END, chr(13) || chr(10), ' ');
    END;
    
    MEMBER PROCEDURE complete_operation_chain(p_operation_chain_id INTEGER DEFAULT NULL) IS
        l_operation_chain_id    INTEGER DEFAULT nvl(p_operation_chain_id, 
                                                               SELF.OBJ.get_attribute_val(CONST_INTERBANKPAYMENTS.ATTR_SETTELMENT_OPER_CHAIN).value_int);
    BEGIN
        IF l_operation_chain_id IS NULL THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                                                    p_action => 'create_operation',
                                                    p_additional => 'Цепочка пустая');
            RETURN;
        END IF;
        
        IBS.API_OPERATION.COMPLETE_OPERATION_CHAIN(l_operation_chain_id);
        api_interbankpayments.add_payment_change(mobj => obj, 
                                                    p_action => 'create_operation',
                                                    p_additional => 'Завершаем цепочку операций' || l_operation_chain_id);
    END;
    
    MEMBER PROCEDURE create_operation IS
        l_operation_id			INTEGER;
        l_operation_chain_id    INTEGER;
        l_payer_id				INTEGER	DEFAULT get_payer_id();
        l_receiver_id			INTEGER	DEFAULT get_receiver_id();
        l_temp                  NUMBER;
        l_arrest_oper_id        INTEGER;
        l_is_inkasso            BOOLEAN DEFAULT obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_IS_ORDER_INKASSO_PAYMENT);
        l_is_order              BOOLEAN DEFAULT obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_IS_ORDER_PAYMENT);
        p_is_rs_acc_deb_acc     VARCHAR2(100) DEFAULT obj.get_attribute_val(CONST_INTERBANKPAYMENTS.ATTR_IS_RS_ACC_DEB).value_str;
        p_is_rs_acc_crd_acc     VARCHAR2(100) DEFAULT obj.get_attribute_val(CONST_INTERBANKPAYMENTS.ATTR_IS_RS_ACC_CRD).value_str;   
        p_is_rs_acc_deb_acc_id  INTEGER DEFAULT ibs.api_account.get_account_id(p_is_rs_acc_deb_acc);
        p_is_rs_acc_crd_acc_id  INTEGER DEFAULT ibs.api_account.get_account_id(p_is_rs_acc_crd_acc);
        l_wroff25               VARCHAR2(10)        DEFAULT NULL;
        l_acc_id                ibs.account.id%TYPE DEFAULT ibs.api_account.get_account_id(SELF.obj.PAYER_ACCOUNT);
        l_operation             ibs.operation%ROWTYPE;
    BEGIN
        -- У платежа может быть только одна операция
        IF SELF.obj.OPERATION_ID IS NOT NULL THEN
            l_operation := ibs.api_operation.read_operation(SELF.obj.OPERATION_ID, p_is_raise_ndf => FALSE);
            IF l_operation.id IS NOT NULL THEN
                ibs.api_operation.remove_operation_chain(l_operation.operation_chain_id, 
                                                         'New operation for Outgoing payment ' || SELF.obj.ID);
            END IF;
        END IF;
        
        IF obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_IS_WITHOUT_OPERATIONS) THEN
           api_interbankpayments.add_payment_change(mobj => obj, 
                                                       p_action => 'create_operation',
                                                       p_desc => 'Attribute without operations has been detected'
                                                       );
            RETURN;
        END IF;
        
        /*IF obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_IS_MANUAL_OPERATION) AND obj.OPERATION_ID IS NOT NULL THEN
            l_operation_id := obj.OPERATION_ID;
            api_interbankpayments.add_payment_change(mobj => obj, 
                                                       p_action => 'create_operation',
                                                       p_desc => 'Manual opertaion has been setted ',
                                                       p_additional => l_operation_id
                                                       );
        ELSE */
        l_temp := ibs.api_operation.create_operation(SELF.get_operation_object_id,
                                           ibs.const_deposit.OT_DUMMY_OPERATION, 
                                           l_operation_chain_id); 
        burn_operation();
        l_operation_id          := SELF.OBJ.OPERATION_ID;
        l_operation_chain_id    := SELF.OBJ.get_attribute_val(CONST_INTERBANKPAYMENTS.ATTR_SETTELMENT_OPER_CHAIN).value_int;
        --END IF;
        
        -- Если платеж с предыдущего дня и что для того чтобы исключить косяки Ид из-за конвертации
        update_fee_collection();
        
        -- Первести красиво в 103 обработчик
        IF l_is_inkasso OR l_is_order THEN
            l_wroff25 := ibs.api_attribute.get_str_attribute_value(p_object_id => l_acc_id,
                                                                   p_attribute_id => ibs.const_account.ATR_ACCOUNT_USER_TYPE);
            IF l_wroff25 IS NOT NULL THEN
                ibs.api_attribute.set_attribute_value(p_object_id => l_acc_id,
                                                      p_attribute_id => ibs.const_account.ATR_ACCOUNT_USER_TYPE,
                                                      p_value => REPLACE(l_wroff25, ibs.const_obi.UT_ACC_WROFF25, ''));
            END IF;
            
            api_interbankpayments.add_payment_change(mobj => obj, 
                                                    p_action => 'create_operation',
                                                    p_additional => 'Установлен атрибут Инкассо {'||
                                                        SYS.DIUTIL.BOOL_TO_INT(l_is_inkasso)  
                                                    ||'} или Серенджам{'|| 
                                                        SYS.DIUTIL.BOOL_TO_INT(l_is_order)  
                                                    ||'}');
            CASE WHEN l_is_order THEN
                    l_temp := ibs.api_serengam.Sign_V_Account(SELF.obj.PAYER_ACCOUNT, 0);
                    api_interbankpayments.add_payment_change(mobj => obj, 
                                                        p_action => 'create_operation',
                                                        p_additional => 'Вызов api_serengam.Sign_V_Account - 0');
                 ELSE 
                     l_temp := ibs.api_incasso.Sign_I_Account(SELF.obj.PAYER_ACCOUNT, 0, l_operation_chain_id);
                     api_interbankpayments.add_payment_change(mobj => obj, 
                                                        p_action => 'create_operation',
                                                        p_additional => 'Вызов api_incasso.Sign_I_Account - 0');
            END CASE;
            l_arrest_oper_id := ibs.api_account.account_arrests(SELF.obj.PAYER_ACCOUNT,0,NULL, l_operation_chain_id,0);    
            api_interbankpayments.add_payment_change(mobj => obj, 
                                                p_action => 'create_operation',
                                                p_additional => 'Сняли арест со счета' 
                                                                || SELF.obj.PAYER_ACCOUNT || 
                                                                '. ID операции снятия ареста: ' || l_arrest_oper_id);
        /*END IF;
        
        IF l_is_inkasso OR l_is_order THEN*/
            -- Ð¡Ð´ÐµÐ»Ð°Ñ‚ÑŒ Ð¿Ñ€Ð¾Ð²ÐµÑ€ÐºÐ¸ Ð½Ð° Ð½Ð°Ð»Ð¸Ñ‡Ð¸Ðµ Ð²ÑÐµÑ… Ð½ÑƒÐ¶Ð½Ñ‹Ñ… Ð´Ð°Ð½Ð½Ñ‹Ñ…
            ibs.api_settlement.settlement_transaction(p_is_rs_acc_deb_acc_id,
                                                      p_is_rs_acc_crd_acc_id,
                                                      ibs.t_amount(SELF.obj.AMOUNT, SELF.obj.CURRENCY),
                                                      NULL,
                                                      NULL,
                                                      l_operation_id,
                                                      l_operation_chain_id,
                                                      REPLACE(obj.get_attribute_val(CONST_INTERBANKPAYMENTS.ATTR_IS_RS_GROUND).value_str, chr(13) || chr(10),' '),
                                                      NULL,
                                                      NULL);
            IF obj.FEE_COLLECTION IS NOT NULL AND obj.FEE_COLLECTION.count > 0 THEN
                l_temp := obj.FEE_COLLECTION.FIRST;
                WHILE l_temp IS NOT NULL
                LOOP
                    obj.FEE_COLLECTION(l_temp).ground := obj.AMOUNT || ' ' || obj.CURRENCY_CODE || ' köçürməyə görə komissiya';
                    l_temp := obj.FEE_COLLECTION.next(l_temp);
                END LOOP;
            END IF;
            api_interbankpayments.add_payment_change(mobj => obj, 
                                                p_action => 'create_operation',
                                                p_additional => 'Проводка для RS по дебет счету {' 
                                                                -- ÐÐ¸ÐºÐ°ÐºÐ¾Ð³Ð¾ Ð¶ÐµÐ»Ð°Ð½Ð¸Ñ ÑÐ¾Ð·Ð´Ð°Ð²Ð°Ñ‚ÑŒ Ð¿ÐµÑ€ÐµÐ¼ÐµÐ½Ð½Ñ‹Ðµ Ð½ÐµÑ‚ :(
                                                                || p_is_rs_acc_deb_acc || 
                                                                '} и кредит счету {' 
                                                                || p_is_rs_acc_crd_acc || '} создана ');
        END IF;
        
        
        
        
        -- Ð¡Ð½Ð¸Ð¼Ð°ÐµÐ¼ Ð±Ð»Ð¾ÐºÐ¸Ñ€Ð¾Ð²ÐºÑƒ ÑÐ¾ ÑÑ‡ÐµÑ‚Ð° Ð½Ð° ÑÑƒÐ¼Ð¼Ð° Ð¿Ð»Ð°Ñ‚ÐµÐ¶ÐºÐ¸
        jui_interbankpayments_tools.unfreeze_amount(SELF);
        api_interbankpayments.add_payment_change(mobj => obj, 
                                                    p_action => 'create_operation',
                                                    p_additional => 'Сняли блокировку суммы со счета');

        ibs.api_settlement.settlement_transaction(l_payer_id,
                                                  l_receiver_id, 
                                                  ibs.t_amount(obj.AMOUNT, obj.CURRENCY),
                                                  null,
                                                  null,
                                                  l_operation_id,
                                                  l_operation_chain_id,
                                                  get_main_operation_ground,
                                                  null,
                                                  null);
                                                  
        api_interbankpayments.add_payment_change(mobj => obj, 
                                                    p_action => 'create_operation',
                                                    p_additional => 'Проводка по счетам плательщика и получателя');
        
		update_attribute(T_INTBANKPAYS_ATTR(CONST_INTERBANKPAYMENTS.ATTR_SETTELMENT_PAYER_ID, 	p_value_int => l_payer_id));
        pay_fee();
        
        IF l_is_inkasso OR l_is_order THEN
            CASE WHEN l_is_order THEN
                    l_temp := ibs.api_serengam.Sign_V_Account(SELF.obj.PAYER_ACCOUNT, 1);
                    api_interbankpayments.add_payment_change(mobj => obj, 
                                                        p_action => 'create_operation',
                                                        p_additional => 'Вызов api_serengam.Sign_V_Account - 1');
                 ELSE 
                     l_temp := ibs.api_incasso.Sign_I_Account(SELF.obj.PAYER_ACCOUNT, 1, l_operation_chain_id);
                     api_interbankpayments.add_payment_change(mobj => obj, 
                                                        p_action => 'create_operation',
                                                        p_additional => 'Вызов api_incasso.Sign_I_Account - 1');
            END CASE;
        /*END IF;
        
        
                                                                    
        IF l_is_inkasso OR l_is_order THEN*/
            -- Ð£ÑÑ‚Ð°Ð½Ð°Ð²Ð»Ð¸Ð²Ð°ÐµÐ¼ Ð°Ñ€ÐµÑÑ‚ Ð·Ð°Ð½Ð¾Ð²Ð¾
            l_arrest_oper_id := ibs.api_account.account_arrests( SELF.OBJ.PAYER_ACCOUNT,
                                                                    1,
                                                                    NULL,
                                                                    l_operation_chain_id,
                                                                    to_number(obj.get_attribute_val(CONST_INTERBANKPAYMENTS.ATTR_IS_RS_ARREST_SUM).value_str)
                                                                    ,TRUE);
            api_interbankpayments.add_payment_change(mobj => obj, 
                                                    p_action => 'create_operation',
                                                    p_additional => 'Установили арест на счет ' 
                                                                    || SELF.obj.PAYER_ACCOUNT || 
                                                                    '. ID операции снятия ареста: ' || l_arrest_oper_id);
            CASE WHEN l_is_order THEN
                    ibs.api_serengam.Check_Rest_Vn(SELF.OBJ.PAYER_ACCOUNT);   
                    api_interbankpayments.add_payment_change(mobj => obj, 
                                                    p_action => 'create_operation',
                                                    p_additional => 'Вызов ibs.api_serengam.Check_Rest_Vn');  
                 ELSE 
                    ibs.api_incasso.Check_Rest_Vn_Incasso(SELF.OBJ.PAYER_ACCOUNT, l_operation_chain_id);   
                    api_interbankpayments.add_payment_change(mobj => obj, 
                                                        p_action => 'create_operation',
                                                        p_additional => 'Вызов ibs.api_incasso.Check_Rest_Vn_Incasso');
            END CASE;
        END IF;
        
        SELF.complete_operation_chain(l_operation_chain_id);
        
        IF l_wroff25 IS NOT NULL THEN
            ibs.api_attribute.set_attribute_value(p_object_id => l_acc_id,
                                                  p_attribute_id => ibs.const_account.ATR_ACCOUNT_USER_TYPE,
                                                  p_value => l_wroff25);
        END IF;
        
        api_interbankpayments.add_payment_change(mobj => obj, 
                                                    p_action => 'create_operation',
                                                    p_additional => 'Завершаем цепочку операций ' || l_operation_chain_id);
    END;
    
    MEMBER FUNCTION get_payer_id (SELF IN OUT T_INTBANKPAYS_MSG) RETURN INTEGER IS 
    BEGIN RETURN ibs.api_account.get_account_for_settelment_id(obj.PAYER_ACCOUNT); END;
    
    MEMBER PROCEDURE get_corr_acc_id(p_corr_id IN OUT INTEGER) IS 
    BEGIN
        NULL;
    END;
    
    MEMBER FUNCTION get_receiver_id(SELF IN OUT T_INTBANKPAYS_MSG) RETURN INTEGER IS 
        l_cor VARCHAR2(50);
    BEGIN
    	IF obj.SYSTEM_ID IS NULL OR obj.CURRENCY IS NULL THEN
            const_exceptions.raise_exception(const_exceptions.NO_CORACC_PSYS, obj.SYSTEM_ID || '', obj.CURRENCY || '' );
        END IF;
        
        SELECT a.ACCOUNT_NUMBER
        INTO l_cor
        FROM ibs.PAYMENT_COR_ACCOUNTS pca, ibs.ACCOUNT a
        WHERE pca.ACCOUNT_ID = a.ID AND pca.PAYMENT_SYSTEM_ID = obj.SYSTEM_ID AND pca.currency_id = obj.CURRENCY;

    	RETURN ibs.API_ACCOUNT.read_account(l_cor).id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           const_exceptions.raise_exception(const_exceptions.NO_CORACC_PSYS, obj.SYSTEM_ID || '', obj.CURRENCY || '' );
    END;

    
    MEMBER PROCEDURE pay_fee IS 
        l_operation_chain_id INTEGER DEFAULT obj.get_attribute_val(CONST_INTERBANKPAYMENTS.ATTR_SETTELMENT_OPER_CHAIN).value_int;
        l_indx  INTEGER;
    BEGIN
        IF obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_IS_WITHOUT_FEE) THEN RETURN; END IF;
        IF obj.FEE_COLLECTION IS NOT NULL AND obj.FEE_COLLECTION.count > 0 THEN
            
            l_indx := obj.FEE_COLLECTION.FIRST;
            -- ÐžÐºÑ€ÑƒÐ³Ð»ÑÐµÐ¼ Ð¿ÐµÑ€ÐµÐ´ Ð¾Ð¿Ð»Ð°Ñ‚Ð¾Ð¹ ÐºÐ¾Ð¼Ð¸ÑÑÐ¸Ð¹
            WHILE l_indx IS NOT NULL
            LOOP
                obj.FEE_COLLECTION(l_indx).fee_amount := ROUND(obj.FEE_COLLECTION(l_indx).fee_amount, 4);
                l_indx := obj.FEE_COLLECTION.next(l_indx);
            END LOOP;
        
            ibs.api_settlement.pay_fee(SELF.get_fee_payer_id(),
                                       obj.FEE_COLLECTION,
                                       obj.OPERATION_ID,
                                       l_operation_chain_id,
                                       null,
                                       null,
                                       p_parent_id => ibs.api_document.get_last_doc(l_operation_chain_id));
        END IF;
    END;
    
    MEMBER FUNCTION get_fee_payer_id(SELF IN OUT T_INTBANKPAYS_MSG) RETURN INTEGER
    IS BEGIN 
        RETURN obj.get_attribute_val(CONST_INTERBANKPAYMENTS.ATTR_SETTELMENT_PAYER_ID).value_int;
    END;
      
    MEMBER FUNCTION set_state(SELF IN OUT T_INTBANKPAYS_MSG, p_var IN INTEGER) RETURN BOOLEAN IS
        l_var       INTEGER DEFAULT p_var;
        l_result    BOOLEAN DEFAULT TRUE;
    BEGIN
        -- ÐšÐ¾ÑÑ‚Ñ‹Ð»ÑŒ, Ð½Ð°Ð´Ð¾ Ð¿Ð¾Ð´ÑƒÐ¼Ð°Ñ‚ÑŒ
        IF SELF.obj.STATE NOT IN (const_interbankpayments.STATE_PROVIDER_SENT, 
                                  const_interbankpayments.STATE_PROVIDER_ERROR, 
                                  const_interbankpayments.STATE_PROVIDER_IN_QUEEE,
                                  const_interbankpayments.STATE_PROVIDER_B_ERROR,
                                  const_interbankpayments.STATE_PROVIDER_NOTFOUND,
                                  const_interbankpayments.STATE_IB_WAITING,
                                  const_interbankpayments.STATE_IB_TIMEOUT)
        THEN 
            -- /ÐšÐ¾ÑÑ‚Ñ‹Ð»ÑŒ Ð·Ð°ÐºÐ¾Ð½Ñ‡Ð¸Ð»ÑÑ
            BEGIN api_interbankpayments_access.has_state_grand(SELF.obj.MESSAGE_TYPE, l_var);
            EXCEPTION WHEN OTHERS THEN
                const_exceptions.raise_exception(const_exceptions.NO_ACC_STAT_CH, 
                                                 ibs.api_context.get_def_user || '', 
                                                 SELF.obj.MESSAGE_TYPE || '',
                                                 l_var || '');
            END;
        END IF;
        
        IF jui_interbankpayments_tools.is_IB_user(ibs.api_context.get_def_user)
            AND NOT jui_interbankpayments_tools.check_ib_time_availablity(SELF.obj) THEN
            api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                               p_action => 'T_INTBANKPAYS_MSG.set_state', 
                               p_additional => 'Время для перевода платежа из ИБ истекло - переведено в статус ожидание');
            l_var := const_interbankpayments.STATE_IB_WAITING;
            l_result := FALSE;
        END IF;
        
        check_state(l_var);
        
        IF l_var = const_interbankpayments.STATE_COMPLETED THEN
            SELF.remove_attribute(const_interbankpayments.ATTR_CBAR_RESP_ERROR_MSG);
        END IF;
        
        
        
        IF obj.PAYMENT_DATE < TRUNC(SYSDATE) THEN
            SELF.set_payment_date(ibs.api_calendar.get_work_day(TRUNC(SYSDATE)));
            api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                               p_action => 'T_INTBANKPAYS_MSG.set_state', 
                               p_additional => 'Дата платежа отлична от текущей банковской - переводим на следующий банковский день');
        END IF;
        
        obj.STATE := l_var;
        obj.add_state_history(l_var, ibs.api_context.get_def_user, SYSDATE);
        
        RETURN l_result;
    END;
    
    MEMBER FUNCTION generate_fee_ground(p_fee ibs.t_fee_amount) RETURN VARCHAR IS
        l_result VARCHAR2(2000);
    BEGIN
        IF p_fee.fee_id = const_interbankpayments.FEE_KIND_URGENT THEN
            l_result := REPLACE(const_interbankpayments.FEE_URG_DEFGROUND, ':SUM:', self.obj.AMOUNT || ' ' || ibs.api_currency.get_iso_name(self.obj.CURRENCY));
        ELSE l_result := REPLACE(const_interbankpayments.FEE_DEFGROUND, ':SUM:', self.obj.AMOUNT || ' ' || ibs.api_currency.get_iso_name(self.obj.CURRENCY));
        END IF;
        IF jui_interbankpayments_tools.is_IB_payment(SELF.obj) THEN
            l_result := l_result || '(Internet Banking)';
        END IF;
        RETURN l_result;
    END;
    
    MEMBER PROCEDURE set_fee_collection (p_fee_kind INTEGER)
    IS l_fee ibs.t_fee_amount;
    BEGIN
--      raise_application_error(-20000, l_fee.currency_id);
        l_fee := ibs.api_tariff.get_fee(p_fee_kind,
                                        NULL,
                                        NULL,
                                        NULL,
                                        SELF.obj.AMOUNT,
                                        SELF.obj.CURRENCY,
                                        NULL,
                                        NULL);
        l_fee.ground := generate_fee_ground(l_fee);
        
        
        
        IF l_fee IS NULL THEN 
            const_exceptions.raise_exception(const_exceptions.PAYER_ACC_NO, p_fee_kind || '');
        END IF;
        
        l_fee.account_id := SELF.get_account_id;
        SELF.OBJ.FEE_COLLECTION.extend;
        SELF.OBJ.FEE_COLLECTION(SELF.OBJ.FEE_COLLECTION.last) := l_fee;
    END;
    
    MEMBER FUNCTION is_incountry_payment(SELF IN OUT T_INTBANKPAYS_MSG) RETURN BOOLEAN IS
    BEGIN
        RETURN JUI_INTERBANKPAYMENTS_TOOLS.IS_COUNTRY_BANK(SELF.obj.BENEFICIAR_BANK_SWIFT);
    END;
    
    MEMBER FUNCTION is_outcountry_payment(SELF IN OUT T_INTBANKPAYS_MSG) RETURN BOOLEAN IS
    BEGIN
        RETURN NOT JUI_INTERBANKPAYMENTS_TOOLS.IS_COUNTRY_BANK(SELF.obj.BENEFICIAR_BANK_SWIFT);
    END;
    
    MEMBER FUNCTION check_data_before_feeupdating(SELF IN OUT T_INTBANKPAYS_MSG) RETURN BOOLEAN IS
    BEGIN
        IF  SELF.OBJ.PAYER_ACCOUNT IS NULL OR 
            SELF.obj.AMOUNT IS NULL OR 
            SELF.obj.CURRENCY IS NULL OR
            SELF.obj.BENEFICIAR_BANK_SWIFT IS NULL
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
    
    MEMBER PROCEDURE genereate_fees_by_rules(l_fee_kind IN OUT ibs.t_integer_collection, p_special_fee OUT ibs.t_fee_amount) IS
        l_subject_form  INTEGER;
        l_account_row   ibs.account%rowtype;
        l_spec_id       INTEGER;
    BEGIN
        IF NOT check_data_before_feeupdating THEN RETURN; END IF;

        l_account_row   := ibs.api_account.read_account(SELF.OBJ.PAYER_ACCOUNT);
        l_subject_form  := ibs.api_subject.get_subject_legal_form(l_account_row.owner_id);
        
        -- Если платеж внутри страны
        IF is_incountry_payment() THEN
            -- Если интернет-банкинг платеж
            IF jui_interbankpayments_tools.is_IB_payment(SELF.obj) THEN
                api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                                                   p_action => 'jui_interbankpayments_tools.update_fee_collection',
                                                   p_additional => 'Расчет по комиссии в пределах страны для интернет-банкинга');
                --Для физиков интернет-банкинг
                IF l_subject_form = IBS.CONST_SUBJECT.LEGAL_FORM_PERSON THEN
                    l_fee_kind.extend;
                    l_fee_kind(l_fee_kind.last) := CONST_INTERBANKPAYMENTS.FEE_KIND_INCNTR_PHS_IB; 
                    api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                                                   p_action => 'jui_interbankpayments_tools.update_fee_collection',
                                                   p_additional => 'Комиссия для юр. лиц');   
                -- Ð”Ð»Ñ ÑŽÑ€Ð¸ÐºÐ¾Ð² Ð¸Ð½Ñ‚ÐµÑ€Ð½ÐµÑ‚-Ð±Ð°Ð½ÐºÐ¸Ð½Ð³
                ELSIF   l_subject_form IN (IBS.CONST_SUBJECT.LEGAL_FORM_COMPANY,IBS.CONST_SUBJECT.LEGAL_FORM_ENTERPRISER) THEN
                    l_fee_kind.extend;
                    l_fee_kind(l_fee_kind.last)  := CONST_INTERBANKPAYMENTS.FEE_KIND_INCNTR_JUR_IB;
                    api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                                                   p_action => 'jui_interbankpayments_tools.update_fee_collection',
                                                   p_additional => 'Комиссия для физ. лиц');
                END IF;
            -- Ð•ÑÐ»Ð¸ Ð½Ðµ Ð¸Ð½Ñ‚ÐµÑ€Ð½ÐµÑ‚-Ð±Ð°Ð½ÐºÐ¸Ð½Ð³ Ð¿Ð»Ð°Ñ‚ÐµÐ¶
            ELSE    
                api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                                                   p_action => 'jui_interbankpayments_tools.update_fee_collection',
                                                   p_additional => 'Расчет по комиссии в пределах страны');                
                l_spec_id := jui_interbankpayments_tools.get_special_fee_id(l_account_row.owner_id, 
                                                                            CONST_INTERBANKPAYMENTS.FEE_TYPES_INCNTR,
                                                                            SELF.obj.CURRENCY
                                                                            );
                IF l_spec_id IS NOT NULL THEN 
                    l_fee_kind.extend;
                    l_fee_kind(l_fee_kind.last) := l_spec_id;
                    api_interbankpayments.add_payment_change(mobj => SELF.obj, 
									   p_action => 'jui_interbankpayments_tools.update_fee_collection',
									   p_additional => 'Специальная комиссия для клиента внутри страны{' || 
															ibs.api_object.get_object_code(l_account_row.owner_id,
                                                                                           ibs.const_subject.CODE_KIND_CODE)|| 
															'}');
                -- Ð”Ð»Ñ Ñ„Ð¸Ð·Ð¸ÐºÐ¾Ð²
                ELSIF l_subject_form = IBS.CONST_SUBJECT.LEGAL_FORM_PERSON THEN
                    l_fee_kind.extend;
                    l_fee_kind(l_fee_kind.last)  := CONST_INTERBANKPAYMENTS.FEE_KIND_INCNTR_PHS;    
                    api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                                                   p_action => 'jui_interbankpayments_tools.update_fee_collection',
                                                   p_additional => 'Комиссия для юр. лиц');
                -- Ð”Ð»Ñ ÑŽÑ€Ð¸ÐºÐ¾Ð²
                ELSIF   l_subject_form IN (IBS.CONST_SUBJECT.LEGAL_FORM_COMPANY,IBS.CONST_SUBJECT.LEGAL_FORM_ENTERPRISER) THEN
                    l_fee_kind.extend;
                    l_fee_kind(l_fee_kind.last)  := CONST_INTERBANKPAYMENTS.FEE_KIND_INCNTR_JUR;
                    api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                                                   p_action => 'jui_interbankpayments_tools.update_fee_collection',
                                                   p_additional => 'Комиссия для физ. лиц');
                END IF;
            END IF;
        -- Ð•ÑÐ»Ð¸ Ð¿Ð»Ð°Ñ‚ÐµÐ¶ Ð·Ð° Ð¿Ñ€ÐµÐ´ÐµÐ»Ñ‹ ÑÑ‚Ñ€Ð°Ð½Ñ‹
        ELSE 
            
            -- Ð•ÑÐ»Ð¸ Ð¸Ð½Ñ‚ÐµÑ€Ð½ÐµÑ‚-Ð±Ð°Ð½ÐºÐ¸Ð½Ð³ Ð¿Ð»Ð°Ñ‚ÐµÐ¶
            IF jui_interbankpayments_tools.is_IB_payment(SELF.obj) THEN
                api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                                                   p_action => 'jui_interbankpayments_tools.update_fee_collection',
                                                   p_additional => 'Расчет по комиссии за пределы страны для интернет-банкинга');
                -- Ð”Ð»Ñ Ñ„Ð¸Ð·Ð¸ÐºÐ¾Ð² Ð¸Ð½Ñ‚ÐµÑ€Ð½ÐµÑ‚-Ð±Ð°Ð½ÐºÐ¸Ð½Ð³
                IF l_subject_form = IBS.CONST_SUBJECT.LEGAL_FORM_PERSON THEN
                    l_fee_kind.extend;
                    l_fee_kind(l_fee_kind.last)  := CONST_INTERBANKPAYMENTS.FEE_KIND_OUTCNTR_PHS_IB;  
                    api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                                                   p_action => 'jui_interbankpayments_tools.update_fee_collection',
                                                   p_additional => 'Комиссия для юр. лиц');  
                -- Ð”Ð»Ñ ÑŽÑ€Ð¸ÐºÐ¾Ð² Ð¸Ð½Ñ‚ÐµÑ€Ð½ÐµÑ‚-Ð±Ð°Ð½ÐºÐ¸Ð½Ð³
                ELSIF   l_subject_form IN (IBS.CONST_SUBJECT.LEGAL_FORM_COMPANY,IBS.CONST_SUBJECT.LEGAL_FORM_ENTERPRISER) THEN
                    l_fee_kind.extend;
                    l_fee_kind(l_fee_kind.last)  := CONST_INTERBANKPAYMENTS.FEE_KIND_OUTCNTR_JUR_IB;
                    api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                                                   p_action => 'jui_interbankpayments_tools.update_fee_collection',
                                                   p_additional => 'Комиссия для физ. лиц');
                END IF;
            -- Ð•ÑÐ»Ð¸ Ð½Ðµ Ð¸Ð½Ñ‚ÐµÑ€Ð½ÐµÑ‚-Ð±Ð°Ð½ÐºÐ¸Ð½Ð³ Ð¿Ð»Ð°Ñ‚ÐµÐ¶
            ELSE
                api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                                                   p_action => 'jui_interbankpayments_tools.update_fee_collection',
                                                   p_additional => 'Расчет по комиссии за пределы страны');
                l_spec_id := jui_interbankpayments_tools.get_special_fee_id(l_account_row.owner_id, 
                                                                            CONST_INTERBANKPAYMENTS.FEE_TYPES_OUTCNTR,
                                                                            SELF.obj.CURRENCY);
                IF l_spec_id IS NOT NULL THEN 
                    l_fee_kind.extend;
                    l_fee_kind(l_fee_kind.last) := l_spec_id;
                    api_interbankpayments.add_payment_change(mobj => SELF.obj, 
									   p_action => 'jui_interbankpayments_tools.update_fee_collection',
									   p_additional => 'Специальная комиссия для клиента за пределы страны{' || 
															ibs.api_object.get_object_code(l_account_row.owner_id,ibs.const_subject.CODE_KIND_CODE)|| 
															'}');
                -- Ð”Ð»Ñ Ñ„Ð¸Ð·Ð¸ÐºÐ¾Ð²
                ELSIF l_subject_form = IBS.CONST_SUBJECT.LEGAL_FORM_PERSON THEN
                    l_fee_kind.extend;
                    l_fee_kind(l_fee_kind.last)  := CONST_INTERBANKPAYMENTS.FEE_KIND_OUTCNTR_PHS;
                    api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                                                   p_action => 'jui_interbankpayments_tools.update_fee_collection',
                                                   p_additional => 'Комиссия для юр. лиц');     
                -- Ð”Ð»Ñ ÑŽÑ€Ð¸ÐºÐ¾Ð²
                ELSIF   l_subject_form IN (IBS.CONST_SUBJECT.LEGAL_FORM_COMPANY, IBS.CONST_SUBJECT.LEGAL_FORM_ENTERPRISER) THEN
                    l_fee_kind.extend;
                    l_fee_kind(l_fee_kind.last)  := CONST_INTERBANKPAYMENTS.FEE_KIND_OUTCNTR_JUR;
                     api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                                                   p_action => 'jui_interbankpayments_tools.update_fee_collection',
                                                   p_additional => 'Комиссия для физ. лиц');
                END IF;
            END IF;
        END IF;
    END;
    
    MEMBER PROCEDURE update_fee_collection 
    IS 
        l_fee_kind      ibs.t_integer_collection DEFAULT ibs.t_integer_collection();
        l_manual_fee    ibs.t_fee_amount DEFAULT NULL;
    BEGIN

        IF SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_IS_URGENCY) THEN   
           api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                           p_action => 'jui_interbankpayments_tools.update_fee_collection',
                           p_additional => 'Установлен атрибут "Срочность"');
           l_fee_kind.extend;
           l_fee_kind(l_fee_kind.last) := CASE WHEN obj.isset_attribute(const_interbankpayments.ATTR_IS_IB) 
                                                    THEN CONST_INTERBANKPAYMENTS.FEE_KIND_URGENT_IB
                                               ELSE CONST_INTERBANKPAYMENTS.FEE_KIND_URGENT
                                          END;
        END IF;
    
        IF SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_IS_WITHOUT_FEE) THEN
            SELF.obj.FEE_COLLECTION := ibs.t_fee_amount_collection();
            l_fee_kind.delete;
            api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                           p_action => 'jui_interbankpayments_tools.update_fee_collection',
                           p_additional => 'Payment setted without fee');
        ELSIF SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_IS_MANUAL_FEE) THEN
             l_manual_fee := obj.get_fee_by_kind(const_interbankpayments.FEE_KIND_MANUAL);
             api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                           p_action => 'jui_interbankpayments_tools.update_fee_collection',
                           p_additional => 'Fee setted manually');
        ELSE SELF.genereate_fees_by_rules(l_fee_kind, l_manual_fee);
        END IF;

        --Учитывать ручной ввод
        SELF.OBJ.FEE_COLLECTION.delete;
        IF l_fee_kind.count > 0 THEN
            FOR indx IN l_fee_kind.FIRST .. l_fee_kind.LAST
            LOOP
                SELF.set_fee_collection(l_fee_kind(indx));
            END LOOP;
        END IF;
        IF l_manual_fee IS NOT NULL THEN 
            SELF.obj.FEE_COLLECTION.extend;
            SELF.obj.FEE_COLLECTION(SELF.obj.FEE_COLLECTION.last) := l_manual_fee;
        END IF;
    END;
    
    MEMBER FUNCTION get_account_id (SELF IN OUT T_INTBANKPAYS_MSG, p_raise BOOLEAN DEFAULT FALSE) RETURN INTEGER
    IS 
        l_account_row   ibs.account%rowtype; 
        l_balance       varchar2(20);
        l_legal_form    integer;
        l_parsed        varchar2(50);
    BEGIN
       IF SELF.OBJ.PAYER_ACCOUNT IS NULL THEN
            IF p_raise THEN  const_exceptions.raise_exception(const_exceptions.PAYER_ACC_NO); ELSE RETURN NULL; END IF;
        END IF;
        IF SELF.OBJ.CURRENCY IS NULL THEN
            IF p_raise THEN const_exceptions.raise_exception(const_exceptions.NO_CURRENCY);  ELSE RETURN NULL; END IF;
        END IF;
        
        l_account_row   := ibs.api_account.read_account(SELF.OBJ.PAYER_ACCOUNT);
        l_legal_form    := ibs.api_subject.get_subject_legal_form(l_account_row.owner_id);
        
        l_balance := ibs.api_account.get_balance_account(IBS.CONST_OBJECT.OT_PAYMENT,
                                                        NULL,
                                                        CONST_INTERBANKPAYMENTS.ACC_CAT_IN_FEE_IPAYMENTS,
                                                        l_legal_form,
                                                        CASE WHEN SELF.OBJ.CURRENCY = IBS.CONST_CURRENCY.CURRENCY_AZN THEN false ELSE true END,
                                                        NULL,
                                                        NULL,
                                                        NULL,
                                                        NULL);

         l_parsed := cat_acc_tpl_parse(l_balance, 
                                        IBS.API_CURRENCY.get_code_in_account(SELF.OBJ.CURRENCY), 
                                        get_account_tpl_lgform(l_legal_form), 
                                        ibs.api_branch.get_code_in_account(CASE WHEN jui_interbankpayments_tools.is_IB_payment(SELF.OBJ) THEN  
                                                                                     ibs.const_branch.BRANCH_NEYMETULLA
                                                                                ELSE SELF.OBJ.PAYER_BRANCH_ID
                                                                           END)
                                        );
         RETURN IBS.API_ACCOUNT.GET_ACCOUNT_ID(l_parsed);
    END;    
    
    MEMBER FUNCTION cat_acc_tpl_parse(p_blns VARCHAR2, p_cur VARCHAR2, p_lgform VARCHAR2, p_branch VARCHAR2, p_tt VARCHAR2 DEFAULT NULL) RETURN VARCHAR2
    IS 
        l_bln_acc   varchar2(30) DEFAULT CONST_INTERBANKPAYMENTS.ACC_CAT_IN_FEE_IPAYMENTS_TPL;
        l_tt        VARCHAR(10) DEFAULT nvl(p_tt, '00000');
    BEGIN
        IF p_blns IS NULL THEN
            raise_application_error(IBS.CONST_EXCEPTION.GENERAL_ERROR, 'Не возможно получить счет доходов по комиссиям - не установленна категория учета балансовых счетов. 
                                                                        Платеж {' || SELF.OBJ.ID ||'}');
        END IF;
        IF p_cur IS NULL THEN
            raise_application_error(IBS.CONST_EXCEPTION.GENERAL_ERROR, 'Не возможно получить счет доходов по комиссиям - не установленно значение валюты . 
                                                                        Платеж {' || SELF.OBJ.ID ||'}');
        END IF;
        IF p_lgform IS NULL THEN
            raise_application_error(IBS.CONST_EXCEPTION.GENERAL_ERROR, 'Не возможно получить счет доходов по комиссиям - не установлен legal form клиента. 
                                                                        Платеж {' || SELF.OBJ.ID ||'}');
        END IF;

        l_bln_acc := REPLACE(l_bln_acc, '|BLNC',    p_blns);
        l_bln_acc := REPLACE(l_bln_acc, '|CUR',     p_cur);
        l_bln_acc := REPLACE(l_bln_acc, '|TT',      l_tt);
        l_bln_acc := REPLACE(l_bln_acc, '|LGFORM',  p_lgform);
        l_bln_acc := REPLACE(l_bln_acc, '|BRANCH',  nvl(p_branch,''));
        RETURN l_bln_acc;
    END;
    
    MEMBER FUNCTION get_account_tpl_lgform(p_lg_form INTEGER DEFAULT NULL) RETURN VARCHAR2
    IS lg_form  INTEGER DEFAULT nvl(p_lg_form,ibs.api_subject.get_subject_legal_form(ibs.api_account.read_account(SELF.OBJ.PAYER_ACCOUNT).owner_id));
    BEGIN
        IF lg_form  = ibs.const_subject.LEGAL_FORM_PERSON THEN RETURN '03';
        ELSE RETURN '01';
        END IF;
    END;
    
    -- Возвращает платежную систему. Определяет автоматически на основе параметров платежа
    MEMBER FUNCTION get_system_id(SELF IN OUT T_INTBANKPAYS_MSG) RETURN INTEGER
    IS l_res INTEGER;
    BEGIN 
        IF SELF.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_IS_URGENCY)
            OR  SELF.obj.AMOUNT > 40000 AND SELF.obj.CURRENCY = 0 OR 
            SELF.obj.BENEFICIAR_BANK_SWIFT NOT IN ('CTREAZ24', 'CTREAZ22') 
            THEN
                l_res := CONST_INTERBANKPAYMENTS.PAYMENT_SYSTEM_ID_AZIPS;
        ELSIF(SELF.obj.AMOUNT < 40000 AND SELF.obj.CURRENCY = 0) OR 
              SELF.obj.BENEFICIAR_BANK_SWIFT NOT IN ('CTREAZ24', 'CTREAZ22') 
            THEN l_res := CONST_INTERBANKPAYMENTS.PAYMENT_SYSTEM_ID_XOHKS;
        ELSE l_res := CONST_INTERBANKPAYMENTS.PAYMENT_SYSTEM_ID_AZIPS;
        END IF; 
        RETURN l_res;
    END;
    
    MEMBER PROCEDURE set_payment_date(p_var IN DATE) IS 
    BEGIN 
        SELF.obj.PAYMENT_DATE := TRUNC(p_var);
        IF p_var IS NOT NULL THEN CHECK_DATE; END IF;
        api_interbankpayments.add_payment_change(mobj => obj,  
                                                p_action => 'set_payment_date',
                                                p_additional => p_var);
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                               p_action => 'set_payment_date', 
                               p_autonomus => TRUE,
                               p_result => SQLERRM || '',
                               p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;
    
    MEMBER PROCEDURE update_to_correct_bank_date(p_var DATE DEFAULT NULL) IS
    BEGIN
        obj.PAYMENT_DATE := TRUNC(ibs.api_calendar.get_work_day(TRUNC(nvl(p_var,obj.PAYMENT_DATE))));
        api_interbankpayments.add_payment_change(mobj => obj,  
                                                p_action => 'update_to_correct_bank_date',
                                                p_additional =>'Payment date update for correct bank date {' || obj.PAYMENT_DATE || '}');
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                               p_action => 'update_to_correct_bank_date', 
                               p_autonomus => TRUE,
                               p_result => SQLERRM || '',
                               p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;
    
    MEMBER PROCEDURE set_message_type(p_var IN INTEGER) IS 
    BEGIN 
        obj.MESSAGE_TYPE := p_var;
        CHECK_MSGTYPE;
        api_interbankpayments.add_payment_change(mobj => obj,  
                                                p_action => 'set_message_type',
                                                p_additional => p_var);
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                               p_action => 'set_message_type', 
                               p_autonomus => TRUE,
                               p_result => SQLERRM || '',
                               p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;
    
    MEMBER PROCEDURE set_amount(p_var IN NUMBER) IS 
        l_var NUMBER DEFAULT nvl(p_var, 0.0);
    BEGIN 
        SELF.obj.AMOUNT := l_var;
        CHECK_AMOUNT();
        IF SELF.obj.PAYER_ACCOUNT IS NOT NULL THEN SELF.CHECK_AMOUNT_ENOUGHT(); END IF;  
        update_fee_collection();
        api_interbankpayments.add_payment_change(  mobj => SELF.obj, 
                                                   p_action => 'set_amount', 
                                                   p_additional => l_var);     
        NULL;
    /*EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                               p_action => 'set_amount', 
                               p_autonomus => TRUE,
                               p_result => SQLERRM || '',
                               p_additional => dbms_utility.format_error_backtrace);
            RAISE;*/
    END;
    
    MEMBER PROCEDURE set_system_id(p_var IN INTEGER)
    IS BEGIN 
        SELF.obj.SYSTEM_ID := p_var;
        IF p_var IS NOT NULL THEN CHECK_SYSTEM_ID; END IF;
        api_interbankpayments.add_payment_change(mobj => obj,  
                                                p_action => 'set_system_id',
                                                p_additional => p_var);
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                               p_action => 'set_system_id', 
                               p_autonomus => TRUE,
                               p_result => SQLERRM || '',
                               p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;

    MEMBER PROCEDURE set_currency(p_var IN INTEGER) IS
    BEGIN 
        obj.CURRENCY := p_var;
        IF p_var IS NOT NULL THEN 
            CHECK_CURRENCY(); 
            IF SELF.obj.BENEFICIAR_BANK_CODE IS NOT NULL THEN
                set_bn_corr_acc(jui_interbankpayments_tools.get_bank_correspondent_account(p_code => SELF.obj.BENEFICIAR_BANK_CODE, 
                                                                                           p_currency => p_var));
             END IF;
        END IF;
        ------------------------------------------------------
        api_interbankpayments.add_payment_change(  mobj => obj, 
                                                   p_action => 'set_currency', 
                                                   p_additional => p_var);
        update_fee_collection();
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                               p_action => 'set_currency', 
                               p_autonomus => TRUE,
                               p_result => SQLERRM || '',
                               p_additional => dbms_utility.format_error_backtrace);
            RAISE;   
    END;
    
    MEMBER PROCEDURE set_fee(p_var IN ibs.t_fee_amount) IS 
    BEGIN 
        obj.remove_fee(const_interbankpayments.FEE_KIND_MANUAL);
        IF p_var IS NULL OR p_var.fee_id IS NULL OR p_var.fee_amount IS NULL OR nvl(p_var.fee_amount, 0) = 0.00 THEN
            remove_attribute(const_interbankpayments.ATTR_IS_MANUAL_FEE);
            api_interbankpayments.add_payment_change(mobj => obj, 
                                                       p_action => 'set_fee', 
                                                       p_additional => 'Manual fee has been removed');
            RETURN;
        END IF;
        CHECK_CURRENCY();
        ------------------------------------------------------
        IF obj.FEE_COLLECTION IS NULL THEN obj.FEE_COLLECTION := ibs.t_fee_amount_collection(); END IF;
        update_attribute(T_INTBANKPAYS_ATTR(id_attr => CONST_INTERBANKPAYMENTS.ATTR_IS_MANUAL_FEE, 
                                            value_str => NULL,  
                                            value_int => NULL));
        obj.FEE_COLLECTION.extend;
        obj.FEE_COLLECTION(obj.FEE_COLLECTION.last) := p_var;
        CHECK_AMOUNT_ENOUGHT();
        api_interbankpayments.add_payment_change(mobj => obj, 
                           p_action => 'set_fee', 
                           p_additional => ibs.to_.to_string(p_var));
    EXCEPTION
    WHEN OTHERS THEN
        api_interbankpayments.add_payment_change(mobj => obj, 
                           p_action => 'set_fee', 
                           p_autonomus => TRUE,
                           p_result => SQLERRM || '',
                           p_additional => dbms_utility.format_error_backtrace);
        RAISE;
    END;
    
    MEMBER FUNCTION full_normalize(p_text VARCHAR2, p_max_line INTEGER, p_chr_per_line INTEGER DEFAULT 35, p_swift_chr VARCHAR DEFAULT 'x') 
    RETURN VARCHAR2 IS
    BEGIN
        RETURN normalize(jui_interbankpayments_tools.normilize(regexp_replace( api_interbankpayments.translit_to_swift(p_text), 
                                                                               api_interbankpayments.as_swift_charset(p_swift_chr), 
                                                                               '')),
                         p_chr_per_line, 
                         p_max_line);
    END;
    
    MEMBER FUNCTION normalize(p_text VARCHAR2, p_chr_per_line INTEGER, p_max_line INTEGER) RETURN VARCHAR2 IS
        l_var       VARCHAR2(5000) DEFAULT NULL;
        l_coll      ibs.t_clob_collection;
        l_ind       INTEGER;
    BEGIN
        IF p_text IS NULL THEN RETURN NULL; END IF;
        l_coll := ibs.regexp_match_clob_collection('([^\r\n]+)', p_text);
        IF l_coll IS NOT NULL THEN
            l_ind := l_coll.FIRST;
            WHILE l_ind IS NOT NULL
            LOOP
                IF l_var IS NOT NULL THEN l_var := l_var || /*chr(13) || */chr(10) ; END IF;
                l_var := l_var || jui_interbankpayments_tools.TRIMMING(SUBSTR(l_coll(l_ind), 0, p_chr_per_line));
                IF l_ind = p_max_line THEN EXIT; END IF;
                l_ind := l_coll.next(l_ind);
            END LOOP;
        END IF;
        RETURN l_var;
    END;
    
    MEMBER FUNCTION get_addinfo_max_lines_count RETURN INTEGER IS
    BEGIN RETURN const_interbankpayments.CFG_DEF_ADDI_MAXLINES; END;
    
    MEMBER FUNCTION get_ground_max_lines_count RETURN INTEGER IS
    BEGIN RETURN const_interbankpayments.CFG_DEF_GROUND_MAXLINES; END;
    
    --Устанавливает основание платежа
    MEMBER PROCEDURE set_ground(p_var IN VARCHAR2) IS
        l_var VARCHAR2(5000) DEFAULT p_var;
    BEGIN
        SELF.obj.GROUND := CASE WHEN l_var IS NOT NULL THEN full_normalize(l_var, get_ground_max_lines_count()) ELSE NULL END;
        IF l_var IS NOT NULL THEN CHECK_GROUND(); END IF;
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
    MEMBER PROCEDURE set_operation_id(p_var IN INTEGER) IS 
    BEGIN 
        update_attribute(T_INTBANKPAYS_ATTR(CONST_INTERBANKPAYMENTS.ATTR_IS_MANUAL_OPERATION, NULL,  value_int => 1));
        obj.OPERATION_ID := p_var;
        IF p_var IS NOT NULL THEN CHECK_MANUAL_OPID(); END IF;
        api_interbankpayments.add_payment_change(mobj => obj, 
                                               p_action => 'set_operation_id', 
                                               p_additional => p_var);
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                                                       p_action => 'set_operation_id', 
                                                       p_autonomus => TRUE,
                                                       p_result => SQLERRM || '',
                                                       p_additional => dbms_utility.format_error_backtrace);
            RAISE;                                           
    END;
    MEMBER PROCEDURE set_payer_account(p_var IN VARCHAR2) IS 
        l_account   ibs.account%ROWTYPE;
        l_var       VARCHAR2(5000) DEFAULT jui_interbankpayments_tools.TRIMMING(p_var);
    BEGIN 
        obj.PAYER_ACCOUNT := l_var;
        IF l_var IS NOT NULL THEN
            CHECK_PAYER_ACCOUNT();
            l_account := ibs.API_ACCOUNT.READ_ACCOUNT(l_var);
            set_payer_branch_id(l_account.branch_id); 
            --set_currency(l_account.CURRENCY_ID);
            IF obj.AMOUNT IS NOT NULL AND l_var IS NOT NULL THEN CHECK_AMOUNT_ENOUGHT(); END IF;
            api_interbankpayments.add_payment_change(mobj => obj, 
                                                     p_action => 'set_payer_account', 
                                                     p_additional => l_var);
            update_fee_collection();
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                               p_action => 'set_payer_account', 
                               p_autonomus => TRUE,
                               p_result => SQLERRM || '',
                               p_additional => dbms_utility.format_error_backtrace);
            RAISE;                                       
    END;
    
    -- Устанавливает имя получателя
    MEMBER PROCEDURE set_receiver_name(p_var IN VARCHAR2) IS
        l_var VARCHAR(150) DEFAULT jui_interbankpayments_tools.TRIMMING(api_interbankpayments.translit_to_swift(trim(p_var)));
    BEGIN 
        obj.RECEIVER_NAME := api_interbankpayments.translit_to_swift(regexp_replace(l_var,
                                                                     api_interbankpayments.as_swift_charset('x'),
                                                                     ''));
        IF l_var IS NOT NULL THEN CHECK_RECEIVER_NAME(); END IF;
        
        api_interbankpayments.add_payment_change(  mobj => obj, 
                                                   p_action => 'set_receiver_name', 
                                                   p_additional => l_var);
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                               p_action => 'set_receiver_name', 
                               p_autonomus => TRUE,
                               p_result => SQLERRM || '',
                               p_additional => dbms_utility.format_error_backtrace);
            RAISE;                                               
    END;
     
    MEMBER PROCEDURE set_receiver_iban (p_var IN VARCHAR2) IS 
        l_var VARCHAR2(5000) DEFAULT jui_interbankpayments_tools.TRIMMING(p_var);
    BEGIN 
        obj.RECEIVER_IBAN := l_var;
        IF l_var IS NOT NULL AND obj.BENEFICIAR_BANK_SWIFT IS NOT NULL THEN 
            CHECK_RECEIVER_IBAN(); 
        END IF;
        api_interbankpayments.add_payment_change(  mobj => obj, 
                                                   p_action => 'set_receiver_iban', 
                                                   p_additional => l_var);
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                               p_action => 'set_receiver_iban', 
                               p_autonomus => TRUE,
                               p_result => SQLERRM || '',
                               p_additional => dbms_utility.format_error_backtrace);
            RAISE;                                         
    END;
    
    MEMBER PROCEDURE set_receiver_tax (p_var IN VARCHAR2) IS
        l_var VARCHAR2(5000) DEFAULT jui_interbankpayments_tools.TRIMMING(p_var);
    BEGIN
        obj.RECEIVER_TAX := l_var; 
        IF l_var IS NOT NULL THEN CHECK_RECEIVER_TAX(); END IF;
        api_interbankpayments.add_payment_change(mobj => obj, 
                                                   p_action => 'set_receiver_tax', 
                                                   p_additional => l_var);
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                               p_action => 'set_receiver_tax', 
                               p_autonomus => TRUE,
                               p_result => SQLERRM || '',
                               p_additional => dbms_utility.format_error_backtrace);
            RAISE;                                               
    END;
    
    MEMBER PROCEDURE set_emitent_bank_corr_acc(p_var IN VARCHAR2) IS
        l_var VARCHAR2(5000) DEFAULT jui_interbankpayments_tools.TRIMMING(p_var);
    BEGIN 
        obj.EMITENT_BANK_CORR_ACCOUNT := l_var;
        api_interbankpayments.add_payment_change(mobj => obj, 
                                                   p_action => 'set_emitent_bank_corr_acc', 
                                                   p_additional => l_var || '');
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                                                       p_action => 'set_emitent_bank_corr_acc',
                                                       p_autonomus => TRUE, 
                                                       p_result => SQLERRM || '',
                                                       p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;
    
    MEMBER PROCEDURE set_emitent_bank_code(p_var IN VARCHAR2, p_auto_branch_id BOOLEAN DEFAULT TRUE) IS
        l_br_id     INTEGER;
        l_var       VARCHAR2(5000) DEFAULT jui_interbankpayments_tools.TRIMMING(p_var);
    BEGIN 
        obj.EMITENT_BANK_CODE := l_var;
        api_interbankpayments.add_payment_change(mobj => obj, 
                                                   p_action => 'set_emitent_bank_code', 
                                                   p_additional => l_var || '');
        IF TRIM(l_var) IS NOT NULL THEN
            l_br_id := JUI_INTERBANKPAYMENTS_TOOLS.is_emitentbank_bob(l_var);
            IF l_br_id IS NOT NULL THEN IF p_auto_branch_id THEN set_payer_branch_id(l_br_id); END IF;
            ELSIF CONST_INTERBANKPAYMENTS.CFG_ACCEPT_NON_BOB_EM_BIKS = FALSE THEN
                    raise_application_error(IBS.CONST_EXCEPTION.GENERAL_ERROR,
                                            'Запрещено устанавливать БИК эмитента, не принадлежащий Bank Of Baku');
            END IF;
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                                                       p_action => 'set_emitent_bank_code',
                                                       p_autonomus => TRUE, 
                                                       p_result => SQLERRM || '',
                                                       p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;
    
    MEMBER PROCEDURE set_payer_branch_id(p_var IN INTEGER) IS
    BEGIN 
        obj.PAYER_BRANCH_ID := p_var;
        IF p_var IS NOT NULL THEN CHECK_BRANCH_ID(); END IF;
        api_interbankpayments.add_payment_change(mobj => obj, 
                                                   p_action => 'set_payer_branch_id', 
                                                   p_additional => p_var);
        
        set_emitent_bank_code(JUI_INTERBANKPAYMENTS_TOOLS.get_branch_bik(p_var), FALSE);
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                               p_action => 'set_payer_branch_id', 
                               p_autonomus => TRUE,
                               p_result => SQLERRM || '',
                               p_additional => dbms_utility.format_error_backtrace);
            RAISE;                                               
    END;
    
    MEMBER PROCEDURE set_beneficiar_bank_name (p_var IN VARCHAR2) IS 
        l_var VARCHAR2(100) DEFAULT jui_interbankpayments_tools.TRIMMING(p_var);
    BEGIN 
        obj.BENEFICIAR_BANK_NAME := UPPER(l_var);
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
    
    MEMBER PROCEDURE set_beneficiar_bank_code (p_var IN VARCHAR2) IS
        l_var               VARCHAR2(100) DEFAULT jui_interbankpayments_tools.TRIMMING(p_var);
        l_known_bank        bank_list%rowtype DEFAULT JUI_INTERBANKPAYMENTS_TOOLS.FIND_IN_BANKS_LIST_BY_BIK(l_var);
        l_known_bank_acc    VARCHAR2(200);
    BEGIN 
        obj.BENEFICIAR_BANK_CODE := l_var;
        
        IF l_known_bank.ID IS NOT NULL THEN
            set_beneficiar_bank_name(l_known_bank.BANK_NAME);
            set_beneficiar_bank_swift(l_known_bank.BANK_SWIFT, l_known_bank.ALETERNATIVE_SWIFT);
            set_beneficiar_bank_tax(l_known_bank.voen);
            
            IF SELF.obj.CURRENCY IS NOT NULL THEN
                set_bn_corr_acc(jui_interbankpayments_tools.get_bank_correspondent_account(p_code => p_var, p_currency => SELF.obj.CURRENCY));
            --Для обратной совместимости со старой версией
            ELSIF l_known_bank.corr_acc IS NOT NULL THEN
                set_bn_corr_acc(l_known_bank.corr_acc);
            END IF;
        ELSIF  l_var IS NULL THEN
            set_beneficiar_bank_name(NULL);
            set_beneficiar_bank_swift(NULL);
            set_beneficiar_bank_tax(NULL);
            set_beneficiar_bank_corr_acc(NULL);
        END IF;
        
        api_interbankpayments.add_payment_change(  mobj => obj, 
                                                   p_action => 'set_beneficiar_bank_code', 
                                                   p_additional => l_var);
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                               p_action => 'set_beneficiar_bank_code', 
                               p_autonomus => TRUE,
                               p_result => SQLERRM || '',
                               p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;

    MEMBER PROCEDURE set_beneficiar_bank_swift(p_var IN VARCHAR2, p_alt_swift IN VARCHAR2 DEFAULT NULL) IS 
        l_var       VARCHAR2(50) DEFAULT jui_interbankpayments_tools.TRIMMING(p_var);
        l_bank_list bank_list%rowtype;
    BEGIN
       IF p_alt_swift IS NOT NULL 
            THEN l_var := p_alt_swift;
            api_interbankpayments.add_payment_change(mobj => obj, 
                                                           p_action => 'set_beneficiar_bank_swift', 
                                                           p_additional => 'Alternative swift has been detected {' || p_alt_swift || '}');
       ELSIF obj.SYSTEM_ID IN (const_interbankpayments.PAYMENT_SYSTEM_ID_AZIPS, const_interbankpayments.PAYMENT_SYSTEM_ID_NPS) AND l_var IN ('XXXXXXXX')
            THEN l_var := 'XXXXXXXX';
                 api_interbankpayments.add_payment_change(mobj => obj, 
                                                           p_action => 'set_beneficiar_bank_swift', 
                                                           p_additional => 'Bank is {XXXXXXXX} AND SYSTEM is {' || obj.SYSTEM_ID || '} so swift overrided to {XXXXXXXX}');
       ELSIF obj.BENEFICIAR_BANK_CODE IN ('501004') AND obj.CURRENCY <> ibs.const_currency.CURRENCY_AZN 
            THEN l_var := 'XXXXXXXX';
                 api_interbankpayments.add_payment_change(mobj => obj, 
                                                           p_action => 'set_beneficiar_bank_swift', 
                                                           p_additional => 'Bank is {XXXXXXXX} AND CURRENCY is {' || obj.CURRENCY || '} so swift overrided to {XXXXXXXX}');
       END IF;
       
       obj.BENEFICIAR_BANK_SWIFT := UPPER(l_var);
       
        IF obj.BENEFICIAR_BANK_SWIFT IN ('CTREAZ22','CTREAZ24') AND 
            jui_interbankpayments_tools.is_IB_payment(SELF.obj) THEN
            SELF.remove_attribute(const_interbankpayments.ATTR_IS_URGENCY); 
        END IF;  
       
       IF l_var IS NOT NULL AND obj.RECEIVER_IBAN IS NOT NULL THEN 
            CHECK_RECEIVER_IBAN(); 
        END IF;
        
       api_interbankpayments.add_payment_change(mobj => obj, 
                           p_action => 'set_beneficiar_bank_swift', 
                           p_additional => l_var);
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                               p_action => 'set_beneficiar_bank_swift', 
                               p_autonomus => TRUE,
                               p_result => SQLERRM || '',
                               p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;

    MEMBER PROCEDURE set_beneficiar_bank_tax(p_var IN VARCHAR2) IS 
        l_var VARCHAR2(5000) DEFAULT jui_interbankpayments_tools.TRIMMING(p_var);
    BEGIN
       obj.BENEFICIAR_BANK_TAX := l_var;
       api_interbankpayments.add_payment_change(mobj => obj, 
                                                   p_action => 'set_beneficiar_bank_tax', 
                                                   p_additional => l_var);
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                               p_action => 'set_beneficiar_bank_tax', 
                               p_autonomus => TRUE,
                               p_result => SQLERRM || '',
                               p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;

    MEMBER PROCEDURE set_bn_corr_acc(p_cor IN VARCHAR2 DEFAULT NULL) IS 
        l_known_bank bank_list%ROWTYPE;
        l_cor VARCHAR2(100) DEFAULT jui_interbankpayments_tools.TRIMMING(p_cor);
    BEGIN
        IF l_cor IS NULL AND obj.BENEFICIAR_BANK_CODE IS NOT NULL THEN
            l_known_bank := JUI_INTERBANKPAYMENTS_TOOLS.FIND_IN_BANKS_LIST_BY_BIK(obj.BENEFICIAR_BANK_CODE);
            l_cor := l_known_bank.corr_acc;
        END IF;
        obj.BENEFICIAR_BANK_CORR_ACCOUNT := l_cor;
        api_interbankpayments.add_payment_change(mobj => obj, 
                                                   p_action => 'set_bn_corr_acc', 
                                                   p_additional => l_cor);
    END;

    MEMBER PROCEDURE set_beneficiar_bank_corr_acc(p_var IN VARCHAR2) IS 
        l_var VARCHAR2(5000) DEFAULT jui_interbankpayments_tools.TRIMMING(p_var);
    BEGIN
        obj.BENEFICIAR_BANK_CORR_ACCOUNT := l_var;
        api_interbankpayments.add_payment_change(mobj => obj, 
                                                   p_action => 'set_beneficiar_bank_corr_acc', 
                                                   p_additional => l_var);
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                               p_action => 'set_beneficiar_bank_corr_acc', 
                               p_autonomus => TRUE,
                               p_result => SQLERRM || '',
                               p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;
    MEMBER procedure default_check_state_error(p_new_state in integer) is
        BEGIN
            raise_application_error(ibs.const_exception.INSUFFICIENT_PRIVILEGES,
                                'Запрещено заявку {' || SELF.obj.ID ||
                                '} со статусом {' || SELF.obj.STATE ||
                                '} переводить в статус {' || p_new_state || '}');
        END;
        
    -- Проверка нового статуса. Можно ли его переводить со старого статуса в новый и иные сопутствующие действия
    MEMBER PROCEDURE check_state(p_new_state IN INTEGER)
    IS BEGIN
        IF SELF.obj.STATE IN (CONST_INTERBANKPAYMENTS.STATE_COMPLETED) THEN
            raise_application_error(ibs.const_exception.GENERAL_ERROR,
                                    'Платеж завершен. Дальнейшая работа с платежом не возвожна');
        ELSIF p_new_state IN (CONST_INTERBANKPAYMENTS.STATE_IB_WAITING,
                                 CONST_INTERBANKPAYMENTS.STATE_IB_TIMEOUT,
                                 CONST_INTERBANKPAYMENTS.STATE_PROVIDER_NOTFOUND,
                                 CONST_INTERBANKPAYMENTS.STATE_PROVIDER_B_ERROR,
                                 CONST_INTERBANKPAYMENTS.STATE_PROVIDER_ERROR,
                                 CONST_INTERBANKPAYMENTS.STATE_PROVIDER_IN_QUEEE)
            THEN RETURN;
        END IF;
        IF p_new_state NOT IN
           (CONST_INTERBANKPAYMENTS.STATE_DRAFT,
            CONST_INTERBANKPAYMENTS.STATE_NEW,
            CONST_INTERBANKPAYMENTS.STATE_DELETED,
            CONST_INTERBANKPAYMENTS.STATE_VERIFICATION,
            CONST_INTERBANKPAYMENTS.STATE_CHANGING,
            CONST_INTERBANKPAYMENTS.STATE_CHANGINGFROMAUTH,
            CONST_INTERBANKPAYMENTS.STATE_AUTHORIZATION,
            CONST_INTERBANKPAYMENTS.STATE_CANCELED,
            CONST_INTERBANKPAYMENTS.STATE_PROVIDER_SENT,
            CONST_INTERBANKPAYMENTS.STATE_PROVIDER_ERROR,
            CONST_INTERBANKPAYMENTS.STATE_PROVIDER_B_ERROR,
            CONST_INTERBANKPAYMENTS.STATE_PROVIDER_NOTFOUND,
            CONST_INTERBANKPAYMENTS.STATE_PROVIDER_IN_QUEEE,
            CONST_INTERBANKPAYMENTS.STATE_COMPLETED,
            CONST_INTERBANKPAYMENTS.STATE_IB_WAITING,
            CONST_INTERBANKPAYMENTS.STATE_IB_TIMEOUT
            ) THEN
           raise_application_error(ibs.const_exception.GENERAL_ERROR,
                                  'Недопустимое состояние платежа {' ||
                                  SELF.obj.STATE ||
                                  '} для возврата к предыдущей стадии обработки');
        END IF;
        
        IF p_new_state = SELF.obj.STATE THEN
           raise_application_error(ibs.const_exception.INSUFFICIENT_PRIVILEGES,
                                    'Платеж{' || SELF.obj.ID  ||
                                    '} уже находится в статусе {' || IBS.API_ENUMERATION.READ_ENUMERATION_VALUE(CONST_INTERBANKPAYMENTS.ENUMTYPE_PAYMENT_STATE,
                                                                                                                p_new_state).ENUM_NAME || '}'); 
        END IF;
        
        IF NOT p_new_state member of ibs.API_ENUMERATION.get_enumeration_id(const_interbankpayments.ENUMTYPE_PAYMENT_STATE) 
            THEN
                  raise_application_error(ibs.const_exception.GENERAL_ERROR, 'Недопустимое новое состояние платежа {' || p_new_state ||'}');
        ELSIF SELF.obj.STATE = CONST_INTERBANKPAYMENTS.STATE_NEW AND p_new_state NOT IN
                                                               (CONST_INTERBANKPAYMENTS.STATE_VERIFICATION,
                                                                CONST_INTERBANKPAYMENTS.STATE_DELETED,
                                                                CONST_INTERBANKPAYMENTS.STATE_IB_WAITING) 
                THEN default_check_state_error(p_new_state);
        ELSIF SELF.obj.STATE = CONST_INTERBANKPAYMENTS.STATE_DELETED AND
              p_new_state NOT IN (CONST_INTERBANKPAYMENTS.STATE_NEW) 
                THEN default_check_state_error(p_new_state);
        ELSIF SELF.obj.STATE = CONST_INTERBANKPAYMENTS.STATE_CANCELED 
                THEN default_check_state_error(p_new_state);
        ELSIF SELF.obj.STATE = CONST_INTERBANKPAYMENTS.STATE_VERIFICATION AND
              p_new_state NOT IN (CONST_INTERBANKPAYMENTS.STATE_AUTHORIZATION,
                                    CONST_INTERBANKPAYMENTS.STATE_CHANGING,
                                    CONST_INTERBANKPAYMENTS.STATE_CANCELED,
                                    CONST_INTERBANKPAYMENTS.STATE_PROVIDER_SENT) 
                THEN default_check_state_error(p_new_state);
        ELSIF SELF.obj.STATE = CONST_INTERBANKPAYMENTS.STATE_AUTHORIZATION AND
              p_new_state NOT IN (CONST_INTERBANKPAYMENTS.STATE_COMPLETED,
                                   CONST_INTERBANKPAYMENTS.STATE_CHANGINGFROMAUTH,
                                   CONST_INTERBANKPAYMENTS.STATE_CANCELED,
                                   CONST_INTERBANKPAYMENTS.STATE_PROVIDER_SENT,
                                   CONST_INTERBANKPAYMENTS.STATE_PROVIDER_IN_QUEEE,
                                   CONST_INTERBANKPAYMENTS.STATE_PROVIDER_ERROR,
                                   CONST_INTERBANKPAYMENTS.STATE_PROVIDER_NOTFOUND
                                   ) 
                THEN default_check_state_error(p_new_state);
        ELSIF SELF.obj.STATE = CONST_INTERBANKPAYMENTS.STATE_CHANGING AND
              p_new_state NOT IN (CONST_INTERBANKPAYMENTS.STATE_VERIFICATION,
                                  CONST_INTERBANKPAYMENTS.STATE_AUTHORIZATION,
                                    CONST_INTERBANKPAYMENTS.STATE_CANCELED) 
                THEN default_check_state_error(p_new_state);
        ELSIF SELF.obj.STATE = CONST_INTERBANKPAYMENTS.STATE_CHANGINGFROMAUTH AND
              p_new_state NOT IN (CONST_INTERBANKPAYMENTS.STATE_AUTHORIZATION,
                                   CONST_INTERBANKPAYMENTS.STATE_CANCELED,
                                   CONST_INTERBANKPAYMENTS.STATE_CHANGING) 
                THEN default_check_state_error(p_new_state);
        END IF;
    END;
    
    MEMBER PROCEDURE update_attribute_trigger(p_attr IN t_intbankpays_attr, p_is_delete BOOLEAN) IS 
        l_fee_col ibs.t_fee_amount_collection;
        l_attr    t_intbankpays_attr DEFAULT p_attr;
    BEGIN
        CASE WHEN   p_attr.id_attr = const_interbankpayments.ATTR_IS_WITHOUT_FEE 
                    OR p_attr.id_attr = const_interbankpayments.ATTR_IS_MANUAL_FEE
                THEN update_fee_collection();
             WHEN  p_attr.id_attr = const_interbankpayments.ATTR_IS_URGENCY THEN
                 IF obj.BENEFICIAR_BANK_SWIFT IN ('CTREAZ22','CTREAZ24') AND 
                    jui_interbankpayments_tools.is_IB_payment(SELF.obj) THEN
                    SELF.remove_attribute(const_interbankpayments.ATTR_IS_URGENCY, FALSE);
                 END IF;   
                 update_fee_collection();
             WHEN p_attr.id_attr = const_interbankpayments.ATTR_ADDITIONAL_INFO THEN
                 IF NOT p_is_delete THEN
                     IF LENGTH(p_attr.value_str) > 140 THEN
                         const_exceptions.raise_exception(const_exceptions.GROUND_WRONG_LENGTH);
                     END IF;
                     l_attr.value_str := SELF.normalize(p_attr.value_str, 35, get_addinfo_max_lines_count());
                     SELF.obj.update_attr_val(l_attr);
                 --ELSE SELF.remove_attribute(const_interbankpayments.ATTR_ADDITIONAL_INFO, FALSE);
                 END IF;
             ELSE NULL;
        END CASE;
    END;

    MEMBER PROCEDURE remove_attribute(p_attr_id IN INTEGER, p_use_trigger BOOLEAN DEFAULT TRUE) IS
    BEGIN
        SELF.obj.remove_attr(p_attr_id);
        IF p_use_trigger THEN
            SELF.update_attribute_trigger(p_attr => t_intbankpays_attr(id_attr => p_attr_id, 
                                                                    value_int => NULL, 
                                                                    value_str => NULL),
                                          p_is_delete => TRUE);
        END IF;
        api_interbankpayments.add_payment_change(mobj => obj, 
                                                       p_action => 'remove_attribute', 
                                                       p_additional => 'ID attribute'   || p_attr_id);
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                               p_action => 'set_beneficiar_bank_corr_acc', 
                               p_autonomus => TRUE,
                               p_result => SQLERRM || '',
                               p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;
    MEMBER PROCEDURE update_attribute(p_attr_id IN INTEGER,
                                      p_value_str   IN VARCHAR DEFAULT NULL,
                                      p_value_int   IN INTEGER DEFAULT NULL,
                                      p_use_trigger BOOLEAN DEFAULT TRUE) IS
    BEGIN
        update_attribute(t_intbankpays_attr(id_attr => p_attr_id, 
                                            value_str => p_value_str, 
                                            value_int => p_value_int), 
                         p_use_trigger);
    END;
    
    MEMBER PROCEDURE update_attribute(p_attr IN t_intbankpays_attr, p_use_trigger BOOLEAN DEFAULT TRUE) IS
    BEGIN
        SELF.obj.update_attr_val(p_attr);

        IF p_use_trigger THEN
            SELF.update_attribute_trigger(p_attr, FALSE);
        END IF;

        -- Если атрибут в списке удаляемых при нулевом значении, то удаляем
        IF tools.collection_constrain(p_attr.id_attr, const_interbankpayments.ATTR_DELETE_IS_NULL) 
           AND p_attr.value_str IS NULL
           AND p_attr.value_int IS NULL
        THEN SELF.obj.remove_attr(p_attr.id_attr);
        END IF;
        
        api_interbankpayments.add_payment_change(mobj => obj, 
                                                       p_action => 'update_attribute', 
                                                       p_additional => 'ID attribute: '   || p_attr.id_attr || chr(10)   ||
                                                                        'STRING VALUE: '  || p_attr.value_str || chr(10) ||
                                                                        'INT VALUE: '     || p_attr.value_int);
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => obj, 
                               p_action => 'set_beneficiar_bank_corr_acc', 
                               p_autonomus => TRUE,
                               p_result => SQLERRM || '',
                               p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;
    
    -- CallBack, запускается после создания платежа
    MEMBER PROCEDURE onCreate IS BEGIN NULL; END;
    MEMBER PROCEDURE oncomplete IS BEGIN NULL; END;
    MEMBER PROCEDURE createFile(p_id IN INTEGER) IS BEGIN NULL; END;
    MEMBER PROCEDURE collect_fee IS BEGIN NULL; END;
    
    MEMBER PROCEDURE SET_OBJ(pobj IN OUT NOCOPY t_interbankpayments_extend) IS 
    BEGIN 
        SELF.obj := pobj;
    END;
    
    MEMBER FUNCTION  GET_OBJ RETURN t_interbankpayments_extend IS
    BEGIN
        RETURN SELF.obj;
    END;
    
    CONSTRUCTOR FUNCTION T_INTBANKPAYS_MSG(pid IN INTEGER) RETURN SELF AS RESULT 
    IS BEGIN 
        SELF.obj := t_interbankpayments_extend(pid);
    RETURN; END;
    
    CONSTRUCTOR FUNCTION T_INTBANKPAYS_MSG(pobj IN OUT NOCOPY t_interbankpayments_extend) RETURN SELF AS RESULT 
    IS BEGIN 
        SELF.obj := pobj;
    RETURN; END;
    
    CONSTRUCTOR FUNCTION T_INTBANKPAYS_MSG RETURN SELF AS RESULT 
    IS BEGIN 
        SELF.obj := t_interbankpayments_extend();
        RETURN; 
        END;

end;
/
