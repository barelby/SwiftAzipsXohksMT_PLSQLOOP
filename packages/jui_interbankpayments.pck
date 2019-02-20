create or replace package jui_interbankpayments is
    -- Author  : RVKHALAFOV
    -- Created : 3/4/2016 12:01:33
    -- Purpose : 
    -- Конст. пакет: 	const_interbankpayments
    -- Api пакет: 		api_interbankpayments
    -- Пакет утилит: 	jui_interbankspayments_tools
    -- Таблицы:			interbankpayments
    -- View				v_interbankpayments
    FUNCTION new_payment_standalone_as_msg(p_mobj t_interbankpayments) RETURN t_intbankpays_msg;
    FUNCTION new_payment_standalone(p_mobj t_interbankpayments) RETURN v_interbankpayments%ROWTYPE;
    -- Создает новый платеж
    FUNCTION new_payment(p_msg_type     IN INTEGER,
    					 p_payment_date	IN DATE		DEFAULT NULL,
                         p_system_id    IN INTEGER  DEFAULT const_interbankpayments.CFG_DEFAULT_SYSTEM_ID,
                         p_user_id      IN INTEGER  DEFAULT ibs.api_context.get_def_user,      
                         p_operation    IN INTEGER  DEFAULT NULL,                   
                         p_branch_id    IN INTEGER  DEFAULT ibs.api_context.get_def_branch,
                         p_currency     IN INTEGER  DEFAULT const_interbankpayments.CFG_DEFAULT_CURRENCY,
                         p_auto_commit  IN BOOLEAN  DEFAULT TRUE,
                         p_attributes   IN T_INTBANKPAYS_ATTR_COLLECTION DEFAULT NULL)				
    RETURN v_interbankpayments%ROWTYPE;
    
    FUNCTION new_payment(p_mobj t_interbankpayments, p_auto_commit  IN BOOLEAN  DEFAULT TRUE)				
    RETURN v_interbankpayments%ROWTYPE;
    
    FUNCTION state_to_complete(pid INTEGER) 
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    FUNCTION state_to_complete(pids ibs.t_integer_collection) 
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    -- Переводит платеж на верификациюstate_to_authorization
    FUNCTION state_to_verification	(pid INTEGER)		
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    FUNCTION state_to_verification(pids ibs.t_integer_collection) 
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    -- Возвращает платеж на изменения
    FUNCTION state_to_changing(pid INTEGER,  p_comments BLOB DEFAULT NULL)		
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    -- Возвращает платеж на изменения
    FUNCTION state_to_authorization	(pid INTEGER)		
	RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    FUNCTION state_to_authorization(pids ibs.t_integer_collection) 
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    -- Возвращает платеж на изменения из авторизации
    FUNCTION state_to_changing_auth	(pid INTEGER)								
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    -- Переводит платеж в черновик
    FUNCTION state_to_draft			(pid INTEGER)								
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    -- Переводит платеж в черновик
    FUNCTION state_copy_from_draft	(pid INTEGER)								
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    -- Отменяет платеж
    FUNCTION state_to_cancel		(pid INTEGER)								
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    PROCEDURE deletePayment          (pid INTEGER);
    
    -- Отклоняет платеж
    FUNCTION state_reject			(pid INTEGER)								
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    -- Установка даты платежа
    FUNCTION set_payment_date(pid IN INTEGER, p_var IN DATE)				
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    -- Установка платежной системы 
    FUNCTION set_system_id(pid IN INTEGER,p_var IN INTEGER DEFAULT NULL,p_auto_detect boolean DEFAULT TRUE)			
	RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    -- Установка установка типа сообщения
    FUNCTION set_message_type(pid IN INTEGER,p_var IN INTEGER)							
	RETURN V_INTERBANKPAYMENTS%ROWTYPE;

    -- Установка суммы платежа
    FUNCTION set_amount(pid IN INTEGER, p_var IN NUMBER) 
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;

    -- Установка валюты платежа
    FUNCTION set_currency(pid IN INTEGER,p_var IN INTEGER DEFAULT const_interbankpayments.CFG_DEFAULT_CURRENCY)
	RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    -- Установка комиссии по объекту t_fee_amount
    FUNCTION set_fee(pid IN INTEGER,p_var IN ibs.t_fee_amount)		
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    -- Установка комиссии по сумме и валюте комиссии
    FUNCTION set_fee(pid IN INTEGER,p_var IN NUMBER, p_currency IN INTEGER DEFAULT NULL)		
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    -- Установка основания платежа
    FUNCTION set_ground(pid IN INTEGER,p_var IN VARCHAR2)		
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    -- Установка операции
    FUNCTION set_manual_operation_id(pid IN INTEGER,p_var IN INTEGER)		
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    /**
    * Обновляет реферальный номер
    * @param pid                    integer     Ид платежа
    */
    FUNCTION refresh_reference(pid INTEGER) 
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    /**
    * Установка филиала плательщика
    * @param pid                    integer     Ид платежа
    * @param p_var                  integer     Новое значение
    */
    FUNCTION set_payer_branch_id(pid IN INTEGER,p_var IN INTEGER)		
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    FUNCTION update_to_correct_bank_date(pid IN INTEGER, p_date DATE DEFAULT NULL) RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    /**
    * Установка счета плательщика по номеру счета
    * @param pid                    integer     Ид платежа
    * @param p_var                  integer     Новое значение
    * @param p_set_auto_branch      boolean     Автоопределение по счету филиал и устанавливать его для платежа
    * @param p_set_auto_currency    boolean     Автоопределение по счету валюту и устанавливать его для платежа
    * @param p_check_enough         boolean     Проверять наличие доступности суммы платежа на счете 
    */
    FUNCTION set_payer_account(pid IN INTEGER,
    							p_var IN VARCHAR2)		
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;

    -- Установка счета плательщика по ид счета в базе
    FUNCTION set_payer_account(pid IN INTEGER,
    							p_account_id IN INTEGER,
    							p_set_auto_branch	in boolean DEFAULT TRUE,
                                p_set_auto_currency in boolean DEFAULT TRUE,
                                p_check_enough		in boolean DEFAULT TRUE)		
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    -- Установка имение получателя
    FUNCTION set_receiver_name(pid IN INTEGER,p_var IN VARCHAR2)		
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    -- Установка IBAN-а получателя
    FUNCTION set_receiver_iban(pid IN INTEGER,p_var IN VARCHAR2)		
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    -- Установка ИНН получателя
    FUNCTION set_receiver_tax(pid IN INTEGER,p_var IN VARCHAR2)		
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    -- Установка БИК банка-отправителя (стандартно наш банк)
    FUNCTION set_emitent_bank_code(pid IN INTEGER,p_var IN VARCHAR2,p_auto_branch_id BOOLEAN DEFAULT TRUE)		
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    -- Установка названия банка-получателя 
    FUNCTION set_beneficiar_bank_name(pid IN INTEGER,p_var IN VARCHAR2)        
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    FUNCTION set_beneficiar_bank_corr_acc(pid IN INTEGER, p_var IN VARCHAR2) 
    RETURN v_interbankpayments%ROWTYPE;
    
    -- Установка БИК банка-получателя 
    FUNCTION set_beneficiar_bank_code(pid IN INTEGER,p_var IN VARCHAR2)		
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    -- Установка SWIFT банка-получателя 
    FUNCTION set_beneficiar_bank_swift(pid IN INTEGER,p_var IN VARCHAR2)		
    RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    -- Установка ид филиала 
    --FUNCTION set_payer_branch_id(pid IN INTEGER, p_var IN VARCHAR2)       	RETURN v_interbankpayments%ROWTYPE;
    -- Обновляет комисии
    PROCEDURE update_fee_collection(pid INTEGER);
    
    -- Attributes
    -- Проверяет наличие атрибута у платежки
    FUNCTION isset_attribute(pid IN INTEGER, p_attr_id INTEGER) 
    RETURN BOOLEAN;
    
    -- Возвращает все атрибуты платежа  
    FUNCTION get_attributes (pid in INTEGER, p_raise_error BOOLEAN DEFAULT FALSE) 
    RETURN t_intbankpays_attr_collection;
    
    --Возвращает значение атрибута платежа
    FUNCTION get_attribute_val(pid IN INTEGER, p_attr_id INTEGER,  p_raise_error BOOLEAN DEFAULT FALSE) 
    RETURN t_intbankpays_attr;

    -- Обновление атрибута платежки, если нет атрибута, то создает его 
    FUNCTION update_attr_val(pid IN INTEGER, p_id_attr IN INTEGER, 
                                              p_val_str IN VARCHAR2 DEFAULT NULL, 
                                              p_val_int IN NUMBER DEFAULT NULL) RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    
    -- Удаляет атрибут у платежа
    FUNCTION remove_attr(pid IN INTEGER, p_id_attr IN INTEGER) RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    -- Главная функция возврата платежей по фильтру
    FUNCTION get_payments(p_intpayment    IN T_INTERBANKPAYMENTS,
                          p_date_from     DATE    DEFAULT TRUNC(SYSDATE),
                          p_date_to       DATE    DEFAULT TRUNC(SYSDATE),
                          p_min_amount    NUMBER  DEFAULT 0.0,
                          p_max_amount    NUMBER  DEFAULT 9999999999.99,
                          p_states        ibs.t_integer_collection DEFAULT NULL,
                          p_payments_id ibs.t_integer_collection DEFAULT NULL) RETURN SYS_REFCURSOR;

    -- Перегруженная функция возврата платежей по функции
    FUNCTION get_payments(p_system      INTEGER DEFAULT NULL,
                          p_msg_type    INTEGER DEFAULT NULL,
                          p_state       INTEGER DEFAULT NULL,
                          p_states      ibs.t_integer_collection DEFAULT NULL,
                          p_refer_num   VARCHAR DEFAULT NULL,
                          p_date_from   DATE    DEFAULT NULL,
                          p_date_to     DATE    DEFAULT NULL,
                          p_min_amount  NUMBER  DEFAULT 0.0,
                          p_max_amount  NUMBER  DEFAULT NULL,
                          p_user        INTEGER DEFAULT NULL,
                          p_currency    INTEGER DEFAULT NULL,
                          p_branch      INTEGER DEFAULT NULL,
                          p_rec_iban    VARCHAR DEFAULT NULL,
                          p_rec_tax     VARCHAR DEFAULT NULL,
                          p_bn_code     VARCHAR DEFAULT NULL,
                          p_payer_acc   VARCHAR DEFAULT NULL,
                          p_payments_id ibs.t_integer_collection DEFAULT NULL) RETURN SYS_REFCURSOR;--RETURN T_INTERBANKPAYMENTS_COLLECTION;
    
    PROCEDURE set_payment_comments(pid INTEGER, p_comments BLOB);
    FUNCTION get_payment_comments(p_id INTEGER) RETURN BLOB;
    
    
    
    
   /******************************************* Other ***************************/
   -- Для обратной совместимости
   FUNCTION create_interbank_payment(p_branch_id  in number,                   --ИД филиала
                                        p_bbank_code in varchar2,               --БИК банка
                                        p_pay_acc    in varchar2,               --Аккаунт плательщика
                                        p_rec_iban   in varchar2,               --Ибан счет получателя
                                        p_rec_name   in varchar2,               --Имя получателя
                                        p_rec_tax    in varchar2,               --ИНН получателя
                                        p_amount     in number,                 --Сумма
                                        p_ground     in varchar2,               --Основание
                                        p_order      in INTEGER,                --Признак "серенджам" 1/0
                                        p_inkasso    in integer,                --Признак "инкассо"   1/0
                                        p_bud_dest   in varchar2,               --Бюджетный код destination
                                        p_bud_level  in varchar2,               --Бюджетный код level
                                        p_msg_type   in integer,                -- Тип сообщения
                                        p_add_info   in varchar2    default null,  --Доп информация
                                        p_fee        in number      default null,    --Комиссия(ручной ввод)    
                                        p_ground2    in varchar2    default null,
                                        p_acc_deb    in varchar2    default null,
                                        p_acc_crd    in varchar2    default null,                                        
                                        p_pay_sys    in varchar2    default null
                                        ) RETURN INTEGER;
end jui_interbankpayments;
/
create or replace package body jui_interbankpayments  IS
    /*************************************************** Moves **************************************************/
    FUNCTION new_payment_standalone_as_msg(p_mobj t_interbankpayments) RETURN t_intbankpays_msg IS
        l v_interbankpayments%ROWTYPE;
    BEGIN
        l := new_payment_standalone(p_mobj);
        RETURN api_interbankpayments.getMessageTypeObject(l.ID);
    END;
    
    FUNCTION new_payment_standalone(p_mobj t_interbankpayments) RETURN v_interbankpayments%ROWTYPE IS
        l v_interbankpayments%ROWTYPE;
        l_newpobj t_intbankpays_msg;
        l_ground  VARCHAR2(5000) DEFAULT p_mobj.GROUND;
        
        FUNCTION normilize_ib_ground(l_ground VARCHAR2) RETURN VARCHAR2 IS
            l_cur     INTEGER DEFAULT 0 ;
            l_replace_source    VARCHAR2(5000) DEFAULT l_ground;
            l_indx    INTEGER DEFAULT LENGTH(l_replace_source)/35;
            l_result  CLOB;
        BEGIN
            l_replace_source := jui_interbankpayments_tools.normilize(REPLACE(REPLACE(REPLACE(l_replace_source, chr(13) || chr(10),' '), chr(13), ' '), chr(10), ' '));
            WHILE l_cur < l_indx
            LOOP
                l_result := l_result || LTRIM(SUBSTR((l_replace_source), l_cur*35, 35))  || 
                CASE WHEN l_cur+1 < l_indx THEN chr(13) || chr(10) ELSE '' END;
                l_cur := l_cur + 1 ;
            END LOOP;
            RETURN l_result;
        END;
        
    BEGIN
        l := new_payment(p_mobj, p_auto_commit => FALSE);
        l_newpobj :=  api_interbankpayments.getMessageTypeObject(l.ID);
        ---- Emitent
        l_newpobj.set_emitent_bank_code(p_mobj.EMITENT_BANK_CODE);
        IF p_mobj.EMITENT_BANK_CORR_ACCOUNT IS NOT NULL THEN l_newpobj.set_emitent_bank_code(p_mobj.EMITENT_BANK_CORR_ACCOUNT); END IF;
        ---- Beneficiar
        l_newpobj.set_beneficiar_bank_code(p_mobj.BENEFICIAR_BANK_CODE);
        IF p_mobj.BENEFICIAR_BANK_NAME IS NOT NULL THEN l_newpobj.set_beneficiar_bank_name(p_mobj.BENEFICIAR_BANK_NAME);END IF;
        IF p_mobj.BENEFICIAR_BANK_SWIFT IS NOT NULL THEN l_newpobj.set_beneficiar_bank_swift(p_mobj.BENEFICIAR_BANK_SWIFT); END IF;
        IF p_mobj.BENEFICIAR_BANK_TAX IS NOT NULL THEN l_newpobj.set_beneficiar_bank_tax(p_mobj.BENEFICIAR_BANK_TAX); END IF;
        IF p_mobj.BENEFICIAR_BANK_CORR_ACCOUNT IS NOT NULL THEN l_newpobj.set_beneficiar_bank_corr_acc(p_mobj.BENEFICIAR_BANK_CORR_ACCOUNT); END IF;
        ---- Payer Info        
        l_newpobj.set_payer_account(p_mobj.PAYER_ACCOUNT);
        ---- Receiver Info
        l_newpobj.set_receiver_iban(p_mobj.RECEIVER_IBAN);
        IF p_mobj.RECEIVER_NAME IS NOT NULL THEN l_newpobj.set_receiver_name(p_mobj.RECEIVER_NAME); END IF;
        IF p_mobj.RECEIVER_TAX IS NOT NULL THEN l_newpobj.set_receiver_tax(p_mobj.RECEIVER_TAX); END IF;
        ---- Financial Info
        l_newpobj.set_amount(p_mobj.AMOUNT);
        IF p_mobj.CURRENCY IS NOT NULL THEN  l_newpobj.set_currency(p_mobj.CURRENCY); END IF;
        
        l_newpobj.set_ground( CASE WHEN jui_interbankpayments_tools.is_IB_user(ibs.api_context.get_def_user) THEN
                                        normilize_ib_ground(l_ground)
                                    ELSE l_ground
                              END);
        l_newpobj.obj.update_payment;
        l_newpobj.obj.attrs := nvl(p_mobj.ATTRS, t_intbankpays_attr_collection());
        RETURN api_interbankpayments.read_payment_view(l.ID, TRUE);
    END;
    
    FUNCTION new_payment(p_mobj t_interbankpayments, p_auto_commit  IN BOOLEAN  DEFAULT TRUE) RETURN v_interbankpayments%ROWTYPE IS
        l_id INTEGER;
        l_newpobj t_intbankpays_msg;
    BEGIN
        l_id := api_interbankpayments.new_payment(p_mobj, p_auto_commit => p_auto_commit);
        l_newpobj :=  api_interbankpayments.getMessageTypeObject(l_id);
        api_interbankpayments.add_payment_change(mobj => l_newpobj.obj, 
                                                 p_action => 'jui_interbankpayments.new_payment', 
                                                 p_additional => 'Created. Payment date is ' || 
                                                                  to_char(l_newpobj.obj.PAYMENT_DATE,'dd-MM-YYYY'));
        l_newpobj.onCreate();
        l_newpobj.obj.update_payment;
        RETURN api_interbankpayments.read_payment_view(l_id, TRUE);
    END;

    FUNCTION new_payment(p_msg_type     IN INTEGER,
    					 p_payment_date	IN DATE		DEFAULT NULL,
                         p_system_id    IN INTEGER  DEFAULT const_interbankpayments.CFG_DEFAULT_SYSTEM_ID,
                         p_user_id      IN INTEGER  DEFAULT ibs.api_context.get_def_user,  
                         p_operation    IN INTEGER  DEFAULT NULL,                       
                         p_branch_id    IN INTEGER  DEFAULT ibs.api_context.get_def_branch,
                         p_currency     IN INTEGER  DEFAULT const_interbankpayments.CFG_DEFAULT_CURRENCY,                         
                         p_auto_commit  IN BOOLEAN  DEFAULT TRUE,
                         p_attributes   IN T_INTBANKPAYS_ATTR_COLLECTION DEFAULT NULL) 
                         RETURN v_interbankpayments%ROWTYPE
    IS  
        l_pobj      t_interbankpayments_extend DEFAULT t_interbankpayments_extend();
        l_newpayid  INT;
    BEGIN
      
        l_pobj.MESSAGE_TYPE     := p_msg_type;
        l_pobj.SYSTEM_ID        := p_system_id;
        l_pobj.CREATOR_ID       := nvl(p_user_id, ibs.api_context.get_def_user);
        l_pobj.OPERATION_ID     := p_operation;
        l_pobj.PAYER_BRANCH_ID  := p_branch_id;
        l_pobj.PAYMENT_DATE		:= TRUNC(nvl(p_payment_date, SYSDATE));
        l_pobj.CURRENCY         := nvl(p_currency, const_interbankpayments.CFG_DEFAULT_CURRENCY);
        l_pobj.ATTRS            := nvl(p_attributes, T_INTBANKPAYS_ATTR_COLLECTION());
        RETURN new_payment(l_pobj, p_auto_commit);
     END;
    
    PROCEDURE check_payment(pid INTEGER, p_state INTEGER DEFAULT NULL) IS 
        l_mobj t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
       l_mobj.CHECKING_PAYMENT(p_state);
    END;
    
    /************************************************************ State changes ************************************************************/
    FUNCTION state_to_verification(pid INTEGER) RETURN V_INTERBANKPAYMENTS%ROWTYPE IS 
    	l_mobj 		t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        l_mobj.state_to_verification();
        l_mobj.obj.update_payment;
        RETURN api_interbankpayments.read_payment_view(pid);
    END;

    FUNCTION state_to_verification(pids ibs.t_integer_collection) RETURN V_INTERBANKPAYMENTS%ROWTYPE IS 
        l_result V_INTERBANKPAYMENTS%ROWTYPE;
    BEGIN
        FOR indx IN pids.FIRST .. pids.LAST LOOP l_result := state_to_verification(pids(indx)); END LOOP;
        RETURN l_result;
    END;

    FUNCTION state_to_changing(pid INTEGER, p_comments BLOB DEFAULT NULL) RETURN V_INTERBANKPAYMENTS%ROWTYPE IS 
    	l_mobj t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        l_mobj.state_to_changing;
        l_mobj.obj.update_payment;
        IF p_comments IS NOT NULL THEN
            set_payment_comments(pid, p_comments);
        END IF;
        RETURN api_interbankpayments.read_payment_view(pid);
    END;
    
    FUNCTION state_to_authorization(pid INTEGER) RETURN V_INTERBANKPAYMENTS%ROWTYPE IS 
        l_mobj t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        l_mobj.state_to_authorization();
        l_mobj.obj.update_payment;
        RETURN api_interbankpayments.read_payment_view(pid);
    END;
    
    FUNCTION state_to_authorization(pids ibs.t_integer_collection) RETURN V_INTERBANKPAYMENTS%ROWTYPE IS 
        l_result V_INTERBANKPAYMENTS%ROWTYPE;
    BEGIN
        FOR indx IN pids.FIRST .. pids.LAST 
        LOOP 
            BEGIN l_result := state_to_authorization(pids(indx)); 
            EXCEPTION WHEN OTHERS THEN NULL;
            END;
        END LOOP;
        RETURN l_result;
    END;

    FUNCTION state_to_complete(pid INTEGER) RETURN V_INTERBANKPAYMENTS%ROWTYPE IS 
        l_mobj t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
        l_result CLOB;
    BEGIN
        l_mobj.STATE_TO_COMPLETE();
        l_mobj.obj.update_payment;
        l_result := jui_interbankpayments_tools.send_cbar_xohks_payment(pid); 
        RETURN api_interbankpayments.read_payment_view(pid);
    END;

    FUNCTION state_to_complete(pids ibs.t_integer_collection) RETURN V_INTERBANKPAYMENTS%ROWTYPE IS 
        l_index                 INTEGER DEFAULT pids.FIRST;
        TYPE map_messages       IS TABLE OF t_interbankpayments_ext_col INDEX BY VARCHAR2(30);
        l_map_messages          map_messages;
        l_related_messages      t_interbankpayments_ext_col DEFAULT t_interbankpayments_ext_col();
        l_temp_msg              t_interbankpayments_extend;
        l_cur_map_key           VARCHAR2(10);
        l_batch_num             INTEGER;
        l_related_messages_obj  t_interbankpayments_ext_col;
        l_parent_obj            t_interbankpayments_extend;
        l_parent_msg            t_intbankpays_msg;
        l_msg                   t_intbankpays_msg;
        l_result                V_INTERBANKPAYMENTS%ROWTYPE;
        l_errors                CLOB DEFAULT NULL;
        l_t                     V_INTERBANKPAYMENTS%ROWTYPE;
        l_clob                  CLOB;
    BEGIN
        IF pids.count > 0 AND pids IS NOT NULL THEN
            WHILE (l_index IS NOT NULL)
            LOOP
                l_temp_msg := t_interbankpayments_extend(pids(l_index));
                l_temp_msg.remove_attr(const_interbankpayments.ATTR_BATCH_PAYMENT_NUM);
                l_temp_msg.remove_attr(const_interbankpayments.ATTR_IS_BATCH_PARENT_MSG);
                l_temp_msg.remove_attr(const_interbankpayments.ATTR_IS_BATCH_RELATED_MSG);
                l_cur_map_key := l_temp_msg.system_id || l_temp_msg.message_type;
                
                IF NOT l_map_messages.exists(l_cur_map_key) THEN 
                    l_map_messages(l_cur_map_key) := t_interbankpayments_ext_col(); 
                END IF;
                
                l_map_messages(l_cur_map_key).extend;
                l_map_messages(l_cur_map_key)(l_map_messages(l_cur_map_key).LAST) := l_temp_msg;
                l_index := pids.NEXT(l_index);
            END LOOP; 

            l_index := l_map_messages.FIRST;
            WHILE (l_index IS NOT NULL)
            LOOP
                IF l_map_messages(l_index).count > 1 THEN
                    BEGIN
                        l_batch_num := round((sysdate - to_date('19700101 0000', 'YYYYMMDD HH24MI'))*86400) || dbms_random.value(1,9999);
                        l_related_messages.delete;                    
                        FOR indx IN l_map_messages(l_index).FIRST .. l_map_messages(l_index).LAST
                        LOOP
                            -- Если тип сообщения не поддерживает пакетную обработку проводить одинарно
                            IF NOT l_map_messages(l_index)(indx).isset_attribute(const_interbankpayments.ATTR_IS_SUPPORT_BATCHING)
                            THEN 
                                l_result := state_to_complete(pid => l_map_messages(l_index)(indx).id);
                                CONTINUE;
                            END IF;
                            
                            l_map_messages(l_index)(indx).update_attr_val(t_intbankpays_attr(
                                    id_attr => const_interbankpayments.ATTR_BATCH_PAYMENT_NUM, 
                                    value_int => l_batch_num,
                                    value_str => NULL
                                ));
                                
                            IF indx > 1 THEN
                                l_related_messages.extend;
                                l_related_messages(l_related_messages.last) := l_map_messages(l_index)(indx);
                            END IF;
                        END LOOP;
                        
                        IF l_related_messages.count > 0 THEN
                            l_parent_msg := api_interbankpayments.getMessageTypeObject(l_map_messages(l_index)(l_map_messages(l_index).FIRST));
                            l_parent_msg.state_to_complete(l_related_messages);
                            l_parent_msg.obj.update_payment();
                            FOR indx IN l_related_messages.FIRST .. l_related_messages.LAST
                            LOOP l_related_messages(indx).update_payment(); END LOOP;                        
                        l_clob := jui_interbankpayments_tools.send_cbar_xohks_payment(l_parent_msg.obj.id); 
                        END IF;
                    EXCEPTION
                        WHEN OTHERS THEN l_errors := l_errors || '#' || l_map_messages(l_index)(l_map_messages(l_index).FIRST).id || ' : ' || SQLERRM || '<br><b>{' || dbms_utility.format_error_backtrace || '}</b>' || '<br>' ||  chr(10)  ;
                    END;
                ELSE 
                    BEGIN
                        l_result := state_to_complete(l_map_messages(l_index)(1).id);
                    EXCEPTION
                        WHEN OTHERS THEN l_errors := l_errors || '#' || l_map_messages(l_index)(1).id || ' : ' || SQLERRM || '<br>' || chr(10) ;
                    END;
                END IF;
                l_index := l_map_messages.NEXT(l_index);
            END LOOP;
        END IF;
        
        IF l_errors IS NOT NULL THEN
            raise_application_error(-20000, 'Во время пакетного завершения возникли ошибки: ' || chr(10) 
                                            || '---------------<br>' || chr(10) 
                                            || l_errors
                                            || '--------------- ' || '<br>' || chr(10) );
        END IF;
        
        /*
        Херовое решение, лишний селект тут, лишний селект в jui_interbankpayments_tools.rowtypeWrapper для JAVA
        Но надо это решить после запуска - как решение перевести на объектную модель, но Java 1.6 почему-то сбоила (1,7 все нормально)
        */
        IF l_result.id IS NULL THEN
            SELECT * INTO l_result 
            FROM v_interbankpayments
            WHERE rownum = 1;
        END IF;
        
        RETURN l_result;
    END;
    
    FUNCTION state_to_changing_auth(pid INTEGER) RETURN V_INTERBANKPAYMENTS%ROWTYPE IS 
    	l_mobj t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        l_mobj.state_to_changing_auth();
        l_mobj.obj.update_payment;
    	RETURN api_interbankpayments.read_payment_view(pid);
    END;

    FUNCTION state_to_draft(pid INTEGER) 
    RETURN V_INTERBANKPAYMENTS%ROWTYPE
    IS	l_mobj	t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
    	RETURN NULL;
    END;

    FUNCTION state_copy_from_draft(pid INTEGER) RETURN V_INTERBANKPAYMENTS%ROWTYPE IS	
        l_mobj	t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
    	RETURN NULL;
    END;

    FUNCTION state_to_cancel(pid INTEGER) RETURN V_INTERBANKPAYMENTS%ROWTYPE IS	
        l_mobj	t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
    	l_mobj.state_to_cancel();
        l_mobj.obj.update_payment;
        RETURN api_interbankpayments.read_payment_view(pid);
    END;
    
    PROCEDURE deletePayment(pid INTEGER) IS	
        l_mobj	t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        l_mobj.erase();        
    END;
    
    FUNCTION state_reject(pid INTEGER) RETURN V_INTERBANKPAYMENTS%ROWTYPE IS
        l_mobj	t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
    	RETURN NULL;
    END;

    PROCEDURE update_fee_collection(pid INTEGER) IS 
        l_mobj t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN l_mobj.update_fee_collection(); END;
    
    /*************************************************** Setter ***************************************************/
    
    FUNCTION refresh_reference(pid INTEGER)  RETURN V_INTERBANKPAYMENTS%ROWTYPE IS
        l_mobj	t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        l_mobj.refresh_reference;
        l_mobj.obj.update_payment; 
        RETURN api_interbankpayments.read_payment_view(pid);
    END;
      
    
    
    FUNCTION update_to_correct_bank_date(pid IN INTEGER, p_date DATE DEFAULT NULL) RETURN V_INTERBANKPAYMENTS%ROWTYPE IS
        l_mobj	t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        l_mobj.update_to_correct_bank_date(p_date);
        l_mobj.obj.update_payment; 
        RETURN api_interbankpayments.read_payment_view(pid);
    END;
    
    FUNCTION set_payment_date(pid IN INTEGER, p_var IN DATE) RETURN V_INTERBANKPAYMENTS%ROWTYPE IS	
        l_mobj	t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        l_mobj.set_payment_date(p_var);
        l_mobj.obj.update_payment;  
        RETURN api_interbankpayments.read_payment_view(pid);
    END;
    
    FUNCTION set_system_id(pid IN INTEGER, p_var IN INTEGER DEFAULT NULL, p_auto_detect boolean DEFAULT TRUE) RETURN V_INTERBANKPAYMENTS%ROWTYPE
    IS 
    	l_mobj 		t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
        l_var		INTEGER DEFAULT p_var;
    BEGIN
    	IF p_auto_detect AND p_var IS NULL THEN l_var := l_mobj.get_system_id(); END IF;
        
        l_mobj.set_system_id(l_var);
        l_mobj.obj.update_payment;
        
		RETURN api_interbankpayments.read_payment_view(pid);
    END;

    FUNCTION set_message_type(pid IN INTEGER, p_var IN INTEGER) RETURN V_INTERBANKPAYMENTS%ROWTYPE IS
        l_mobj	t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        l_mobj.set_message_type(p_var);
        l_mobj.obj.update_payment;
        RETURN api_interbankpayments.read_payment_view(pid);
    END;
    
    FUNCTION set_amount(pid IN INTEGER, p_var IN NUMBER) RETURN V_INTERBANKPAYMENTS%ROWTYPE IS 
    	l_mobj t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        l_mobj.set_amount(p_var);
        l_mobj.obj.update_payment(); 
        RETURN api_interbankpayments.read_payment_view(pid);
    END;

    FUNCTION set_currency(pid IN INTEGER, p_var IN INTEGER DEFAULT const_interbankpayments.CFG_DEFAULT_CURRENCY) RETURN V_INTERBANKPAYMENTS%ROWTYPE IS 
    	l_mobj 	t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        l_mobj.set_currency(p_var);
        l_mobj.obj.update_payment;
        RETURN api_interbankpayments.read_payment_view(pid);
    END;
    
    -- Ручная установка комиссии по t_fee_amount
    FUNCTION set_fee(pid IN INTEGER, p_var IN ibs.t_fee_amount) RETURN V_INTERBANKPAYMENTS%ROWTYPE IS 
    	l_mobj	t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        IF l_mobj.obj.isset_attribute(CONST_INTERBANKPAYMENTS.ATTR_IS_WITHOUT_FEE) THEN
            raise_application_error(IBS.CONST_EXCEPTION.GENERAL_ERROR, 'Для платежа {' || pid || 
                                                                        '} установлен атрибут "Без комиссии".Удалите атрибут перед установкой значения');
        END IF;
        l_mobj.set_fee(p_var);
        l_mobj.obj.update_payment;
        RETURN api_interbankpayments.read_payment_view(pid);
    END;
    
    -- Ручная установка комиссии по сумме и валюте
    FUNCTION set_fee(pid IN INTEGER, p_var IN NUMBER, p_currency IN INTEGER DEFAULT NULL) RETURN V_INTERBANKPAYMENTS%ROWTYPE IS 
    	l_mobj      t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
        l_fee       ibs.t_fee_amount DEFAULT NULL;
        l_result    V_INTERBANKPAYMENTS%ROWTYPE;
        l_currency  INTEGER DEFAULT nvl(p_currency, l_mobj.obj.CURRENCY);
    BEGIN
        IF p_var > 0.0 THEN
            l_fee           := ibs.api_tariff.get_fee(CONST_INTERBANKPAYMENTS.FEE_KIND_MANUAL,
                                                      NULL,
                                                      NULL,
                                                      NULL,
                                                      l_mobj.obj.AMOUNT,
                                                      l_currency,
                                                      NULL,
                                                      NULL);
            l_fee.fee_amount    := p_var;
            l_fee.currency_id   := l_currency;
            l_fee.account_id    := l_mobj.get_account_id();
        END IF;
        l_result            := set_fee(pid, l_fee);
        RETURN l_result; 
    END;
    
    -- Устанавливает основание платежки
    FUNCTION set_ground(pid IN INTEGER, p_var IN VARCHAR2) RETURN V_INTERBANKPAYMENTS%ROWTYPE IS 
    	l_mobj t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        l_mobj.set_ground(p_var);
        l_mobj.obj.update_payment;
        RETURN api_interbankpayments.read_payment_view(pid);
    END;

    FUNCTION set_manual_operation_id(pid IN INTEGER, p_var IN INTEGER) RETURN v_interbankpayments%ROWTYPE IS
        l_mobj 	t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
    	l_mobj.set_operation_id(p_var);
        l_mobj.obj.update_payment;    
        RETURN api_interbankpayments.read_payment_view(pid);
    END;
    /*************************************************** Payer Info ***************************************************/
    FUNCTION set_payer_account (pid IN INTEGER,
    							p_var IN VARCHAR2)  RETURN V_INTERBANKPAYMENTS%ROWTYPE IS 
    	l_mobj 		t_intbankpays_msg   DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        
        l_mobj.set_payer_account(p_var);
        l_mobj.obj.update_payment();
        RETURN api_interbankpayments.read_payment_view(pid);
    END;
    
    FUNCTION set_payer_account(pid IN INTEGER,
    							p_account_id IN INTEGER,
    							p_set_auto_branch	in boolean DEFAULT TRUE,
                                p_set_auto_currency in boolean DEFAULT TRUE,
                                p_check_enough		in boolean DEFAULT TRUE) RETURN V_INTERBANKPAYMENTS%ROWTYPE IS 
    	l_mobj 		t_intbankpays_msg 	DEFAULT api_interbankpayments.getMessageTypeObject(pid);
        l_account  	ibs.account%ROWTYPE	DEFAULT ibs.api_account.read_account(p_account_id);
    BEGIN
        RETURN set_payer_account(pid, l_account.account_number,  p_set_auto_branch, p_set_auto_currency, p_check_enough);
    END;

    FUNCTION set_payer_branch_id(pid  IN INTEGER,p_var IN INTEGER) RETURN v_interbankpayments%ROWTYPE IS  
        l_mobj	t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        --raise_application_error(-20000, p_var);
        l_mobj.set_payer_branch_id(p_var);
        l_mobj.obj.update_payment;
        RETURN api_interbankpayments.read_payment_view(pid);
    END;
    
     /*************************************************** Receiver Info ***************************************************/
    FUNCTION set_receiver_name(pid IN INTEGER, p_var IN VARCHAR2) RETURN V_INTERBANKPAYMENTS%ROWTYPE IS 
        l_mobj  t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN 
        l_mobj.set_receiver_name(p_var);
        l_mobj.obj.update_payment();
        RETURN api_interbankpayments.read_payment_view(pid);
    END;
    
    FUNCTION set_receiver_iban(pid IN INTEGER, p_var IN VARCHAR2) RETURN v_interbankpayments%ROWTYPE IS
        l_mobj 	t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        l_mobj.set_receiver_iban(p_var);
        l_mobj.obj.update_payment;
        RETURN api_interbankpayments.read_payment_view(pid);
    END;

    FUNCTION set_receiver_tax(pid IN INTEGER, p_var IN VARCHAR2) RETURN v_interbankpayments%ROWTYPE IS 
        l_mobj  t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        l_mobj.set_receiver_tax(p_var);
        l_mobj.obj.update_payment;
        RETURN api_interbankpayments.read_payment_view(pid);
    END;
    /*************************************************** Emitent ***************************************************/
    FUNCTION set_emitent_bank_code(pid IN INTEGER, p_var IN VARCHAR2, p_auto_branch_id BOOLEAN DEFAULT TRUE) RETURN v_interbankpayments%ROWTYPE
    IS l_mobj 	t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        l_mobj.set_emitent_bank_code(p_var);
        l_mobj.obj.update_payment;
        RETURN api_interbankpayments.read_payment_view(pid);
    END;
   
    /*************************************************** Beneficiar ***************************************************/
    FUNCTION set_beneficiar_bank_name(pid IN INTEGER,p_var IN VARCHAR2) RETURN v_interbankpayments%ROWTYPE IS 
        l_mobj t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        l_mobj.set_beneficiar_bank_name(p_var);
        l_mobj.obj.update_payment();
        RETURN api_interbankpayments.read_payment_view(pid);
    END;
    
    FUNCTION set_beneficiar_bank_code(pid IN INTEGER, p_var IN VARCHAR2) RETURN V_INTERBANKPAYMENTS%ROWTYPE IS 
        l_mobj	t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        l_mobj.set_beneficiar_bank_code(p_var);
        l_mobj.obj.update_payment;
        RETURN api_interbankpayments.read_payment_view(pid);
    END;
    
    FUNCTION set_beneficiar_bank_corr_acc(pid IN INTEGER, p_var IN VARCHAR2) RETURN v_interbankpayments%ROWTYPE IS
        l_mobj	t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        l_mobj.set_beneficiar_bank_corr_acc(p_var);
        l_mobj.obj.update_payment;
        RETURN api_interbankpayments.read_payment_view(pid);
    END;
    
    FUNCTION set_beneficiar_bank_swift(pid IN INTEGER, p_var IN VARCHAR2) RETURN v_interbankpayments%ROWTYPE IS
        l_mobj	t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        l_mobj.set_beneficiar_bank_swift(p_var);
        l_mobj.obj.update_payment;
        RETURN api_interbankpayments.read_payment_view(pid);
    END;

    /*************************************************** Attributes managment ***************************************************/
    FUNCTION isset_attribute(pid IN INTEGER, p_attr_id INTEGER) RETURN BOOLEAN IS
        l_c    INTEGER; 
    BEGIN
        SELECT count(1) INTO l_c FROM TABLE(SELECT t.attrs FROM INTERBANKPAYMENTS t WHERE T.ID = pid) u WHERE u.id_attr = p_attr_id;
        IF l_c > 0 THEN RETURN TRUE;
        ELSE RETURN FALSE;
        END IF;
    END;

    FUNCTION get_attribute_val(pid IN INTEGER, p_attr_id INTEGER, p_raise_error BOOLEAN DEFAULT FALSE) RETURN t_intbankpays_attr IS 
        l_result_coll   t_intbankpays_attr_collection DEFAULT get_attributes(pid, p_raise_error);
    BEGIN
        IF l_result_coll IS NOT NULL AND l_result_coll.count > 0 THEN
            FOR indx IN l_result_coll.FIRST .. l_result_coll.LAST
            LOOP
               IF l_result_coll(indx).id_attr = p_attr_id THEN
                   RETURN l_result_coll(indx);
                   END IF;
               END LOOP; 
        END IF;
        IF p_raise_error = TRUE THEN        
            raise_application_error(ibs.const_exception.GENERAL_ERROR, 
                                    'Для платежа с ид {' || pid || '} не установлен атрибут {' || p_attr_id || '}');
        END IF;
        RETURN NULL;
    END;

    FUNCTION get_attributes(pid IN INTEGER, p_raise_error BOOLEAN DEFAULT FALSE) RETURN t_intbankpays_attr_collection IS 
        l_result t_intbankpays_attr_collection;
    BEGIN
        SELECT ibp.attrs INTO l_result 
        FROM interbankpayments ibp WHERE ibp.id = pid;
        RETURN l_result; 
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF p_raise_error = TRUE THEN
                raise_application_error(ibs.const_exception.GENERAL_ERROR, 'Для платежа с ид {' || pid || '} нет ниодного атрибута');
            END IF;
            RETURN NULL;            
    END;
 
    FUNCTION update_attr_val(pid IN INTEGER, 
                                p_id_attr IN INTEGER, 
                                p_val_str IN VARCHAR2 DEFAULT NULL, 
                                p_val_int IN NUMBER  DEFAULT NULL) RETURN V_INTERBANKPAYMENTS%ROWTYPE
    IS 
        l_mobj	t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        l_mobj.update_attribute(t_intbankpays_attr(p_id_attr => p_id_attr,
                                                   p_value_str => p_val_str, 
                                                   p_value_int => p_val_int));
        l_mobj.obj.update_payment;
        RETURN api_interbankpayments.read_payment_view(pid);                                                   
    END;

    FUNCTION remove_attr(pid IN INTEGER, p_id_attr IN INTEGER) RETURN V_INTERBANKPAYMENTS%ROWTYPE
    IS l_mobj t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        
        l_mobj.remove_attribute(p_id_attr); 
        l_mobj.obj.update_payment();
        api_interbankpayments.add_payment_change(mobj => l_mobj.obj, 
                           p_action => 'jui_interbankpayments.remove_attr', 
                           p_additional => p_id_attr);
        RETURN api_interbankpayments.read_payment_view(pid); 
    END;
    
    PROCEDURE add_payment_change(pid IN INTEGER, p_changes t_intbankpays_changes)
    IS l_mobj t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        l_mobj.obj.add_changes_entry(p_changes);
        l_mobj.obj.update_payment();
    END; 
    
    FUNCTION get_payments(p_intpayment    IN T_INTERBANKPAYMENTS,
                          p_date_from     DATE    DEFAULT TRUNC(SYSDATE),
                          p_date_to       DATE    DEFAULT TRUNC(SYSDATE),
                          p_min_amount    NUMBER  DEFAULT 0.0,
                          p_max_amount    NUMBER  DEFAULT 9999999999.99,
                          p_states        ibs.t_integer_collection DEFAULT NULL,
                          p_payments_id   ibs.t_integer_collection DEFAULT NULL) RETURN SYS_REFCURSOR
    IS 
        l_cursor SYS_REFCURSOR; 
        l_intpayment    T_INTERBANKPAYMENTS DEFAULT nvl(p_intpayment,T_INTERBANKPAYMENTS());
        l_date_from     DATE DEFAULT TRUNC(nvl(l_intpayment.PAYMENT_DATE, nvl(p_date_from, to_date('01/01/2010', 'dd/MM/yyyy'))));
        l_date_to       DATE DEFAULT TRUNC(nvl(l_intpayment.PAYMENT_DATE, nvl(p_date_to, SYSDATE)));
        l_msg_acs_col   t_intbankpays_users_access_col;
        
        
        
    BEGIN
        -- Для того чтобы клиент не псал фигню и не было фул скана
        l_intpayment.PAYER_ACCOUNT := REPLACE(l_intpayment.PAYER_ACCOUNT,'%','');
        l_intpayment.RECEIVER_NAME := REPLACE(l_intpayment.RECEIVER_NAME,'%','');
        l_intpayment.RECEIVER_IBAN := REPLACE(l_intpayment.RECEIVER_IBAN,'%','');
        l_intpayment.RECEIVER_TAX  := REPLACE(l_intpayment.RECEIVER_TAX,'%','');
        
        
        SELECT t_intbankpays_users_access(USER_ID => m.user_id, MT_TYPE => m.mt_types, ACCESS_MODES => m.access_modes) 
        BULK COLLECT INTO l_msg_acs_col
        FROM INTERBANKPAYMENTS_USERS_ACCESS m 
        WHERE m.user_id = ibs.api_context.get_def_user();
--        raise_application_error(-20000, ibs.to_.to_string(p_payments_id));
        -- Т.к. конструктор не поддерживает rowtype приходится пока делать так -  возможно перепишу на ин-ию каждого поля
        -- Возможно, следует перевести на динамический SQL
        OPEN l_cursor FOR   SELECT tb.* 
                            FROM V_INTERBANKPAYMENTS tb
                            -- Права доступа
                            --JOIN INTERBANKPAYMENTS_USERS_ACCESS m ON m.mt_types = tb.MESSAGE_TYPE   -- из-за это дубликаты
                            WHERE ( 
                                    (p_states IS NOT NULL AND tb.state IN (select * from table(p_states))) OR 
                                    (p_states IS NULL AND (tb.state = l_intpayment.STATE OR l_intpayment.STATE IS NULL))
                                  )
                                  AND (tb.ID IN (SELECT COLUMN_VALUE FROM TABLE(p_payments_id)) OR p_payments_id IS NULL)
                                  AND (tb.system_id = l_intpayment.SYSTEM_ID OR l_intpayment.SYSTEM_ID IS NULL)
                                  /* старая имплементация прав доступа - косячная :)
                                  AND (tb.MESSAGE_TYPE IN (SELECT m.mt_types 
                                                          FROM INTERBANKPAYMENTS_USERS_ACCESS m 
                                                          WHERE 1 = (SELECT 1
                                                                     FROM TABLE(m.access_modes) x  
                                                                     WHERE x.column_value IN (const_interbankpayments.ACCESS_FULL,const_interbankpayments.ACCESS_VIEW) 
                                                                     GROUP BY 1) 
                                                                OR m.user_id = tb.CREATOR_ID)
                                        AND (tb.MESSAGE_TYPE = l_intpayment.MESSAGE_TYPE OR l_intpayment.MESSAGE_TYPE IS NULL)
                                        )*/
                                  AND (tb.MESSAGE_TYPE = l_intpayment.MESSAGE_TYPE OR l_intpayment.MESSAGE_TYPE IS NULL)
                                  AND ( 
                                    (
                                        CASE WHEN tb.MESSAGE_TYPE IN (SELECT MT_TYPE FROM TABLE(l_msg_acs_col)) THEN
                                            CASE
                                                -- Создатель платежа имеет право видеть
                                                WHEN tb.CREATOR_ID = ibs.api_context.get_def_user
                                                     THEN 1
                                                WHEN API_INTERBANKPAYMENTS_ACCESS.has_grand(const_interbankpayments.ACCESS_VIEW, l_msg_acs_col) = 1
                                                     THEN 1
                                                -- Если предоставлен полный доступ
                                                WHEN API_INTERBANKPAYMENTS_ACCESS.has_grand(const_interbankpayments.ACCESS_FULL, l_msg_acs_col) = 1
                                                    THEN 1
                                                -- Если есть право перевода на Верификацию
                                                WHEN tb.STATE = const_interbankpayments.STATE_NEW 
                                                      AND (API_INTERBANKPAYMENTS_ACCESS.has_grand(const_interbankpayments.ACCESS_STATE_TO_10, l_msg_acs_col) = 1 
                                                           OR tb.CREATOR_ID = ibs.api_context.get_def_user)
                                                      THEN 1
                                                -- Если есть право перевода на Авторизацию
                                                WHEN tb.STATE IN (const_interbankpayments.STATE_VERIFICATION, const_interbankpayments.STATE_CHANGINGFROMAUTH)
                                                     AND API_INTERBANKPAYMENTS_ACCESS.has_grand(const_interbankpayments.ACCESS_STATE_TO_20, l_msg_acs_col) = 1
                                                     THEN 1
                                                -- Если есть право перевода на Завершен
                                                WHEN tb.STATE = const_interbankpayments.STATE_AUTHORIZATION
                                                     AND API_INTERBANKPAYMENTS_ACCESS.has_grand(const_interbankpayments.ACCESS_STATE_TO_60, l_msg_acs_col) = 1
                                                     THEN 1
                                            END
                                        END
                                    ) = 1
                                  )
                                  AND (tb.amount BETWEEN nvl(l_intpayment.AMOUNT,nvl(p_min_amount,0.0)) AND nvl(l_intpayment.AMOUNT, nvl(p_max_amount,9999999999999999.99))
                                       OR tb.AMOUNT IS NULL)
                                  AND (tb.currency = l_intpayment.CURRENCY OR l_intpayment.CURRENCY IS NULL) 
                                  AND (tb.PAYER_BRANCH_ID = l_intpayment.PAYER_BRANCH_ID OR l_intpayment.PAYER_BRANCH_ID IS NULL)
                                  AND (tb.BENEFICIAR_BANK_CODE = l_intpayment.BENEFICIAR_BANK_CODE OR l_intpayment.BENEFICIAR_BANK_CODE IS NULL)
                                  AND (tb.PAYER_ACCOUNT LIKE l_intpayment.PAYER_ACCOUNT || '%' OR l_intpayment.PAYER_ACCOUNT IS NULL)
                                  AND (l_intpayment.RECEIVER_NAME IS NULL OR tb.RECEIVER_NAME LIKE l_intpayment.RECEIVER_NAME || '%')
                                  AND (l_intpayment.RECEIVER_IBAN IS NULL OR tb.RECEIVER_IBAN LIKE l_intpayment.RECEIVER_IBAN || '%')
                                  AND (l_intpayment.RECEIVER_TAX  IS NULL OR tb.RECEIVER_TAX  LIKE l_intpayment.RECEIVER_TAX  || '%')
                                  AND (l_intpayment.CREATOR_ID IS NULL OR tb.CREATOR_ID = l_intpayment.CREATOR_ID)
                                  AND (l_intpayment.CREATION_DATE IS NULL OR tb.CREATION_DATE = l_intpayment.CREATION_DATE)
                                  AND (tb.payment_date BETWEEN l_date_from AND l_date_to)
                                  AND (tb.REFERENCE = l_intpayment.REFERENCE OR l_intpayment.REFERENCE IS NULL)
                                  AND (
                                        
                                        (SELECT 1 
                                         FROM TABLE(tb.ATTRS) tb_attrs, TABLE(l_intpayment.ATTRS) l_attrs
                                         WHERE  tb_attrs.ID_ATTR = l_attrs.ID_ATTR AND (l_attrs.VALUE_STR IS NULL OR tb_attrs.VALUE_STR = l_attrs.VALUE_STR) 
                                               AND (l_attrs.VALUE_INT IS NULL OR tb_attrs.VALUE_INT = l_attrs.VALUE_INT)    
                                         GROUP BY 1                           
                                         ) = 1 OR (l_intpayment.ATTRS IS NULL OR tb.ATTRS IS NULL)
                                       );   
        RETURN l_cursor;
    END;

    FUNCTION get_payments(p_system      INTEGER DEFAULT NULL,
                          p_msg_type    INTEGER DEFAULT NULL,
                          p_state       INTEGER DEFAULT NULL,
                          p_states      ibs.t_integer_collection DEFAULT NULL,
                          p_refer_num   VARCHAR DEFAULT NULL,
                          p_date_from   DATE    DEFAULT NULL,
                          p_date_to     DATE    DEFAULT NULL,
                          p_min_amount  NUMBER  DEFAULT 0.0,
                          p_max_amount  NUMBER  DEFAULT NULL,
                          p_user        INTEGER DEFAULT NULL,
                          p_currency    INTEGER DEFAULT NULL,
                          p_branch      INTEGER DEFAULT NULL,
                          p_rec_iban    VARCHAR DEFAULT NULL,
                          p_rec_tax     VARCHAR DEFAULT NULL,
                          p_bn_code     VARCHAR DEFAULT NULL,
                          p_payer_acc   VARCHAR DEFAULT NULL,
                          p_payments_id ibs.t_integer_collection DEFAULT NULL) RETURN SYS_REFCURSOR
    IS l_intpayment T_INTERBANKPAYMENTS DEFAULT t_interbankpayments; 
    BEGIN
        l_intpayment.STATE                  := p_state;
        l_intpayment.SYSTEM_ID              := p_system;
        l_intpayment.MESSAGE_TYPE           := p_msg_type;
        l_intpayment.REFERENCE              := p_refer_num;
        l_intpayment.CURRENCY               := p_currency; 
        l_intpayment.PAYER_BRANCH_ID        := p_branch;
        l_intpayment.RECEIVER_IBAN          := p_rec_iban;
        l_intpayment.RECEIVER_TAX           := p_rec_tax;
        l_intpayment.PAYER_ACCOUNT          := p_payer_acc;
        l_intpayment.BENEFICIAR_BANK_CODE   := p_bn_code;
        l_intpayment.CREATOR_ID             := p_user;
        -- На случай если не установлен контекст
        BEGIN l_intpayment.CREATOR_ID := nvl(p_user, ibs.api_context.get_def_user);
        EXCEPTION WHEN OTHERS THEN l_intpayment.CREATOR_ID := NULL;
        END;
        
        RETURN get_payments(l_intpayment,
                            p_date_from => p_date_from,
                            p_date_to => p_date_to,
                            p_min_amount => p_min_amount,
                            p_max_amount => p_max_amount,
                            p_states => p_states,
                            p_payments_id => p_payments_id);
    END;
    
    PROCEDURE set_payment_comments(pid INTEGER, p_comments BLOB) IS
        l_mobj t_intbankpays_msg DEFAULT api_interbankpayments.getMessageTypeObject(pid);
    BEGIN
        DELETE FROM interbankpayments_comments ib WHERE ib.id = pid;
        INSERT INTO interbankpayments_comments VALUES(pid, p_comments);
        api_interbankpayments.add_payment_change(mobj => l_mobj.obj, 
                           p_action => 'jui_interbankpayments.set_payment_comments', 
                           p_additional => 'Comments has been added');
    EXCEPTION
        WHEN OTHERS THEN
            api_interbankpayments.add_payment_change(mobj => l_mobj.obj, 
                                                       p_action => 'jui_interbankpayments.set_payment_comments', 
                                                       p_autonomus => TRUE,
                                                       p_result => SQLERRM || '',
                                                       p_additional => dbms_utility.format_error_backtrace);
            RAISE;
    END;
    
    FUNCTION get_payment_comments(p_id INTEGER) RETURN BLOB IS
        l_result BLOB;
    BEGIN
        SELECT ib.comments INTO l_result FROM interbankpayments_comments ib WHERE ib.id = p_id;
        RETURN l_result;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN 
            raise_application_error(-20000, 'По платежу {'|| p_id ||'} нет комментарий');
    END;
    /***************************************** Others **********************************************/
    FUNCTION create_interbank_payment(p_branch_id  in number,                   --ИД филиала
                                        p_bbank_code in varchar2,               --БИК банка
                                        p_pay_acc    in varchar2,               --Аккаунт плательщика
                                        p_rec_iban   in varchar2,               --Ибан счет получателя
                                        p_rec_name   in varchar2,               --Имя получателя
                                        p_rec_tax    in varchar2,               --ИНН получателя
                                        p_amount     in number,                 --Сумма
                                        p_ground     in varchar2,               --Основание
                                        p_order      in INTEGER,                --Признак "серенджам" 1/0
                                        p_inkasso    in integer,                --Признак "инкассо"   1/0
                                        p_bud_dest   in varchar2,               --Бюджетный код destination
                                        p_bud_level  in varchar2,               --Бюджетный код level
                                        p_msg_type   in integer, -- Тип сообщения
                                        p_add_info   in varchar2    default null,  --Доп информация
                                        p_fee        in number      default null,    --Комиссия(ручной ввод)    
                                        p_ground2    in varchar2    default null,
                                        p_acc_deb    in varchar2    default null,
                                        p_acc_crd    in varchar2    default null,
                                        p_pay_sys    in varchar2    default null
                                        ) RETURN INTEGER IS
        p_interbankpayment  ipay.t_interbankpayments DEFAULT ipay.t_interbankpayments();
        p_interbankpay_msg  ipay.t_intbankpays_msg;
        p_payment_row       ipay.v_interbankpayments%ROWTYPE;
        l_fee               ibs.t_fee_amount;
        l_arrest_sum        NUMBER;
        l_py_acc_object    ibs.object%rowtype DEFAULT ibs.api_object.read_object(ibs.api_account.read_account(p_pay_acc).id);
    BEGIN
        -- Заполняем структуру
        
        p_interbankpayment.PAYER_BRANCH_ID := p_branch_id;
        p_interbankpayment.BENEFICIAR_BANK_CODE := p_bbank_code;
        p_interbankpayment.PAYER_ACCOUNT := p_pay_acc;
        p_interbankpayment.AMOUNT := p_amount;
        p_interbankpayment.MESSAGE_TYPE := p_msg_type;
        
        -- Создаем платеж и получаем ассоциированным с ним объект
        p_interbankpay_msg := jui_interbankpayments.new_payment_standalone_as_msg(p_interbankpayment);
        -- Продолжаем заполнять структуру
        p_interbankpay_msg.update_attribute(const_interbankpayments.ATTR_UNCHECK_IBAN, p_value_str => p_bud_dest);
        p_interbankpay_msg.set_receiver_iban(p_rec_iban);
        p_interbankpay_msg.set_receiver_name(p_rec_name);
        p_interbankpay_msg.set_RECEIVER_TAX(p_rec_tax);
        p_interbankpay_msg.set_ground(p_ground);

        IF l_py_acc_object.object_type_id = ibs.const_object.OT_DEPOSIT THEN
            l_arrest_sum := ibs.api_account.get_sarandjam_amount(p_interbankpay_msg.obj.payer_account);
        END IF;
        
        -- Устанавливаем атрибут серенджам
        IF p_order = 1 THEN p_interbankpay_msg.update_attribute(const_interbankpayments.ATTR_IS_ORDER_PAYMENT);END IF;
        -- Устанавливаем атрибут инкассо
        IF p_inkasso = 1 THEN p_interbankpay_msg.update_attribute(const_interbankpayments.ATTR_IS_ORDER_INKASSO_PAYMENT); END IF;
        
        IF TRIM(p_bud_dest) IS NOT NULL THEN p_interbankpay_msg.update_attribute(const_interbankpayments.ATTR_BUDGET_DESTINATION, p_value_str => p_bud_dest); END IF;
        IF TRIM(p_bud_level) IS NOT NULL THEN p_interbankpay_msg.update_attribute(const_interbankpayments.ATTR_BUDGET_LEVEL, p_value_str => p_bud_level); END IF;
        IF TRIM(p_add_info) IS NOT NULL THEN p_interbankpay_msg.update_attribute(const_interbankpayments.ATTR_ADDITIONAL_INFO, p_value_str => p_add_info); END IF;
        IF p_acc_deb IS NOT NULL  THEN p_interbankpay_msg.update_attribute(const_interbankpayments.ATTR_IS_RS_ACC_DEB, p_value_str => p_acc_deb); END IF;
        IF p_acc_crd IS NOT NULL  THEN p_interbankpay_msg.update_attribute(const_interbankpayments.ATTR_IS_RS_ACC_CRD, p_value_str => p_acc_crd); END IF;
        IF p_ground2 IS NOT NULL  THEN p_interbankpay_msg.update_attribute(const_interbankpayments.ATTR_IS_RS_GROUND, p_value_str => p_ground2); END IF;
        IF p_ground2 IS NOT NULL  THEN p_interbankpay_msg.update_attribute(const_interbankpayments.ATTR_IS_RS_GROUND, p_value_str => p_ground2); END IF;
        IF l_arrest_sum IS NOT NULL THEN p_interbankpay_msg.update_attribute(const_interbankpayments.ATTR_IS_RS_ARREST_SUM, p_value_str => to_char(l_arrest_sum));END IF;
        IF p_fee IS NOT NULL THEN
            l_fee :=  ibs.api_tariff.get_fee(CONST_INTERBANKPAYMENTS.FEE_KIND_MANUAL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      p_interbankpay_msg.obj.AMOUNT,
                                      p_interbankpay_msg.obj.CURRENCY,
                                      NULL,
                                      NULL);
            l_fee.fee_amount    := p_fee;
            l_fee.currency_id   := p_interbankpay_msg.obj.CURRENCY;
            l_fee.account_id    := p_interbankpay_msg.get_account_id();
            p_interbankpay_msg.set_fee(l_fee);
        END IF;
        p_interbankpay_msg.STATE_TO_VERIFICATION;
        p_interbankpay_msg.obj.update_payment;   
             
        RETURN p_interbankpay_msg.obj.id;
    END;

end jui_interbankpayments;
/
