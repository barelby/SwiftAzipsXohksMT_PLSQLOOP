create or replace package const_interbankpayments is

    IB_USER_ID                         CONSTANT INTEGER := 3562;                -- ИД ИБ пользователя в таблице swa_user 
    IB_USER_BRANCH_ID                  CONSTANT INTEGER := 23;                  -- ИД филиала ИБ
    IB_USER_TIMEOUT_DATE_COUNT         CONSTANT INTEGER := 3;                   -- Количество дней после которых ИБ платеж считается просроченным

    CFG_DEFAULT_SYSTEM_ID               CONSTANT INTEGER := 303;
    CFG_ACCEPT_NON_BOB_EM_BIKS			CONSTANT BOOLEAN := FALSE;				-- Позволить устанавливать БИК эмитента не принадлежащий БоБ
    CFG_DEF_GROUND_MAXLINES             CONSTANT INTEGER := 6;
    CFG_DEF_ADDI_MAXLINES               CONSTANT INTEGER := 6;
    
    CFG_MT113_ACCTYPE_NOSTRO            CONSTANT VARCHAR(100) := 'nostro';
    CFG_MT113_ACCTYPE_LORO              CONSTANT VARCHAR(100) := 'loro';
    CFG_MT113_OPERCODE_BEN              CONSTANT VARCHAR(100) := 'BEN';
    CFG_MT113_OPERCODE_OUR              CONSTANT VARCHAR(100) := 'OUR';
    CFG_MT113_OPERCODE_SHA              CONSTANT VARCHAR(100) := 'SHA';
    CFG_MT113_DEF_GROUND_MAXLINES       CONSTANT INTEGER := 4;
    
    CFG_MT205_GROUND_PREFIX_CODE        CONSTANT VARCHAR(100) := '/BNF/';
    CFG_MT205_REFLEC_ACCISSPEC          CONSTANT VARCHAR(100) := 'XXXXXXXX';
    CFG_MT205_REFLEC_ACCISSPEC_GRN      CONSTANT VARCHAR(100) := '/BCSL/XXXXXXXX' || chr(13) || chr(10) ||
                                                                 '//XOHKS HESABIN MOHKEMLENDIRILMESI';
    CFG_MT103_DEF_GROUND_MAXLINES       CONSTANT INTEGER := 4;
    CFG_MT103_DEF_ADDI_MAXLINES         CONSTANT INTEGER := 4;
    
    CFG_NPS_STATUS_UPDATER_INP_DIR      CONSTANT VARCHAR(100) := 'INPAYMENTS_PROCESSED_DIR';    -- Папка с входящими платежами
    CFG_NPS_STATUS_UPDATER_REG          CONSTANT VARCHAR(100) := '\{1:([^{}]+)\}\{2:(\w([0-9]{3})[^{}]+)}(\{3:\{[^{}]+}})(\{4:[^{}]+\}){0,1}(\{5:\{[^{}]+\}\}){0,1}';
    CFG_NPS_STATUS_UPDATER_RM_TYPE      CONSTANT INTEGER := 298;                        -- Тип входящего сообщения с ответом на посланный платеж
    CFG_NPS_STATUS_UPDATER_B4_REG       CONSTANT VARCHAR(100) := '{4:\s*([^{}]+)\s*-}'; -- Регулярка для выдергивания 4 блока
    ---------------- Платежные системы
    PAYMENT_SYSTEM_ID_SWIFT				CONSTANT INTEGER := 301;
    PAYMENT_SYSTEM_ID_AZIPS				CONSTANT INTEGER := 302;
    PAYMENT_SYSTEM_ID_XOHKS				CONSTANT INTEGER := 303;
    PAYMENT_SYSTEM_ID_NPS				CONSTANT INTEGER := 304;
    ---------------- Типы сообщений
    PAYMENT_MSG_TYPE_99                 CONSTANT INTEGER := 99;
    PAYMENT_MSG_TYPE_103                CONSTANT INTEGER := 103;
    PAYMENT_MSG_TYPE_103_USD            CONSTANT INTEGER := 113;
    PAYMENT_MSG_TYPE_123                CONSTANT INTEGER := 123;
    PAYMENT_MSG_TYPE_200                CONSTANT INTEGER := 200;
    PAYMENT_MSG_TYPE_205                CONSTANT INTEGER := 205;
    
    ---------------- Роли
    ACCESS_FULL                          CONSTANT INTEGER := 1;         -- Полный доступ. Учавствует при отображении платежей
    ACCESS_CREATE                        CONSTANT INTEGER := 2;         -- Доступ на создание
    ACCESS_VIEW                          CONSTANT INTEGER := 3;         -- Доступ на просмотр. Учавствует при отображении платежей
    ACCESS_DELETE                        CONSTANT INTEGER := 4;         -- Доступ на удаление
    ACCESS_EDIT                          CONSTANT INTEGER := 5;         -- Доступ на изменение
    ACCESS_STATE_TO_10                   CONSTANT INTEGER := 6;         -- Доступ на перевод "Верификация". Учавствует при отображении платежей
    ACCESS_STATE_TO_11                   CONSTANT INTEGER := 7;         -- 
    ACCESS_STATE_TO_12                   CONSTANT INTEGER := 8;         -- 
    ACCESS_STATE_TO_20                   CONSTANT INTEGER := 9;         -- Учавствует при отображении платежей
    ACCESS_STATE_TO_30                   CONSTANT INTEGER := 10;        --
    ACCESS_STATE_TO_60                   CONSTANT INTEGER := 13;        -- Учавствует при отображении платежей

    USER_ROLE_CREATOR                    CONSTANT INTEGER := 15100;
    USER_ROLE_VIEWER                     CONSTANT INTEGER := 15101;
    USER_ROLE_VERIFICATOR                CONSTANT INTEGER := 15102;
    USER_ROLE_AUTHORIZATOR               CONSTANT INTEGER := 15103;
    
    CFG_DEFAULT_CURRENCY                 CONSTANT INTEGER := 0;
    ---------------- Статусы
    -- Front
    STATE_NEW                           CONSTANT INTEGER := 1;     				-- только созданный
    STATE_DRAFT                         CONSTANT INTEGER := 3;     				-- сохраненный как черновик
    STATE_DELETED                       CONSTANT INTEGER := 4;     				-- удаленный
    STATE_REJECTED                      CONSTANT INTEGER := 5;     				-- удаленный
    -- Back
    STATE_VERIFICATION                  CONSTANT INTEGER := 10;     			-- На верификации. Только из  STATE_NEW и STATE_CHANGING
    STATE_CHANGING                      CONSTANT INTEGER := 11;     			-- отосланный на изменения
    STATE_CHANGINGFROMAUTH              CONSTANT INTEGER := 12;     			-- отосланный на изменения из STATE_AUTHORIZATION
    STATE_AUTHORIZATION                 CONSTANT INTEGER := 20;     			-- На авторизации. Только из  STATE_VERIFICATION
    STATE_CANCELED                      CONSTANT INTEGER := 30;     			-- Отмененный. Только из  STATE_VERIFICATION
    STATE_PROVIDER_SENT                 CONSTANT INTEGER := 40;     			-- Платежное поручение отослано провайдеру.        
    STATE_PROVIDER_ERROR                CONSTANT INTEGER := 41;     			-- Платеж отправлен провайдеру - Ответ отрицательный от платежного провайдера
    STATE_PROVIDER_NOTFOUND             CONSTANT INTEGER := 42;     			-- Платеж не попал к провайдеру
    STATE_PROVIDER_IN_QUEEE             CONSTANT INTEGER := 43;     			-- Платеж в очереди на отправку
    STATE_PROVIDER_B_ERROR              CONSTANT INTEGER := 44;     			-- Провайдер вернул ошибку - Ошибка в структуре. Не отправлено
    STATE_COMPLETED                     CONSTANT INTEGER := 60;     			-- Завершенный. Только из STATE_FILECREATED
    STATE_IB_WAITING                    CONSTANT INTEGER := 90;     			-- Платеж подтвержден пользователем, но из-за временного лимита в ожидании подтверждения
    STATE_IB_TIMEOUT                    CONSTANT INTEGER := 91;     			-- Время для подтверждения ИБ платежа прошло
    
    -- Атрибуты
    ATTR_FAST_RECIEVER_CODE             CONSTANT INTEGER := 1;
    ATTR_URGENCY_KIND                   CONSTANT INTEGER := 2;
    ATTR_BUDGET_DESTINATION             CONSTANT INTEGER := 3;
    ATTR_BUDGET_LEVEL                   CONSTANT INTEGER := 4;
    ATTR_ADDITIONAL_INFO                CONSTANT INTEGER := 5;
    ATTR_BRING_BACK_COMMENT             CONSTANT INTEGER := 6;  
    ATTR_BOOKKEEPING_ACCOUNT            CONSTANT INTEGER := 7;
    ATTR_LINKED_REFERENCE               CONSTANT INTEGER := 8;
    ATTR_REFLECTING_ACCOUNT             CONSTANT INTEGER := 9;
    ATTR_IS_MANUAL_OPERATION			CONSTANT INTEGER := 10;					/*Установлена ли операция ручным способом.Все проводки будут в рамках
    																			установленной операции, а не создаваться по новой.*/
    ATTR_REFLECTING_ACCOUNT_IBAN        CONSTANT INTEGER := 11;

    --- Атрибуты IS_*
    ATTR_IS_ORDER_PAYMENT               CONSTANT INTEGER := 100;                -- Sərəncam - Vergi
    ATTR_IS_MANUAL_FEE                  CONSTANT INTEGER := 101;
    ATTR_IS_WITHOUT_FEE                 CONSTANT INTEGER := 102;
	ATTR_IS_URGENCY                  	CONSTANT INTEGER := 104;
    ATTR_IS_ORDER_INKASSO_PAYMENT       CONSTANT INTEGER := 105;                -- Sərəncam - İnkasso
    ATTR_IS_WITHOUT_REM_TRANSFER        CONSTANT INTEGER := 107;                -- Без файла
    ATTR_IS_WITHOUT_FREEZE_AMOUNT       CONSTANT INTEGER := 108;                -- Без заморозки суммы
    ATTR_IS_WITHOUT_OPERATIONS          CONSTANT INTEGER := 109;                -- Без заморозки суммы
    ATTR_IS_SUPPORT_BATCHING            CONSTANT INTEGER := 110;                -- Данным атрибутом отмечаются типы сообщений, который поддерживают пакетную обратботку при отправке провайдеру 
    ATTR_IS_BATCH_PARENT_MSG            CONSTANT INTEGER := 111;                -- Нужен для отметки родительского платежа
    ATTR_IS_BATCH_RELATED_MSG           CONSTANT INTEGER := 112;                -- Нужен для отметки зависимых платежей, которые учавствуют в пакетной обработке. В value_id заносится id родительского платежа
     
    -- Атрибуты проверки
    ATTR_UNCHECK_PAYER_ACC              CONSTANT INTEGER := 120;                -- Не проверять валидность счет получателя
    ATTR_UNCHECK_GROUND                 CONSTANT INTEGER := 121;                -- Не проверять валидность основания
    ATTR_UNCHECK_IBAN                   CONSTANT INTEGER := 123;                -- Не проверять валидность ИБАН получателя 
    ATTR_UNCHECK_PAY_DATE               CONSTANT INTEGER := 124;                -- Не проверять валидность даты платежа
    ATTR_UNCHECK_PAY_STATE              CONSTANT INTEGER := 125;                -- Не проверять валидность статуса
    ATTR_UNCHECK_REC_NAME               CONSTANT INTEGER := 126;                -- Не проверять валидность имя получателя
    ATTR_UNCHECK_REC_TAX                CONSTANT INTEGER := 127;                -- Не проверять валидность ИНН получателя
    ATTR_UNCHECK_GROUND_EMPTY           CONSTANT INTEGER := 128;                -- Не проверять пустое значение основания
    ATTR_UNCHECK_ENOUGH_ACC_AMOUNT      CONSTANT INTEGER := 129;                -- Не проверять недостаточность средств на счете плательщика 
    ATTR_UNCHECK_PAYER_BRANCH           CONSTANT INTEGER := 130;                -- Не проверять пустое значение филиала плательщика
    ATTR_UNCHECK_CURRENCY               CONSTANT INTEGER := 131;                -- Не проверять пустое значение валюты
    ATTR_UNCHECK_PANULL_SETAMOUNT       CONSTANT INTEGER := 132;                -- Не проверять пустое значение счета плательща при установки суммы платежа
    ATTR_UNCHECK_PAYSYS_NULL            CONSTANT INTEGER := 133;                -- Не проверять пустое значение платежной системы
    ATTR_UNCHECK_PAYDATE_NULL           CONSTANT INTEGER := 134;                -- Не проверять пустое значение даты платежа
    ATTR_UNCHECK_REC_IBAN_NULL          CONSTANT INTEGER := 136;                -- Не проверять пустое значение ИБАН получателя
    ATTR_UNCHECK_REC_TAX_NULL           CONSTANT INTEGER := 137;                -- Не проверять пустое значение ИНН получателя
    ATTR_UNCHECK_CURRENCY_NULL          CONSTANT INTEGER := 138;                -- Не проверять пустое значение валюты
    ATTR_UNCHECK_CURRENCY_AVBLE         CONSTANT INTEGER := 139;                -- Не проверять валидность значения валюты
    ATTR_UNCHECK_BFC_BANKCODE_NULL      CONSTANT INTEGER := 140;                -- Не проверять пустое значение банка получателя
    ATTR_UNCHECK_PAY_ACCOUNT_NULL       CONSTANT INTEGER := 141;                -- Не проверять пустое значение счета отправителя
    ATTR_UNCHECK_MSGTYPE_NULL           CONSTANT INTEGER := 142;                -- Не проверять пустое значение типа сообщения
    ATTR_UNCHECK_MSGTYPE                CONSTANT INTEGER := 143;                -- Не проверять тип сообщения на валидность
    ATTR_UNCHECK_PAY_SYS_NULL           CONSTANT INTEGER := 144;                -- Не проверять пустое значение платежной системы
    ATTR_UNCHECK_PAY_SYS                CONSTANT INTEGER := 145;                -- Не проверять платежную систему на валидность
    
    -- Атрибуты интернет-банкинга
    ATTR_IS_IB                          CONSTANT INTEGER := 200;				-- Признак того, что платеж пришел из Интернет Банкинга
    ATTR_FREEZE_OP_ID                   CONSTANT INTEGER := 201;                -- Ид операции удержания суммы на счете
    -- Разное
    ATTR_SETTELMENT_PAYER_ID			CONSTANT INTEGER := 300;				-- Ид плательщика при api_settlement.settlement_transaction
    ATTR_SETTELMENT_RECEIVER_ID			CONSTANT INTEGER := 301;				-- Ид получателя при api_settlement.settlement_transaction
    ATTR_SETTELMENT_OPER_CHAIN			CONSTANT INTEGER := 302;                -- Идентификатор цепочки операций
    -- Атрибуты для Кости
    ATTR_IS_RS_ORDER                    CONSTANT INTEGER := 303;
    ATTR_IS_RS_ACC_DEB                  CONSTANT INTEGER := 304;
    ATTR_IS_RS_ACC_CRD                  CONSTANT INTEGER := 305;
    ATTR_IS_RS_GROUND                   CONSTANT INTEGER := 306;
    ATTR_IS_RS_ARREST_SUM               CONSTANT INTEGER := 307;
    
    ATTR_CORRESPONDENT_ACCOUNT          CONSTANT INTEGER := 330;
    ATTR_RECIEVER_IBAN_FOR_123          CONSTANT INTEGER := 331;                -- IBAN для получателя, только для внутрибанковских платежей
    ATTR_FREE_FORMAT_MT_TYPE            CONSTANT INTEGER := 332;                -- Не проверять платежную систему на валидность
    ATTR_FREE_FORMAT_PAGE_COUNT         CONSTANT INTEGER := 333;
    ATTR_FREE_FORMAT_FEE_ACCOUNT        CONSTANT INTEGER := 334;
    ATTR_BATCH_PAYMENT_NUM			    CONSTANT INTEGER := 335;
    ATTR_CBAR_RESPONSE_STATUS	        CONSTANT INTEGER := 336;                -- Статус от ЦБ
    ATTR_CBAR_RESP_ERROR_MSG	        CONSTANT INTEGER := 337;                -- Текст сообщения об ошибке от ЦБ
    ATTR_USE_FILE_PROV_QUEE             CONSTANT INTEGER := 338;                -- При передаче файлов использовать очередь сообщений
    ATTR_FREE_FORMAT_DATE               CONSTANT INTEGER := 339;                
    ATTR_FREE_FORMAT_AMOUNT             CONSTANT INTEGER := 340;
    
    -- 113
    ATTR_113_OPERATION_CODE             CONSTANT INTEGER := 342;        
    ATTR_113_INIT_AMOUNT                CONSTANT INTEGER := 343;
    ATTR_113_INIT_CURRENCY              CONSTANT INTEGER := 344;
    ATTR_113_EXCHANGE_RATE              CONSTANT INTEGER := 345;
    ATTR_113_PAYER_ADDINFO              CONSTANT INTEGER := 346;
    ATTR_113_RECIVER_ADDINFO            CONSTANT INTEGER := 347;
    ATTR_113_FEE_ACCOUNT                CONSTANT INTEGER := 348;
    ATTR_113_CORR_BANK_ID               CONSTANT INTEGER := 349;
    ATTR_113_CORR_BANK_ACC              CONSTANT INTEGER := 350;
    ATTR_113_CORR_BANK_SWIFT            CONSTANT INTEGER := 351;
    ATTR_113_INTBANK_SWIFT              CONSTANT INTEGER := 352;
    ATTR_113_INTBANK_NAME               CONSTANT INTEGER := 353;
    ATTR_113_INTBANK_ACC                CONSTANT INTEGER := 354;
    ATTR_113_INTBANK_ADDINFO            CONSTANT INTEGER := 355;
    ATTR_113_BENEFBANK_ADDINFO          CONSTANT INTEGER := 356;
    ATTR_113_INTBANK_IN_AG              CONSTANT INTEGER := 357;            -- Признак того, что информация заполнена из таблицы bank_list на основе введенного swift. Сделано для того чтобы определить. можно ли при обнулении SWIFT обнулять остальные поля (не введены ли остальные поля ручным способов)
    ATTR_113_PAYER_CHARGES              CONSTANT INTEGER := 358;
    ATTR_113_CORR_BANK_NAME             CONSTANT INTEGER := 359;
    ATTR_113_CORR_BANK_ACC_ID           CONSTANT INTEGER := 360;
    ATTR_113_CORR_BANK_ACC_BOB          CONSTANT INTEGER := 361;
    ATTR_113_PAYER_BANK_SWIFT           CONSTANT INTEGER := 362;
    ATTR_113_PAYER_BANK_NAME            CONSTANT INTEGER := 363;
    ATTR_113_CORR_BANK_ACC_TYPE         CONSTANT INTEGER := 364;
    ATTR_113_BENEFBANK_IN_AG            CONSTANT INTEGER := 365;
    ATTR_113_RUB_NN4                    CONSTANT INTEGER := 366;
    ATTR_113_RUB_NN8                    CONSTANT INTEGER := 367;
    ATTR_113_RUB_NN5                    CONSTANT INTEGER := 368;
    ATTR_113_RUB_OPERATIONTYPE	        CONSTANT INTEGER := 369;
    
    -- Список атрибутов, которые должны быть удалены, если значение являются NULL
    ATTR_DELETE_IS_NULL                 CONSTANT ibs.t_integer_collection DEFAULT ibs.t_integer_collection(ATTR_FAST_RECIEVER_CODE,ATTR_URGENCY_KIND,ATTR_BUDGET_DESTINATION,ATTR_BUDGET_LEVEL,ATTR_ADDITIONAL_INFO,
                                                                                                            ATTR_BRING_BACK_COMMENT,ATTR_BOOKKEEPING_ACCOUNT,ATTR_LINKED_REFERENCE,ATTR_REFLECTING_ACCOUNT
                                                                                                            ,ATTR_SETTELMENT_PAYER_ID,ATTR_SETTELMENT_RECEIVER_ID,ATTR_SETTELMENT_OPER_CHAIN,ATTR_CORRESPONDENT_ACCOUNT,ATTR_RECIEVER_IBAN_FOR_123
                                                                                                            ,ATTR_FREE_FORMAT_MT_TYPE,ATTR_FREE_FORMAT_PAGE_COUNT,ATTR_FREE_FORMAT_FEE_ACCOUNT,ATTR_BATCH_PAYMENT_NUM,ATTR_CBAR_RESPONSE_STATUS,ATTR_CBAR_RESP_ERROR_MSG
                                                                                                            ,ATTR_USE_FILE_PROV_QUEE,ATTR_FREE_FORMAT_DATE ,ATTR_FREE_FORMAT_AMOUNT ,ATTR_113_OPERATION_CODE ,ATTR_113_INIT_AMOUNT,ATTR_113_INIT_CURRENCY,ATTR_113_EXCHANGE_RATE,ATTR_113_PAYER_ADDINFO
                                                                                                            ,ATTR_113_RECIVER_ADDINFO,ATTR_113_FEE_ACCOUNT,ATTR_113_CORR_BANK_ID ,ATTR_113_CORR_BANK_ACC,ATTR_113_CORR_BANK_SWIFT,ATTR_113_INTBANK_SWIFT,ATTR_113_INTBANK_NAME ,ATTR_113_INTBANK_ACC
                                                                                                            ,ATTR_113_INTBANK_ADDINFO,ATTR_113_BENEFBANK_ADDINFO,ATTR_113_INTBANK_IN_AG,ATTR_113_PAYER_CHARGES,ATTR_113_CORR_BANK_NAME ,ATTR_113_CORR_BANK_ACC_ID ,ATTR_113_CORR_BANK_ACC_BOB,ATTR_113_PAYER_BANK_SWIFT 
                                                                                                            ,ATTR_113_PAYER_BANK_NAME,ATTR_113_CORR_BANK_ACC_TYPE ,ATTR_113_BENEFBANK_IN_AG,ATTR_113_RUB_NN4,ATTR_113_RUB_NN8,ATTR_113_RUB_NN5,ATTR_113_RUB_OPERATIONTYPE
                                                                                                            );
    
    ---------------- Комиссии
    ---Учесть старый пакет const_payment. Гаранитровать что идентификаторы комиссий не пересекаются
    -- Фронт тарифы
    FEE_KIND_MANUAL                     CONSTANT INTEGER        := 15100;   -- Комиссия ручной ввод
    FEE_KIND_INCNTR_JUR                 CONSTANT INTEGER        := 15101;   -- Комиссия внутри страны (юр. лица)
    FEE_KIND_INCNTR_PHS                 CONSTANT INTEGER        := 15102;   -- Комиссия внутри страны (физ. лица)
    FEE_KIND_INCNTR_BUS                 CONSTANT INTEGER        := 15103;   -- Комиссия внутри страны (биз. лица)
    FEE_KIND_INBNK_PHS_REG_A            CONSTANT INTEGER        := 15104;   -- Комиссия внутри банковский Регион A      (физ. лица)
    FEE_KIND_INBNK_PHS_REG_D            CONSTANT INTEGER        := 15105;   -- Комиссия внутри банковский Регион D      (физ. лица)
    FEE_KIND_INBNK_PHS_REG_OT           CONSTANT INTEGER        := 15106;   -- Комиссия внутри банковский Регион Другие (физ. лица)
    FEE_KIND_INBNK_PHS_SAME_BR          CONSTANT INTEGER        := 15107;   -- Комиссия внутри банковский Один и тот же филиал (физ. лица )
    FEE_KIND_INBNK_JUR_REG_A            CONSTANT INTEGER        := 15108;   -- Комиссия внутри банковский Регион A (юр. лица)
    FEE_KIND_INBNK_JUR_REG_D            CONSTANT INTEGER        := 15109;   -- Комиссия внутри банковский Регион D (юр. лица)
    FEE_KIND_INBNK_JUR_REG_OT           CONSTANT INTEGER        := 15110;   -- Комиссия внутри банковский Регион Другие (юр. лица)
    FEE_KIND_INBNK_JUR_SAME_BR          CONSTANT INTEGER        := 15111;   -- Комиссия внутри банковский Один и тот же филиал) (юр. лица)
    FEE_KIND_OUTCNTR_JUR                CONSTANT INTEGER        := 15112;   -- Комиссия за пределы страны (юр. лица)
    FEE_KIND_OUTCNTR_PHS                CONSTANT INTEGER        := 15113;   -- Комиссия за пределы страны (физ. лица)
    FEE_KIND_OUTCNTR_BUS                CONSTANT INTEGER        := 15114;   -- Комиссия за пределы страны (биз. лица)
    FEE_KIND_URGENT                     CONSTANT INTEGER        := 15115;   -- Комиссия за срочность

    FEE_TYPES_INBANK                     CONSTANT INTEGER        := 15900;   -- Комиссия внутри банковский платеж
    FEE_TYPES_INCNTR                     CONSTANT INTEGER        := 15901;   -- Комиссия внутри страны
    FEE_TYPES_OUTCNTR                    CONSTANT INTEGER        := 15902;   -- Комиссия за пределы страны
    
    -- интернет-банкинг тарифы
    FEE_KIND_INCNTR_PHS_IB              CONSTANT INTEGER        := 15200;   -- Комиссия интернет банкинг
    FEE_KIND_INCNTR_JUR_IB              CONSTANT INTEGER        := 15201;   -- Комиссия интернет банкинг
    FEE_KIND_INBNK_PHS_REG_A_IB         CONSTANT INTEGER        := 15202;   -- Комиссия внутри банковский Регион A интернет-банкинг (физ. лица)
    FEE_KIND_INBNK_PHS_REG_D_IB         CONSTANT INTEGER        := 15203;   -- Комиссия внутри банковский Регион D интернет-банкинг (физ. лица)
    FEE_KIND_INBNK_PHS_REG_OT_IB        CONSTANT INTEGER        := 15204;   -- Комиссия внутри банковский Регион Другие интернет-банкинг (физ. лица)
    FEE_KIND_INBNK_PHS_SAME_BR_IB       CONSTANT INTEGER        := 15205;   -- Комиссия внутри банковский Один и тот же филиал интернет-банкинг (физ. лица 
    FEE_KIND_INBNK_JUR_REG_A_IB         CONSTANT INTEGER        := 15206;   -- Комиссия внутри банковский Регион A интернет-банкинг (юр. лица)
    FEE_KIND_INBNK_JUR_REG_D_IB         CONSTANT INTEGER        := 15207;   -- Комиссия внутри банковский Регион D интернет-банкинг (юр. лица)
    FEE_KIND_INBNK_JUR_REG_OT_IB        CONSTANT INTEGER        := 15208;   -- Комиссия внутри банковский Регион Другие интернет-банкинг (юр. лица)
    FEE_KIND_INBNK_JUR_SAME_BR_IB       CONSTANT INTEGER        := 15209;   -- Комиссия внутри банковский Один и тот же филиал) интернет-банкинг (юр. лица)
    FEE_KIND_OUTCNTR_PHS_IB             CONSTANT INTEGER        := 15210;   -- Комиссия за пределы страны интернет банкинг
    FEE_KIND_OUTCNTR_JUR_IB             CONSTANT INTEGER        := 15211;   -- Комиссия интернет банкинг
    FEE_KIND_URGENT_IB                  CONSTANT INTEGER        := 15212;   -- Комиссия за срочность интернет банкинг
    
    -- Для спец комиссий
    FEE_SPECIAL_FEE_START               CONSTANT INTEGER        := 15600;   -- Ид с которого начнется создание комиссий
    
    FEE_DEFGROUND                       CONSTANT VARCHAR2(100)  := ':SUM: köçürməyə görə komissiya';
    FEE_URG_DEFGROUND                   CONSTANT VARCHAR2(100)  := ':SUM: təcili köçürməyə görə komissiya';
    
    ---------------- Счета 
    ACC_CAT_IN_FEE_IPAYMENTS            CONSTANT INTEGER        := 15101;
    ACC_CAT_IN_FEE_IPAYMENTS_TPL        CONSTANT VARCHAR2(100)  := '|BLNC|CUR|TT|LGFORM|BRANCH';
    
    ---------------- Операции
    OT_OUTBANK_PAYMENT                   CONSTANT INTEGER  := 15100;				-- Тип операции (межбанковсикй платеж)
    OCT_OUTBANK_PAYMENT					 CONSTANT INTEGER  := 15101;				-- Тип цепочки операций (межбанковсикй платеж)
    ---------------- Перечисления

    ENUMTYPE_PAYMENT_STATE              CONSTANT INTEGER  := 15100;				-- Перечисления для статусов платежей.
    ENUMTYPE_PAYMENT_MSGTYPE            CONSTANT INTEGER  := 15101;             -- Перечисления для типов сообщений.
    ENUMTYPE_PAYMENT_ACCESS             CONSTANT INTEGER  := 15102;             -- Перечисления для прав доступа.
    ENUMTYPE_PAYMENT_SYSTEM 			CONSTANT INTEGER  := 15103;             -- Перечисления платежные системы
    ENUMTYPE_PAYMENT_FEETYPE            CONSTANT INTEGER  := 15104;
    ENUMTYPE_PAYMENT_MT113ADICODES      CONSTANT INTEGER  := 15105;
    ENUMTYPE_BUDGET_DESTINATION               constant integer := 15001;
    ENUMTYPE_BUDGET_LEVEL                     constant integer := 15002;
    --
    PAYMENT_OBJECT_ID					CONSTANT INTEGER  := 1;					-- ИД Объекта const_object.OT_PAYMENT 
    --
    -- Depreacted
    NOTIFICATION_TYPE_HIGH              CONSTANT VARCHAR(10) := 'ERROR';
    NOTIFICATION_TYPE_OK                CONSTANT VARCHAR(10) := 'OK';
    NOTIFICATION_TYPE_LOW               CONSTANT VARCHAR(10) := 'WARNING';
    
    PROCEDURE load_state_to_enum;
    PROCEDURE load_special_tariff;
    PROCEDURE load_tariff;   
    PROCEDURE load_dir;   
    PROCEDURE load_mt113_addi_codes_to_enum;
    PROCEDURE load_operation__dependencies;
    PROCEDURE load_budgets_data;
    PROCEDURE automizer;
    PROCEDURE ib_payments;
    PROCEDURE onIbsConvertation;
    PROCEDURE load_msgtypes_to_enum;
end const_interbankpayments;
/
create or replace package body const_interbankpayments IS
    
    PROCEDURE cleaner IS
        TYPE l_type IS RECORD(
            l_fees      ibs.t_fee_amount_collection,
            l_payment_id    INTEGER
        );
        l_payment_fees l_type;
    BEGIN
        -- Удаляем "новые" и "удаленные" платежи от сотрудников банка
        -- Удаляем "новые" платежи с сроком 30 дней и все "Удаленные" от ИБ
        DELETE FROM interbankpayments i WHERE (i.state = const_interbankpayments.STATE_NEW AND i.creator_id <> const_interbankpayments.IB_USER_ID)
                                         OR
                                         (i.state = const_interbankpayments.STATE_NEW AND i.creator_id = const_interbankpayments.IB_USER_ID AND i.creation_date = TRUNC(SYSDATE)-30)
                                         OR i.state = const_interbankpayments.STATE_DELETED;
        -- Производим очистку ид операции, т.к. каждый день происходит конвертация и очистка таблицы операций
        /*
        UPDATE interbankpayments i 
        SET i.operation_id = NULL
        WHERE i.operation_id IS NOT NULL; --AND i.creation_date = TRUNC(SYSDATE)-1;
        */
    END;

    PROCEDURE ib_payments IS
        l_msg_obj               t_intbankpays_msg;
        l_payment_id            INTEGER;
        l_temp_boolean          BOOLEAN;
    BEGIN
        ibs.api_context.set_context(const_interbankpayments.IB_USER_ID, 
                                    ibs.cnv_credit.get_convert_date_next, 
                                    const_interbankpayments.IB_USER_BRANCH_ID);
        FOR REC in (SELECT i.id 
                             FROM interbankpayments i 
                             WHERE i.state = const_interbankpayments.STATE_IB_WAITING) 
        LOOP
            l_payment_id := REC.id;
            l_msg_obj := NULL;
            BEGIN
                l_msg_obj := api_interbankpayments.getMessageTypeObject(pid => l_payment_id);
                IF l_msg_obj.obj.payment_date < ibs.api_calendar.add_work_day(ibs.api_context.get_def_date, 
                                                                              const_interbankpayments.IB_USER_TIMEOUT_DATE_COUNT, 
                                                                              ibs.const_general.YES)
                THEN
                    l_temp_boolean := l_msg_obj.set_state(const_interbankpayments.STATE_IB_TIMEOUT);
                    api_interbankpayments.add_payment_change(l_msg_obj.obj, 
                           p_action => 'const_interbankpayments.ib_payments',
                           p_additional => 'Срок давности для платежа истек - платеж перемещен в статус "Просрочен"'); 
                    dbms_output.put_line('Срок давности для платежа истек - платеж перемещен в статус "Просрочен"');
                ELSIF ibs.api_account.read_account(l_msg_obj.obj.PAYER_ACCOUNT).rest < l_msg_obj.obj.AMOUNT THEN 
                    api_interbankpayments.add_payment_change(l_msg_obj.obj, 
                           p_action => 'const_interbankpayments.ib_payments', 
                           p_additional => 'На счету не достаточно средств для проведения операции на сумму {'||
                                                l_msg_obj.obj.AMOUNT || '} с комиссией { ' || l_msg_obj.obj.FEE_SUM_AMOUNT ||' }');
                    dbms_output.put_line('На счету не достаточно средств для проведения операции на сумму');
                ELSE  
                    l_msg_obj.obj.set_payment_date(JUI_INTERBANKPAYMENTS_TOOLS.get_bank_date());
                    l_msg_obj.STATE_TO_VERIFICATION;
                END IF;
                l_msg_obj.obj.update_payment;
            EXCEPTION WHEN OTHERS THEN
                IF l_msg_obj IS NOT NULL THEN
                    api_interbankpayments.add_payment_change(mobj => l_msg_obj.obj, 
                                                           p_action => 'const_interbankpayments.ib_payments', 
                                                           p_autonomus => TRUE,
                                                           p_result => SQLERRM || '',
                                                           p_additional => dbms_utility.format_error_backtrace);
                END IF;
                dbms_output.put_line(SQLERRM);
            END;
        END LOOP;
    END;
    
    PROCEDURE automizer IS
    BEGIN
        cleaner();
        COMMIT;
        ib_payments();
        COMMIT;
    END;


    PROCEDURE load_payment_systems_to_enum IS
    BEGIN
        ibs.api_enumeration.cor_enumeration_type(const_interbankpayments.ENUMTYPE_PAYMENT_SYSTEM, 'Типы платежных систем');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_SYSTEM, PAYMENT_SYSTEM_ID_SWIFT, 'SWIFT');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_SYSTEM, PAYMENT_SYSTEM_ID_XOHKS, 'XOHKS');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_SYSTEM, PAYMENT_SYSTEM_ID_NPS,   'NPS');
    END;
    
    -- Создаем enumeration для типов прав доступа
    PROCEDURE load_accesses_to_enum
    IS BEGIN
        ibs.api_enumeration.cor_enumeration_type(const_interbankpayments.ENUMTYPE_PAYMENT_ACCESS, 'Типы прав доступа');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_ACCESS, ACCESS_FULL,         'Полный доступ');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_ACCESS, ACCESS_CREATE,       'Создание платежа');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_ACCESS, ACCESS_VIEW,         'Просмотр платежа');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_ACCESS, ACCESS_DELETE,       'Удаление платежа');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_ACCESS, ACCESS_STATE_TO_10,  'Перевод на стадию Верификация');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_ACCESS, ACCESS_STATE_TO_11,  'Перевод на изменения из стадии Верификация');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_ACCESS, ACCESS_STATE_TO_12,  'Перевод на изменения из стадии Авторизация');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_ACCESS, ACCESS_STATE_TO_20,  'Перевод на стадию Авторизация');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_ACCESS, ACCESS_STATE_TO_30,  'Перевод на стадию Отмененный из Верификация');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_ACCESS, ACCESS_STATE_TO_60,  'Перевод на стадию Верификация');
    END;
    
    PROCEDURE load_mt113_addi_codes_to_enum
    IS BEGIN
        ibs.api_enumeration.cor_enumeration_type(const_interbankpayments.ENUMTYPE_PAYMENT_MT113ADICODES, 'Коды для MT113');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_MT113ADICODES, 1, 'ACC');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_MT113ADICODES, 2,'INS');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_MT113ADICODES, 3,'INT');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_MT113ADICODES, 4,'REC');      
    END;
    
    -- Создаем enumeration дл типов сообщений
    PROCEDURE load_msgtypes_to_enum
    IS BEGIN
        ibs.api_enumeration.cor_enumeration_type(const_interbankpayments.ENUMTYPE_PAYMENT_MSGTYPE, 'Типы платежей');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_MSGTYPE, PAYMENT_MSG_TYPE_205,       'Banklararası köçürmə (AZN)');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_MSGTYPE, PAYMENT_MSG_TYPE_103,       'Bankxarici köçürmə');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_MSGTYPE, PAYMENT_MSG_TYPE_103_USD,   'Bankxarici köçürmə');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_MSGTYPE, PAYMENT_MSG_TYPE_200,       'Banklararası köçürmə');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_MSGTYPE, PAYMENT_MSG_TYPE_123,       'Bankdaxili köçürmə');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_MSGTYPE, PAYMENT_MSG_TYPE_99,        'Sərbəst formatlı mesaj');        
    END;
    
    PROCEDURE load_fee_types_to_enum
    IS BEGIN
        ibs.api_enumeration.cor_enumeration_type(const_interbankpayments.ENUMTYPE_PAYMENT_FEETYPE, 'Типы платежей');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_FEETYPE, FEE_TYPES_INBANK,       'Bankdaxilir komissiya');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_FEETYPE, FEE_TYPES_INCNTR,       'Olke daxilir komissiya');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_FEETYPE, FEE_TYPES_OUTCNTR,      'Olke xarici komissiya');   
    END;
    
    -- Создаем enumeration для статусов
    PROCEDURE load_state_to_enum
    IS BEGIN
        ibs.api_enumeration.cor_enumeration_type(const_interbankpayments.ENUMTYPE_PAYMENT_STATE, 'Состояние платежа (новые)');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_STATE, const_interbankpayments.STATE_NEW, 'Новый');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_STATE, const_interbankpayments.STATE_DRAFT, 'Черновик');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_STATE, const_interbankpayments.STATE_DELETED, 'Удаленный'); 
		ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_STATE, const_interbankpayments.STATE_REJECTED, 'Отколенный');       
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_STATE, 
                                                const_interbankpayments.STATE_VERIFICATION, 'Верификация');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_STATE, 
                                                const_interbankpayments.STATE_CHANGING, 'Модификация(В)');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_STATE, 
                                                const_interbankpayments.STATE_CHANGINGFROMAUTH, 'Модификация(А)');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_STATE, 
                                                const_interbankpayments.STATE_AUTHORIZATION, 'Авторизация');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_STATE, 
                                                const_interbankpayments.STATE_CANCELED, 'Отменен');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_STATE,
                                                const_interbankpayments.STATE_PROVIDER_SENT, 'Отправлен провайдеру');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_STATE, 
                                                const_interbankpayments.STATE_PROVIDER_ERROR, 'Провайдер вернул ошибку');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_STATE, 
                                                const_interbankpayments.STATE_PROVIDER_B_ERROR, 'Ошибка при отправке провайдеру');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_STATE, 
                                                const_interbankpayments.STATE_PROVIDER_NOTFOUND, 'Не попал к провайдеру');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_STATE, 
                                                const_interbankpayments.STATE_PROVIDER_IN_QUEEE, 'В очереди на отправку');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_STATE, 
                                                const_interbankpayments.STATE_COMPLETED, 'Завершен');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_STATE, 
                                                const_interbankpayments.STATE_IB_WAITING, 'Ожидающий платеж ИБ');
        ibs.api_enumeration.cor_enumeration_value(const_interbankpayments.ENUMTYPE_PAYMENT_STATE, 
                                                const_interbankpayments.STATE_IB_TIMEOUT, 'Время платежа ИБ истекло');
    END;
    --
    PROCEDURE load_budgets_data IS
    BEGIN
        ibs.api_enumeration.cor_enumeration_type(ENUMTYPE_BUDGET_DESTINATION, 'Büdcə təsnifatı');
        ibs.api_enumeration.cor_enumeration_type(ENUMTYPE_BUDGET_LEVEL, 'Büdcə səviyyəsinin');
        --
        delete ibs.enumeration_value t where t.enum_type_id = ENUMTYPE_BUDGET_DESTINATION;
        delete ibs.enumeration_value t where t.enum_type_id = ENUMTYPE_BUDGET_LEVEL;
        --
        insert into ibs.enumeration_value (enum_type_id, enum_id, enum_name, enum_code, is_delete)
        select ENUMTYPE_BUDGET_DESTINATION, rownum, bd.t_code || ' - ' || SUBSTRB(bd.t_name,0,130), bd.t_code, ibs.const_general.NO
        from   dwmain.budget_destination bd;-- WHERE LENGTH(bd.t_code || ' - ' || bd.t_name) < 149;
        --*
        insert into ibs.enumeration_value (enum_type_id, enum_id, enum_name, enum_code, is_delete)
        select ENUMTYPE_BUDGET_LEVEL, rownum, bd.t_code || ' - ' || bd.t_name, bd.t_code, ibs.const_general.NO
        from   dwmain.budget_level bd;
    END;
    --
    PROCEDURE load_corr_accs
    IS
    BEGIN
        DELETE FROM ibs.PAYMENT_COR_ACCOUNTS;
    	--AZIPS
        INSERT INTO ibs.PAYMENT_COR_ACCOUNTS (PAYMENT_SYSTEM_ID, ACCOUNT_ID, CURRENCY_ID) VALUES (302,ibs.api_account.get_account_id('XXXXXXXX'),ibs.const_currency.CURRENCY_AZN);
        INSERT INTO ibs.PAYMENT_COR_ACCOUNTS (PAYMENT_SYSTEM_ID, ACCOUNT_ID, CURRENCY_ID) VALUES (302,ibs.api_account.get_account_id('XXXXXXXX'),ibs.const_currency.CURRENCY_USD);
        INSERT INTO ibs.PAYMENT_COR_ACCOUNTS (PAYMENT_SYSTEM_ID, ACCOUNT_ID, CURRENCY_ID) VALUES (302,ibs.api_account.get_account_id('XXXXXXXX'),ibs.const_currency.CURRENCY_EUR);
        -- XOHKS
        INSERT INTO ibs.PAYMENT_COR_ACCOUNTS (PAYMENT_SYSTEM_ID, ACCOUNT_ID, CURRENCY_ID) VALUES (303,ibs.api_account.get_account_id('XXXXXXXX'),ibs.const_currency.CURRENCY_AZN);
        --INSERT INTO PAYMENT_COR_ACCOUNTS (PAYMENT_SYSTEM_ID, ACCOUNT_ID, CURRENCY_ID) VALUES (303,api_account.get_account_id('10620010100001'),ibs.const_currency.CURRENCY_USD);
        --INSERT INTO PAYMENT_COR_ACCOUNTS (PAYMENT_SYSTEM_ID, ACCOUNT_ID, CURRENCY_ID) VALUES (303,api_account.get_account_id('10620020000001'),ibs.const_currency.CURRENCY_EUR);
        --NPS
        INSERT INTO ibs.PAYMENT_COR_ACCOUNTS (PAYMENT_SYSTEM_ID, ACCOUNT_ID, CURRENCY_ID) VALUES (304,ibs.api_account.get_account_id('XXXXXXXX'),ibs.const_currency.CURRENCY_AZN);
        INSERT INTO ibs.PAYMENT_COR_ACCOUNTS (PAYMENT_SYSTEM_ID, ACCOUNT_ID, CURRENCY_ID) VALUES (304,ibs.api_account.get_account_id('XXXXXXXX'),ibs.const_currency.CURRENCY_USD);
        INSERT INTO ibs.PAYMENT_COR_ACCOUNTS (PAYMENT_SYSTEM_ID, ACCOUNT_ID, CURRENCY_ID) VALUES (304,ibs.api_account.get_account_id('XXXXXXXX'),ibs.const_currency.CURRENCY_EUR);
    END;
    
    -- Загружаем важные данные после конвертации
    PROCEDURE load_special_tariff IS
        l_tariff_row ibs.tariff%ROWTYPE;
    BEGIN
        BEGIN DELETE FROM INTERBANKPAYMENTS_SPECIAL_FEE;
        EXCEPTION WHEN OTHERS THEN NULL; END;
        
        -- Перенести на табличную форму
        -------------------------------------------- Azen Oil Co (024703) 
        -- в пределах страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа в пределах страны Azen Oil Co (024703)', 
                                                  ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                  ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.10, 0.20,   90, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('024703', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);
        -- за пределы страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа за пределы страны Azen Oil Co (024703)', 
                                                  ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                  ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.10, 0.20,   90, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('024703', l_tariff_row.id, const_interbankpayments.FEE_TYPES_OUTCNTR);

        -------------------------------------------- NANT MMC (015163)
        -- в пределах страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа в пределах страны NANT MMC (015163)', 
                                                  ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                  ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.1,     1,  150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('015163', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);
        -- за пределы страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа за пределы страны NANT MMC (015163)', 
                                                  ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                  ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.1,     1,  150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('015163', l_tariff_row.id, const_interbankpayments.FEE_TYPES_OUTCNTR);
        
        -------------------------------------------- AZAUTO MMC (034593)
        -- в пределах страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа в пределах страны AZAUTO MMC (034593)', 
                                                  ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                  ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.1,     1,  150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('034593', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);
        -- за пределы страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа за пределы страны AZAUTO MMC (034593)', 
                                                  ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                  ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.1,     1,  150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('034593', l_tariff_row.id, const_interbankpayments.FEE_TYPES_OUTCNTR);
        
        -------------------------------------------- Embawood MMC (938041)
        -- в пределах страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа в пределах страны Embawood MMC (938041)', 
                                                  ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                  ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.1,     1,  150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('938041', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);
        -- за пределы страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа за пределы страны Embawood MMC (938041)', 
                                                  ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                  ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.1,  1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.20, 5, 200, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.20, 5, 200, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.20, 5, 200, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.20, 5, 200, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.20, 5, 200, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.20, 5, 200, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.20, 5, 200, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.20, 5, 200, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('938041', l_tariff_row.id, const_interbankpayments.FEE_TYPES_OUTCNTR);
        
        -------------------------------------------- Hacı Camalxan KFT (145471)
        -- в пределах страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа в пределах страны Hacı Camalxan KFT (145471)', 
                                                  ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                  ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.1,     1,  150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('145471', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);
        -- за пределы страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа за пределы страны Hacı Camalxan KFT (145471)', 
                                                  ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                  ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.1,  1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.20, 30, 500, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.20, 30, 500, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.20, 30, 500, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.20, 30, 500, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.20, 30, 500, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.20, 30, 500, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.20, 30, 500, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.20, 30, 500, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('145471', l_tariff_row.id, const_interbankpayments.FEE_TYPES_OUTCNTR);
        
        -------------------------------------------- Azərtrans LTD (028094)
        -- в пределах страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа в пределах страны Azərtrans LTD (028094)', 
                                                  ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                  ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.08,     1,  120, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('028094', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);
        -- за пределы страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа за пределы страны Azərtrans LTD (028094)', 
                                                  ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                  ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.05,  0.5, 75, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('028094', l_tariff_row.id, const_interbankpayments.FEE_TYPES_OUTCNTR);
        
        -------------------------------------------- SETEXGROUP MMC (313725)
        -- в пределах страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа в пределах страны SETEXGROUP MMC (313725)', 
                                                  ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                  ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.05,  0.5, 75, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('313725', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);
        
        -------------------------------------------- KOMTEC MMC (437419)
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа в пределах страны 437419', 
                                                     ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                     ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.1,  1, 100, ibs.const_currency.CURRENCY_AZN); 
        jui_interbankpayments_tools.add_special_fee('437419', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);
        
        -------------------------------------------- Azersun Holdinq MMC (229949)
        -- в пределах страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа в пределах страны 229949', 
                                                 ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                 ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.1,  1,  150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('229949', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);
        /*l_tariff_row := api_tariff.create_tariff('Комиссия за отправку срочного платежа 229949', const_tariff.TARIFF_KIND_GENERAL, const_tariff.TARIFF_BASE_OPERATION);
        api_tariff.create_tariff_general(l_tariff_row.id, const_currency.CURRENCY_AZN, null, 0.00, 0, 0, const_currency.CURRENCY_AZN);
        api_tariff.create_tariff_general(l_tariff_row.id, const_currency.CURRENCY_USD, null, 0.00, 0, 0, const_currency.CURRENCY_AZN);
        api_tariff.create_tariff_general(l_tariff_row.id, const_currency.CURRENCY_EUR, null, 0.00, 0, 0, const_currency.CURRENCY_AZN);
        api_tariff.create_tariff_general(l_tariff_row.id, const_currency.CURRENCY_GBP, null, 0.00, 0, 0, const_currency.CURRENCY_AZN);
        api_tariff.create_tariff_general(l_tariff_row.id, const_currency.CURRENCY_RUB, null, 0.00, 0, 0, const_currency.CURRENCY_AZN);
        api_tariff.create_tariff_general(l_tariff_row.id, const_currency.CURRENCY_YTL, null, 0.00, 0, 0, const_currency.CURRENCY_AZN);
        api_tariff.create_tariff_general(l_tariff_row.id, const_currency.CURRENCY_JPY, null, 0.00, 0, 0, const_currency.CURRENCY_AZN);
        api_tariff.create_tariff_general(l_tariff_row.id, const_currency.CURRENCY_CHF, null, 0.00, 0, 0, const_currency.CURRENCY_AZN);
        api_tariff.create_tariff_general(l_tariff_row.id, const_currency.CURRENCY_IRR, null, 0.00, 0, 0, const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('229949', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);*/
        -- за пределы страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа за пределы страны 229949', 
                                                    ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                    ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.1,  1,  150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('229949', l_tariff_row.id, const_interbankpayments.FEE_TYPES_OUTCNTR);
        
        -------------------------------------------- AZAUTO MMC (034593)
        -- в пределах страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа в пределах страны 034593', 
                                                     ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                     ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.1,  1,  150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('034593', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);
        -- за пределы страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа за пределы страны 034593', 
                                                     ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                     ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.1,  1,  150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('034593', l_tariff_row.id, const_interbankpayments.FEE_TYPES_OUTCNTR);
        
        
        -------------------------------------------- Buta siğorta qrupu (108553)
        -- в пределах страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа в пределах страны 108553', 
                                                 ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                 ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.1,  1,  150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('108553', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);
        -- за пределы страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа за пределы страны 108553', 
                                                     ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                     ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.1,  1,  150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.25, 30, 300, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('108553', l_tariff_row.id, const_interbankpayments.FEE_TYPES_OUTCNTR);
        
        -------------------------------------------- Lenk Ruth Nancy (510194)
        -- в пределах страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа в пределах страны 510194', 
                                                     ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                     ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.00,  0,   0, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('510194', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);
        -- за пределы страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа за пределы страны 510194', 
                                                    ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                    ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.00,  0,   0, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.30, 30, 300, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('510194', l_tariff_row.id, const_interbankpayments.FEE_TYPES_OUTCNTR);
        
        -------------------------------------------- BOB Broker MMC (115228)
        -- в пределах страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа в пределах страны 115228', 
                                                 ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                 ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.00, 0, 0, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.00, 0, 0, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.00, 0, 0, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.00, 0, 0, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.00, 0, 0, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.00, 0, 0, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.00, 0, 0, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.00, 0, 0, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.00, 0, 0, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('115228', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);
        -- за пределы страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа за пределы страны 115228', 
                                                 ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                 ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.00, 0, 0, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.00, 0, 0, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.00, 0, 0, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.00, 0, 0, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.00, 0, 0, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.00, 0, 0, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.00, 0, 0, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.00, 0, 0, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.00, 0, 0, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('115228', l_tariff_row.id, const_interbankpayments.FEE_TYPES_OUTCNTR);
        
        -------------------------------------------- "SSİ RETAİL" MMC (604651)
        -- в пределах страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа за пределы страны 604651', 
                                                 ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                 ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('604651', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);
        
        -------------------------------------------- "SİNTEKS CO502" MMC  (609298)
        -- в пределах страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа за пределы страны 609298', 
                                                 ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                 ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('609298', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);
        
        -------------------------------------------- "SİNTEKS CO501" MMC  (610747)
        -- в пределах страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа за пределы страны 610747', 
                                                 ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                 ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('610747', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);
        
        -------------------------------------------- "SİAY" MMC (452370)
        -- в пределах страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа за пределы страны 452370', 
                                                 ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                 ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.08, 1, 150, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('452370', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);
        
        -------------------------------------------- "MİR HOLDİNG” MMC   (573922)
        -- в пределах страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа в пределах страны 573922', 
                                                 ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                 ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.1,  1, 70, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('573922', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);
        
        -------------------------------------------- "Princeps Legem” MMC MMC   (575569)
        -- в пределах страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа в пределах страны 575569', 
                                                 ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                 ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.08,  1, 120, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('575569', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);
        
        -------------------------------------------- “Caspian Fish Co Azerbaijan” MMC (575641)
        -- в пределах страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа в пределах страны 575641', 
                                                 ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                 ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.08,  1, 120, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('575641', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);
        
        -------------------------------------------- “Medi Lux (597164)
        -- в пределах страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа в пределах страны 597164', 
                                                 ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                 ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.05,  0.5, 75, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('597164', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);
        
        -------------------------------------------- "BAKI TRAVEL -TOURİSM" MMC  (859276)
        -- в пределах страны
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа в пределах страны 859276', 
                                                 ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                 ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.08,  1, 150, ibs.const_currency.CURRENCY_AZN);
        jui_interbankpayments_tools.add_special_fee('859276', l_tariff_row.id, const_interbankpayments.FEE_TYPES_INCNTR);
        
    END;
    
    -- Загружаем важные данные после конвертации
    PROCEDURE load_standart_tariff
    IS 
        l_tariff_row ibs.tariff%ROWTYPE;
    BEGIN
        
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа (Ручной ввод)', 
                                                    ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                    ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, NULL, 0, NULL, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, NULL, NULL, 0, NULL, ibs.const_currency.CURRENCY_USD);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, NULL, NULL, 0, NULL, ibs.const_currency.CURRENCY_EUR);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, NULL, NULL, 0, NULL, ibs.const_currency.CURRENCY_RUB);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, NULL, NULL, 0, NULL, ibs.const_currency.CURRENCY_GBP);
        ibs.api_tariff.cor_fee(FEE_KIND_MANUAL, 
                           OT_OUTBANK_PAYMENT, 
                           const_interbankpayments.FEE_DEFGROUND, 
                           l_tariff_row.id, 
                           const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS, 
                           ':Комиссия за отправку платежа (Ручной ввод):', 
                           ibs.const_general.NO);
                           
        -------------------------------------------------------- Меж. банковские платежи (в пределах страны) --------------------------------------------------------    
        -- Комиссия за отправку платежа в пределах страны (юр. лица)              
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа в пределах страны (юр. лица)', 
                                                    ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                    ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.1,    1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, NULL, 0.25,  25, 300, ibs.const_currency.CURRENCY_USD);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.25,  25, 300, ibs.const_currency.CURRENCY_EUR);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB,   10, 0.3,   30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.3,   30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.3,   30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.3,   30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.3,   30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.3,   30, 300, ibs.const_currency.CURRENCY_AZN);     
        ibs.api_tariff.cor_fee(FEE_KIND_INCNTR_JUR,
                           OT_OUTBANK_PAYMENT, 
                           const_interbankpayments.FEE_DEFGROUND, 
                           l_tariff_row.id, 
                           const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS, 
                           ':Комиссия за отправку платежа в пределах страны (юр. лица):', 
                           ibs.const_general.NO);
                           
        -- Комиссия за отправку платежа в пределах страны (бизнес. лица)              
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа в пределах страны (бизнес лица)', 
                                                    ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                    ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.1,    1, 150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, NULL, 0.25,  25, 300, ibs.const_currency.CURRENCY_USD);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.25,  25, 300, ibs.const_currency.CURRENCY_EUR);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB,   10, 0.3,   30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.3,   30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.3,   30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.3,   30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.3,   30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.3,   30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.cor_fee(FEE_KIND_INCNTR_BUS, 
                           OT_OUTBANK_PAYMENT, 
                           const_interbankpayments.FEE_DEFGROUND, 
                           l_tariff_row.id, 
                           const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS, 
                           ':Комиссия за отправку платежа в пределах страны (предприн.):', 
                           ibs.const_general.NO);

        -- Комиссия за отправку платежа в пределах страны (физ. лица)
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа в пределах страны (физ. лица)', 
                                                    ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                    ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.1,   1,   150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.25,  25,  300, ibs.const_currency.CURRENCY_USD);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.25,  25,  300, ibs.const_currency.CURRENCY_EUR);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, 10,   NULL,  NULL,NULL,  ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.5,   20,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.5,   20,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.5,   20,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.5,   20,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.5,   20,  300, ibs.const_currency.CURRENCY_AZN);

        ibs.api_tariff.cor_fee(FEE_KIND_INCNTR_PHS, 
                           OT_OUTBANK_PAYMENT, 
                           const_interbankpayments.FEE_DEFGROUND, 
                           l_tariff_row.id, 
                           const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS, 
                           ':Комиссия за отправку платежа в пределах страны (физ. лица):', 
                           ibs.const_general.NO);
        
        -- Комиссия за отправку платежа физ. лица (интернет-банкинг)
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа физ. лица в пределах страны (интернет-банкинг)', 
                                                    ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                    ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.05,     0.5, 75,  ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.2,       20, 200,  ibs.const_currency.CURRENCY_USD);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.2,       20, 200,  ibs.const_currency.CURRENCY_EUR);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, NULL, 0.3,       30, 300,  ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.3,      20, 200, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.3,      20, 200, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.3,      20, 200, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.3,      20, 200, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.3,      20, 200, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.cor_fee(FEE_KIND_INCNTR_PHS_IB, 
                           OT_OUTBANK_PAYMENT, 
                           const_interbankpayments.FEE_DEFGROUND, 
                           l_tariff_row.id, 
                           const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS, 
                           ':Комиссия за отправку платежа (интернет-банкинг):', 
                           ibs.const_general.NO);
                           
        -- Комиссия за отправку платежа юр. лица (интернет-банкинг)
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа юр. лица в пределах страны (интернет-банкинг)', 
                                                    ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                    ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.05,     0.5, 75,  ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.2,      20, 200,  ibs.const_currency.CURRENCY_USD);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.2,      20, 200,  ibs.const_currency.CURRENCY_EUR);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, NULL, 0.3,      30, 300,  ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.3,      20, 200, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.3,      20, 200, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.3,      20, 200, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.3,      20, 200, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.3,      20, 200, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.cor_fee(FEE_KIND_INCNTR_JUR_IB, 
                           OT_OUTBANK_PAYMENT, 
                           const_interbankpayments.FEE_DEFGROUND, 
                           l_tariff_row.id, 
                           const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS, 
                           ':Комиссия за отправку платежа (интернет-банкинг):', 
                           ibs.const_general.NO);
        -------------------------------------------------------- Меж. банковские платежи (за пределы страны) --------------------------------------------------------    
        -- Комиссия за отправку платежа в пределах страны (юр. лица)              
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа за пределы страны (юр. лица)', 
                                                    ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                    ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.1,    1,    75, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, NULL, 0.30,   30,  300, ibs.const_currency.CURRENCY_USD);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_EUR);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, NULL, 0.3,    30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.3,    30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.3,    30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.3,    30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.3,    30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.3,    30,  300, ibs.const_currency.CURRENCY_AZN);     
        ibs.api_tariff.cor_fee(FEE_KIND_OUTCNTR_JUR,
                           OT_OUTBANK_PAYMENT, 
                           const_interbankpayments.FEE_DEFGROUND, 
                           l_tariff_row.id, 
                           const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS, 
                           ':Комиссия за отправку платежа за пределы страны (юр. лица):', 
                           ibs.const_general.NO);
                           
        -- Комиссия за отправку платежа за пределы страны (бизнес. лица)              
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа за пределы страны (бизнес лица)', 
                                                    ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                    ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.1,    1,    75, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, NULL, 0.30,   30,  300, ibs.const_currency.CURRENCY_USD);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_EUR);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, NULL, 0.3,    30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.3,    30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.3,    30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.3,    30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.3,    30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.3,    30,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.cor_fee(FEE_KIND_OUTCNTR_BUS, 
                           OT_OUTBANK_PAYMENT, 
                           const_interbankpayments.FEE_DEFGROUND, 
                           l_tariff_row.id, 
                           const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS, 
                           ':Комиссия за отправку платежа за пределы страны (предприн.):', 
                           ibs.const_general.NO);

        -- Комиссия за отправку платежа в пределах страны (физ. лица)
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа за пределы страны (физ. лица)', 
                                                    ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                    ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null, 0.1,    1,    75, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, NULL, 0.30,   30,  300, ibs.const_currency.CURRENCY_USD);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.30,   30,  300, ibs.const_currency.CURRENCY_EUR);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB,   10, NULL, NULL, NULL, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.5,    20,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.5,    20,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.5,    20,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.5,    20,  300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.5,    20,  300, ibs.const_currency.CURRENCY_AZN);     

        ibs.api_tariff.cor_fee(FEE_KIND_OUTCNTR_PHS, 
                           OT_OUTBANK_PAYMENT, 
                           const_interbankpayments.FEE_DEFGROUND, 
                           l_tariff_row.id, 
                           const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS, 
                           ':Комиссия за отправку платежа за пределы страны (физ. лица):', 
                           ibs.const_general.NO);
        
        -- Комиссия за отправку платежа за пределы физ. лица (интернет-банкинг)
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа физ. лицаза пределы страны (интернет-банкинг)', 
                                                    ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                    ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null,0.05,     0.5, 75,  ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.2,      20, 200,  ibs.const_currency.CURRENCY_USD);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.2,      20, 200,  ibs.const_currency.CURRENCY_EUR);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, 10,  NULL,    NULL, NULL,  ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.5,      20, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.5,      20, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.5,      20, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.5,      20, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.5,      20, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.cor_fee(FEE_KIND_OUTCNTR_PHS_IB, 
                           OT_OUTBANK_PAYMENT, 
                           const_interbankpayments.FEE_DEFGROUND, 
                           l_tariff_row.id, 
                           const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS, 
                           ':Комиссия за отправку платежа за пределы (интернет-банкинг):', 
                           ibs.const_general.NO);
        -- Комиссия за отправку платежа за пределы юр. лица  (интернет-банкинг)
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа юр. лица за пределы страны (интернет-банкинг)', 
                                                    ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                    ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, null,0.05,     0.5, 75,  ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, null, 0.2,      20, 200,  ibs.const_currency.CURRENCY_USD);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, null, 0.2,      20, 200,  ibs.const_currency.CURRENCY_EUR);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, NULL, 0.3,      30, 300,  ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, null, 0.3,      30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, null, 0.3,      30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, null, 0.3,      30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, null, 0.3,      30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, null, 0.3,      30, 300, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.cor_fee(FEE_KIND_OUTCNTR_JUR_IB, 
                           OT_OUTBANK_PAYMENT, 
                           const_interbankpayments.FEE_DEFGROUND, 
                           l_tariff_row.id, 
                           const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS, 
                           ':Комиссия за отправку платежа юр. лица за пределы (интернет-банкинг):', 
                           ibs.const_general.NO);                   
        
        -------------------------------------------------------- Внутрибанковские платежи --------------------------------------------------------
                                        /*********************** Физические лица *****************************/
        -- Fiziki şəxslər üzrə Bakı, Xırdalan və Sumqayıt şəhərlərində yerləşən istənilən filiallararası köçürmə                    
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа внутри банка для физ. лиц (Регион А - Bakı, Xırdalan və Sumqayıt)', 
                                                    ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                    ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_USD);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_EUR);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_GBP);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_AZN); -- Rubl ilə köçürmələr zamanı 1 AZN
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_YTL);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_JPY);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_CHF);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_IRR);
        ibs.api_tariff.cor_fee(FEE_KIND_INBNK_PHS_REG_A, 
                               OT_OUTBANK_PAYMENT, 
                               const_interbankpayments.FEE_DEFGROUND, 
                               l_tariff_row.id, 
                               const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS, 
                               ':Комиссия за отправку платежа внутри банка для физ. лиц (Регион А):', 
                               ibs.const_general.NO);

        -- Fiziki şəxslər üzrə Gəncə şəhərində yerləşən filiallararası köçürmə                   
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа внутри банка для физ. лиц (Регион D - Gəncə)', 
                                                    ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                    ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_USD);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_EUR);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_GBP);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_AZN); -- Rubl ilə köçürmələr zamanı 1 AZN
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_YTL);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_JPY);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_CHF);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_IRR);
        ibs.api_tariff.cor_fee(FEE_KIND_INBNK_PHS_REG_D, 
                               OT_OUTBANK_PAYMENT, 
                               const_interbankpayments.FEE_DEFGROUND, 
                               l_tariff_row.id, 
                               const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS, 
                               ':Комиссия за отправку платежа внутри банка для физ. лиц (Регион D):', 
                               ibs.const_general.NO);
        
        -- Fiziki şəxslər üzrə digər filiallararası köçürmə                 
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа внутри банка для физ. лиц (Регион Другие)', 
                                                    ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                    ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, NULL, 0.1,   1,  150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, NULL, 0.1,   1,  150, ibs.const_currency.CURRENCY_USD);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, NULL, 0.1,   1,  150, ibs.const_currency.CURRENCY_EUR);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, NULL, 0.1,   1,  150, ibs.const_currency.CURRENCY_GBP);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, NULL, 0.1,   1,  150, ibs.const_currency.CURRENCY_AZN); -- Rubl ilə köçürmələr zamanı NULL AZN
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, NULL, 0.1,   1,  150, ibs.const_currency.CURRENCY_YTL);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, NULL, 0.1,   1,  150, ibs.const_currency.CURRENCY_JPY);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, NULL, 0.1,   1,  150, ibs.const_currency.CURRENCY_CHF);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, NULL, 0.1,   1,  150, ibs.const_currency.CURRENCY_IRR);
        ibs.api_tariff.cor_fee(FEE_KIND_INBNK_PHS_REG_OT, 
                               OT_OUTBANK_PAYMENT, 
                               const_interbankpayments.FEE_DEFGROUND, 
                               l_tariff_row.id, 
                               const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS, 
                               ':Комиссия за отправку платежа внутри банка для физ. лиц (Регион Другие):', 
                               ibs.const_general.NO);
        
        -- Fiziki şəxslər üzrə bütün şəhər və rayonlarda yerləşən fiiallarda filialdaxili  köçürmə
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа внутри банка для физ. лиц (Один и тот же филиал)', 
                                                    ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                    ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_USD);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_EUR);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_GBP);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_AZN); -- Rubl ilə köçürmələr zamanı 1 AZN
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_YTL);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_JPY);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_CHF);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_IRR);
        ibs.api_tariff.cor_fee(FEE_KIND_INBNK_PHS_SAME_BR, 
                               OT_OUTBANK_PAYMENT, 
                               const_interbankpayments.FEE_DEFGROUND, 
                               l_tariff_row.id, 
                               const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS, 
                               ':Комиссия за отправку платежа внутри банка для физ. лиц (Один и тот же филиал):', 
                               ibs.const_general.NO);
                               
                                                /*********************** Юр лица *****************************/
        -- Fiziki şəxslər üzrə Bakı, Xırdalan və Sumqayıt şəhərlərində yerləşən istənilən filiallararası köçürmə                    
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа внутри банка для юр. лиц (Регион А - Bakı, Xırdalan və Sumqayıt)', 
                                                    ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                    ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_USD);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_EUR);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_GBP);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_AZN); -- Rubl ilə köçürmələr zamanı 1 AZN
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_YTL);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_JPY);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_CHF);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_IRR);
        ibs.api_tariff.cor_fee(FEE_KIND_INBNK_JUR_REG_A, 
                               OT_OUTBANK_PAYMENT, 
                               const_interbankpayments.FEE_DEFGROUND, 
                               l_tariff_row.id, 
                               const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS, 
                               ':Комиссия за отправку платежа внутри банка для юр. лиц (Регион А):', 
                               ibs.const_general.NO);

        -- Fiziki şəxslər üzrə Gəncə şəhərində yerləşən filiallararası köçürmə                   
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа внутри банка для юр. лиц (Регион D - Gəncə)', 
                                                    ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                    ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_USD);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_EUR);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_GBP);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_AZN); -- Rubl ilə köçürmələr zamanı 1 AZN
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_YTL);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_JPY);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_CHF);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_IRR);
        ibs.api_tariff.cor_fee(FEE_KIND_INBNK_JUR_REG_D, 
                               OT_OUTBANK_PAYMENT, 
                               const_interbankpayments.FEE_DEFGROUND, 
                               l_tariff_row.id, 
                               const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS, 
                               ':Комиссия за отправку платежа внутри банка для корпоративных лиц (Регион D):', 
                               ibs.const_general.NO);
        
        -- Fiziki şəxslər üzrə digər filiallararası köçürmə                 
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа внутри банка для юр. лиц (Регион Другие)', 
                                                    ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                    ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, NULL, 0.1,   1,  150, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, NULL, 0.1,   1,  150, ibs.const_currency.CURRENCY_USD);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, NULL, 0.1,   1,  150, ibs.const_currency.CURRENCY_EUR);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, NULL, 0.1,   1,  150, ibs.const_currency.CURRENCY_GBP);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, NULL, 0.1,   1,  150, ibs.const_currency.CURRENCY_AZN); -- Rubl ilə köçürmələr zamanı NULL AZN
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, NULL, 0.1,   1,  150, ibs.const_currency.CURRENCY_YTL);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, NULL, 0.1,   1,  150, ibs.const_currency.CURRENCY_JPY);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, NULL, 0.1,   1,  150, ibs.const_currency.CURRENCY_CHF);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, NULL, 0.1,   1,  150, ibs.const_currency.CURRENCY_IRR);
        ibs.api_tariff.cor_fee(FEE_KIND_INBNK_JUR_REG_OT, 
                               OT_OUTBANK_PAYMENT, 
                               const_interbankpayments.FEE_DEFGROUND, 
                               l_tariff_row.id, 
                               const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS, 
                               ':Комиссия за отправку платежа внутри банка для юр. лиц (Регион D):', 
                               ibs.const_general.NO);
        
        -- Fiziki şəxslər üzrə bütün şəhər və rayonlarda yerləşən fiiallarda filialdaxili  köçürmə
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за отправку платежа внутри банка для юр. лиц (Один и тот же филиал)', 
                                                    ibs.const_tariff.TARIFF_KIND_GENERAL, 
                                                    ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_USD);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_EUR);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_GBP);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_AZN); -- Rubl ilə köçürmələr zamanı 1 AZN
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_YTL);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_JPY);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_CHF);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, 1, NULL,    NULL,  NULL, ibs.const_currency.CURRENCY_IRR);
        ibs.api_tariff.cor_fee(FEE_KIND_INBNK_JUR_SAME_BR, 
                               OT_OUTBANK_PAYMENT, 
                               const_interbankpayments.FEE_DEFGROUND, 
                               l_tariff_row.id, 
                               const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS, 
                               ':Комиссия за отправку платежа внутри банка для юр. лиц (Один и тот же филиал):', 
                               ibs.const_general.NO);

        -------------------------------------------------------- Разное --------------------------------------------------------
        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за срочный платеж', ibs.const_tariff.TARIFF_KIND_GENERAL, ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, 30, null, null, null, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, 30, null, null, null, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, 30, null, null, null, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, 30, null, null, null, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, 30, null, null, null, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, 30, null, null, null, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, 30, null, null, null, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, 30, null, null, null, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, 30, null, null, null, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.cor_fee(FEE_KIND_URGENT, 
                               OT_OUTBANK_PAYMENT, 
                               const_interbankpayments.FEE_DEFGROUND, 
                               l_tariff_row.id, 
                               const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS, 
                               ':Комиссия за срочность платежа:', 
                               ibs.const_general.NO); 

        l_tariff_row := ibs.api_tariff.create_tariff('Комиссия за срочный платеж интернет-банкинг', ibs.const_tariff.TARIFF_KIND_GENERAL, ibs.const_tariff.TARIFF_BASE_OPERATION);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_AZN, 15, null, null, null, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_USD, 15, null, null, null, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_EUR, 15, null, null, null, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_GBP, 15, null, null, null, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_RUB, 15, null, null, null, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_YTL, 15, null, null, null, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_JPY, 15, null, null, null, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_CHF, 15, null, null, null, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.create_tariff_general(l_tariff_row.id, ibs.const_currency.CURRENCY_IRR, 15, null, null, null, ibs.const_currency.CURRENCY_AZN);
        ibs.api_tariff.cor_fee(FEE_KIND_URGENT_IB, 
                               OT_OUTBANK_PAYMENT, 
                               const_interbankpayments.FEE_DEFGROUND, 
                               l_tariff_row.id, 
                               const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS, 
                               ':Комиссия за срочность платежа интернет-банкинг:', 
                               ibs.const_general.NO);        
    END;
    
    
    
    PROCEDURE load_tariff IS
    BEGIN
         -- Загрузка стандартных комиссий
        load_standart_tariff;
        -- Загрузка специальных комиссий
        load_special_tariff;
    END;

    PROCEDURE load_dir
    IS 
    	l_obj_id INTEGER;
    BEGIN
       ibs.api_operation.cor_operation_type(CONST_INTERBANKPAYMENTS.OT_OUTBANK_PAYMENT, 
                                            'Отправка межбанковского платежа', 
                                            'api_payment.out_paym_op_state_change_handl', 
                                            null);
       ibs.api_operation.cor_operation_chain_type(CONST_INTERBANKPAYMENTS.OCT_OUTBANK_PAYMENT, 'Отправка межбанковского платежа');
        
       ibs.api_account.cor_acc_category_type(const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS,  
                                          'Категория учета за комиссию отправки платежа', 
                                          const_interbankpayments.ACC_CAT_IN_FEE_IPAYMENTS_TPL);
       load_fee_types_to_enum;
       load_payment_systems_to_enum;
       load_msgtypes_to_enum;
       load_accesses_to_enum;
       load_state_to_enum;
       load_mt113_addi_codes_to_enum;
       load_budgets_data;
       /* перенесено в D:\DEVNEW_Loader\sql\load_payment_system_cor_accs.sql, т.к. для спец тарифов нужны клиенты
       load_tariff;
       load_special_tariff;*/
        
       /*
       Перенесено в пакет const_payment
       -- Для обратной совместимости со старjq реализацией
       ibs.api_operation.set_operation_type_dependency(ipay.CONST_INTERBANKPAYMENTS.OT_OUTBANK_PAYMENT, 
                                                    ibs.t_integer_collection(ibs.const_payment.OT_PAY_UTILITIES,
                                                                         ibs.const_payment.OT_SEND_FAST_TRANSFER,
                                                                         ibs.const_payment.OT_FAST_TRANSFER_PAYMENT,
                                                                         ibs.const_payment.OT_FAST_TRANSFER_RETURNING,
                                                                         ibs.const_payment.OT_FAST_TRANSF_CANCELATION,
                                                                         ibs.const_payment.OT_SEND_OUT_PAYM_MT103,
                                                                         ibs.const_account.OP_TYPE_SET_ARREST,
                                                                         ipay.CONST_INTERBANKPAYMENTS.OT_OUTBANK_PAYMENT,
                                                                         ibs.const_account.OP_TYPE_SET_ARREST,
                                                                         ibs.const_deposit.OT_SERENGAM
                                                                         )); 
       */
    END;
    
    PROCEDURE load_operation__dependencies IS
    BEGIN
        ibs.api_operation.set_operation_type_dependency(CONST_INTERBANKPAYMENTS.OT_OUTBANK_PAYMENT, 
                                                    ibs.t_integer_collection(ibs.const_payment.OT_PAY_UTILITIES,
                                                                         ibs.const_payment.OT_SEND_FAST_TRANSFER,
                                                                         ibs.const_payment.OT_FAST_TRANSFER_PAYMENT,
                                                                         ibs.const_payment.OT_FAST_TRANSFER_RETURNING,
                                                                         ibs.const_payment.OT_FAST_TRANSF_CANCELATION,
                                                                         ibs.const_payment.OT_SEND_OUT_PAYM_MT103,
                                                                         ibs.const_account.OP_TYPE_SET_ARREST,
                                                                         CONST_INTERBANKPAYMENTS.OT_OUTBANK_PAYMENT)); 
    END;
    
    PROCEDURE onIbsConvertation IS
    BEGIN
        load_corr_accs;
        load_tariff;
        automizer;
    END;
end const_interbankpayments;
/
