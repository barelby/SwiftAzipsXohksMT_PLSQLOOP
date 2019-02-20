create or replace package const_exceptions IS
    --- Не забыть увеличить capacity для t_string_int as object str VARCHAR2(50) -> VARCHAR2(2000) 
    -- Клиентские
    SUM_NOT_SET                 CONSTANT t_string_int := t_string_int(str => 'Не установлена сумма для платежа', integ => -20601);
    NO_GROUND                   CONSTANT t_string_int := t_string_int(str => 'Основание платежа не указано', integ => -20602);
    GROUND_WRONG_SYM            CONSTANT t_string_int := t_string_int(str => 'Основание содержит запрещенные символы', integ => -20603);
    GROUND_WRONG_LENGTH         CONSTANT t_raise_message := t_raise_message(message => 'Основание превышает {%1} максимальную длину {%2} символов', 
                                                                        code => -20604);
    NO_BENBANK_CODE             CONSTANT t_string_int := t_string_int(str => 'Код банка-получателя не указан', integ => -20605);
    NO_CURRENCY                 CONSTANT t_raise_message := t_raise_message(message => 'Не установлена валюта для платежа',code => -20606);
    CURRENCY_WRONG              CONSTANT t_string_int := t_string_int(str => 'Неизвестная валюта {%1}', integ => -20607);
    AMOUNT_NO_ENOUGHT           CONSTANT t_string_int := t_string_int(str => 'На счету {%1} не достаточно средств {%2} для 
                                                                                    создания платежа {%3} на сумму {%4} : 
                                                                                    сумма платежа - {%5}; 
                                                                                    сумма комиссии {%6}', integ => -20608);
    RECEIVERNAME_WRONG          CONSTANT t_string_int := t_string_int(str => 'Некорректное имя получателя {%1}: 
                                                                          Имя должно содержать 34 символа (только латинские буквы)', 
                                                                  integ => -20609);
    RECEIVERTAX_NO              CONSTANT t_string_int := t_string_int(str => 'ИНН получателя неустановлен', 
                                                                  integ => -20610);
    RECEIVERTAX_WRONG           CONSTANT t_string_int := t_string_int(str => 'Некорректный ИНН {%1} получателя: ИНН должен содержать 10 или 7 символов {%2} 
                                                                          (только цифры) или может быть пустым', 
                       	                                                       integ => -20611);
    RECEIVERIBAN_NO             CONSTANT t_string_int := t_string_int(str => 'Не установлен ИБАН счет получателя', 
                                                                          integ => -20612);
    RECEIVERIBAN_L_WR           CONSTANT t_string_int := t_string_int(str => 'Неверная длина {%1} ИБАН счета {%2}',integ => -20613);
    PAYER_ACC_NO                CONSTANT t_raise_message := t_raise_message(message => 'Счет плательщика не указан',code => -20614);
    NO_REF_ACC_ADD              CONSTANT t_raise_message := t_raise_message(message => 'Выбран "Əks olunan hesab", a "Əlavə məlumat" не записан',code => -20615);
    ACC_CLOSED                  CONSTANT t_raise_message := t_raise_message(message => 'Счет {%1} закрыт',code => -20616);
    NO_REF_ACC                  CONSTANT t_raise_message := t_raise_message(message => 'Не установлен "Ödənişin əks olunduğu hesab"',code => -20617);
    NO_BENB_SWIFT               CONSTANT t_raise_message := t_raise_message(message => 'Не установлен swift банка получателя', code => -20618); 
    MT123_REC_PAY_DIF_CUR       CONSTANT t_raise_message := t_raise_message(message => 'Для внутрибанковских платежей валюта {%1} счета {%2} получателя и валюта {%3} счета {%4} отправителя не должны отличаться.', code => -20619); 
    RECEIVERIBAN_WRONG          CONSTANT t_string_int := t_string_int(str => 'Некорректное IBAN получателя {%1}',  integ => -20620);
    MT113_BB_NOT_FOUND          CONSTANT t_raise_message := t_raise_message(message => 'Банк бенефициар со SWIFT {%1} не найден в базе',  code => -20621);
    MT113_IB_IBAN_WRONG         CONSTANT t_raise_message := t_raise_message(message => 'Некорректный IBAN банка посредника {%1}',  code => -20622);
    MT113_FEE_ACC_ENOUGHT       CONSTANT t_raise_message := t_raise_message(message => 'На счету {%1} не достаточно средств {%2} для комиссии {%3}',  code => -20623);
    ACC_CURENCY_DIF_PCURRENCY   CONSTANT t_raise_message := t_raise_message(message => 'Валюта счета плательщика {%1} отличается от валюты платежа {%2}',  code => -20624);
    BOTH_BUDGET_WILLFILL        CONSTANT t_raise_message := t_raise_message(message => 'Оба бюджетных кода должны быть заполнены',  code => -20625);
    
    -- Лучше не показывать ИБ клиенту
    PAYSYS_NOT_SET          CONSTANT t_raise_message := t_raise_message(message => 'Не определена платежная система',code => -20501);
    NO_BANK_DATE            CONSTANT t_string_int := t_string_int(str => 'Установленная дата не является рабочей банковской датой', integ => -20502);
    NO_PAYER_BRANCH         CONSTANT t_string_int := t_string_int(str => 'Филиал плательщика не указан', integ => -20503);
    OPERATION_NOEXS         CONSTANT t_string_int := t_string_int(str => 'Операция {%1} не существует.', integ => -20504);
    BRANCH_CLOSED           CONSTANT t_string_int := t_string_int(str => 'Филиал {%1} закрыт.', integ => -20505);
    BRANCH_UNKNOWN          CONSTANT t_raise_message := t_raise_message(message => 'Филиал {%1} неизвестен.', code => -20506);
    NO_MSG_TYPE             CONSTANT t_raise_message := t_raise_message(message => 'Не указан тип сообщения',code => -20507);
    MSG_TYPE_WRONG          CONSTANT t_raise_message := t_raise_message(message => 'Не известный тип сообщения {%1}',code => -20508);
    PAYSYS_WRONG            CONSTANT t_raise_message := t_raise_message(message => 'Не известная платежная система {%1}',code => -20509);
    NO_RELATED_MSG          CONSTANT t_raise_message := t_raise_message(message => 'Не переданы зависимые платежи при пакетной обработке',code => -20510);
    NO_CORACC_PSYS          CONSTANT t_raise_message := t_raise_message(message => 'Не возможно получить кор счет для платежной системы {%1} с валютой {%2}',code => -20511);
    NO_ACC_STAT_CH          CONSTANT t_raise_message := t_raise_message(message => 'У пользователя {%1} нет прав доступа для перевода платежа с типом {%2} в статус {%3}',
                                                                        code => -20512);
    NO_FEE_BY_KIND          CONSTANT t_raise_message := t_raise_message(message => 'Не найдена комиссия по FEE KIND ID {%1}', code => -20513);
    FEE_SET_ACC_NO          CONSTANT t_raise_message := t_raise_message(message => 'Выбрано количество доп. страниц, но не указан счет комиссии',code => -20514);
    WR_PS_99                CONSTANT t_raise_message := t_raise_message(message => 'Для сообщений типа *99 запрещено устанавливать систему отличную от XOHKS и SWIFT',code => -20515);
    MT_103_NOT_AZN          CONSTANT t_raise_message := t_raise_message(message => 'Для сообщений типа "Bankxarici köçürmə (AZN)" запрещено устанавливать валюту отличную от AZN',code => -20516);
    MT_113_UNKNOW_CB        CONSTANT t_raise_message := t_raise_message(message => 'Кореспонденсткий банк с SWIFT {%1} не найден',code => -20517);
    MT_113_UNKNOW_CB_ACC    CONSTANT t_raise_message := t_raise_message(message => 'Счет для кореспонденсткого банка со SWIFT {%1}, в валюте {%2} и типа {%3} не найден',code => -20518);
    UNKNOW_BL               CONSTANT t_raise_message := t_raise_message(message => 'Банк со SWIFT-ом {%1} отсутсвует в базе',code => -20518);
    
    CORR_BANK_SWIFT_ISNULL  CONSTANT t_raise_message := t_raise_message(message => 'SWIFT корреспондентского банка имеет пустое значение',code => -20519);
    CORR_BANK_NAME_ISNULL   CONSTANT t_raise_message := t_raise_message(message => 'Название корреспондентского банка имеет пустое значение',code => -20520);
    CORR_BANK_ACCBOB_ISNULL CONSTANT t_raise_message := t_raise_message(message => 'Внутренний счет корреспондентского банка имеет пустое значение',code => -20521);
    CORR_BANK_IBAN_ISNULL   CONSTANT t_raise_message := t_raise_message(message => 'ИБАН счет корреспондентского банка имеет пустое значение',code => -20522);
    
    NO_BENB_NAME            CONSTANT t_raise_message := t_raise_message(message => 'Не установлен название банка получателя',code => -20523);
    MT113_NO_OPCODE         CONSTANT t_raise_message := t_raise_message(message => 'MT113 - Не установлен операционный код',code => -20524);
    MT113_UNKONW_OPCODE     CONSTANT t_raise_message := t_raise_message(message => 'MT113 - Неизвестное значение операционного кода',code => -20525);
    MT113_RUB_NN_MUSTNNULL  CONSTANT t_raise_message := t_raise_message(message => 'MT113 - Рублевый платеж - Одно из NN полей не заполнено.',code => -20526);
    FUNCTION format(p_str VARCHAR, 
                    p_val1 VARCHAR DEFAULT '', 
                    p_val2 VARCHAR DEFAULT '', 
                    p_val3 VARCHAR DEFAULT '', 
                    p_val4 VARCHAR DEFAULT '', 
                    p_val5 VARCHAR DEFAULT '', 
                    p_val6 VARCHAR DEFAULT '', 
                    p_val7 VARCHAR DEFAULT '', 
                    p_val8 VARCHAR DEFAULT '', 
                    p_val9 VARCHAR DEFAULT '', 
                    p_val10 VARCHAR DEFAULT '' 
                    ) RETURN VARCHAR;
    PROCEDURE raise_exception(p_raise_msg t_raise_message, 
                        p_val1 VARCHAR DEFAULT '', 
                        p_val2 VARCHAR DEFAULT '', 
                        p_val3 VARCHAR DEFAULT '', 
                        p_val4 VARCHAR DEFAULT '', 
                        p_val5 VARCHAR DEFAULT '', 
                        p_val6 VARCHAR DEFAULT '', 
                        p_val7 VARCHAR DEFAULT '', 
                        p_val8 VARCHAR DEFAULT '', 
                        p_val9 VARCHAR DEFAULT '', 
                        p_val10 VARCHAR DEFAULT '' 
                        );
end const_exceptions;


-- utl_lms.format_message(const_exceptions.GROUND_WRONG_SYM.str, 'world', 42)
-- const_exceptions.raise_exception(const_exceptions.PAYER_ACC_NO);
/
create or replace package body const_exceptions IS
    -- жопа, конечно, а не код. Но два часа ночи :(
    FUNCTION format(p_str VARCHAR, 
                    p_val1 VARCHAR DEFAULT '', 
                    p_val2 VARCHAR DEFAULT '', 
                    p_val3 VARCHAR DEFAULT '', 
                    p_val4 VARCHAR DEFAULT '', 
                    p_val5 VARCHAR DEFAULT '', 
                    p_val6 VARCHAR DEFAULT '', 
                    p_val7 VARCHAR DEFAULT '', 
                    p_val8 VARCHAR DEFAULT '', 
                    p_val9 VARCHAR DEFAULT '', 
                    p_val10 VARCHAR DEFAULT '' 
                    ) RETURN VARCHAR IS
    BEGIN
        RETURN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(p_str,
                                                                                               '%10',
                                                                                               p_val10),
                                                                                       '%9',
                                                                                       p_val9),
                                                                               '%8',
                                                                               p_val8),
                                                                       '%7',
                                                                       p_val7),
                                                               '%6',
                                                               p_val6),
                                                       '%5',
                                                       p_val5),
                                               '%4',
                                               p_val4),
                                       '%3',
                                       p_val3),
                               '%2',
                               p_val2),
                       '%1',
                       p_val1);
    END;
    
    PROCEDURE raise_exception(p_raise_msg t_raise_message, 
                        p_val1 VARCHAR DEFAULT '', 
                        p_val2 VARCHAR DEFAULT '', 
                        p_val3 VARCHAR DEFAULT '', 
                        p_val4 VARCHAR DEFAULT '', 
                        p_val5 VARCHAR DEFAULT '', 
                        p_val6 VARCHAR DEFAULT '', 
                        p_val7 VARCHAR DEFAULT '', 
                        p_val8 VARCHAR DEFAULT '', 
                        p_val9 VARCHAR DEFAULT '', 
                        p_val10 VARCHAR DEFAULT '' 
                        ) IS
    BEGIN
        raise_application_error(p_raise_msg.code, format(p_raise_msg.message, p_val1,p_val2,p_val3,p_val4,p_val5,p_val6,p_val7,p_val8,p_val9,p_val10));
    END;
    
end const_exceptions;
/
