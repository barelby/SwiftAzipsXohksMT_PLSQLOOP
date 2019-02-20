create or replace type T_INTBANKPAYS_CHANGES FORCE as object
(
    change_date        TIMESTAMP,           -- Дата и время изменения
    change_initiator   INTEGER,             -- Инициатор изменений
    change_desc        VARCHAR2(100),       -- Описание/название изменения
    change_action      VARCHAR2(100),       -- Функция, где было произведено изменение
    change_result      VARCHAR2(3000),      -- Результат изменений. ОК или сообщение об ошибке
    change_additional  VARCHAR2(3000),       -- Дополнительная информация
    
    constructor function T_INTBANKPAYS_CHANGES(p_change_initiator   IN INTEGER,
                                               p_change_action      IN VARCHAR2,
                                               p_change_desc        IN VARCHAR2 DEFAULT NULL,
                                               p_change_result      IN VARCHAR2 DEFAULT 'OK',
                                               p_change_additional  IN VARCHAR2 DEFAULT NULL,
                                               p_change_date        IN TIMESTAMP DEFAULT SYSDATE
                                               ) return self as RESULT,
                                               
    constructor function T_INTBANKPAYS_CHANGES  return self as RESULT
)
/
create or replace type body T_INTBANKPAYS_CHANGES IS

    constructor function T_INTBANKPAYS_CHANGES(p_change_initiator   IN INTEGER,
                                               p_change_action      IN VARCHAR2,
                                               p_change_desc        IN VARCHAR2 DEFAULT NULL,
                                               p_change_result      IN VARCHAR2 DEFAULT 'OK',
                                               p_change_additional  IN VARCHAR2 DEFAULT NULL,
                                               p_change_date        IN TIMESTAMP DEFAULT SYSDATE
                                               ) return self as RESULT
    AS BEGIN
        SELF.change_date := SYSTIMESTAMP;
        SELF.change_initiator := p_change_initiator;
        SELF.change_desc := p_change_desc;
        SELF.change_action := p_change_action;
        SELF.change_result := nvl(p_change_result, 'OK');
        SELF.change_additional := p_change_additional;
        RETURN;
    END;

    constructor function T_INTBANKPAYS_CHANGES  return self as RESULT
    AS BEGIN  RETURN; END;
end;
/
