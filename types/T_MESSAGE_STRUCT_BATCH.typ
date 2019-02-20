create or replace type T_MESSAGE_STRUCT_BATCH FORCE UNDER T_MESSAGE_STRUCT
(
    obj_collection       t_interbankpayments_ext_col,
    OVERRIDING MEMBER FUNCTION tag_32a RETURN VARCHAR2,
    OVERRIDING MEMBER FUNCTION GENERATE_BODY(SELF IN OUT T_MESSAGE_STRUCT_BATCH) RETURN VARCHAR2,
    -- Окончательная логика по итоговому телу сообщения (к примеру, добавление доп. тегов)
    MEMBER FUNCTION GENERATE_COMPLETED_BODY(l_result CLOB) RETURN VARCHAR2,
    -- Возвращает тело платежа конкретно для одного сообщения
    MEMBER FUNCTION GENERATE_SINGLE_MESSAGE_BODY(SELF IN OUT T_MESSAGE_STRUCT_BATCH) RETURN VARCHAR2,
    MEMBER PROCEDURE SET_COLLECTION(pobj_collection IN OUT NOCOPY t_interbankpayments_ext_col),
    MEMBER FUNCTION GET_BATCH_AMOUNT_SUM RETURN NUMBER,
    CONSTRUCTOR FUNCTION T_MESSAGE_STRUCT_BATCH(pobj_collection IN OUT NOCOPY t_interbankpayments_ext_col) RETURN SELF AS RESULT
) NOT FINAL
/
create or replace type body T_MESSAGE_STRUCT_BATCH IS
    OVERRIDING MEMBER FUNCTION tag_32a RETURN VARCHAR2 IS
    begin
        return ':32A:' || to_char(obj.PAYMENT_DATE, 'YYMMDD') || 
                          obj.CURRENCY_CODE || 
                          SELF.format_amount(SELF.GET_BATCH_AMOUNT_SUM);
    end;
    
    MEMBER FUNCTION GENERATE_COMPLETED_BODY(l_result CLOB) RETURN VARCHAR2 IS 
    BEGIN RETURN  l_result; END;
    
    MEMBER FUNCTION GENERATE_SINGLE_MESSAGE_BODY(SELF IN OUT T_MESSAGE_STRUCT_BATCH) RETURN VARCHAR2 IS 
    BEGIN RETURN  ''; END;

    OVERRIDING MEMBER FUNCTION GENERATE_BODY(SELF IN OUT T_MESSAGE_STRUCT_BATCH) RETURN VARCHAR2 IS 
        l_index     INTEGER DEFAULT SELF.obj_collection.FIRST;
        l_result    CLOB DEFAULT '';
    BEGIN
        WHILE (l_index IS NOT NULL)
        LOOP
            SELF.init(SELF.obj_collection(l_index));
            l_result := l_result || GENERATE_SINGLE_MESSAGE_BODY();
            l_index := SELF.obj_collection.next(l_index);
        END LOOP;
        RETURN GENERATE_COMPLETED_BODY(l_result);
    END;
    
    MEMBER FUNCTION GET_BATCH_AMOUNT_SUM RETURN NUMBER IS
        l_index INTEGER;
        l_sum   NUMBER DEFAULT 0.0;
    BEGIN
        l_index := SELF.obj_collection.FIRST;
        WHILE (l_index IS NOT NULL)
        LOOP
            l_sum := l_sum + nvl(SELF.obj_collection(l_index).AMOUNT, 0.0);
            l_index := SELF.obj_collection.next(l_index);
        END LOOP;
        RETURN l_sum;
    END;
    
    MEMBER PROCEDURE SET_COLLECTION(pobj_collection IN OUT NOCOPY t_interbankpayments_ext_col) IS
        l_index INTEGER;
        l_b     bank_list%ROWTYPE;
    BEGIN
        IF pobj_collection.count > 0 AND pobj_collection IS NOT NULL THEN
            SELF.obj_collection := pobj_collection;
        ELSE raise_application_error(-20000, 'Для пакетной генерации платежных файлов не передано ниодного платежа');    
        END IF;
    END;
    
    CONSTRUCTOR FUNCTION T_MESSAGE_STRUCT_BATCH(pobj_collection IN OUT NOCOPY t_interbankpayments_ext_col) RETURN SELF AS RESULT IS 
    BEGIN  SET_COLLECTION(pobj_collection); RETURN; END;
end;
/
