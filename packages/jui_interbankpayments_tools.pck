create or replace package jui_interbankpayments_tools is
  -- Author  : RVKHALAFOV
  -- Created : 3/17/2016 11:58:57
  -- Purpose :
  
    PROCEDURE add_budget_destination(p_code VARCHAR2, p_name VARCHAR2);
    PROCEDURE add_budget_level(p_code VARCHAR2, p_name VARCHAR2);
    PROCEDURE remove_from_bank_list(l_bank_id INTEGER);
    FUNCTION check_ib_time_availablity(p_obj in t_interbankpayments_extend) RETURN BOOLEAN;
    FUNCTION get_constant_value(p_const_name VARCHAR) RETURN INTEGER;
    PROCEDURE freeze_amount(mobj IN OUT t_intbankpays_msg);
    PROCEDURE unfreeze_amount(mobj IN OUT t_intbankpays_msg);
    PROCEDURE freeze_amount(pid IN INTEGER);
    PROCEDURE unfreeze_amount(pid IN INTEGER);
    FUNCTION smart_normilize(p_text CLOB) RETURN CLOB;
    FUNCTION normilize(p_text CLOB) RETURN CLOB;
    FUNCTION TRIMMING(p_var CLOB, l_in_start BOOLEAN DEFAULT TRUE) RETURN CLOB;
    FUNCTION get_messages_by_batch_num(p_batch_num IN NUMBER, p_without_parent BOOLEAN DEFAULT FALSE) RETURN t_intbankpays_msg_collection;
    FUNCTION get_special_fee_src_clients RETURN SYS_REFCURSOR;
    FUNCTION get_special_fee_src(p_client_code VARCHAR2, p_type INTEGER DEFAULT NULL) RETURN SYS_REFCURSOR;
    PROCEDURE rebuild_special_fees(p_code VARCHAR2);
    PROCEDURE rebuild_special_fees;
    PROCEDURE update_special_fee_src(p_client_code VARCHAR, p_type INTEGER, 
                                     p_opcur INTEGER, p_feecur INTEGER,
                                     p_percent NUMBER, p_fixamount NUMBER,
                                     p_minamount NUMBER, p_maxamount NUMBER,
                                     p_id INTEGER DEFAULT NULL);
    PROCEDURE remove_special_fee_src(p_src_id INTEGER);
    FUNCTION update_transaction(p_ground IN VARCHAR2,  p_mobj IN OUT t_intbankpays_msg) RETURN INTEGER;
    
    FUNCTION get_next_reference RETURN VARCHAR2;
    
    FUNCTION get_bank_correspondent_account(p_code VARCHAR,
                                            p_currency INTEGER, 
                                            p_acc_type VARCHAR DEFAULT 'no113' , 
                                            p_raise BOOLEAN DEFAULT TRUE) RETURN VARCHAR;
    FUNCTION get_bank_correspondent_account(p_bank_id INTEGER,  
                                            p_currency INTEGER, 
                                            p_acc_type VARCHAR DEFAULT 'no113' , 
                                            p_raise BOOLEAN DEFAULT TRUE) RETURN VARCHAR;
    --FUNCTION get_bank_correspondent_account(p_code VARCHAR, p_currency INTEGER, p_raise BOOLEAN DEFAULT TRUE) RETURN VARCHAR;
    FUNCTION get_branch_bik (p_branch_id IN INTEGER, p_raise BOOLEAN DEFAULT FALSE) RETURN VARCHAR;
	FUNCTION is_emitentbank_bob (p_em_bik   IN VARCHAR2,
                                 p_raise       BOOLEAN DEFAULT FALSE) RETURN INTEGER;
    PROCEDURE remove_bank_corr_account(p_bank_cor_acc_id INTEGER);
    PROCEDURE add_to_bank_list(l_bank bank_list%ROWTYPE);
    PROCEDURE add_to_bank_list(l_bank_code VARCHAR2, l_bank_name VARCHAR2, l_bank_swift VARCHAR2, 
                               l_corr_acc  VARCHAR2, l_voen VARCHAR2, l_parent_id INTEGER,
                               l_corr_sub  VARCHAR2, l_aleternative_swift VARCHAR2);
    -- Возвращает банк с кодом. Если указан параметр is_parent := TRUE, то будет возвращен родитель этого банка 
    FUNCTION find_in_banks_list_by_bik (p_bik VARCHAR, is_parent boolean DEFAULT FALSE)
    RETURN BANK_LIST%rowtype;
    FUNCTION get_parent_banks_list RETURN ibs.t_two_string_collection;
    -- Возвращает банк со свифтом swift, при этом, будет возвращен только родитель
    FUNCTION find_in_banks_list_by_swift (p_bik VARCHAR, p_raise BOOLEAN DEFAULT FALSE) 
    RETURN BANK_LIST%rowtype;
    
    FUNCTION is_country_bank (p_swift VARCHAR2, p_country_code VARCHAR2 DEFAULT 'AZ') 
    RETURN BOOLEAN;
    
    --Возвращает код страны по SWIFTкоду банка
    FUNCTION get_bank_country (p_swift VARCHAR2) 
    RETURN VARCHAR2;
    
    FUNCTION is_IB_payment(p_payment t_interbankpayments) RETURN BOOLEAN;
    FUNCTION  ISVALID_IBANKACCOUNT(P_IBANACCOUNT VARCHAR2, P_SWIFT VARCHAR2 DEFAULT NULL) RETURN BOOLEAN;
    -- Проверяет является ли пользователь интернет банкингом
    FUNCTION is_IB_user(p_user_id integer) 
    RETURN BOOLEAN;
    
    -- @Overloaded Проверяет является ли пользователь интернет банкингом
    FUNCTION is_IB_user(p_payment t_interbankpayments) 
    RETURN BOOLEAN;
    FUNCTION add_chr_tostart(p_chr VARCHAR2, p_text VARCHAR2, p_from_line INTEGER DEFAULT 1) RETURN VARCHAR2;
    
    FUNCTION is_struct_type_exist(p_system VARCHAR, p_message_type VARCHAR, p_postfix VARCHAR DEFAULT NULL) RETURN BOOLEAN;
    FUNCTION is_struct_type_exist(p_msg t_intbankpays_msg, p_postfix VARCHAR DEFAULT NULL) RETURN BOOLEAN;
    FUNCTION is_struct_type_exist(p_obj t_interbankpayments_extend, p_postfix VARCHAR DEFAULT NULL) RETURN BOOLEAN;
    -- Проверяет известен ли тип сообщения
    FUNCTION is_known_msgtype(p_mtype INTEGER) RETURN BOOLEAN;
    FUNCTION is_known_payment_system(p_payment_system_id INTEGER) RETURN BOOLEAN;
    -- Врзвращает банковский день. Если SYSDATE не является бан. днем, то возвращает следующий
    FUNCTION get_bank_date RETURN DATE;

    PROCEDURE add_special_fee(p_object_code IN VARCHAR,
                              p_tariff_id IN INTEGER, 
                              p_fee_type INTEGER,
                              p_acc_cat_id IN INTEGER DEFAULT NULL,
                              p_ground_template IN VARCHAR DEFAULT NULL);
    FUNCTION get_special_fee(p_object_id IN INTEGER, 
                             p_fee_type INTEGER, 
                             p_amount NUMBER, 
                             p_currency INTEGER) RETURN ibs.t_fee_amount;
    FUNCTION get_special_fee_id(p_object_id IN INTEGER, p_fee_type INTEGER, p_currency INTEGER) RETURN INTEGER;
    PROCEDURE roll_back_operation(p_mobj IN OUT t_intbankpays_msg);
    
    -- Удаляет пакетность платежей
    PROCEDURE remove_batching(p_batch_num VARCHAR2);
    
    FUNCTION send_cbar_xohks_payment(p_id INTEGER) RETURN CLOB;
    PROCEDURE set_batch_payments_status(p_msg IN OUT NOCOPY t_intbankpays_msg, p_state INTEGER, p_err_msg VARCHAR DEFAULT NULL);
    /************************************** Конвертеры *******************************************/
    FUNCTION rowtypeWrapper(p_ipay V_INTERBANKPAYMENTS%rowtype) RETURN SYS_REFCURSOR;
    FUNCTION converter_cursor(p_ipay t_interbankpayments_collection) RETURN SYS_REFCURSOR;
    FUNCTION converter_cursor(p_ipay V_INTERBANKPAYMENTS%rowtype) RETURN SYS_REFCURSOR;
    FUNCTION converter_object(p_ip INTERBANKPAYMENTS%ROWTYPE) RETURN t_interbankpayments;
    
    /************************************** List functions **********************************************/
    -- Возвращает Büdcə təsnifatı kodu
    FUNCTION get_budget_destination_list return ibs.T_TWO_STRING_COLLECTION;
    -- Возвращает Büdcə səviyyə kodu
    FUNCTION get_budget_level_list return ibs.T_TWO_STRING_COLLECTION;
    -- Возвращает все достпуные списки
    FUNCTION get_all_list RETURN SYS_REFCURSOR;
    -- Возвращает список валют
    FUNCTION get_currency_list RETURN ibs.t_two_string_collection;
    -- Возвращает список банков получателей
    FUNCTION get_beneficiar_banks_list RETURN ibs.t_two_string_collection;
    FUNCTION get_banks_list RETURN SYS_REFCURSOR;
    FUNCTION get_beneficiar_banks_list_az RETURN ibs.t_two_string_collection;
    FUNCTION get_enum_as_list(p_enum_type INTEGER) RETURN  ibs.t_two_string_collection;
    -- Возвращает список статусов
    FUNCTION get_status_list RETURN ibs.t_two_string_collection;
    -- Возвращает список типов сообщений
    FUNCTION get_messages_type_list(p_grandtolist INTEGER DEFAULT NULL) RETURN ibs.t_two_string_collection;
    -- Взвращает список пользователей
    FUNCTION get_users_list (p_role INTEGER DEFAULT const_interbankpayments.USER_ROLE_CREATOR)  RETURN ibs.t_two_string_collection;
    -- Возвращает список платежных систем
    FUNCTION get_payment_system_list RETURN ibs.t_two_string_collection;
    PROCEDURE update_bank_corr_account(p_currency INTEGER,
                                       p_account VARCHAR2,
                                       p_acc_type VARCHAR2,
                                       p_account_bob VARCHAR2,
                                       p_bank_list_id INTEGER DEFAULT NULL,
                                       p_bank_swift VARCHAR2 DEFAULT NULL);
    FUNCTION get_bank_corr_account(p_bank_id INTEGER) RETURN SYS_REFCURSOR;
    FUNCTION get_bank_corr_account (p_swift VARCHAR2, p_currency INTEGER, p_acc_type VARCHAR2) RETURN t_mt113_corr_bank_acc;
    FUNCTION get_mt113_corr_bank (p_swift VARCHAR2)  RETURN t_mt113_corr_bank_acc_col;
    /************************************** /List functions **********************************************/
    
    FUNCTION GET_NR_CODE(  P_COUNTRY_2  VARCHAR2,
                           P_NR_2       VARCHAR2,
                           P_SWIFT_4    VARCHAR2,
                           P_ACCOUNT_20 VARCHAR2) RETURN VARCHAR2;
end jui_interbankpayments_tools;
/
create or replace package body jui_interbankpayments_tools IS

    PROCEDURE add_budget_destination(p_code VARCHAR2, p_name VARCHAR2) IS
        l_name VARCHAR2(256) DEFAULT SUBSTRB (TRIM(p_name), 1, 256);
    BEGIN
        merge into dwmain.budget_destination m using dual on (t_code = p_code) 
                when not matched then insert (t_code, t_name) values (p_code, l_name)
                when matched then update set t_name = l_name;
    END;

    PROCEDURE add_budget_level(p_code VARCHAR2, p_name VARCHAR2) IS
        l_name VARCHAR2(256) DEFAULT SUBSTRB (TRIM(p_name), 1, 256);
    BEGIN
        merge into dwmain.budget_level m using dual on (t_code = p_code) 
                when not matched then insert (t_code, t_name) values (p_code, l_name)
                when matched then update set t_name = l_name;
    END;

    FUNCTION get_constant_value(p_const_name VARCHAR) RETURN INTEGER IS
        l_result INTEGER;
    BEGIN
        
        EXECUTE IMMEDIATE 'begin :result := const_interbankpayments.' || p_const_name || '; end;' 
        USING OUT l_result;
        RETURN l_result;
    END;
    
    -- Пересобирает спецаильные коммисии- создает ибс комиссии и помещает в таблицу INTERBANKPAYMENTS_SPECFEE
    PROCEDURE rebuild_special_fees(p_code VARCHAR2) IS
        l_tariff_row        ibs.tariff%ROWTYPE;
        l_clent_specs       SYS_REFCURSOR;
        l_cur_clent_specs   V_INTERBANKPAYMENTS_SPECFEESRC%ROWTYPE;
        -- Перенести потом на enumaration
        l_fee_types         ibs.t_integer_collection DEFAULT ibs.t_integer_collection(const_interbankpayments.FEE_TYPES_INBANK,
                                                                                      const_interbankpayments.FEE_TYPES_INCNTR,
                                                                                      const_interbankpayments.FEE_TYPES_OUTCNTR);
        l_fee_types_title   ibs.t_string_collection  DEFAULT ibs.t_string_collection(' внутри банка ',
                                                                                     ' внутри страны ',
                                                                                     ' за пределы страны ');
        -- /Перенести потом на enumaration
        l_indx              INTEGER;
    BEGIN
        DELETE FROM INTERBANKPAYMENTS_SPECIAL_FEE s WHERE s.client_id = ibs.api_object.get_object_id(p_object_code => p_code,
                                                                                                    p_code_kind_id => 1);
                                                                                                    
        l_indx := l_fee_types.FIRST;
        WHILE l_indx IS NOT NULL
        LOOP
            l_clent_specs := get_special_fee_src(p_code, p_type => l_fee_types(l_indx));
            DBMS_OUTPUT.PUT_LINE(' FEETYPE: ' || l_fee_types(l_indx) || ' (' || l_fee_types_title(l_indx) || ')');

            IF l_clent_specs IS NOT NULL THEN
                l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа ' || l_fee_types_title(l_indx) 
                                                                                             || p_code, 
                                                              ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                              ibs.const_tariff.TARIFF_BASE_OPERATION);
                LOOP
                    FETCH l_clent_specs INTO l_cur_clent_specs;
                    EXIT WHEN l_clent_specs%NOTFOUND;

                    DBMS_OUTPUT.PUT_LINE('      ' || l_cur_clent_specs.OPERATION_CURRENCY || ' +');
                    ibs.api_tariff.create_tariff_general(l_tariff_row.id, 
                                                         l_cur_clent_specs.OPERATION_CURRENCY, 
                                                         l_cur_clent_specs.FIX_AMOUNT,
                                                         l_cur_clent_specs.PERCENT,
                                                         l_cur_clent_specs.MIN_AMOUNT,
                                                         l_cur_clent_specs.MAX_AMOUNT,
                                                         l_cur_clent_specs.FEE_CURRENCY);
                        
                END LOOP;
                jui_interbankpayments_tools.add_special_fee(p_code, l_tariff_row.id, l_fee_types(l_indx));
            ELSE dbms_output.put_line('NOT FOUND');
            END IF;
            l_indx := l_fee_types.NEXT(l_indx);
        END LOOP;      
    END;
    
    PROCEDURE rebuild_special_fees IS
        l_spec_clients      SYS_REFCURSOR DEFAULT get_special_fee_src_clients();
        l_cur_spec_client   v_specfeesrc_clients%ROWTYPE;
    BEGIN
        LOOP
            FETCH l_spec_clients INTO l_cur_spec_client;
            EXIT WHEN l_spec_clients%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE('-- Current client: ' || l_cur_spec_client.client_code);
            rebuild_special_fees(l_cur_spec_client.client_code);
        END LOOP;
    END;
    
    PROCEDURE update_special_fee_src(p_client_code VARCHAR, p_type INTEGER, 
                                     p_opcur INTEGER, p_feecur INTEGER,
                                     p_percent NUMBER, p_fixamount NUMBER,
                                     p_minamount NUMBER, p_maxamount NUMBER,
                                     p_id INTEGER DEFAULT NULL) IS
    BEGIN
        
        merge into INTERBANKPAYMENTS_SPECFEE_SRC s
        using dual on ( s.client_code = p_client_code 
                        AND s.TYPE    = p_type
                        AND s.operation_currency = p_opcur)
        when matched then
        update set s.fee_currency = p_feecur, 
                   s.fix_amount = p_fixamount,
                   s.percent = p_percent,
                   s.min_amount = p_minamount, 
                   s.max_amount = p_maxamount
        when not matched then
        insert values (NULL, p_client_code, p_type, p_opcur, p_feecur, p_fixamount,
                        p_percent, p_minamount, p_maxamount);
        rebuild_special_fees(p_client_code);
    END;
    
    PROCEDURE remove_special_fee_src(p_src_id INTEGER) IS
        l_client_code VARCHAR(20);
    BEGIN 
        DELETE FROM INTERBANKPAYMENTS_SPECFEE_SRC s WHERE s.id = p_src_id RETURNING s.client_code INTO l_client_code ; 
        rebuild_special_fees(l_client_code);
        END;   

    FUNCTION get_special_fee_src_clients RETURN SYS_REFCURSOR IS
        l_res SYS_REFCURSOR;
    BEGIN
        OPEN l_res FOR SELECT * FROM v_specfeesrc_clients;
        RETURN l_res;
    END;
    
    FUNCTION get_special_fee_src(p_client_code VARCHAR2, p_type INTEGER DEFAULT NULL) RETURN SYS_REFCURSOR IS
        l_res   SYS_REFCURSOR;
        l_count INTEGER DEFAULT 0;
    BEGIN
        -- херня, но как-то пока так
        SELECT COUNT(1) INTO l_count 
        FROM V_INTERBANKPAYMENTS_SPECFEESRC t WHERE t.CLIENT_CODE = p_client_code AND (t.TYPE = p_type OR p_type IS NULL);
        
        IF l_count > 0  THEN
            OPEN l_res FOR select * from V_INTERBANKPAYMENTS_SPECFEESRC t 
                            WHERE t.CLIENT_CODE = p_client_code AND (t.TYPE = p_type OR p_type IS NULL);
            RETURN l_res;
        ELSE RETURN NULL;
        END IF;
    END;
    
    FUNCTION get_next_reference RETURN VARCHAR2 IS
    BEGIN RETURN to_char(sysdate, 'YYMMDDHHMI') || INTERBANKSPAYMENTS_SEQ.NEXTVAL; END;


     -- Check time for payments availabilities
    FUNCTION check_ib_time_availablity(p_obj in t_interbankpayments_extend) RETURN BOOLEAN
    IS l_bank_open_time    DATE DEFAULT TO_DATE(TO_CHAR(SYSDATE,'dd-mm-YYYY') || ' 09:00:00','dd-mm-YYYY HH24:MI:SS');
    BEGIN
        IF is_IB_payment(p_obj) THEN 
            IF ibs.api_calendar.is_work_day(TRUNC(SYSDATE)) = 0 THEN
                RETURN FALSE;
            END IF; 
            
            IF p_obj.BENEFICIAR_BANK_SWIFT = 'XXXXXXXX'
               AND SYSDATE BETWEEN l_bank_open_time 
               AND TO_DATE(TO_CHAR(SYSDATE,'dd-mm-YYYY') || ' 17:00:00','dd-mm-YYYY HH24:MI:SS')
               THEN RETURN TRUE;                      
            ELSIF p_obj.BENEFICIAR_BANK_SWIFT IN ('CTREAZ22','CTREAZ24') 
                  AND SYSDATE BETWEEN l_bank_open_time 
                  AND TO_DATE(TO_CHAR(SYSDATE,'dd-mm-YYYY') || ' 14:00:00','dd-mm-YYYY HH24:MI:SS')
                  THEN RETURN TRUE;
            ELSIF SYSDATE BETWEEN l_bank_open_time AND TO_DATE(TO_CHAR(SYSDATE,'dd-mm-YYYY') || ' 15:30:00','dd-mm-YYYY HH24:MI:SS')
                THEN RETURN TRUE;
            END IF;
            RETURN FALSE;
        END IF;
        RETURN TRUE;
    END;
    -- /


    PROCEDURE add_special_fee(p_object_code     IN VARCHAR,
                              p_tariff_id       IN INTEGER,
                              p_fee_type        IN INTEGER, -- одно из значений const_interbankpayments.FEE_TYPE_*
                              p_acc_cat_id      IN INTEGER DEFAULT NULL,
                              p_ground_template IN VARCHAR DEFAULT NULL) IS
        l_fee_value_row ibs.fee_value%rowtype;
        l_income_category_id    INTEGER DEFAULT nvl(p_acc_cat_id, const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS);
        l_ground_template       VARCHAR(100) DEFAULT nvl(p_ground_template, const_interbankpayments.FEE_DEFGROUND);
        l_client_id             NUMBER DEFAULT ibs.api_object.get_object_id(p_object_code => p_object_code,
                                                                            p_code_kind_id => ibs.const_subject.CODE_KIND_CODE);
        l_max_fee_id            INTEGER;
    BEGIN
        --l_fee_value_row := ibs.api_tariff.create_fee_value(p_tariff_id, l_income_category_id, l_ground_template);
        
        SELECT MAX(isf.fee_id)+1 INTO l_max_fee_id FROM interbankpayments_special_fee isf;
        
        IF l_max_fee_id IS NULL THEN l_max_fee_id := const_interbankpayments.FEE_SPECIAL_FEE_START; END IF;
        
        ibs.api_tariff.cor_fee(l_max_fee_id, 
                               const_interbankpayments.OT_OUTBANK_PAYMENT, 
                               const_interbankpayments.FEE_DEFGROUND, 
                               p_tariff_id, 
                               const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS, 
                               ':Специальная комиссия для клиента ' || p_object_code ||' :', 
                               ibs.const_general.NO);

        merge into INTERBANKPAYMENTS_SPECIAL_FEE isp
        using dual on (isp.CLIENT_id = l_client_id AND isp.fee_type = p_fee_type)
        when matched then
        update set isp.fee_id = l_max_fee_id
        when not matched then
        insert values (l_client_id, l_max_fee_id, p_fee_type);
    END;
    
    FUNCTION get_special_fee_id(p_object_id IN INTEGER, 
                                p_fee_type INTEGER,
                                p_currency INTEGER) RETURN INTEGER AS
        l_result INTEGER;
        l_fee ibs.t_fee_amount;
    BEGIN
        SELECT isp.fee_id INTO l_result 
        FROM interbankpayments_special_fee isp 
        WHERE isp.client_id = p_object_id AND isp.fee_type = p_fee_type;
        
        l_fee := ibs.api_tariff.get_fee(l_result,
                                        NULL,
                                        NULL,
                                        NULL,
                                        1,
                                        p_currency,
                                        NULL,
                                        NULL);
        RETURN l_result;
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
    END;
    
    FUNCTION get_special_fee(p_object_id IN INTEGER, 
                             p_fee_type INTEGER, 
                             p_amount NUMBER, 
                             p_currency INTEGER) RETURN ibs.t_fee_amount IS
        l_fee_id    INTEGER DEFAULT get_special_fee_id(p_object_id, p_fee_type, p_currency);
    BEGIN
        IF l_fee_id IS NULL THEN RETURN NULL; END IF;
        RETURN ibs.api_tariff.get_fee(l_fee_id,
                                NULL,
                                NULL,
                                NULL,
                                p_amount,
                                p_currency,
                                NULL,
                                NULL);
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
    END;

    FUNCTION converter_cursor(p_ipay t_interbankpayments_collection) RETURN SYS_REFCURSOR
    IS l_cursor SYS_REFCURSOR; 
    BEGIN
        OPEN l_cursor FOR SELECT * FROM TABLE(p_ipay); 
        RETURN l_cursor;
    END;
    
    FUNCTION converter_cursor(p_ipay V_INTERBANKPAYMENTS%rowtype) RETURN SYS_REFCURSOR
    IS l_cursor SYS_REFCURSOR; 
    BEGIN
        -- Все ради того, что гребанный JDBC не понимает RecordSet !!!!!
        --OPEN l_cursor FOR SELECT * FROM V_INTERBANKPAYMENTS v WHERE V.ID = p_ipay.ID; 
        OPEN l_cursor FOR SELECT    p_ipay.id,p_ipay.reference, p_ipay.state, p_ipay.payment_date, p_ipay.system_id,p_ipay.message_type, p_ipay.amount, p_ipay.currency,
                                    p_ipay.fee_collection,p_ipay.ground, p_ipay.operation_id, p_ipay.payer_branch_id, p_ipay.payer_account,
                                    p_ipay.receiver_name, p_ipay.receiver_iban, p_ipay.receiver_tax, p_ipay.emitent_bank_code, p_ipay.beneficiar_bank_code,
                                    p_ipay.beneficiar_bank_swift,p_ipay.beneficiar_bank_tax,p_ipay.context_id, p_ipay.creator_id, p_ipay.state_history, p_ipay.ATTRS, p_ipay.changes,
                                    -- View
                                    p_ipay.STATE_NAME, p_ipay.SYSTEM_NAME, p_ipay.PAYER_NAME, p_ipay.PAYER_ACCOUNT_ID, p_ipay.PAYER_ACCOUNT_CURRENCY,
                                    p_ipay.PAYER_ACCOUNT_BRANCH, p_ipay.PAYER_TAX_NUMBER, p_ipay.PAYER_IBAN_ACCOUNT, p_ipay.EMITENT_BANK_SWIFT,
                                    p_ipay.EMITENT_BANK_TAX, p_ipay.EMITENT_BANK_NAME, p_ipay.CURRENCY_CODE, p_ipay.FEE_SUM_AMOUNT, p_ipay.USER_NAME, p_ipay.LOGIN_NAME,
                                    p_ipay.PAYER_CLIENT_CODE, p_ipay.beneficiar_bank_name, p_ipay.EMITENT_BANK_CORR_ACCOUNT,p_ipay.BENEFICIAR_BANK_CORR_ACCOUNT
                          FROM dual;
        RETURN l_cursor;
    END;    

    FUNCTION converter_object(p_ip INTERBANKPAYMENTS%ROWTYPE) RETURN t_interbankpayments
    IS l_object t_interbankpayments;
    BEGIN
        l_object.ID := p_ip.id;
        l_object.REFERENCE:= p_ip.reference;
        l_object.STATE := p_ip.state;
        l_object.PAYMENT_DATE := p_ip.payment_date;
        l_object.SYSTEM_ID := p_ip.system_id;
        l_object.MESSAGE_TYPE := p_ip.MESSAGE_TYPE;
        l_object.AMOUNT := p_ip.AMOUNT;
        l_object.CURRENCY := p_ip.CURRENCY;
        l_object.FEE_COLLECTION := p_ip.FEE_COLLECTION;
        l_object.GROUND := p_ip.GROUND;
        l_object.OPERATION_ID := p_ip.OPERATION_ID;
        l_object.PAYER_BRANCH_ID := p_ip.PAYER_BRANCH_ID;
        l_object.PAYER_ACCOUNT := p_ip.PAYER_ACCOUNT;
        l_object.RECEIVER_NAME := p_ip.RECEIVER_NAME;
        l_object.RECEIVER_IBAN := p_ip.RECEIVER_IBAN;
        l_object.RECEIVER_TAX := p_ip.RECEIVER_TAX;
        l_object.EMITENT_BANK_CODE := p_ip.EMITENT_BANK_CODE;
        l_object.BENEFICIAR_BANK_CODE := p_ip.BENEFICIAR_BANK_CODE;
        l_object.BENEFICIAR_BANK_SWIFT := p_ip.BENEFICIAR_BANK_SWIFT;
        l_object.CONTEXT_ID := p_ip.CONTEXT_ID;
        l_object.CREATOR_ID := p_ip.CREATOR_ID;
        l_object.STATE_HISTORY := p_ip.STATE_HISTORY;
        l_object.ATTRS := p_ip.ATTRS;
        l_object.CHANGES := p_ip.CHANGES;
        RETURN l_object;
    END;
    
    FUNCTION send_cbar_xohks_payment(p_id INTEGER) RETURN CLOB IS
        l_cur_msg               t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(p_id);
        p_batch_num             NUMBER DEFAULT l_cur_msg.obj.get_attribute_val(const_interbankpayments.ATTR_BATCH_PAYMENT_NUM).value_int;
        l_result                CLOB;
        p_related_msg           t_intbankpays_msg_collection;
        l_xmltype               xmltype;
        l_result_vc             varchar(32767);
        p_loop_indx             INTEGER;
        xml_parse_exception     exception;
        
        pragma  exception_init(xml_parse_exception, -31011 );
    BEGIN
        
        l_result := ext_serv.cbar_xohks.importFile(api_interbankpayments.get_payment_file_content(p_id));
        l_xmltype := xmltype(l_result);
        set_batch_payments_status(l_cur_msg, const_interbankpayments.STATE_PROVIDER_SENT);
        api_interbankpayments.update_payment_file_content(l_cur_msg.obj.ID, l_result);
        
        RETURN l_result;
        
    EXCEPTION WHEN xml_parse_exception THEN 
                    set_batch_payments_status(l_cur_msg, 
                                              const_interbankpayments.STATE_PROVIDER_B_ERROR, 
                                              substr(l_result, 1, 32767));
                    RETURN '';
              WHEN OTHERS THEN 
                    set_batch_payments_status(l_cur_msg, 
                                              const_interbankpayments.STATE_PROVIDER_B_ERROR, 
                                              'Нет связи с сервисом. Код: ' || SQLCODE || '; {' || SQLERRM || '}');
                    RETURN '';
    END;
    
    -- Deprecated
    FUNCTION rowtypeWrapper(p_ipay V_INTERBANKPAYMENTS%rowtype) RETURN SYS_REFCURSOR
    IS l_cursor SYS_REFCURSOR; 
    BEGIN
        -- Все ради того, что гребанный JDBC не видит RecordSet !!!!!
        OPEN l_cursor FOR SELECT * FROM V_INTERBANKPAYMENTS v WHERE V.ID = p_ipay.ID; 
        RETURN l_cursor;
    END;

    FUNCTION get_budget_destination_list return ibs.T_TWO_STRING_COLLECTION 
    IS l_budget_destinations_list IBS.T_TWO_STRING_COLLECTION default ibs.T_TWO_STRING_COLLECTION();
    BEGIN
        SELECT ibs.T_TWO_STRING_ID(VB.CODE, VB.NAME) BULK COLLECT INTO l_budget_destinations_list
        FROM ibs.V_BUDGET_DESTINATION vb ORDER BY vb.code ASC/*
        WHERE VB.ID IN (SELECT ev.enum_id 
                            FROM ibs.enumeration_value ev 
                            WHERE ev.enum_type_id = ibs.const_payment.ET_BUDGET_DESTINATION)*/;
        return l_budget_destinations_list;
    END;

    FUNCTION get_budget_level_list return ibs.T_TWO_STRING_COLLECTION 
    IS l_budget_destinations_list IBS.T_TWO_STRING_COLLECTION default ibs.T_TWO_STRING_COLLECTION();
    BEGIN
        SELECT ibs.T_TWO_STRING_ID(VB.CODE, VB.NAME) BULK COLLECT INTO l_budget_destinations_list
        FROM IBS.V_BUDGET_LEVEL vb ORDER BY vb.code ASC/*
        WHERE VB.ID IN (SELECT ev.enum_id 
                            FROM ibs.enumeration_value ev 
                            WHERE ev.enum_type_id = ibs.const_payment.ET_BUDGET_DESTINATION)*/;
        return l_budget_destinations_list;
    END;
    
       
    FUNCTION isvalid_ibankaccount(P_IBANACCOUNT VARCHAR2, P_SWIFT VARCHAR2 DEFAULT NULL) RETURN BOOLEAN IS
    BEGIN
        IF SUBSTR(P_IBANACCOUNT, 5, 4) = 'GUNA' or P_SWIFT = 'GUNA' THEN RETURN TRUE; END IF;
        IF SUBSTR(P_IBANACCOUNT, 3, 2) =
                   jui_interbankpayments_tools.GET_NR_CODE( SUBSTR(P_IBANACCOUNT, 1, 2),
                                                            '00',
                                                            SUBSTR(P_IBANACCOUNT, 5, 4),
                                                            SUBSTR(P_IBANACCOUNT, 9)) 
        THEN
            IF P_SWIFT IS NULL OR SUBSTR(P_IBANACCOUNT, 5, 4) = SUBSTR(P_SWIFT, 1, 4) THEN RETURN TRUE;
            ELSE RETURN FALSE;
            END IF;
        ELSE RETURN FALSE;
        END IF;
    END;
    
    FUNCTION is_IB_payment(p_payment t_interbankpayments) RETURN BOOLEAN
    IS BEGIN
        RETURN p_payment.isset_attribute(const_interbankpayments.ATTR_IS_IB);
    END;

    FUNCTION is_IB_user(p_user_id integer) RETURN BOOLEAN
    IS BEGIN
        RETURN p_user_id = CONST_INTERBANKPAYMENTS.IB_USER_ID;
    END;
    
    FUNCTION is_IB_user(p_payment t_interbankpayments) RETURN BOOLEAN
    IS BEGIN
        RETURN is_IB_user(p_payment.CREATOR_ID);
    END;
    
    FUNCTION get_bank_country (p_swift VARCHAR2) RETURN VARCHAR2
    IS BEGIN
       RETURN SUBSTR(p_swift, 5, 2);     
    END;
    
    FUNCTION is_country_bank (p_swift VARCHAR2, p_country_code VARCHAR2 DEFAULT 'AZ') RETURN BOOLEAN
    IS BEGIN
        IF UPPER(get_bank_country(p_swift)) = p_country_code THEN
            RETURN TRUE;
        END IF;
        RETURN FALSE;
    END;
    FUNCTION get_bank_correspondent_account(p_code VARCHAR,
                                            p_currency INTEGER, 
                                            p_acc_type VARCHAR DEFAULT 'no113' , 
                                            p_raise BOOLEAN DEFAULT TRUE) RETURN VARCHAR IS
    BEGIN
        RETURN get_bank_correspondent_account(find_in_banks_list_by_bik(p_code).ID, p_currency, p_acc_type, p_raise);
    END;
    
    FUNCTION get_bank_correspondent_account(p_bank_id INTEGER,  
                                            p_currency INTEGER, 
                                            p_acc_type VARCHAR DEFAULT 'no113' , 
                                            p_raise BOOLEAN DEFAULT TRUE) RETURN VARCHAR IS
        l_result VARCHAR(50);
    BEGIN
        
        /*SELECT bi.account INTO l_result
        FROM bank_iban bi
        LEFT JOIN bank_list bl ON bi.bank_code = CASE WHEN bl.parent_id IS NULL THEN bi.bank_code
                                                      ELSE (SELECT bbl.bank_code 
                                                            FROM bank_list bbl 
                                                            WHERE bbl.id = bl.parent_id) 
                                                 END*/
        /*SELECT bi.account INTO l_result
        FROM bank_list bl
        LEFT JOIN bank_iban bi ON bl.bank_code = bi.bank_code 
        WHERE bl.bank_code = p_code AND bi.currency_id = p_currency;*/
        SELECT blca.account INTO l_result FROM bank_list_corr_account blca WHERE blca.bank_list_id = p_bank_id
                                                                                AND blca.currency = p_currency
                                                                                AND blca.acc_type = p_acc_type;
        
        RETURN l_result;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN  
            --Для обратной совместимости со стрым хранилищем ИБАН счетов
            BEGIN
                
                SELECT bi.account INTO l_result
                FROM bank_list bl
                LEFT JOIN bank_iban bi ON bl.bank_code = bi.bank_code 
                WHERE bl.id = p_bank_id AND bi.currency_id = p_currency;
                RETURN l_result;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    IF p_raise THEN 
                        raise_application_error(-20000, 'Для банка c ID {' || p_bank_id || 
                                                  '} или его родителя не найден корреспондентский  счет в валюте {' || 
                                                  p_currency || '} и типа {' || p_acc_type || '}');
                    ELSE RETURN NULL;
                    END IF;
            END;
            
        
        
            
    END;
    
    PROCEDURE remove_from_bank_list(l_bank_id INTEGER) IS
    BEGIN
        DELETE FROM ipay.bank_list l WHERE l.id = l_bank_id;
    END;
    
    PROCEDURE add_to_bank_list(l_bank_code VARCHAR2, l_bank_name VARCHAR2, l_bank_swift VARCHAR2, 
                               l_corr_acc  VARCHAR2, l_voen VARCHAR2, l_parent_id INTEGER,
                               l_corr_sub  VARCHAR2, l_aleternative_swift VARCHAR2) IS
        l_row bank_list%ROWTYPE;
    BEGIN
        l_row.bank_swift := l_bank_swift;
        l_row.bank_name:= l_bank_name; 
        l_row.bank_code:= l_bank_code; 
        l_row.corr_acc:= l_corr_acc; 
        l_row.voen:= l_voen; 
        l_row.parent_id:= l_parent_id; 
        l_row.corr_sub := l_corr_sub;
        l_row.aleternative_swift := l_aleternative_swift;
        add_to_bank_list(l_row);
    END;

    
    PROCEDURE add_to_bank_list(l_bank bank_list%ROWTYPE) IS
    BEGIN
        
        
    
        merge into ipay.bank_list m using dual on (m.bank_swift = l_bank.bank_swift OR (m.bank_code = l_bank.bank_code AND l_bank.bank_code IS NOT NULL))
            when not matched then INSERT (  bank_swift, 
                                            bank_name, 
                                            bank_code, 
                                            corr_acc, 
                                            voen, 
                                            parent_id, 
                                            parent_code, 
                                            corr_sub, 
                                            aleternative_swift, 
                                            aleternative_account, 
                                            aleternative_rule_paysys) 
                                  VALUES(   l_bank.bank_swift, 
                                            l_bank.bank_name, 
                                            l_bank.bank_code, 
                                            l_bank.corr_acc, 
                                            l_bank.voen, 
                                            l_bank.parent_id, 
                                            l_bank.parent_code, 
                                            l_bank.corr_sub, 
                                            l_bank.aleternative_swift, 
                                            l_bank.aleternative_account, 
                                            l_bank.aleternative_rule_paysys)
             when matched then update SET   bank_name = l_bank.bank_name, 
                                            corr_acc = l_bank.corr_acc, 
                                            voen = l_bank.voen, 
                                            parent_id = l_bank.parent_id, 
                                            parent_code = l_bank.parent_code, 
                                            corr_sub = l_bank.corr_sub, 
                                            aleternative_swift = l_bank.aleternative_swift, 
                                            aleternative_account = l_bank.aleternative_account, 
                                            aleternative_rule_paysys = l_bank.aleternative_rule_paysys;
    END;

    
    FUNCTION find_in_banks_list_by_bik (p_bik VARCHAR, is_parent boolean DEFAULT FALSE) RETURN BANK_LIST%ROWTYPE IS 
        l_result bank_list%rowtype; 
    BEGIN
        IF is_parent = TRUE THEN
            SELECT * INTO l_result FROM bank_list b WHERE b.id = (SELECT b.parent_id FROM bank_list b WHERE b.BANK_CODE = p_bik);
        ELSE
            SELECT * INTO l_result FROM bank_list b WHERE b.BANK_CODE = p_bik;    
        END IF;
        RETURN l_result;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN RETURN NULL;
    END;
    
    PROCEDURE freeze_amount(mobj IN OUT t_intbankpays_msg)
    IS 
        l_op    INTEGER;
        l_acc   ibs.account%ROWTYPE;
    BEGIN
        IF mobj.obj.isset_attribute(const_interbankpayments.ATTR_IS_WITHOUT_FREEZE_AMOUNT) THEN RETURN; END IF;
        l_acc := IBS.API_ACCOUNT.READ_ACCOUNT(mobj.obj.PAYER_ACCOUNT);
        -- Добавить проверку достаточности средств на счете для фриза
        l_op := ibs.api_operation.create_operation(l_acc.id, ibs.const_account.OP_TYPE_BLOCK_AMOUNT, NULL);
        
        ibs.api_register.change_register_value(l_acc.id, l_acc.id , ibs.const_account.REG_BLOCK, ibs.t_amount(mobj.obj.AMOUNT + mobj.obj.get_fee_sum, 
                                                                                                      mobj.obj.CURRENCY));
        mobj.obj.update_attr_val(t_intbankpays_attr(p_id_attr => CONST_INTERBANKPAYMENTS.ATTR_FREEZE_OP_ID, 
                                                    p_value_str => NULL, 
                                                    p_value_int => l_op));
        IBS.API_OPERATION.COMPLETE_OPERATION(l_op);
        
        api_interbankpayments.add_payment_change(mobj => mobj.obj, 
                                                p_result => 'Operation ID ' || l_op,
                                                p_action => 'jui_interbankpayments_tools.freeze_amount');
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => mobj.obj, 
                                                       p_action => 'jui_interbankpayments_tools.set_fee', 
                                                       p_autonomus => TRUE,
                                                       p_result => SQLERRM || '',
                                                       p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;
    
    
    PROCEDURE unfreeze_amount(mobj IN OUT t_intbankpays_msg)
    IS  l_attr_am   t_intbankpays_attr DEFAULT mobj.obj.get_attribute_val(CONST_INTERBANKPAYMENTS.ATTR_FREEZE_OP_ID);
    BEGIN
        IF l_attr_am IS NULL THEN
            RETURN;
            /*raise_application_error(IBS.CONST_EXCEPTION.GENERAL_ERROR, 
                                    'У платежа {' || mobj.obj.ID || '} нет зарегистрированной операции для блокировки суммы на счете');    */
        END IF;
        BEGIN
        IBS.API_OPERATION.REMOVE_OPERATION(l_attr_am.value_int, 'Удаление заблокированной суммы для платежа {' || mobj.obj.ID || '}');
        EXCEPTION 
            WHEN OTHERS THEN
                api_interbankpayments.add_payment_change(mobj => mobj.obj, 
                                                p_result => 'Операции для удержания суммы {' || l_attr_am.value_int || '} нет в базе',
                                                p_action => 'jui_interbankpayments_tools.unfreeze_amount');
        END;
    END;
    
    FUNCTION add_chr_tostart(p_chr VARCHAR2, 
                             p_text VARCHAR2, 
                             p_from_line INTEGER DEFAULT 1) RETURN VARCHAR2 IS
        l_coll  ibs.t_clob_collection DEFAULT ibs.regexp_get_by_lines(p_text);
        l_ind   INTEGER DEFAULT l_coll.First;
        l_var   VARCHAR2(5000) DEFAULT p_text;
    BEGIN
         IF l_coll.count > 1 THEN
            l_var := '';
            WHILE l_ind IS NOT NULL
            LOOP
                l_var := l_var ||  CASE WHEN l_ind >= p_from_line AND  SUBSTR(l_coll(l_ind),0,LENGTH(p_chr)) <> p_chr THEN p_chr || l_coll(l_ind)
                                        ELSE  l_coll(l_ind)
                                   END;
                IF l_ind <> l_coll.LAST THEN l_var := l_var || chr(10); END IF;
                l_ind := l_coll.NEXT(l_ind);
            END LOOP;
         END IF;
         RETURN l_var;
    END;
    
    FUNCTION smart_normilize(p_text CLOB) RETURN CLOB IS
        p_clob            CLOB DEFAULT REPLACE(REPLACE(p_text, chr(13), ''), chr(10), ' ');
        l_result          CLOB DEFAULT NULL;
        l_char_perline    INTEGER DEFAULT 35;
        l_indx            INTEGER DEFAULT 0;
        l_piece           CLOB;
    BEGIN
        LOOP
            l_piece := jui_interbankpayments_tools.TRIMMING(SUBSTR(p_clob, l_indx*l_char_perline, l_char_perline));
            l_indx := l_indx +1;
            EXIT WHEN LENGTH(l_piece) = 0;
            l_result := l_result  || (CASE WHEN l_result IS NOT NULL THEN chr(13) || chr(10) ELSE '' END) || l_piece;
        END LOOP;
        RETURN l_result;
    end;
    
    FUNCTION normilize(p_text CLOB) RETURN CLOB IS
    BEGIN
        RETURN REGEXP_REPLACE(p_text, '\s{2,}',' '); --jui_interbankpayments_tools.TRIMMING(l_res);
    END;
    
    FUNCTION TRIMMING(p_var CLOB, l_in_start BOOLEAN DEFAULT TRUE) RETURN CLOB IS
        l_var CLOB DEFAULT TRIM(p_var);
    BEGIN
        l_var := CASE WHEN l_in_start AND SUBSTR(l_var, 1) IN (CHR(10),CHR(13)) THEN SUBSTR(l_var, 2, LENGTH(l_var))
                     ELSE l_var
                END;
        
        l_var := CASE WHEN SUBSTR(l_var, LENGTH(l_var)) IN (CHR(10), CHR(13)) THEN SUBSTR(l_var, 0, LENGTH(l_var)-1)
                        ELSE l_var
                 END;
    
        RETURN l_var;
    END;
    
    PROCEDURE freeze_amount(pid IN INTEGER)
    IS l_mobj  t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        freeze_amount(l_mobj);
    END;
    
    PROCEDURE unfreeze_amount(pid IN INTEGER)
    IS l_mobj      t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        unfreeze_amount(l_mobj);
    END;
    
    FUNCTION find_in_banks_list_by_swift (p_bik VARCHAR, p_raise BOOLEAN DEFAULT FALSE) 
    RETURN BANK_LIST%rowtype
    IS l_result bank_list%rowtype; 
    BEGIN
        SELECT * INTO l_result FROM bank_list b WHERE b.BANK_SWIFT = p_bik AND b.parent_id IS NULL;
        RETURN l_result;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN 
            IF p_raise THEN
                const_exceptions.raise_exception(const_exceptions.UNKNOW_BL);
            END IF;
            
            RETURN NULL;
    END;
	
    FUNCTION get_bank_date RETURN DATE
    IS BEGIN
        RETURN TRUNC(IBS.API_CALENDAR.GET_WORK_DAY(TRUNC(SYSDATE)));
    END;
    
    FUNCTION is_known_payment_system(p_payment_system_id INTEGER) RETURN BOOLEAN
    IS l_p IBS.ENUMERATION_VALUE%ROWTYPE DEFAULT IBS.API_ENUMERATION.READ_ENUMERATION_VALUE(CONST_INTERBANKPAYMENTS.ENUMTYPE_PAYMENT_SYSTEM, 
                                                                                            p_payment_system_id, 
                                                                                            FALSE);
    BEGIN
        RETURN NOT l_p.ENUM_ID IS NULL;
    END;
    
    FUNCTION is_known_msgtype(p_mtype INTEGER) RETURN BOOLEAN
    IS l_p IBS.ENUMERATION_VALUE%ROWTYPE DEFAULT IBS.API_ENUMERATION.READ_ENUMERATION_VALUE(CONST_INTERBANKPAYMENTS.ENUMTYPE_PAYMENT_MSGTYPE, p_mtype, FALSE);
    BEGIN
        RETURN NOT l_p.ENUM_ID IS NULL;
    END;
    
    FUNCTION is_emitentbank_bob (p_em_bik   IN VARCHAR2, p_raise BOOLEAN DEFAULT FALSE) RETURN INTEGER
	IS l_temp INTEGER;
    BEGIN
    	SELECT ID INTO l_temp FROM (SELECT BR.ID
                                    FROM IBS.OBJECT_CODE oc
                                    JOIN IBS.BRANCH br ON BR.SUBJECT_ID = OC.OBJECT_ID
                                    WHERE OC.CODE_KIND_ID = IBS.CONST_SUBJECT.CODE_KIND_CODE
                                          AND OC.OBJECT_CODE = p_em_bik ORDER BY BR.ID ASC) 
                              WHERE rownum = 1;
        RETURN l_temp;
    EXCEPTION
    	WHEN NO_DATA_FOUND THEN
        	IF p_raise = TRUE THEN
            	raise_application_error(IBS.CONST_EXCEPTION.GENERAL_ERROR, 'Бик {' || p_em_bik || '} не принадлежит нашему банку.');
            END IF;
        RETURN NULL;
    END;
    
    PROCEDURE remove_batching(p_batch_num VARCHAR2) IS
        l_msg   t_intbankpays_msg;
        /*
        l_str   t_intbankpays_attr DEFAULT l_msg.obj.get_attribute_val(const_interbankpayments.ATTR_BATCH_PAYMENT_NUM);*/
        t_temp_payment      t_interbankpayments DEFAULT t_interbankpayments();
        l_rc                sys_refcursor;
        l_payment           v_interbankpayments%rowtype;
    BEGIN
        t_temp_payment.ATTRS := t_intbankpays_attr_collection();
        t_temp_payment.ATTRS.extend;
        t_temp_payment.ATTRS(t_temp_payment.ATTRS.last) := t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_BATCH_PAYMENT_NUM, 
                                                                              value_int => p_batch_num,
                                                                              value_str => NULL);
        l_rc := jui_interbankpayments.get_payments(p_intpayment => t_temp_payment,
                                                   p_date_from => NULL);
        loop
            fetch l_rc into l_payment;
            exit when l_rc%notfound;
            l_msg := api_interbankpayments.getMessageTypeObject(pid => l_payment.ID);
            l_msg.remove_attribute(p_attr_id => const_interbankpayments.ATTR_BATCH_PAYMENT_NUM);
            l_msg.remove_attribute(p_attr_id => const_interbankpayments.ATTR_IS_BATCH_PARENT_MSG);
            l_msg.remove_attribute(p_attr_id => const_interbankpayments.ATTR_IS_BATCH_RELATED_MSG);
            l_msg.obj.update_payment;
        end loop;
    END;    
    
    FUNCTION get_branch_bik (p_branch_id IN INTEGER, p_raise BOOLEAN DEFAULT FALSE) RETURN VARCHAR
    IS l_temp VARCHAR(20);
    BEGIN
        SELECT OC.OBJECT_CODE INTO l_temp
        FROM IBS.OBJECT_CODE oc
        JOIN IBS.BRANCH br ON BR.SUBJECT_ID = OC.OBJECT_ID AND BR.ID = p_branch_id
        WHERE OC.CODE_KIND_ID = IBS.CONST_SUBJECT.CODE_KIND_CODE;
        RETURN l_temp;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF p_raise = TRUE THEN const_exceptions.raise_exception(const_exceptions.BRANCH_UNKNOWN, p_branch_id || '');
            END IF;
        RETURN NULL;
    END;

    FUNCTION update_transaction(p_ground IN VARCHAR2,  p_mobj IN OUT t_intbankpays_msg) RETURN INTEGER
    IS 
    	l_operation ibs.operation%rowtype DEFAULT ibs.api_operation.read_operation(p_mobj.obj.OPERATION_ID, p_is_raise_ndf => false);
    BEGIN
    	IF l_operation.id IS NOT NULL THEN
    		ibs.api_operation.remove_operation_chain(l_operation.operation_chain_id, p_ground);
            p_mobj.obj.OPERATION_ID := NULL;
            p_mobj.obj.update_payment;
            
            api_interbankpayments.add_payment_change(mobj => p_mobj.obj, 
                               p_action => 'jui_interbankpayments_tools.update_transaction',
                               p_desc => 'Operation id ' || l_operation.id || ' has been deleted',
                               p_additional => p_ground
                               );
        END IF;
        --- Change adder        
        api_interbankpayments.add_payment_change(mobj => p_mobj.obj, 
                           p_action => 'jui_interbankpayments_tools.update_transaction',
                           p_additional => p_ground
                           );
        ---/ Change adder
        p_mobj.create_operation;
        RETURN p_mobj.obj.OPERATION_ID;
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => p_mobj.obj, 
                                                       p_action => 'jui_interbankpayments_tools.update_transaction', 
                                                       p_autonomus => TRUE,
                                                       p_result => SQLERRM || '',
                                                       p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;
    
    /** @TODO  Переписать. Все в одном селекте сделать */
    FUNCTION get_messages_by_batch_num(p_batch_num IN NUMBER, p_without_parent BOOLEAN DEFAULT FALSE) RETURN t_intbankpays_msg_collection IS
        l_msgs t_intbankpays_msg_collection;
    BEGIN
        SELECT api_interbankpayments.getMessageTypeObject(s.id) BULK COLLECT INTO l_msgs
        FROM interbankpayments s, TABLE(s.Attrs) x 
        WHERE x.value_int = p_batch_num 
              AND x.id_attr = const_interbankpayments.ATTR_BATCH_PAYMENT_NUM;
        
        IF p_without_parent THEN
            FOR indx IN l_msgs.FIRST .. l_msgs.LAST
            LOOP
                IF l_msgs(indx).obj.isset_attribute(const_interbankpayments.ATTR_IS_BATCH_PARENT_MSG) THEN
                    l_msgs.delete(indx);
                    EXIT;
                END IF;
            END LOOP;
        END IF;
        
        RETURN l_msgs;
    END;
   
    PROCEDURE set_batch_payments_status(p_msg IN OUT NOCOPY t_intbankpays_msg, p_state INTEGER, p_err_msg VARCHAR DEFAULT NULL) IS
        p_batch_num INTEGER DEFAULT p_msg.obj.get_attribute_val(const_interbankpayments.ATTR_BATCH_PAYMENT_NUM).value_int;
        l_payments  t_intbankpays_msg_collection;
        l_ind       INTEGER;
        l_temp      BOOLEAN;
    BEGIN
        IF p_batch_num IS NOT NULL THEN 
            dbms_output.put_line(p_batch_num);
            l_payments  := jui_interbankpayments_tools.get_messages_by_batch_num(p_batch_num => p_batch_num, 
                                                                                 p_without_parent => FALSE);
            dbms_output.put_line(l_payments.count);
            l_ind := l_payments.FIRST;                                                                     
            WHILE l_ind IS NOT NULL
            LOOP
                dbms_output.put_line(l_payments(l_ind).obj.reference);
                l_temp := l_payments(l_ind).set_state(p_state);
                IF p_err_msg IS NOT NULL THEN
                    l_payments(l_ind).update_attribute( p_attr_id => const_interbankpayments.ATTR_CBAR_RESP_ERROR_MSG, 
                                                        p_value_str => p_err_msg);
                END IF;
                l_payments(l_ind).obj.update_payment;
                l_ind := l_payments.NEXT(l_ind);
            END LOOP;
        ELSE 
            l_temp := p_msg.set_state(p_state);
            IF p_err_msg IS NOT NULL THEN
                p_msg.update_attribute( p_attr_id => const_interbankpayments.ATTR_CBAR_RESP_ERROR_MSG, 
                                        p_value_str => p_err_msg);
            END IF;
            p_msg.obj.update_payment;
        END IF;
        --raise_application_error(-20000, p_batch_num);
    END;
        
    PROCEDURE roll_back_operation(p_mobj IN OUT t_intbankpays_msg) IS
        l_operation ibs.operation%ROWTYPE;
    BEGIN
        IF p_mobj.obj.OPERATION_ID IS NOT NULL THEN
            l_operation := ibs.api_operation.read_operation(p_mobj.obj.OPERATION_ID, p_is_raise_ndf => FALSE);
            IF l_operation.id IS NOT NULL THEN
                IF l_operation.operation_chain_id IS NOT NULL THEN
                    ibs.api_operation.remove_operation_chain(l_operation.operation_chain_id, 'Payment {' || p_mobj.obj.ID || '} has been canceled');
                    api_interbankpayments.add_payment_change(mobj => p_mobj.obj, 
                               p_action => 'jui_interbankpayments_tools.roll_back_operation',
                               p_additional => 'Operation have rollbacked successufull'
                               );
                ELSE
                    api_interbankpayments.add_payment_change(mobj => p_mobj.obj, 
                               p_action => 'jui_interbankpayments_tools.roll_back_operation',
                               p_additional => 'Opeartion has not chain'
                               );
                END IF;
            ELSE  p_mobj.obj.OPERATION_ID := NULL;
            END IF;
        ELSE
           api_interbankpayments.add_payment_change(mobj => p_mobj.obj, 
                           p_action => 'jui_interbankpayments_tools.roll_back_operation',
                           p_additional => 'Operation is NULL - can not rollback it'
                           );
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => p_mobj.obj, 
                                                       p_action => 'jui_interbankpayments_tools.update_transaction', 
                                                       p_autonomus => TRUE,
                                                       p_result => SQLERRM || '',
                                                       p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;
    
    /************************************************************* List functions **************************************************/
    FUNCTION get_all_list RETURN SYS_REFCURSOR
    IS l_cursor SYS_REFCURSOR;
    BEGIN
        OPEN l_cursor FOR   SELECT  jui_interbankpayments_tools.get_status_list,
                                    jui_interbankpayments_tools.get_beneficiar_banks_list,
                                    jui_interbankpayments_tools.get_messages_type_list,
                                    jui_interbankpayments_tools.get_payment_system_list,
                                    jui_interbankpayments_tools.get_users_list,
                                    jui_interbankpayments_tools.get_currency_list
                            FROM DUAL;
        RETURN l_cursor;    
    END;
    
    FUNCTION get_currency_list RETURN ibs.t_two_string_collection
    IS l_res ibs.t_two_string_collection;
    BEGIN
        SELECT ibs.t_two_string_id(bl.id, bl.iso_name) BULK COLLECT INTO l_res
        FROM ibs.currency bl;
        RETURN l_res;
    END;
    FUNCTION get_beneficiar_banks_list_az RETURN ibs.t_two_string_collection
    IS l_res ibs.t_two_string_collection;
    BEGIN
        SELECT ibs.t_two_string_id(bl.bank_code, bl.bank_name) BULK COLLECT INTO l_res
        FROM bank_list bl WHERE SUBSTR(bl.bank_swift, 5, 2) = 'AZ';
        RETURN l_res;
    END;
    FUNCTION get_beneficiar_banks_list RETURN ibs.t_two_string_collection
    IS l_res ibs.t_two_string_collection;
    BEGIN
        SELECT ibs.t_two_string_id(bl.bank_code, bl.bank_name) BULK COLLECT INTO l_res
        FROM bank_list bl;
        RETURN l_res;
    END;
    
    FUNCTION get_banks_list RETURN SYS_REFCURSOR
    IS l_res SYS_REFCURSOR;
    BEGIN
        OPEN l_res FOR SELECT * FROM bank_list bl;
        RETURN l_res;
    END;
    
    
    FUNCTION get_status_list RETURN ibs.t_two_string_collection IS
    BEGIN
        RETURN get_enum_as_list(const_interbankpayments.ENUMTYPE_PAYMENT_STATE);
    END;
    
    FUNCTION get_enum_as_list(p_enum_type INTEGER) RETURN  ibs.t_two_string_collection
    IS l_res ibs.t_two_string_collection;
    BEGIN
        SELECT ibs.t_two_string_id(to_char(ev.enum_id), ev.enum_name) BULK COLLECT INTO l_res
        FROM ibs.enumeration_value ev
        WHERE ev.enum_type_id = p_enum_type;
        RETURN l_res;
    END;
    
    FUNCTION get_messages_type_list(p_grandtolist INTEGER DEFAULT NULL) RETURN ibs.t_two_string_collection
    IS  l_res ibs.t_two_string_collection;
        l_user_access ibs.t_integer_collection DEFAULT NULL;
    BEGIN
        IF p_grandtolist IS NOT NULL THEN
            BEGIN l_user_access := api_interbankpayments_access.get_access_messges_types(p_grand => nvl(p_grandtolist, 
                                                                                                        const_interbankpayments.ACCESS_CREATE));
            EXCEPTION WHEN OTHERS THEN l_user_access := NULL;
            END;
        END IF;
        SELECT ibs.t_two_string_id(to_char(ev.enum_id), ev.enum_name) BULK COLLECT INTO l_res
        FROM ibs.enumeration_value ev
        WHERE ev.enum_type_id = CONST_INTERBANKPAYMENTS.ENUMTYPE_PAYMENT_MSGTYPE AND
              (ev.enum_id IN (SELECT * FROM TABLE(l_user_access)) OR l_user_access IS NULL);
        RETURN l_res;
    END;
    
    FUNCTION get_parent_banks_list RETURN ibs.t_two_string_collection
    IS l_res ibs.t_two_string_collection;
    BEGIN
        SELECT ibs.t_two_string_id(p.id, p.bank_name || ' - ' || p.bank_swift) BULK COLLECT INTO l_res
        FROM bank_list p 
        WHERE p.parent_id IS NULL;
        RETURN l_res;
    END;
    
    FUNCTION get_payment_system_list RETURN ibs.t_two_string_collection
    IS l_res ibs.t_two_string_collection;
    BEGIN
        SELECT ibs.t_two_string_id(p.id, p.payment_system_name) BULK COLLECT INTO l_res
        FROM ibs.payment_system p 
        WHERE p.payment_system_name IN ('NPS','AZIPS','XOHKS','SWIFT');
        RETURN l_res;
    END;
   -- Переименовать тип t_mt113_corr_bank_acc_col и t_mt113_corr_bank_acc в t_bank_corr__acc
    FUNCTION get_mt113_corr_bank (p_swift VARCHAR2)  RETURN t_mt113_corr_bank_acc_col IS
        l_col_result t_mt113_corr_bank_acc_col;
    BEGIN
       SELECT t_mt113_corr_bank_acc(id => mt113cb.id, 
                                    bank_list_id => mt113cb.bank_list_id,
                                    bank_name => bl.bank_name,
                                    bank_swift => bl.bank_swift,
                                    currency => mt113cb.currency,
                                    account => mt113cb.account,
                                    acc_type => mt113cb.acc_type,
                                    account_bob => mt113cb.account_bob) BULK COLLECT INTO l_col_result
       FROM BANK_LIST_CORR_ACCOUNT mt113cb
       JOIN bank_list bl ON bl.id = mt113cb.bank_list_id
       WHERE bl.bank_swift = p_swift AND bl.parent_id IS NULL AND rownum = 1;
       RETURN l_col_result;
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
    END;
    
    PROCEDURE remove_bank_corr_account(p_bank_cor_acc_id INTEGER) IS
    BEGIN
        DELETE FROM bank_list_corr_account b WHERE b.id = p_bank_cor_acc_id;
    END;
    
    PROCEDURE update_bank_corr_account(p_currency INTEGER,
                                       p_account VARCHAR2,
                                       p_acc_type VARCHAR2,
                                       p_account_bob VARCHAR2,
                                       p_bank_list_id INTEGER DEFAULT NULL,
                                       p_bank_swift VARCHAR2 DEFAULT NULL) 
    IS
        l_bank_id INTEGER DEFAULT nvl(p_bank_list_id, find_in_banks_list_by_swift(p_bank_swift, FALSE).ID);
    BEGIN
        IF l_bank_id IS NOT NULL THEN
            merge into bank_list_corr_account b using dual on ( bank_list_id = l_bank_id AND 
                                                                currency = p_currency AND
                                                                acc_type = p_acc_type) 
                    when not matched then insert (bank_list_id, currency, account, acc_type, account_bob) 
                                          values (l_bank_id, p_currency, p_account, p_acc_type, p_account_bob)
                    when matched then update set account = p_account, account_bob = p_account_bob;
        END IF;
    END;
    
    FUNCTION get_bank_corr_account(p_bank_id INTEGER) RETURN SYS_REFCURSOR IS
        l_res SYS_REFCURSOR;
    BEGIN
        OPEN l_res FOR SELECT * FROM v_banks_list_corr_acc a WHERE a.BANK_LIST_ID = p_bank_id OR p_bank_id IS NULL;
        RETURN l_res;
    END;
    
    FUNCTION get_bank_corr_account (p_swift VARCHAR2, p_currency INTEGER, p_acc_type VARCHAR2) RETURN t_mt113_corr_bank_acc IS
        l_result t_mt113_corr_bank_acc;
    BEGIN
       SELECT t_mt113_corr_bank_acc(id => mt113cb.id, 
                                    bank_list_id => mt113cb.bank_list_id,
                                    bank_name => bl.bank_name,
                                    bank_swift => bl.bank_swift,
                                    currency => mt113cb.currency,
                                    account => mt113cb.account,
                                    acc_type => mt113cb.acc_type,
                                    account_bob => mt113cb.account_bob) INTO l_result
       FROM BANK_LIST_CORR_ACCOUNT mt113cb
       JOIN bank_list bl ON bl.id = mt113cb.bank_list_id
       WHERE bl.bank_swift = p_swift AND bl.parent_id IS NULL AND rownum = 1
             AND mt113cb.currency = p_currency AND mt113cb.acc_type = p_acc_type;
       RETURN l_result;
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN NULL;
    END;
    
    
    FUNCTION get_users_list (p_role INTEGER DEFAULT const_interbankpayments.USER_ROLE_CREATOR)  RETURN ibs.T_TWO_STRING_COLLECTION
    IS l_users_list ibs.t_two_string_collection;
       l_user_roles ibs.t_integer_collection DEFAULT ibs.swa_process.get_user_roles;
    BEGIN
       SELECT ibs.t_two_string_id(su.id, su.login_name || ' / ' || su.user_name) BULK COLLECT INTO l_users_list
       FROM ibs.swa_user su
       WHERE EXISTS (SELECT NULL FROM interbankpayments s WHERE s.creator_id = su.id)
       --WHERE (const_interbankpayments.USER_ROLE_CREATOR member OF l_user_roles)
       ;
       RETURN l_users_list;
    END;

    
    
    FUNCTION GET_NR_CODE(P_COUNTRY_2  VARCHAR2,
                       P_NR_2       VARCHAR2,
                       P_SWIFT_4    VARCHAR2,
                       P_ACCOUNT_20 VARCHAR2) RETURN VARCHAR2 IS
        L_RES VARCHAR2(2 CHAR);
        L_STR2 VARCHAR2(50 CHAR) := P_SWIFT_4 || P_ACCOUNT_20 || P_COUNTRY_2 || P_NR_2;
        L_CH   VARCHAR2(1 CHAR);
        A      NUMBER;
        I      NUMBER;
        S      NUMBER;
        L      NUMBER;
        D      NUMBER;
    BEGIN
        FOR I IN 0 .. 25 LOOP
            L_CH   := CHR(I + 65);
            L_STR2 := REPLACE(L_STR2, L_CH, TO_CHAR(I + 10));
        END LOOP;
        L := LENGTH(L_STR2);
        A := 1;
        I := 0;
        S := 0;
        WHILE I < L LOOP
            BEGIN
                D := SUBSTR(L_STR2, L - I, 1);
                IF I = 0 THEN A := 1; 
                ELSE A := MOD((A * 10), 97);
                END IF;
                S := S + A * D;
                I := I + 1;
            EXCEPTION
                WHEN OTHERS THEN RETURN 'Er';
            END;
        END LOOP;
        D := 98 - MOD(S, 97);
        L_RES := LPAD(D, 2, '0');
        RETURN L_RES;
    END GET_NR_CODE;
    
    FUNCTION is_struct_type_exist(p_obj t_interbankpayments_extend, p_postfix VARCHAR DEFAULT NULL) RETURN BOOLEAN IS
    BEGIN RETURN is_struct_type_exist(p_obj.system_id, p_obj.message_type, p_postfix); END;
  
    FUNCTION is_struct_type_exist(p_msg t_intbankpays_msg, p_postfix VARCHAR DEFAULT NULL) RETURN BOOLEAN IS
    BEGIN RETURN is_struct_type_exist(p_msg.obj.system_id, p_msg.obj.message_type, p_postfix); END;

    FUNCTION is_struct_type_exist(p_system VARCHAR, p_message_type VARCHAR, p_postfix VARCHAR DEFAULT NULL) RETURN BOOLEAN IS
        l_result            T_MESSAGE_STRUCT;
        l_mt                VARCHAR2(100);
        l_temp_obj          t_interbankpayments_extend DEFAULT t_interbankpayments_extend();
        l                   INTEGER;
    BEGIN
        IF p_system IS NOT NULL THEN l_mt := l_mt || '_' || p_system; END IF;
        IF p_message_type IS NOT NULL THEN l_mt := l_mt || '_' || p_message_type; END IF;   
        
        -- Херово, конечно, каждый раз делать запрос, но другого варианта пока нет
        SELECT 1 INTO l
        FROM sys.all_objects d 
        WHERE   d.OBJECT_TYPE = 'TYPE' 
                AND d.OBJECT_NAME = 'T_MESSAGE_STRUCT' || l_mt || p_postfix
                AND d.OWNER = 'IPAY';
        
        RETURN TRUE;
    EXCEPTION WHEN NO_DATA_FOUND THEN RETURN FALSE;
    END; 
end jui_interbankpayments_tools;
/
