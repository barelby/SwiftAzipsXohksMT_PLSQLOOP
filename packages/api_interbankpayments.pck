create or replace package api_interbankpayments is
    -- Author  : RVKHALAFOV
    -- Created : 3/4/2016 12:01:33
    -- Purpose : 
    -- Константный пакет const_interbankpayments

    /************************************** CORE IMPLEMENTATIONS *************************************************/
    /** Создание нового платежа
        README:
        1)  Если передан параметр p_operation, то проводки для платежа будут созданы в рамках существующей цепочки операций,
            а не создавать по новому.
     **/
    FUNCTION  new_payment (p_obj t_interbankpayments, p_auto_commit BOOLEAN DEFAULT TRUE) RETURN INTEGER;
    PROCEDURE update_payment(p_interbankpayment interbankpayments%ROWTYPE, p_auto_commit BOOLEAN DEFAULT TRUE);
    
    -- Выборка из главной таблицы
    FUNCTION read_payment           (p_id IN INTEGER, p_raise_error BOOLEAN DEFAULT TRUE) RETURN t_interbankpayments_extend;
    FUNCTION read_payment_cursor    (p_id IN INTEGER) RETURN SYS_REFCURSOR;
    FUNCTION read_payment_view      (p_id IN INTEGER, p_raise_error BOOLEAN DEFAULT TRUE) RETURN V_INTERBANKPAYMENTS%ROWTYPE;
    FUNCTION read_payment_rowtype   (p_id IN INTEGER, p_raise_error BOOLEAN DEFAULT TRUE) RETURN INTERBANKPAYMENTS%ROWTYPE;
    FUNCTION getMessageTypeObject   (pid   INTEGER) RETURN t_intbankpays_msg;
    FUNCTION getMessageTypeObject   (p_obj IN OUT NOCOPY t_interbankpayments_extend) RETURN t_intbankpays_msg;
    FUNCTION get_payment_id(p_reference VARCHAR2, p_raise BOOLEAN DEFAULT TRUE) RETURN INTEGER;
    /************************************* GETTERS ***************************************/
    --FUNCTION generate_reference(p_id IN INTEGER) RETURN VARCHAR2;
    -- Attributes
    FUNCTION isset_attribute(pid IN INTEGER, p_attr_id INTEGER) RETURN BOOLEAN;
    FUNCTION get_attributes	(pid in INTEGER, p_raise_error BOOLEAN DEFAULT FALSE) RETURN t_intbankpays_attr_collection;
    FUNCTION get_attribute_val(pid IN INTEGER, p_attr_id INTEGER,  p_raise_error BOOLEAN DEFAULT FALSE) RETURN t_intbankpays_attr;
    --/
    
    /************************************* SETTERS ***************************************/
    -- Сохраняет изменения по платежу
    -- Замечания:
    --- Если вызывается для записи эксепшена, то сперва делается откат всего - сделано, чтобы не было deadlock-ов
    PROCEDURE add_payment_change(mobj  IN OUT t_interbankpayments, 
                                 p_action IN VARCHAR2, 
                                 p_autonomus IN BOOLEAN DEFAULT FALSE,
                                 p_result IN VARCHAR2 DEFAULT NULL,
                                 p_desc IN VARCHAR2 DEFAULT NULL,
                                 p_additional VARCHAR2  DEFAULT NULL);
    PROCEDURE add_state_history(p_id    INTEGER,
                                p_state INTEGER,
                                p_user  INTEGER DEFAULT ibs.api_context.get_def_user);
    
        
    FUNCTION get_message_struct(p_obj IN OUT t_intbankpays_msg) RETURN t_message_struct;
    FUNCTION get_message_struct(p_obj IN OUT t_interbankpayments_ext_col) RETURN t_message_struct;
    FUNCTION get_payment_file_content(p_id INTEGER, p_raise BOOLEAN DEFAULT TRUE) RETURN CLOB;
    PROCEDURE update_payment_file_content (p_id INTEGER, p_source_content CLOB DEFAULT NULL, p_provider_result CLOB DEFAULT NULL);
    -- Attributes
    PROCEDURE edit_attr_val  (pid IN INTEGER, p_id_attr IN INTEGER, p_value_str IN VARCHAR2, p_value_int IN NUMBER);
    PROCEDURE insert_attr_val(pid IN INTEGER, p_id_attr IN INTEGER, p_value_str IN VARCHAR2 DEFAULT NULL, p_value_int IN NUMBER DEFAULT NULL);
    PROCEDURE update_attr_val(pid IN INTEGER, p_id_attr IN INTEGER, p_value_str IN VARCHAR2 DEFAULT NULL, p_value_int IN NUMBER DEFAULT NULL);
	
    function as_swift_charset(p_chars_kind in varchar2) return varchar2;
    function translit_to_swift(p_text in varchar2) return varchar2;  

    /************************ README *******************************
                          ----------------------
                         |  t_interbankpayments |
                          ----------------------
                                  ^^^^^^
                                  extend
                                  ^^^^^^
                           -----------------
                          |T_INTBANKPAYS_MSG|
                           -----------------   
                              
                      
    ************************************************************/
end api_interbankpayments;
/
create or replace package body api_interbankpayments  IS
    
    PROCEDURE update_payment_file_content (p_id INTEGER, p_source_content CLOB DEFAULT NULL, p_provider_result CLOB DEFAULT NULL) IS
    BEGIN
        UPDATE interbankpayments_messages im 
        SET im.source_content = nvl(p_source_content, im.source_content),
            im.provider_result = nvl(p_provider_result, im.provider_result)
        WHERE im.payment_id = p_id;
    END;

    FUNCTION get_payment_file_content(p_id INTEGER, p_raise BOOLEAN DEFAULT TRUE) RETURN CLOB IS
        l_result CLOB;
    BEGIN
        SELECT im.source_content INTO l_result
        FROM INTERBANKPAYMENTS_MESSAGES im
        WHERE im.payment_id = p_id;
        RETURN l_result;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN 
            IF p_raise THEN raise_application_error(-20899, 'Содержимое файла для платежа {' || p_id || '} не найдено');
            ELSE RETURN NULL;
            END IF;
    END;

    FUNCTION get_message_struct(p_obj IN OUT t_intbankpays_msg) RETURN t_message_struct
    IS l_result T_MESSAGE_STRUCT;
        l_mt VARCHAR(10) DEFAULT '';
    BEGIN
        IF jui_interbankpayments_tools.is_struct_type_exist(p_obj) THEN
            IF p_obj.obj.system_id IS NOT NULL THEN l_mt := l_mt || '_' || p_obj.obj.system_id; END IF;
            IF p_obj.obj.message_type IS NOT NULL THEN l_mt := l_mt || '_' || p_obj.obj.message_type; END IF;

            EXECUTE IMMEDIATE 'begin :result := T_MESSAGE_STRUCT' || l_mt || '; end;' 
            USING OUT l_result;
            
            l_result.SET_OBJ(p_obj.obj);
            
            RETURN l_result;
        ELSE 
            raise_application_error(-20000, 'Для платежной системы {'|| p_obj.obj.system_id 
                                                ||'} и типа сообщения {'|| p_obj.obj.message_type 
                                                ||'} нет предопределенного структурного типа { T_MESSAGE_STRUCT' 
                                                    || l_mt ||'}'); 
        END IF;
    END;

    FUNCTION get_payment_id(p_reference VARCHAR2, p_raise BOOLEAN DEFAULT TRUE) RETURN INTEGER IS
        l_result INTEGER;
    BEGIN
        SELECT i.id INTO l_result FROM interbankpayments i WHERE i.reference = p_reference;
        RETURN l_result;
    EXCEPTION WHEN OTHERS THEN 
        IF p_raise THEN RAISE; END IF;
        RETURN NULL;
    END;


    FUNCTION get_message_struct(p_obj IN OUT t_interbankpayments_ext_col) RETURN t_message_struct IS 
        l_result T_MESSAGE_STRUCT;
        l_mt VARCHAR(10) DEFAULT '';
    BEGIN
        
        IF p_obj.count = 0 THEN raise_application_error(-20000, 'Количество платежей для группового создания файла - 0'); END IF;
        IF p_obj.count = 1 THEN raise_application_error(-20000, 'Для создания одниночных файлов используйте функцию  get_message_struct(p_obj IN OUT t_intbankpays_msg)'); END IF;
        
        IF p_obj(p_obj.first).system_id IS NOT NULL THEN l_mt := l_mt || '_' || p_obj(p_obj.first).system_id; END IF;
        IF p_obj(p_obj.first).message_type IS NOT NULL THEN l_mt := l_mt || '_' || p_obj(p_obj.first).message_type; END IF;

        EXECUTE IMMEDIATE 'begin :result := T_MESSAGE_STRUCT' || l_mt || '_BATCH(:1); end;' 
        USING OUT l_result, IN OUT p_obj;
        
        RETURN l_result;
    END;
    
    PROCEDURE add_payment_change(mobj  IN OUT t_interbankpayments, 
                                 p_action IN VARCHAR2, 
                                 p_autonomus IN BOOLEAN DEFAULT FALSE,
                                 p_result IN VARCHAR2 DEFAULT NULL,
                                 p_desc IN VARCHAR2 DEFAULT NULL, 
                                 p_additional VARCHAR2  DEFAULT NULL)
    IS 
        l_changes   t_intbankpays_changes_col;
        l_t_change  t_intbankpays_changes DEFAULT t_intbankpays_changes(ibs.api_context.get_def_user,
                                                                         p_action,
                                                                         p_desc,
                                                                         p_result,
                                                                         p_additional);
        PROCEDURE add_payment_change_commit
        IS 
            PRAGMA AUTONOMOUS_TRANSACTION;
        BEGIN
            l_changes := mobj.CHANGES;
            IF l_changes IS NULL THEN l_changes := t_intbankpays_changes_col(); END IF;
            l_changes.extend;                
            l_changes(l_changes.last) := l_t_change;
            UPDATE INTERBANKPAYMENTS i SET i.changes = l_changes WHERE i.id = mobj.id;
            COMMIT;
        END;    
    BEGIN
        IF mobj IS NOT NULL THEN
            IF  p_autonomus THEN 
                ROLLBACK;
                add_payment_change_commit;
            ELSE mobj.add_changes_entry(l_t_change); 
            END IF;
        END IF;
    --EXCEPTION WHEN OTHERS THEN ROLLBACK;  RAISE;
    END;
    
    /*************************************** Private Implementations  ***************************************/
    
    -- Переопределенная: Добавляет историю изменения статуса
    PROCEDURE add_state_history(p_id    INTEGER,
                                p_state INTEGER,
                                p_user  INTEGER DEFAULT ibs.api_context.get_def_user)
    IS l_pobj t_interbankpayments DEFAULT read_payment(p_id);
    BEGIN
        l_pobj.add_state_history(p_state, p_user, SYSDATE);
    END; 

   
    /*************************************** Main Implementations  ***************************************/
    --Создание нового платежа по основным параметрам: Возвращает ид созданного платежа
    FUNCTION new_payment(p_obj t_interbankpayments, p_auto_commit BOOLEAN DEFAULT TRUE) RETURN INTEGER
    IS l_id INTEGER;
       pobj t_interbankpayments DEFAULT p_obj;
    BEGIN
        api_interbankpayments_access.has_grand(p_msg_type => pobj.MESSAGE_TYPE, p_grand_id => const_interbankpayments.ACCESS_CREATE);
        
        pobj.CREATOR_ID := nvl(pobj.CREATOR_ID, ibs.api_context.get_def_user);
        
        IF pobj.PAYMENT_DATE IS NOT NULL AND IBS.API_CALENDAR.IS_WORK_DAY(pobj.PAYMENT_DATE) <> 1 THEN
            pobj.PAYMENT_DATE := NULL;
            --raise_application_error(-20000, 'Установленная дата {' || pobj.MESSAGE_TYPE || '} не является рабочим банковским днем');    
        END IF;
        
        IF NOT JUI_INTERBANKPAYMENTS_TOOLS.is_known_msgtype(pobj.MESSAGE_TYPE) THEN
            raise_application_error(-20000, 'Не известный тип сообщения {' || pobj.MESSAGE_TYPE || '}');
        END IF;
        
        IF pobj.CURRENCY IS NULL THEN pobj.CURRENCY := const_interbankpayments.CFG_DEFAULT_CURRENCY; END IF;
        
        -- Чтобы не нагружать еще одним селектом приходится дублировать эту проверку
        -- Интернет банкинг платежи идут через Аха Нейматулла
        IF jui_interbankpayments_tools.is_IB_user(pObj.CREATOR_ID) THEN
        	pobj.PAYER_BRANCH_ID := ibs.const_branch.BRANCH_NEYMETULLA;
        END IF;
        --raise_application_error(-20000, pobj.PAYER_BRANCH_ID);
        INSERT INTO interbankpayments
        VALUES (INTERBANKSPAYMENTS_SEQ.NEXTVAL,
                nvl(pobj.REFERENCE, jui_interbankpayments_tools.get_next_reference /*to_char(sysdate, 'YYMMDDHHMI') || INTERBANKSPAYMENTS_SEQ.CURRVAL*/),
                nvl(pobj.STATE, const_interbankpayments.STATE_NEW),
                nvl(pobj.PAYMENT_DATE, JUI_INTERBANKPAYMENTS_TOOLS.get_bank_date()),
                pobj.SYSTEM_ID,
                pobj.MESSAGE_TYPE,
                pobj.AMOUNT,
                pobj.CURRENCY,
                NVL(pobj.FEE_COLLECTION, ibs.t_fee_amount_collection()),
                pobj.GROUND,
                pobj.OPERATION_ID,
                pobj.PAYER_BRANCH_ID,
                pobj.PAYER_ACCOUNT,
                pobj.RECEIVER_NAME,
                pobj.RECEIVER_IBAN,
                pobj.RECEIVER_TAX,
                pobj.EMITENT_BANK_CODE,
                pobj.EMITENT_BANK_CORR_ACCOUNT,
                pobj.BENEFICIAR_BANK_NAME,
                pobj.BENEFICIAR_BANK_CODE,
                pobj.BENEFICIAR_BANK_SWIFT,
                pobj.BENEFICIAR_BANK_TAX,
                pobj.BENEFICIAR_BANK_CORR_ACCOUNT,
                nvl(pobj.CONTEXT_ID, ibs.api_context.get_context),
                nvl(pobj.CREATOR_ID, ibs.api_context.get_def_user),
                NVL(pobj.STATE_HISTORY, 
                    t_intbankpays_state_collection(t_intbankpays_state(nvl(pobj.STATE, const_interbankpayments.STATE_NEW),pobj.CREATOR_ID,SYSDATE))),
                NVL(pobj.ATTRS, t_intbankpays_attr_collection()),
                NVL(pobj.CHANGES, t_intbankpays_changes_col()),
                nvl(pobj.CREATION_DATE, CURRENT_TIMESTAMP)
                )
        RETURNING ID INTO l_id;
        
        IF pObj.OPERATION_ID IS NOT NULL THEN
        	insert_attr_val(l_id, CONST_INTERBANKPAYMENTS.ATTR_IS_MANUAL_OPERATION, p_value_int => 1);
        END IF;
        
        IF jui_interbankpayments_tools.is_IB_user(pObj.CREATOR_ID) THEN
        	insert_attr_val(l_id, CONST_INTERBANKPAYMENTS.ATTR_IS_IB, p_value_int => 1);
        END IF;
        
        IF p_auto_commit = TRUE THEN COMMIT; END IF;
        RETURN l_id;
    END;
    -- Обновляет платежку
    PROCEDURE update_payment(p_interbankpayment interbankpayments%ROWTYPE, 
                             p_auto_commit BOOLEAN DEFAULT TRUE)    -- Делать ли авто коммит изменений
    IS BEGIN
       UPDATE interbankpayments SET ROW = p_interbankpayment WHERE ID = p_interbankpayment.ID; 
       IF p_auto_commit = TRUE THEN COMMIT; END IF;
    END;
    
    FUNCTION read_payment_cursor (p_id IN INTEGER) RETURN SYS_REFCURSOR
    IS l_cur SYS_REFCURSOR;
    BEGIN
       OPEN l_cur FOR SELECT * FROM INTERBANKPAYMENTS s WHERE s.id = p_id; 
       RETURN l_cur;
    END;
    
    -- Возвращает платеж с выборкой из главной таблицы, возвращаемый тип объект t_interbankpayments
    FUNCTION read_payment (p_id IN INTEGER, p_raise_error BOOLEAN DEFAULT TRUE) RETURN t_interbankpayments_extend
    IS  
    BEGIN
        RETURN t_interbankpayments_extend(p_id, p_raise_error);
    END;
    -- Возвращает платеж с выборкой из view
    FUNCTION read_payment_view (p_id IN INTEGER, p_raise_error BOOLEAN DEFAULT TRUE) RETURN V_INTERBANKPAYMENTS%ROWTYPE
    IS 
        l_result V_INTERBANKPAYMENTS%ROWTYPE;
    BEGIN
        SELECT * INTO l_result FROM V_INTERBANKPAYMENTS vip WHERE vip.id = p_id;
        RETURN l_result;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF p_raise_error = TRUE THEN
                raise_application_error(ibs.const_exception.NO_DATA_FOUND, 'Платеж с идентификатором {' || p_id || '} не найден');
            ELSE RETURN NULL;
            END IF;
    END;
    -- Возвращает платеж с выборкой из главной таблицы, возвращаемый тип INTERBANKPAYMENTS%ROWTYPE
    FUNCTION read_payment_rowtype (p_id IN INTEGER, p_raise_error BOOLEAN DEFAULT TRUE) RETURN INTERBANKPAYMENTS%ROWTYPE
    IS 
        l_result INTERBANKPAYMENTS%ROWTYPE;
    BEGIN
        SELECT * INTO l_result FROM INTERBANKPAYMENTS vip WHERE vip.id = p_id;
        RETURN l_result;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF p_raise_error = TRUE THEN
                raise_application_error(ibs.const_exception.NO_DATA_FOUND, 
                                        'Платеж с идентификатором {' || p_id || '} не найден');
            ELSE RETURN NULL;
            END IF;
    END;
    
    
    FUNCTION getMessageTypeObject(p_obj IN OUT NOCOPY t_interbankpayments_extend) RETURN t_intbankpays_msg IS 
        l_result t_intbankpays_msg;
    BEGIN
        IF NOT JUI_INTERBANKPAYMENTS_TOOLS.is_known_msgtype(p_obj.MESSAGE_TYPE) THEN
            raise_application_error(-20000, 'Не известный тип сообщения {' || p_obj.MESSAGE_TYPE || '}');
        END IF;
        
        EXECUTE IMMEDIATE 'begin :result := t_intbankpays_msg_' || p_obj.MESSAGE_TYPE || ' (pobj => :pobj); end;' 
        USING OUT l_result, IN OUT p_obj;

        RETURN l_result;
    END;
    
    
    FUNCTION getMessageTypeObject(pid INTEGER) RETURN t_intbankpays_msg IS 
        l_pobj   t_interbankpayments_extend DEFAULT read_payment(pid);
    BEGIN  RETURN getMessageTypeObject(l_pobj); END;
    
    -- Проверяет наличие атрибута у платежки
    FUNCTION isset_attribute(pid IN INTEGER, p_attr_id INTEGER) RETURN BOOLEAN
    IS
    	l_c	INTEGER; 
    BEGIN
    	SELECT count(1) INTO l_c FROM TABLE(SELECT t.attrs FROM INTERBANKPAYMENTS t WHERE T.ID = pid) u WHERE u.id_attr = p_attr_id;
        IF l_c > 0 THEN RETURN TRUE;
        ELSE RETURN FALSE;
        END IF;
    END;
    
    --Возвращает значение атрибута платежа
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
    -- Возвращает все атрибуты платежа     
    FUNCTION get_attributes(pid IN INTEGER, p_raise_error BOOLEAN DEFAULT FALSE) RETURN t_intbankpays_attr_collection
    IS 
        l_result    t_intbankpays_attr_collection;
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
    -- Переопределенная: Добавляет атрибуты к платежке
    PROCEDURE insert_attr_val(pid IN INTEGER, p_id_attr IN INTEGER, p_value_str IN VARCHAR2 DEFAULT NULL, p_value_int IN NUMBER  DEFAULT NULL)
    IS  BEGIN 
        INSERT INTO TABLE(SELECT t.attrs FROM INTERBANKPAYMENTS t WHERE t.id = pid) t 
        VALUES(p_id_attr, p_value_str, p_value_int);
    END;
    -- Переопределенная: Редактирует значение атрибута платежки
    PROCEDURE edit_attr_val(pid IN INTEGER, p_id_attr IN INTEGER, p_value_str IN VARCHAR2, p_value_int IN NUMBER) IS  
    BEGIN 
        UPDATE TABLE(SELECT t.attrs FROM INTERBANKPAYMENTS t WHERE t.id = pid) t
        SET t.value_str = p_value_str, t.value_int = p_value_int WHERE t.id_attr = p_id_attr;
    END;
    -- Переопределенная: Обвновление атрибута платежки, если нет атрибута, то создает его 
    PROCEDURE update_attr_val(pid IN INTEGER, p_id_attr IN INTEGER, p_value_str IN VARCHAR2 DEFAULT NULL, p_value_int IN NUMBER  DEFAULT NULL)
    IS 
        l_attr t_intbankpays_attr DEFAULT get_attribute_val(pid, p_id_attr, FALSE);
    BEGIN
        IF l_attr IS NULL THEN insert_attr_val(pid, p_id_attr, p_value_str, p_value_int);
        ELSE  edit_attr_val(pid, p_id_attr, p_value_str, p_value_int);
        END IF;
        /*
         Oracle bug
         merge into TABLE(SELECT t.attrs FROM INTERBANKPAYMENTS t WHERE t.id = pid) m using dual on (m.id_attr = p_id_attr)
         when not matched then insert (id_attr,value_str, value_int) values (p_id_attr,p_value_str,p_value_int)
             when matched then update set m.value_str = p_value_str;
        */
        --NULL;
    END;
    function as_swift_charset(p_chars_kind in varchar2) return varchar2 is
    begin
        case lower(p_chars_kind)
            when 'n' then return '[^0-9]';
            when 'a' then return '[^A-Z]';
            when 'c' then return '[^A-Z0-9]';
            when 'h' then return '[^A-F0-9]';
            when 'x' then return '[^-A-Za-z0-9 /?:().,''+{}' || chr(13) || chr(10) || ']';
            when 'y' then return '[^-A-Za-z0-9 .,()/=''+:?!"%&*<>;' || chr(13) || chr(10) || ']';
            when 'z' then return '[^-A-Za-z0-9 .,()/=''+:?!"%&*<>;{@#_' || chr(13) || chr(10) || ']';
        end case;
    end;
    function translit_to_swift(p_text in varchar2) return varchar2 is
    	l_text varchar2(2000 char);
    begin
        l_text := translate(p_text, 'ƏÜÖİĞЄəüöığє', 'AUOIGIauoigi');
        l_text := replace(l_text, 'Ç', 'CH');
        l_text := replace(l_text, 'Ş', 'SH');
        l_text := replace(l_text, 'ç', 'ch');
        l_text := replace(l_text, 'ş', 'sh');      
    	return l_text;
    end;
end api_interbankpayments;
/
