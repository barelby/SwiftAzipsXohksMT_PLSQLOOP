CREATE OR REPLACE TYPE T_MESSAGE_STRUCT_301_113 FORCE UNDER T_MESSAGE_STRUCT_304
(
    MEMBER FUNCTION TAG_57D_RUB RETURN VARCHAR2,
    MEMBER FUNCTION TAG_59_RUB RETURN VARCHAR2,
    MEMBER FUNCTION tag_20_RUB  RETURN VARCHAR2,
    MEMBER FUNCTION TAG_50K_RUB RETURN VARCHAR2,
 
    OVERRIDING MEMBER FUNCTION GET_FILE_DIR RETURN VARCHAR2,
   
    MEMBER FUNCTION TAG_50A RETURN VARCHAR2,
    OVERRIDING MEMBER FUNCTION TAG_57A RETURN VARCHAR2,
    MEMBER FUNCTION TAG_57D RETURN VARCHAR2,
    MEMBER FUNCTION GET_HEADER_BLOCK3(SELF IN OUT T_MESSAGE_STRUCT_301_113) RETURN VARCHAR,
    OVERRIDING MEMBER FUNCTION GET_MESSAGE_RECEIVER_BANK(SELF IN OUT T_MESSAGE_STRUCT_301_113) RETURN VARCHAR,
    OVERRIDING MEMBER FUNCTION GET_HEADER_BLOCK2(SELF IN OUT T_MESSAGE_STRUCT_301_113) RETURN VARCHAR,
    OVERRIDING MEMBER FUNCTION GET_HEADER_BLOCK1(SELF IN OUT T_MESSAGE_STRUCT_301_113) RETURN VARCHAR,
    OVERRIDING MEMBER PROCEDURE GENERATE_CONTENT,
    OVERRIDING MEMBER FUNCTION tag_71a RETURN VARCHAR2,
    OVERRIDING MEMBER FUNCTION TAG_26T RETURN VARCHAR2,
    MEMBER FUNCTION TAG_33B RETURN VARCHAR2,
    MEMBER FUNCTION TAG_36 RETURN VARCHAR2,
    OVERRIDING MEMBER FUNCTION tag_50k RETURN VARCHAR2,
    MEMBER FUNCTION TAG_50_FACTORY RETURN VARCHAR2,
    MEMBER FUNCTION TAG_53B RETURN VARCHAR2,
    MEMBER FUNCTION TAG_56_FACTORY RETURN VARCHAR2,
    MEMBER FUNCTION TAG_57_FACTORY RETURN VARCHAR2,
    OVERRIDING MEMBER FUNCTION TAG_59 RETURN VARCHAR2,
    MEMBER FUNCTION TAG_71F RETURN VARCHAR2,
    OVERRIDING MEMBER FUNCTION tag_77B RETURN VARCHAR2,
    OVERRIDING  MEMBER FUNCTION COMPLETE(SELF IN OUT T_MESSAGE_STRUCT_301_113)  RETURN BOOLEAN,
    OVERRIDING MEMBER FUNCTION GET_FILE_EXTENSION RETURN VARCHAR2,
    MEMBER FUNCTION GENERATE_BODY_NONRUB(SELF IN OUT T_MESSAGE_STRUCT_301_113) RETURN VARCHAR2,
    MEMBER FUNCTION GENERATE_BODY_RUB(SELF IN OUT T_MESSAGE_STRUCT_301_113) RETURN VARCHAR2,
    OVERRIDING MEMBER FUNCTION GENERATE_BODY(SELF IN OUT T_MESSAGE_STRUCT_301_113) RETURN VARCHAR2,
    MEMBER FUNCTION TAG_79 RETURN VARCHAR2,
    OVERRIDING MEMBER PROCEDURE init(pobj IN OUT NOCOPY t_interbankpayments_extend),
    CONSTRUCTOR FUNCTION T_MESSAGE_STRUCT_301_113(POBJ IN OUT NOCOPY T_INTERBANKPAYMENTS_EXTEND)
        RETURN SELF AS RESULT,
    CONSTRUCTOR FUNCTION T_MESSAGE_STRUCT_301_113 RETURN SELF AS RESULT
)
NOT FINAL
/
CREATE OR REPLACE TYPE BODY T_MESSAGE_STRUCT_301_113 IS
    MEMBER FUNCTION tag_20_RUB  RETURN VARCHAR2 IS BEGIN RETURN ':20:+' || obj.REFERENCE; end;

    MEMBER FUNCTION TAG_36 RETURN VARCHAR2 IS
    BEGIN RETURN ':36:' || SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_EXCHANGE_RATE).value_str; END;    
    
    MEMBER FUNCTION TAG_33B RETURN VARCHAR2 IS
    BEGIN
        RETURN ':33B:' || ibs.api_currency.get_iso_name(SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_INIT_CURRENCY).value_int)
                       || SELF.FORMAT_AMOUNT(SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_INIT_AMOUNT).value_str);
    END;   

    MEMBER FUNCTION TAG_50K_RUB RETURN VARCHAR2 IS 
        l_str VARCHAR2(5000) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_PAYER_ADDINFO).value_str;
    BEGIN
        RETURN ':50K:/' || obj.PAYER_IBAN_ACCOUNT || 
                        CASE WHEN obj.PAYER_TAX_NUMBER IS NOT NULL OR LENGTH(TRIM(obj.PAYER_TAX_NUMBER)) <> 0 THEN
                                SELF.tag_ln || 
                                CASE WHEN UPPER(SUBSTR(SELF.obj.PAYER_TAX_NUMBER, 0, 3)) <> 'INN' THEN 'INN'
                                     ELSE '' 
                                END ||
                                SUBSTR(obj.PAYER_TAX_NUMBER,0,32)
                            ELSE ''
                        END ||
                        SELF.tag_ln || '''' || REPLACE(substr(obj.PAYER_NAME, 1, 35),'''','') || '''' ||
                        CASE WHEN l_str IS NOT NULL AND LENGTH(TRIM(l_str)) <> 0 THEN SELF.tag_ln || l_str
                             ELSE ''
                        END;
    END;

    MEMBER FUNCTION TAG_50A RETURN VARCHAR2 IS
    BEGIN
        RETURN ':50A:' || '/' || SELF.obj.PAYER_IBAN_ACCOUNT || SELF.tag_ln ||
                           SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_PAYER_BANK_SWIFT).value_str /*|| SELF.tag_ln ||
                           SELF.obj.PAYER_NAME || SELF.tag_ln ||
                           SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_PAYER_ADDINFO).value_str*/;
    END;
    
    MEMBER FUNCTION TAG_50_FACTORY RETURN VARCHAR2 IS
    BEGIN
        IF SELF.obj.isset_attribute(const_interbankpayments.ATTR_113_PAYER_BANK_SWIFT) THEN RETURN SELF.TAG_50A();
        ELSE  RETURN SELF.TAG_50k;
        END IF;
    END;   
    
    MEMBER FUNCTION TAG_53B RETURN VARCHAR2 IS
    BEGIN
        RETURN CASE WHEN SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_CORR_BANK_SWIFT).value_str = 'NABZAZ2X' THEN
                        ':52A:/' || SELF.obj.emitent_bank_corr_account || SELF.tag_ln || SELF.obj.emitent_bank_swift                                  
                    ELSE ':53B:/' || (CASE WHEN SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_CORR_BANK_ACC_TYPE).value_str =  
                                            const_interbankpayments.CFG_MT113_ACCTYPE_LORO THEN 'C/'
                                            ELSE '' END)  
                                       || SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_CORR_BANK_ACC).value_str
               END;
    END;
    MEMBER FUNCTION TAG_56_FACTORY RETURN VARCHAR2 IS
        l_add   VARCHAR2(5000) DEFAULT  SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_INTBANK_ADDINFO).value_str;
        l_name  VARCHAR2(5000) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_INTBANK_NAME).value_str;
        l_acc   VARCHAR2(5000) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_INTBANK_ACC).value_str;
    BEGIN
        IF SELF.obj.isset_attribute(const_interbankpayments.ATTR_113_INTBANK_SWIFT) THEN
            RETURN SELF.SMART_LN(':56A:' || 
                                 CASE  WHEN l_acc IS NOT NULL AND LENGTH(TRIM(l_acc)) <> 0 THEN '/' || l_acc || SELF.tag_ln ELSE '' END ||
                                 SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_INTBANK_SWIFT).value_str 
                                 /*|| SELF.tag_ln ||
                                 l_name || 
                                 CASE  WHEN l_add IS NOT NULL AND LENGTH(TRIM(l_add)) <> 0 THEN SELF.tag_ln || l_add ELSE '' END*/
                                );
        ELSIF l_name IS NOT NULL AND LENGTH(l_name) <> 0 THEN
            RETURN SELF.SMART_LN(':56D:' || 
                                 CASE  WHEN l_acc IS NOT NULL AND LENGTH(TRIM(l_acc)) <> 0 THEN '/' || l_acc || SELF.tag_ln ELSE '' END ||
                                 l_name || 
                                 CASE  WHEN l_add IS NOT NULL AND LENGTH(TRIM(l_add)) <> 0 THEN SELF.tag_ln || l_add ELSE '' END);
       ELSE RETURN '';
       END IF;
    END;

    MEMBER FUNCTION TAG_57D RETURN VARCHAR2 IS
        l_add       VARCHAR2(5000) DEFAULT  SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_BENEFBANK_ADDINFO).value_str;
        l_bn_acc    VARCHAR2(5000) DEFAULT  TRIM(SELF.obj.BENEFICIAR_BANK_CORR_ACCOUNT);
    BEGIN
        RETURN ':57D:' || CASE  WHEN l_bn_acc IS NOT NULL  AND LENGTH(l_bn_acc) <> 0 THEN '/' || l_bn_acc || SELF.tag_ln ELSE '' END ||
                              SELF.obj.BENEFICIAR_BANK_NAME ||
                              CASE WHEN l_add IS NOT NULL AND LENGTH(TRIM(l_add)) <> 0 THEN SELF.tag_ln || l_add ELSE '' END;
    END;
    
    MEMBER FUNCTION TAG_57D_RUB RETURN VARCHAR2 IS
        l_add       VARCHAR2(5000) DEFAULT  SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_BENEFBANK_ADDINFO).value_str;
        l_bn_acc    VARCHAR2(5000) DEFAULT  TRIM(SELF.obj.BENEFICIAR_BANK_CORR_ACCOUNT);
    BEGIN
        RETURN ':57D:' || CASE  WHEN l_bn_acc IS NOT NULL  AND LENGTH(l_bn_acc) <> 0 THEN 
                                CASE WHEN UPPER(SUBSTR(l_bn_acc, 0, 1)) <> '/' THEN '/' ELSE '' END ||
                                CASE WHEN UPPER(SUBSTR(l_bn_acc, 1, 1)) <> '/' THEN '/' ELSE '' END ||
                                CASE WHEN UPPER(SUBSTR(l_bn_acc, 2, 2)) <> 'RU' THEN 'RU' ELSE '' END  || 
                                l_bn_acc || SELF.tag_ln 
                          ELSE '' END ||
                          SELF.obj.BENEFICIAR_BANK_NAME ||
                          CASE WHEN l_add IS NOT NULL AND LENGTH(TRIM(l_add)) <> 0 THEN SELF.tag_ln || l_add ELSE '' END;
    END;
    
    MEMBER FUNCTION TAG_57_FACTORY RETURN VARCHAR2 IS
    BEGIN
        IF SELF.obj.BENEFICIAR_BANK_SWIFT IS NOT NULL THEN RETURN SELF.TAG_57A();
        ELSE RETURN SELF.TAG_57D(); END IF;    
    END;

    MEMBER FUNCTION TAG_59_RUB RETURN VARCHAR2 IS
        l_add VARCHAR2(5000) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_RECIVER_ADDINFO).value_str;
    BEGIN
        RETURN ':59:/' || SELF.obj.RECEIVER_IBAN ||
                          CASE  WHEN SELF.obj.RECEIVER_TAX IS NOT NULL THEN 
                                    SELF.tag_ln ||
                                    CASE WHEN UPPER(SUBSTR(SELF.obj.RECEIVER_TAX, 0, 3)) <> 'INN' THEN 'INN'
                                         ELSE '' 
                                    END ||
                                    SUBSTR(SELF.obj.RECEIVER_TAX,0,32)
                                ELSE ''
                          END  || 
                          SELF.tag_ln || SUBSTR(SELF.obj.RECEIVER_NAME,0,35) || 
                          CASE  WHEN l_add IS NOT NULL AND LENGTH(TRIM(l_add)) <> 0 THEN
                                        SELF.tag_ln || l_add
                                ELSE ''
                          END;
    END;
    
    MEMBER FUNCTION TAG_71F RETURN VARCHAR2 IS
        l_ind INTEGER;
        l_result VARCHAR(5000) DEFAULT '';
    BEGIN
        l_ind := SELF.obj.FEE_COLLECTION.FIRST;
        WHILE l_ind IS NOT NULL
            LOOP
                IF l_result <> '' THEN l_result := l_result || SELF.Tag_Ln; END IF;
                l_result := l_result || 
                            ':71F:' || ibs.api_currency.get_iso_name(SELF.obj.FEE_COLLECTION(l_ind).currency_id) 
                                    || SELF.FORMAT_AMOUNT(SELF.obj.FEE_COLLECTION(l_ind).fee_amount);
                l_ind := SELF.obj.FEE_COLLECTION.NEXT(l_ind);
            END LOOP;
        RETURN TRIM(l_result);
    END;
    
    /****************************************** OVERRIDINGS ******************************************/
    OVERRIDING MEMBER FUNCTION TAG_59 RETURN VARCHAR2 IS
        l_add VARCHAR2(5000) DEFAULT  SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_RECIVER_ADDINFO).value_str;
    BEGIN
        RETURN ':59:/' || SELF.obj.RECEIVER_IBAN || SELF.tag_ln ||
                          SELF.obj.RECEIVER_NAME || 
                          CASE  WHEN SELF.obj.RECEIVER_TAX IS NOT NULL THEN SELF.tag_ln || SELF.obj.RECEIVER_TAX
                                ELSE ''
                          END  || 
                          CASE  WHEN l_add IS NOT NULL AND LENGTH(TRIM(l_add)) <> 0 THEN
                                        SELF.tag_ln || l_add
                                ELSE ''
                          END;
    END;
    
    OVERRIDING MEMBER FUNCTION TAG_57A RETURN VARCHAR2 IS
        l_add       VARCHAR2(5000) DEFAULT  SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_BENEFBANK_ADDINFO).value_str;
        l_bn_acc    VARCHAR2(5000) DEFAULT  TRIM(SELF.obj.BENEFICIAR_BANK_CORR_ACCOUNT);
    BEGIN
        RETURN ':57A:' || CASE  WHEN l_bn_acc IS NOT NULL  AND LENGTH(l_bn_acc) <> 0 THEN '/' || l_bn_acc || SELF.tag_ln ELSE '' END ||
                              SELF.obj.BENEFICIAR_BANK_SWIFT -- || SELF.tag_ln
                              --SELF.obj.BENEFICIAR_BANK_NAME 	|| 
                              --CASE WHEN l_add IS NOT NULL AND LENGTH(TRIM(l_add)) <> 0 THEN SELF.tag_ln || l_add ELSE '' END
                                  ;
    END;
    
    OVERRIDING MEMBER FUNCTION TAG_50K RETURN VARCHAR2 IS 
        l_str VARCHAR2(5000) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_PAYER_ADDINFO).value_str;
    BEGIN
        RETURN ':50K:/' || obj.PAYER_IBAN_ACCOUNT ||
                        SELF.tag_ln || SUBSTR(obj.PAYER_NAME, 0, 35) ||
                        CASE WHEN obj.PAYER_TAX_NUMBER IS NOT NULL OR LENGTH(TRIM(obj.PAYER_TAX_NUMBER)) <> 0 THEN
                            SELF.tag_ln || 'TAX ID:' || obj.PAYER_TAX_NUMBER
                            ELSE ''
                        END ||
                        CASE WHEN l_str IS NOT NULL AND LENGTH(TRIM(l_str)) <> 0 THEN SELF.tag_ln || l_str
                             ELSE ''
                        END;
    END;
    
    OVERRIDING MEMBER FUNCTION GET_FILE_DIR RETURN VARCHAR2 IS BEGIN RETURN 'PAYMENT_FREE_DIR'; END;
    
    OVERRIDING MEMBER FUNCTION tag_77B RETURN VARCHAR2 IS 
        l_date  VARCHAR(10) DEFAULT to_char(SYSDATE, 'dd.MM.yyyy');
        l_n4    VARCHAR2(5000) DEFAULT obj.get_attribute_val(const_interbankpayments.ATTR_113_RUB_NN4).value_str;
        l_n5    VARCHAR2(5000) DEFAULT obj.get_attribute_val(const_interbankpayments.ATTR_113_RUB_NN5).value_str;
        l_n8    VARCHAR2(5000) DEFAULT obj.get_attribute_val(const_interbankpayments.ATTR_113_RUB_NN8).value_str;
    BEGIN 
        IF l_n4 IS NOT NULL AND l_n5 IS NOT NULL AND l_n8 IS NOT NULL THEN
           RETURN  SELF.tag_ln  || ':77B:/N10/PL'   || '/N4/'  || l_n4 || SELF.tag_ln ||
                                '/N5/' || l_n5 || '/N6/TP' || '/N7/0' || SELF.tag_ln ||
                                '/N8/' || l_n8 || '/N9/'   || l_date;
        ELSE RETURN '';
        END IF;
        
    END;
    
    OVERRIDING MEMBER FUNCTION tag_26T RETURN VARCHAR2 IS 
    BEGIN RETURN ':26T:' || SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_RUB_OPERATIONTYPE).value_str; END;
    
    OVERRIDING MEMBER FUNCTION tag_71a RETURN VARCHAR2 IS 
    BEGIN RETURN ':71A:' || SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_OPERATION_CODE).value_str; END;
    
    OVERRIDING  MEMBER FUNCTION COMPLETE(SELF IN OUT T_MESSAGE_STRUCT_301_113)  RETURN BOOLEAN IS 
        l_result    CLOB DEFAULT NULL;
        l_date      DATE DEFAULT SYSDATE;
        l_temp      boolean;
    BEGIN 
        l_temp := (SELF AS T_MESSAGE_STRUCT).COMPLETE();
        RETURN FALSE;
    END;
    
    OVERRIDING MEMBER FUNCTION GET_MESSAGE_RECEIVER_BANK(SELF IN OUT T_MESSAGE_STRUCT_301_113) RETURN VARCHAR IS
    BEGIN RETURN RPAD(SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_CORR_BANK_SWIFT).value_str, 12, 'X'); END;
    
    OVERRIDING MEMBER FUNCTION GET_FILE_EXTENSION RETURN VARCHAR2 IS BEGIN RETURN '.swift'; END;
    
    OVERRIDING MEMBER FUNCTION GET_HEADER_BLOCK1(SELF IN OUT T_MESSAGE_STRUCT_301_113) RETURN VARCHAR IS
    BEGIN RETURN '{1:F01' || SELF.GET_MESSAGE_EMITENT_BANK || substr(SELF.obj.REFERENCE,0,10) || '}'; END;

    OVERRIDING MEMBER FUNCTION GET_HEADER_BLOCK2(SELF IN OUT T_MESSAGE_STRUCT_301_113) RETURN VARCHAR IS
    BEGIN
        RETURN '{2:I103' ||  SELF.GET_MESSAGE_RECEIVER_BANK() ||
                CASE WHEN SELF.obj.isset_attribute(const_interbankpayments.ATTR_IS_URGENCY) THEN 'U1003'
                     ELSE 'N'
                END || '}';
    END;
    
    MEMBER FUNCTION GET_HEADER_BLOCK3(SELF IN OUT T_MESSAGE_STRUCT_301_113) RETURN VARCHAR IS
    BEGIN RETURN '{3:{113:0050}{108:' || SELF.obj.REFERENCE || '}}'; END;
    
    OVERRIDING MEMBER PROCEDURE GENERATE_CONTENT IS
        l_body CLOB DEFAULT SELF.GENERATE_BODY;
    BEGIN
        SELF.SOURCE_CONTENT := chr(1) || SELF.GET_HEADER_BLOCK1() 
                                || SELF.GET_HEADER_BLOCK2() 
                                || SELF.GET_HEADER_BLOCK3()
                                || SELF.GET_HEADER_BLOCK4(l_body) 
                                || chr(3);
    END;
    
    MEMBER FUNCTION GENERATE_BODY_NONRUB(SELF IN OUT T_MESSAGE_STRUCT_301_113) RETURN VARCHAR2 IS
        l_add   VARCHAR(5000) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_ADDITIONAL_INFO).value_str;
    BEGIN
        RETURN SELF.SMART_LN(SELF.TAG_20) || 
               CASE WHEN SELF.obj.isset_attribute(const_interbankpayments.ATTR_LINKED_REFERENCE) 
                        THEN SELF.SMART_LN(SELF.TAG_21)
                    ELSE '' 
               END ||
               SELF.SMART_LN(SELF.TAG_23B) ||
               SELF.SMART_LN(SELF.TAG_32A) ||
               CASE WHEN SELF.obj.isset_attribute(const_interbankpayments.ATTR_113_INIT_AMOUNT) THEN SELF.SMART_LN(SELF.TAG_33B) 
                    ELSE '' 
               END ||
               CASE WHEN SELF.obj.isset_attribute(const_interbankpayments.ATTR_113_EXCHANGE_RATE) THEN SELF.SMART_LN(SELF.TAG_36) 
                    ELSE ''
               END ||
               SELF.SMART_LN(SELF.TAG_50_FACTORY) ||
               SELF.SMART_LN(SELF.TAG_53B) ||
               SELF.TAG_56_FACTORY ||
               SELF.SMART_LN(SELF.TAG_57_FACTORY) ||
               SELF.SMART_LN(SELF.TAG_59) ||
               SELF.SMART_LN(SELF.TAG_70) ||
               SELF.TAG_71A ||
               CASE WHEN SELF.obj.FEE_COLLECTION.count > 0
                         AND SELF.obj.GET_ATTRIBUTE_VAL(const_interbankpayments.ATTR_113_OPERATION_CODE).value_str = const_interbankpayments.CFG_MT113_OPERCODE_BEN
                            THEN SELF.SMART_LN(SELF.TAG_71F) 
                    ELSE '' 
               END ||
               CASE WHEN l_add IS NOT NULL THEN  SELF.tag_ln || SELF.TAG_72
                    ELSE ''
               END;
    END;
    
    MEMBER FUNCTION GENERATE_BODY_RUB(SELF IN OUT T_MESSAGE_STRUCT_301_113) RETURN VARCHAR2 IS
        l_add   VARCHAR(5000) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_ADDITIONAL_INFO).value_str;
    BEGIN
        RETURN SELF.SMART_LN(SELF.tag_20_RUB) || 
               CASE WHEN SELF.obj.isset_attribute(const_interbankpayments.ATTR_LINKED_REFERENCE) 
                        THEN SELF.SMART_LN(SELF.TAG_21)
                    ELSE '' 
               END ||
               SELF.SMART_LN(SELF.TAG_23B) ||
               CASE WHEN SELF.obj.isset_attribute(const_interbankpayments.ATTR_113_RUB_OPERATIONTYPE) THEN SELF.SMART_LN(SELF.TAG_26T) 
                    ELSE '' 
               END ||
               SELF.SMART_LN(SELF.TAG_32A) ||
               CASE WHEN SELF.obj.isset_attribute(const_interbankpayments.ATTR_113_INIT_AMOUNT) THEN SELF.SMART_LN(SELF.TAG_33B) 
                    ELSE '' 
               END ||
               CASE WHEN SELF.obj.isset_attribute(const_interbankpayments.ATTR_113_EXCHANGE_RATE) THEN SELF.SMART_LN(SELF.TAG_36) 
                    ELSE ''
               END ||
               SELF.SMART_LN(SELF.TAG_50K_RUB) ||
               SELF.SMART_LN(SELF.TAG_53B) ||
               SELF.SMART_LN(SELF.TAG_57D_RUB) ||
               SELF.SMART_LN(SELF.TAG_59_RUB) ||
               SELF.SMART_LN(SELF.TAG_70) ||
               SELF.SMART_LN(SELF.TAG_71A) ||
               CASE WHEN l_add IS NOT NULL THEN SELF.TAG_72
                    ELSE ''
               END ||
               SELF.TAG_77B;
    END;
        
    OVERRIDING MEMBER FUNCTION GENERATE_BODY(SELF IN OUT T_MESSAGE_STRUCT_301_113) RETURN VARCHAR2 IS
        l_body CLOB;
    BEGIN
        l_body := CASE WHEN SELF.obj.CURRENCY = ibs.const_currency.CURRENCY_RUB THEN GENERATE_BODY_RUB()
                     ELSE GENERATE_BODY_NONRUB()
                  END;
        RETURN  REPLACE(REPLACE(l_body, chr(13), NULL), chr(10), SELF.TAG_LN);
    END;

    -- Потом разберусь и попытаюсь сделать перегрузками из родительского типа
    MEMBER FUNCTION TAG_79 RETURN VARCHAR2 IS
        RESULT         VARCHAR2(1750 CHAR);
        LINES_LEFT     NUMBER;
        LINE_SIZE      NUMBER;
        WORK_TEXT      VARCHAR2(1750 CHAR);
        NEW_LINE_INDEX NUMBER(4);
    
    BEGIN
        LINES_LEFT := 35;
        LINE_SIZE  := 50;
        WORK_TEXT  := TRIM(TRAILING CHR(10) FROM
                           TRIM(TRAILING CHR(13) FROM SELF.OBJ.GROUND));
        -- work_text  := payment_ground;
        RESULT := NULL;
        IF SELF.OBJ.GROUND IS NOT NULL THEN
            LOOP
                EXIT WHEN LINES_LEFT = 0 OR WORK_TEXT IS NULL;
                LINE_SIZE      := 50;
                NEW_LINE_INDEX := INSTR(WORK_TEXT, CHR(10), 1);
            
                IF NEW_LINE_INDEX > 0 AND NEW_LINE_INDEX <= LINE_SIZE THEN
                    LINE_SIZE := NEW_LINE_INDEX;
                    RESULT    := RESULT || REPLACE(REPLACE(SUBSTR(WORK_TEXT,
                                                                  1,
                                                                  LINE_SIZE),
                                                           CHR(10),
                                                           ''),
                                                   CHR(13),
                                                   '') || CHR(13) || CHR(10);
                ELSE
                    LINE_SIZE := 50;
                    RESULT    := RESULT || SUBSTR(WORK_TEXT, 1, LINE_SIZE);
                END IF;
            
                WORK_TEXT  := SUBSTR(WORK_TEXT, LINE_SIZE + 1);
                LINES_LEFT := LINES_LEFT - 1;
                IF WORK_TEXT IS NOT NULL AND LINE_SIZE = 50 AND
                   (NEW_LINE_INDEX < 50 OR NEW_LINE_INDEX > 51) THEN
                    WORK_TEXT := CHR(13) || CHR(10) || '' || WORK_TEXT;
                END IF;
            END LOOP;
            RESULT := ':79:' ||
                      TRIM(TRAILING CHR(10) FROM
                           TRIM(TRAILING CHR(13) FROM RESULT));
        END IF;
        RETURN RESULT;
    END;
    
    
    OVERRIDING MEMBER PROCEDURE INIT(pobj IN OUT NOCOPY t_interbankpayments_extend) IS
        l_b         bank_list%ROWTYPE;
        l_attr  t_intbankpays_attr;
    BEGIN
        
        
        (SELF AS T_MESSAGE_STRUCT).init(pobj);
        
        
        l_attr := SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_INTBANK_NAME);
    
        IF l_attr.id_attr IS NOT NULL THEN
            l_attr.value_str := SUBSTR(l_attr.value_str,0 , 35);
            SELF.obj.update_attr_val(l_attr);
        END IF;

        l_attr := SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_INTBANK_NAME);
        IF l_attr.id_attr IS NOT NULL THEN
            l_attr.value_str := SUBSTR(l_attr.value_str,0 , 35);
            SELF.obj.update_attr_val(l_attr);
        END IF;
        
        l_attr := SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_CORR_BANK_NAME);
        IF l_attr.id_attr IS NOT NULL THEN
            l_attr.value_str := SUBSTR(l_attr.value_str,0 , 35);
            SELF.obj.update_attr_val(l_attr);
        END IF;

        l_attr := SELF.obj.get_attribute_val(const_interbankpayments.ATTR_113_PAYER_BANK_NAME);
        IF l_attr.id_attr IS NOT NULL THEN
            l_attr.value_str := SUBSTR(l_attr.value_str,0 , 35);
            SELF.obj.update_attr_val(l_attr);
        END IF;
    END;
    
    
    -- Member procedures and functions
    CONSTRUCTOR FUNCTION T_MESSAGE_STRUCT_301_113(POBJ IN OUT NOCOPY T_INTERBANKPAYMENTS_EXTEND)
        RETURN SELF AS RESULT IS
    BEGIN
        SELF.INIT(POBJ);
        RETURN;
    END;
    
    CONSTRUCTOR FUNCTION T_MESSAGE_STRUCT_301_113 RETURN SELF AS RESULT 
    IS BEGIN RETURN; END;
END;
/
