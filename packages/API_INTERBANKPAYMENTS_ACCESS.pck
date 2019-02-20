create or replace package API_INTERBANKPAYMENTS_ACCESS is

  -- Author  : RVKHALAFOV
  -- Created : 7/14/2016 12:06:43
  -- Purpose : 
  
 
    
    
          
    FUNCTION get_state_to_grand_mapping(p_state INTEGER) RETURN INTEGER;
          
    FUNCTION get_grands_as_cusros (p_uid INTEGER DEFAULT NULL) RETURN SYS_REFCURSOR;
              
    -- Добавляет гранд для пользователя
    PROCEDURE add_access_messges_types (p_msg_type INTEGER, p_uid INTEGER DEFAULT NULL);

    -- Возвращает все доступные для пользователя типы сообщения по грандам или без них
    FUNCTION get_access_messges_types (p_uid INTEGER DEFAULT NULL, p_grands ibs.t_integer_collection DEFAULT NULL) 
    RETURN ibs.t_integer_collection;
    -- ВОзвращает все доступные для пользователя типы сообщения по гранду
    FUNCTION get_access_messges_types (p_uid INTEGER DEFAULT NULL, p_grand INTEGER) 
    RETURN ibs.t_integer_collection;
    
    -------------------------------------- Проверка прав доступа --------------------------------------
    -- Проверяет наличие прав доступа
    PROCEDURE has_grand(p_grand_id INTEGER, p_msg_type INTEGER DEFAULT NULL, p_uid INTEGER DEFAULT NULL);
    
    -- Проверяет наличие прав перевода на статус
    PROCEDURE has_state_grand(p_msg_type INTEGER, p_state INTEGER, p_uid INTEGER DEFAULT NULL);
    
    -- Проверяет наличие прав по принципу "Любой из"
    PROCEDURE has_grand(p_grand_id ibs.t_integer_collection, p_msg_type INTEGER DEFAULT NULL, p_uid INTEGER DEFAULT NULL);
    
    -- Проверяет наличие прав по принципу "Любой из"
    FUNCTION has_grand(p_grand ibs.t_integer_collection, p_col t_intbankpays_users_access_col) 
    RETURN integer;

        FUNCTION has_grand(p_grand INTEGER, p_col t_intbankpays_users_access_col) 
        RETURN integer;
        
        FUNCTION has_grand(p_grand ibs.t_integer_collection, p_uid INTEGER DEFAULT ibs.api_context.get_def_user()) 
        RETURN integer;
        
            FUNCTION has_grand(p_grand INTEGER, p_uid INTEGER DEFAULT ibs.api_context.get_def_user())
            RETURN integer;
  
end API_INTERBANKPAYMENTS_ACCESS;
/
create or replace package body API_INTERBANKPAYMENTS_ACCESS IS
    
    FUNCTION get_state_to_grand_mapping(p_state INTEGER) RETURN INTEGER IS
    BEGIN
        CASE 
            WHEN p_state = const_interbankpayments.STATE_VERIFICATION THEN RETURN const_interbankpayments.ACCESS_STATE_TO_10;
            WHEN p_state = const_interbankpayments.STATE_CHANGING THEN RETURN const_interbankpayments.ACCESS_STATE_TO_11;
            WHEN p_state = const_interbankpayments.STATE_CHANGINGFROMAUTH THEN RETURN const_interbankpayments.ACCESS_STATE_TO_12;
            WHEN p_state = const_interbankpayments.STATE_AUTHORIZATION THEN RETURN const_interbankpayments.ACCESS_STATE_TO_20;
            WHEN p_state = const_interbankpayments.STATE_CANCELED THEN RETURN const_interbankpayments.ACCESS_STATE_TO_30;
            WHEN p_state = const_interbankpayments.STATE_COMPLETED THEN RETURN const_interbankpayments.ACCESS_STATE_TO_60;
            ELSE RETURN NULL;
        END CASE;
    END;
    
    -------------------------------------- Проверка прав доступа --------------------------------------
    
    
    PROCEDURE has_grand(p_grand_id ibs.t_integer_collection, p_msg_type INTEGER DEFAULT NULL, p_uid INTEGER DEFAULT NULL) IS
        l_uid INTEGER DEFAULT nvl(p_uid, ibs.api_context.get_def_user);
        l_grand_id  ibs.t_integer_collection DEFAULT nvl(p_grand_id, ibs.t_integer_collection());
        l INTEGER;
    BEGIN
        l_grand_id.extend;
        l_grand_id(l_grand_id.Last) := const_interbankpayments.ACCESS_FULL;
        
        SELECT COUNT(1) INTO l FROM interbankpayments_users_access iua
        WHERE   iua.user_id = l_uid
                AND (iua.mt_types = p_msg_type OR p_msg_type IS NULL)
                AND (SELECT 1  
                    FROM TABLE(iua.access_modes) x  
                    WHERE x.column_value IN (SELECT lg.COLUMN_VALUE FROM TABLE(l_grand_id) lg) 
                    GROUP BY 1) = 1;

        IF l = 0 THEN
            raise_application_error(-20000, 'У пользователя {'|| l_uid ||'} нет прав {'|| ibs.to_.to_string(p_grand_id) ||'}');
        END IF;
    END;
    
        PROCEDURE has_state_grand(p_msg_type INTEGER, p_state INTEGER, p_uid INTEGER DEFAULT NULL) IS
        BEGIN has_grand(get_state_to_grand_mapping(p_state), p_msg_type, p_uid); END; 
    
    PROCEDURE has_grand(p_grand_id INTEGER, p_msg_type INTEGER DEFAULT NULL, p_uid INTEGER DEFAULT NULL) IS
        l_uid INTEGER DEFAULT nvl(p_uid, ibs.api_context.get_def_user);
        l INTEGER;
    BEGIN
        SELECT COUNT(1) INTO l FROM interbankpayments_users_access iua
        WHERE   iua.user_id = l_uid
                AND (iua.mt_types = p_msg_type OR p_msg_type IS NULL)
                AND (SELECT 1  
                    FROM TABLE(iua.access_modes) x  
                    WHERE x.column_value IN (const_interbankpayments.ACCESS_FULL, p_grand_id) 
                    GROUP BY 1) = 1;
        IF l = 0 THEN
            raise_application_error(-20000, 'У пользователя {'|| l_uid ||'} нет прав {'|| p_grand_id ||'}');
        END IF;
    END; 
    
    FUNCTION has_grand(p_grand ibs.t_integer_collection, p_col t_intbankpays_users_access_col) RETURN integer IS
        l_result INTEGER;
        l_grand  ibs.t_integer_collection DEFAULT nvl(p_grand, ibs.t_integer_collection());
    BEGIN
        l_grand.extend;
        l_grand(l_grand.LAST) := const_interbankpayments.ACCESS_FULL;
        SELECT COUNT(1) INTO l_result FROM TABLE(p_col) m
         WHERE 1 = (SELECT 1
                    FROM TABLE(m.access_modes) x  
                    WHERE x.column_value IN (SELECT COLUMN_VALUE FROM TABLE(l_grand)) 
                    GROUP BY 1);
        RETURN CASE WHEN l_result > 0 THEN 1 ELSE 0 END;
    END;
    
    FUNCTION has_grand(p_grand INTEGER, p_col t_intbankpays_users_access_col) RETURN integer IS
    BEGIN RETURN has_grand(ibs.t_integer_collection(p_grand),p_col); END;
    
    FUNCTION has_grand(p_grand ibs.t_integer_collection, p_uid INTEGER DEFAULT ibs.api_context.get_def_user()) RETURN integer IS
        l_msg_acs_col t_intbankpays_users_access_col;
    BEGIN
        SELECT t_intbankpays_users_access(USER_ID => m.user_id, MT_TYPE => m.mt_types, ACCESS_MODES => m.access_modes) 
        BULK COLLECT INTO l_msg_acs_col
        FROM INTERBANKPAYMENTS_USERS_ACCESS m 
        WHERE m.user_id = p_uid;
        RETURN has_grand(p_grand, l_msg_acs_col);
    END;
    
    FUNCTION has_grand(p_grand INTEGER, p_uid INTEGER DEFAULT ibs.api_context.get_def_user()) RETURN integer IS
    BEGIN RETURN has_grand(ibs.t_integer_collection(p_grand), p_uid); END;

    
    
    
    FUNCTION get_grands_as_cusros (p_uid INTEGER DEFAULT NULL) RETURN SYS_REFCURSOR IS
        l_cursor SYS_REFCURSOR;
        l_uid INTEGER DEFAULT nvl(p_uid, ibs.api_context.get_def_user);
    BEGIN
        OPEN l_cursor FOR   SELECT * 
                            FROM INTERBANKPAYMENTS_USERS_ACCESS iua
                            WHERE iua.user_id = l_uid;
        RETURN l_cursor;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            raise_application_error(-20000, 'Для пользователя {' || l_uid ||'} нет определены права доступа');
    END;

    ------------------------- Adding
    PROCEDURE add_access_messges_types (p_msg_type INTEGER, p_uid INTEGER DEFAULT NULL)
    IS  l_uid INTEGER DEFAULT p_uid;
        l INTEGER;
    BEGIN
        IF p_uid IS NULL THEN l_uid := ibs.api_context.get_def_user; END IF;

        SELECT 1 INTO l 
        FROM  INTERBANKPAYMENTS_USERS_ACCESS m 
        WHERE  m.user_id = p_uid AND m.mt_types = p_msg_type;

    EXCEPTION WHEN NO_DATA_FOUND THEN INSERT INTO INTERBANKPAYMENTS_USERS_ACCESS VALUES(l_uid, p_msg_type, ibs.t_integer_collection());
    END;   
    
    FUNCTION get_access_messges_types(p_uid INTEGER DEFAULT NULL, p_grand INTEGER) 
    RETURN ibs.t_integer_collection
    IS l ibs.t_integer_collection DEFAULT ibs.t_integer_collection();
    BEGIN
        l.extend;
        l(l.last) := p_grand;
        RETURN get_access_messges_types(p_uid, l); 
    END;        
    
    FUNCTION get_access_messges_types(p_uid INTEGER DEFAULT NULL, p_grands ibs.t_integer_collection DEFAULT NULL) 
    RETURN ibs.t_integer_collection
    IS  l_uid INTEGER DEFAULT nvl(p_uid, ibs.api_context.get_def_user);
        l_result ibs.t_integer_collection;
        l_grands ibs.t_integer_collection DEFAULT p_grands;
    BEGIN
        l_grands.extend;
        l_grands(l_grands.last) := const_interbankpayments.ACCESS_FULL;
        
        SELECT m.MT_TYPES BULK COLLECT INTO l_result 
        FROM INTERBANKPAYMENTS_USERS_ACCESS m
        WHERE  m.user_id = l_uid AND 
            ((SELECT UNIQUE 1 FROM TABLE(m.access_modes) WHERE COLUMN_VALUE IN 
            (SELECT * FROM TABLE(l_grands))) = 1 OR l_grands IS NULL);
        RETURN nvl(l_result, ibs.t_integer_collection()) ;
    END;
    
  
end API_INTERBANKPAYMENTS_ACCESS;
/
