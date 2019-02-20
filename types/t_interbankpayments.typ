create or replace type t_interbankpayments FORCE AS OBJECT
(
    -- Author  : RVKHALAFOV
    -- Created : 3/9/2016 20:13:39
    -- Purpose : 
    ID                              NUMBER,
    REFERENCE                       VARCHAR2(40 CHAR),
    STATE                           NUMBER,
    PAYMENT_DATE                    TIMESTAMP(6),
    SYSTEM_ID                       NUMBER,
    MESSAGE_TYPE                    NUMBER,
    AMOUNT                          NUMBER(30,2),
    CURRENCY                        NUMBER,
    FEE_COLLECTION                  ibs.t_fee_amount_collection,
    GROUND                          VARCHAR2(2000 CHAR),
    OPERATION_ID                    NUMBER,
    PAYER_BRANCH_ID                 NUMBER,
    PAYER_ACCOUNT                   VARCHAR2(35 CHAR),
    RECEIVER_NAME                   VARCHAR2(100 CHAR),
    RECEIVER_IBAN                   VARCHAR2(35 CHAR),
    RECEIVER_TAX                    VARCHAR2(2000 CHAR),
    EMITENT_BANK_CODE               VARCHAR2(30 CHAR),
    EMITENT_BANK_CORR_ACCOUNT       VARCHAR2(50 CHAR),
    BENEFICIAR_BANK_NAME            VARCHAR2(100 CHAR),
    BENEFICIAR_BANK_CODE            VARCHAR2(100 CHAR),
    BENEFICIAR_BANK_SWIFT           VARCHAR2(100 CHAR),
    BENEFICIAR_BANK_TAX             VARCHAR2(100 CHAR),
    BENEFICIAR_BANK_CORR_ACCOUNT    VARCHAR2(50 CHAR),
    CONTEXT_ID                      NUMBER,
    CREATOR_ID                      NUMBER,
    STATE_HISTORY                   T_INTBANKPAYS_STATE_COLLECTION,
    ATTRS                           T_INTBANKPAYS_ATTR_COLLECTION,
    CHANGES                         T_INTBANKPAYS_CHANGES_COL,
    CREATION_DATE                   TIMESTAMP,
    
    -- Setters
    MEMBER PROCEDURE set_ID(p_var 		NUMBER),
    MEMBER PROCEDURE set_STATE(p_var 	NUMBER),
    MEMBER PROCEDURE set_AMOUNT(p_var 	NUMBER),
    MEMBER PROCEDURE set_CURRENCY(p_var NUMBER),
    MEMBER PROCEDURE set_GROUND(p_var 	VARCHAR2),
    MEMBER PROCEDURE set_SYSTEM_ID(p_var 	NUMBER),
    MEMBER PROCEDURE set_CONTEXT_ID(p_var 	NUMBER),    
    MEMBER PROCEDURE set_REFERENCE(p_var 	VARCHAR2),
    MEMBER PROCEDURE set_CREATION_DATE(p_var 	DATE),
    MEMBER PROCEDURE set_MESSAGE_TYPE(p_var 	NUMBER),
    MEMBER PROCEDURE set_OPERATION_ID(p_var 	NUMBER),
    MEMBER PROCEDURE set_RECEIVER_TAX(p_var 	VARCHAR2),
    MEMBER PROCEDURE set_PAYER_BRANCH_ID(p_var 	NUMBER),
    MEMBER PROCEDURE set_PAYMENT_DATE(p_var 	TIMESTAMP),
    MEMBER PROCEDURE set_PAYER_ACCOUNT(p_var 	VARCHAR2),
    MEMBER PROCEDURE set_RECEIVER_NAME(p_var 	VARCHAR2),
    MEMBER PROCEDURE set_RECEIVER_IBAN(p_var 	VARCHAR2),
    MEMBER PROCEDURE set_EMITENT_BANK_CODE(p_var 	VARCHAR2),
    MEMBER PROCEDURE set_EMITENT_BANK_CORR_ACCOUNT(p_var 	VARCHAR2),
    MEMBER PROCEDURE set_BENEFICIAR_BANK_NAME(p_var     VARCHAR2),
    MEMBER PROCEDURE set_BENEFICIAR_BANK_CODE(p_var 	VARCHAR2),
    MEMBER PROCEDURE set_BENEFICIAR_BANK_SWIFT(p_var 	VARCHAR2),
    member procedure set_beneficiar_bank_corr_acc(p_var varchar2),
    MEMBER PROCEDURE set_ATTRS(p_var T_INTBANKPAYS_ATTR_COLLECTION),
    MEMBER PROCEDURE set_FEE_COLLECTION(p_var ibs.t_fee_amount_collection),
    MEMBER PROCEDURE set_STATE_HISTORY(p_var T_INTBANKPAYS_STATE_COLLECTION),
    MEMBER PROCEDURE set_CHANGES(p_var T_INTBANKPAYS_CHANGES_COL),
    
    MEMBER PROCEDURE remove_fee(p_kind INTEGER),
    MEMBER FUNCTION get_fee_by_kind(p_kind INTEGER) RETURN ibs.t_fee_amount,

    -- Main
    MEMBER PROCEDURE update_payment(p_auto_commit BOOLEAN DEFAULT FALSE),    
    MEMBER PROCEDURE reload(p_id INTEGER),
    -- Changes
    MEMBER PROCEDURE add_changes_entry(p_changes t_intbankpays_changes),
    -- History    
    MEMBER PROCEDURE add_state_history(p_state INTEGER, p_user INTEGER DEFAULT NULL, p_date DATE DEFAULT NULL),
    -- Attributes
    MEMBER FUNCTION isset_attribute(p_attr_id INTEGER) RETURN BOOLEAN,
    MEMBER FUNCTION get_attribute_val(p_attr_id INTEGER, p_raise_error BOOLEAN DEFAULT FALSE) RETURN t_intbankpays_attr,
    MEMBER PROCEDURE remove_attr(p_attr_id IN INTEGER),
    MEMBER PROCEDURE update_attr_val(p_attr IN t_intbankpays_attr),    
    --Fee
    MEMBER FUNCTION get_fee_sum RETURN NUMBER,
    -- Constructors
    CONSTRUCTOR FUNCTION t_interbankpayments(p_id INTEGER, p_raise_error BOOLEAN DEFAULT TRUE)    RETURN SELF AS RESULT,
    CONSTRUCTOR FUNCTION t_interbankpayments RETURN SELF AS RESULT
) NOT FINAL
/
create or replace type body t_interbankpayments IS
    MEMBER PROCEDURE add_changes_entry(p_changes t_intbankpays_changes)
    IS BEGIN
        IF SELF.changes IS NULL THEN
            SELF.changes := T_INTBANKPAYS_CHANGES_COL();
        END IF;
        SELF.changes.EXTEND;
        SELF.changes(SELF.changes.last) := p_changes;
        --update_payment();
    END;


  -- Member procedures and functions
  -- Добавляет историю изменения статуса
    -- Переопредеupdate_paymentленная: Добавляет историю изменения статуса
    MEMBER PROCEDURE add_state_history(p_state INTEGER, p_user INTEGER DEFAULT NULL, p_date DATE DEFAULT NULL)
    IS 
    BEGIN
        IF SELF.STATE_HISTORY IS NULL THEN
           SELF.STATE_HISTORY := t_intbankpays_state_collection();
        END IF;

        SELF.STATE_HISTORY.EXTEND;
        SELF.STATE_HISTORY(SELF.STATE_HISTORY.LAST) := t_intbankpays_state(p_state, p_user, p_date);
        --update_payment();
    END; 

  -- Обновляет платежку
    MEMBER PROCEDURE update_payment(p_auto_commit BOOLEAN DEFAULT FALSE)    -- Делать ли авто коммит изменений
    IS l integer;
    BEGIN
       UPDATE interbankpayments
       SET  reference = TRIM(SELF.REFERENCE),
            state = SELF.STATE,
            payment_date = TRUNC(SELF.PAYMENT_DATE),
            system_id = SELF.SYSTEM_ID,
            message_type = SELF.MESSAGE_TYPE,
            amount = SELF.AMOUNT,
            currency = SELF.CURRENCY,
            fee_collection = SELF.FEE_COLLECTION,
            ground = SELF.GROUND,
            operation_id = SELF.OPERATION_ID,
            payer_branch_id = SELF.PAYER_BRANCH_ID,
            payer_account = TRIM(SELF.PAYER_ACCOUNT),
            receiver_name = TRIM(SELF.RECEIVER_NAME),
            receiver_iban = TRIM(SELF.RECEIVER_IBAN),
            receiver_tax = TRIM(SELF.RECEIVER_TAX),
            emitent_bank_code = TRIM(SELF.EMITENT_BANK_CODE),
            beneficiar_bank_name = TRIM(SELF.BENEFICIAR_BANK_NAME),
            beneficiar_bank_code = TRIM(SELF.BENEFICIAR_BANK_CODE),
            beneficiar_bank_swift = TRIM(SELF.BENEFICIAR_BANK_SWIFT),
            beneficiar_bank_tax = TRIM(SELF.BENEFICIAR_BANK_TAX),
            beneficiar_bank_corr_account = TRIM(SELF.BENEFICIAR_BANK_CORR_ACCOUNT),
            context_id = SELF.CONTEXT_ID,
            creator_id = SELF.CREATOR_ID,
            state_history = SELF.STATE_HISTORY,
            changes = SELF.CHANGES,
            attrs = SELF.ATTRS
       WHERE ID = SELF.ID
       RETURNING ID INTO l; 
       IF p_auto_commit = TRUE THEN COMMIT; END IF;
    END;
    
    MEMBER PROCEDURE reload(p_id INTEGER)
    IS BEGIN
       SELECT  ibp.id,ibp.reference, ibp.state, ibp.payment_date, ibp.system_id,ibp.message_type, ibp.amount, ibp.currency,
                ibp.fee_collection,ibp.ground, ibp.operation_id, ibp.payer_branch_id, ibp.payer_account,
                ibp.receiver_name, ibp.receiver_iban, ibp.receiver_tax, ibp.emitent_bank_code, ibp.beneficiar_bank_code,
                ibp.beneficiar_bank_swift,ibp.beneficiar_bank_tax,ibp.context_id, ibp.creator_id, ibp.state_history, ibp.attrs, ibp.changes,
                ibp.beneficiar_bank_name, ibp.emitent_bank_corr_account, ibp.beneficiar_bank_corr_account
        INTO    SELF.ID, SELF.REFERENCE, SELF.STATE,SELF.PAYMENT_DATE,SELF.SYSTEM_ID,SELF.MESSAGE_TYPE,SELF.AMOUNT,SELF.CURRENCY,
                SELF.FEE_COLLECTION,SELF.GROUND,SELF.OPERATION_ID,SELF.PAYER_BRANCH_ID,
                SELF.PAYER_ACCOUNT,SELF.RECEIVER_NAME,SELF.RECEIVER_IBAN,SELF.RECEIVER_TAX,SELF.EMITENT_BANK_CODE,
                SELF.BENEFICIAR_BANK_CODE,SELF.BENEFICIAR_BANK_SWIFT,SELF.BENEFICIAR_BANK_TAX,SELF.CONTEXT_ID,SELF.CREATOR_ID,
                SELF.STATE_HISTORY, SELF.ATTRS, SELF.CHANGES, SELF.BENEFICIAR_BANK_NAME,
                SELF.EMITENT_BANK_CORR_ACCOUNT, SELF.BENEFICIAR_BANK_CORR_ACCOUNT
        FROM interbankpayments ibp WHERE ibp.id = p_id; 
    END;
    
    -- Проверяет наличие атрибута у платежки
    MEMBER FUNCTION isset_attribute(p_attr_id INTEGER) RETURN BOOLEAN
    IS l_c	INTEGER DEFAULT 0; 
    BEGIN
        SELECT COUNT(1) INTO l_c FROM TABLE(SELF.ATTRS) s WHERE s.id_attr = p_attr_id;
        
        IF l_c > 0 THEN RETURN TRUE;
        ELSE RETURN FALSE;
        END IF;
    END;
    
  --Возвращает значение атрибута платежа
    MEMBER FUNCTION get_attribute_val(p_attr_id INTEGER, p_raise_error BOOLEAN DEFAULT FALSE) RETURN t_intbankpays_attr
    IS l_index     INTEGER DEFAULT SELF.ATTRS.FIRST;
    BEGIN
        WHILE (l_index IS NOT NULL)
        LOOP
            IF SELF.ATTRS(l_index).id_attr = p_attr_id THEN RETURN SELF.ATTRS(l_index); END IF;
            l_index := SELF.ATTRS.NEXT(l_index); 
        END LOOP;
        
        /*
        Тут баг, при нахождении объекта выдает ошибку no data found
        IF SELF.ATTRS.count > 0 AND SELF.ATTRS IS NOT NULL THEN
            FOR indx IN 1 .. SELF.ATTRS.count
            LOOP
               dbms_output.put_line(indx || ' - ' ||p_attr_id || ' - ');
               IF SELF.ATTRS(indx).id_attr = 332 THEN
                   RETURN SELF.ATTRS(indx);
                   END IF;
               END LOOP;
        END IF;*/

        IF p_raise_error = TRUE THEN        
            raise_application_error(ibs.const_exception.GENERAL_ERROR, 
                                    'Для платежа с ид {' || SELF.ID || '} не установлен атрибут {' || p_attr_id || '}');
        END IF;
        RETURN NULL;
    -- EXCEPTION WHEN OTHERS THEN RETURN NULL;
    END;
    -- Удаляет атрибут у платежа
    MEMBER PROCEDURE remove_attr(p_attr_id IN INTEGER) IS
        l_index     INTEGER DEFAULT SELF.ATTRS.FIRST;
    BEGIN
        WHILE (l_index IS NOT NULL)
        LOOP
            IF SELF.ATTRS(l_index).id_attr = p_attr_id 
            THEN 
                SELF.ATTRS.delete(l_index);
                EXIT;
            END IF;
            l_index := SELF.ATTRS.NEXT(l_index); 
        END LOOP;
    END;
    
    -- Добавляет атрибуты к платежке 
    -- Обвновление атрибута платежки, если нет атрибута, то создает его 
    MEMBER PROCEDURE update_attr_val(p_attr IN t_intbankpays_attr)
    IS 
        -- Надо  проверить на возможность передачи о ссылке, чтобы не городить ниже написанную логику
        --l_attr t_intbankpays_attr DEFAULT self.get_attribute_val(p_attr.id_attr, FALSE);
        l       INTEGER;
        l_index INTEGER DEFAULT SELF.ATTRS.FIRST;
        l_attr  t_intbankpays_attr DEFAULT p_attr;
    BEGIN
        IF l_attr.value_str IS NULL AND l_attr.value_int IS NULL THEN
            l_attr.value_int := 1;
        END IF;  
    
    
        SELECT 1 INTO l FROM TABLE(SELF.ATTRS) s WHERE s.id_attr = l_attr.id_attr;
        WHILE (l_index IS NOT NULL)
        LOOP
            IF SELF.ATTRS(l_index).id_attr = l_attr.id_attr 
            THEN 
                SELF.ATTRS(l_index) := l_attr; 
                EXIT;
            END IF;
            l_index := SELF.ATTRS.NEXT(l_index); 
        END LOOP;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            SELF.ATTRS.extend;
            SELF.ATTRS(SELF.ATTRS.last) := l_attr;
    END;

    MEMBER FUNCTION get_fee_sum RETURN NUMBER
    IS 
        l_sum NUMBER DEFAULT 0.0;
        l_fee_coll  ibs.t_fee_amount_collection DEFAULT SELF.FEE_COLLECTION;
    BEGIN
        FOR indx IN 1 .. l_fee_coll.count
        LOOP
            l_sum := l_sum + SELF.FEE_COLLECTION(indx).FEE_AMOUNT;
        END LOOP;
        RETURN l_sum;
    END;
    
    MEMBER PROCEDURE remove_fee(p_kind INTEGER) IS
    BEGIN
        IF FEE_COLLECTION IS NOT NULL AND FEE_COLLECTION.count > 0 THEN
            FOR indx IN FEE_COLLECTION.first .. FEE_COLLECTION.last
            LOOP
                IF FEE_COLLECTION(indx).fee_id = p_kind THEN
                    FEE_COLLECTION.delete(indx);
                END IF;
            END LOOP;
        END IF;
    END;    
    
    MEMBER FUNCTION get_fee_by_kind(p_kind INTEGER) RETURN ibs.t_fee_amount IS
    BEGIN
        IF FEE_COLLECTION IS NOT NULL AND FEE_COLLECTION.count > 0 THEN
            FOR indx IN FEE_COLLECTION.first .. FEE_COLLECTION.last
            LOOP
                IF FEE_COLLECTION(indx).fee_id = p_kind THEN
                    RETURN FEE_COLLECTION(indx);
                END IF;
            END LOOP;
        END IF;
        RETURN NULL;
    EXCEPTION
        -- С хера ли если верхний луп ничего не нашел выдается такой эксепшен
        WHEN NO_DATA_FOUND THEN RETURN NULL;
    END;
    
    ---------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION t_interbankpayments(p_id INTEGER, p_raise_error BOOLEAN DEFAULT TRUE) RETURN SELF AS RESULT
    AS 
    BEGIN 
        reload(p_id);
        RETURN;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF p_raise_error = TRUE THEN
                raise_application_error(ibs.const_exception.NO_DATA_FOUND, 'Платеж с идентификатором {' || p_id || '} не найден');
            ELSE RETURN;
            END IF; 
    END;

    CONSTRUCTOR FUNCTION t_interbankpayments RETURN SELF AS RESULT
    AS BEGIN  RETURN; END;

	member procedure set_id(p_var number)           is begin self.id := p_var; end;
    member procedure set_state(p_var number)        is begin self.state := p_var; end;
    member procedure set_amount(p_var number)   	is begin self.amount := p_var; end;
    member procedure set_currency(p_var number)     is begin self.currency := p_var; end;
    member procedure set_ground(p_var varchar2)     	is begin self.ground := p_var; end;
    member procedure set_system_id(p_var number)     	is begin self.system_id := p_var; end;
    member procedure set_context_id(p_var number)     	is begin self.context_id := p_var; end;    
    member procedure set_reference(p_var varchar2)     	is begin self.reference := p_var; end;
    member procedure set_creation_date(p_var date)     	is begin self.creation_date := p_var; end;    
    member procedure set_message_type(p_var number) 	is begin self.message_type := p_var; end;
    member procedure set_operation_id(p_var number) 	is begin self.operation_id := p_var; end;
    
    member procedure set_payer_branch_id(p_var number)  
    is begin 
        self.payer_branch_id := p_var; 
        end;
        
    member procedure set_payment_date(p_var timestamp)  is begin self.payment_date := p_var; end;
    member procedure set_payer_account(p_var varchar2)  is begin self.payer_account := p_var; end;
    member procedure set_receiver_name(p_var varchar2)  is begin self.receiver_name := p_var; end;
    member procedure set_receiver_iban(p_var varchar2)  is begin self.receiver_iban := p_var; end;
    member procedure set_receiver_tax(p_var  varchar2)	is begin self.receiver_tax := p_var; end;    
    member procedure set_emitent_bank_code(p_var varchar2) 	is begin self.emitent_bank_code := p_var; end;
    member procedure set_emitent_bank_corr_account(p_var varchar2) 	is begin self.EMITENT_BANK_CORR_ACCOUNT := p_var; end;
    member procedure set_beneficiar_bank_name(p_var varchar2)   is begin self.beneficiar_bank_name := p_var; end;
    member procedure set_beneficiar_bank_code(p_var varchar2)	is begin self.beneficiar_bank_code := p_var; end;
    member procedure set_beneficiar_bank_swift(p_var varchar2)  is begin self.beneficiar_bank_swift := p_var; end;
    member procedure set_beneficiar_bank_corr_acc(p_var varchar2) 	is begin self.BENEFICIAR_BANK_CORR_ACCOUNT := p_var; end;
    member procedure set_changes(p_var T_INTBANKPAYS_CHANGES_COL) is begin self.changes := p_var; end;
    member procedure set_attrs(p_var t_intbankpays_attr_collection)		is begin self.attrs := p_var; end;
    member procedure set_fee_collection(p_var ibs.t_fee_amount_collection) 	is begin 
        IF fee_collection IS NULL THEN fee_collection := ibs.t_fee_amount_collection(); END IF;
        FOR indx IN p_var.first .. p_var.last
            LOOP 
                fee_collection.extend;
                fee_collection(self.fee_collection.last) := p_var(indx);
            END LOOP;
        end;
    member procedure set_state_history(p_var t_intbankpays_state_collection) is begin self.state_history := p_var; end;
END;
/
