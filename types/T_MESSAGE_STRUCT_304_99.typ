/**
 * SWIFT message 304/99
 * @Author: Rashad Khalafov
 * @Date: November, 2016
 */

CREATE OR REPLACE TYPE T_MESSAGE_STRUCT_304_99 FORCE UNDER T_MESSAGE_STRUCT_304
(
    OVERRIDING MEMBER FUNCTION GET_FILE_EXTENSION RETURN VARCHAR2,
    OVERRIDING MEMBER FUNCTION GET_FILE_DIR RETURN VARCHAR2,
    OVERRIDING MEMBER FUNCTION GENERATE_BODY(SELF IN OUT T_MESSAGE_STRUCT_304_99) RETURN VARCHAR2,
    OVERRIDING MEMBER FUNCTION TAG_72 RETURN VARCHAR2,
    MEMBER FUNCTION TAG_79 RETURN VARCHAR2,
    OVERRIDING MEMBER PROCEDURE INIT(pobj IN OUT NOCOPY t_interbankpayments_extend),
    OVERRIDING MEMBER PROCEDURE GENERATE_CONTENT,
    CONSTRUCTOR FUNCTION T_MESSAGE_STRUCT_304_99 RETURN SELF AS RESULT
)
NOT FINAL
/
CREATE OR REPLACE TYPE BODY T_MESSAGE_STRUCT_304_99 IS

    /****************************************** OVERRIDINGS ******************************************/
    OVERRIDING MEMBER FUNCTION GET_FILE_EXTENSION RETURN VARCHAR2 IS BEGIN RETURN '.swift'; END;
    OVERRIDING MEMBER FUNCTION GET_FILE_DIR RETURN VARCHAR2 IS BEGIN RETURN 'PAYMENT_FREE_DIR'; END;
    OVERRIDING MEMBER FUNCTION GENERATE_BODY(SELF IN OUT T_MESSAGE_STRUCT_304_99) RETURN VARCHAR2 IS
    BEGIN
        RETURN SELF.SMART_LN(SELF.TAG_20) || SELF.SMART_LN(SELF.TAG_21) || SELF.SMART_LN(SELF.TAG_79);
    END;

    OVERRIDING MEMBER FUNCTION TAG_72 RETURN VARCHAR2 IS
    BEGIN
        RETURN ':72:/BNF/1';
    END;
    
    -- ����� ��������� � ��������� ������� ������������ �� ������������� ����
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
                                                   '') || CHR(13) ||
                                 CHR(10);
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
        l_b bank_list%ROWTYPE;
    BEGIN
        SELF.obj := pobj;
        l_b := JUI_INTERBANKPAYMENTS_TOOLS.FIND_IN_BANKS_LIST_BY_BIK(SELF.obj.BENEFICIAR_BANK_CODE);
        SELF.STRUCT_IDENTIFER :=  SELF.GENERATE_STRUCT_IDENTIFER;
        SELF.obj.PAYER_NAME := regexp_replace(api_interbankpayments.translit_to_swift(upper(trim(SELF.obj.PAYER_NAME))),
                                              api_interbankpayments.as_swift_charset('x'),
                                              '');
        SELF.obj.EMITENT_BANK_S_CORR_ACC := ibs.api_attribute.get_str_attribute_value(ibs.api_object.get_object_id(ibs.const_subject.OUR_BANK_CODE, 
                                                                                                                      ibs.const_subject.CODE_KIND_CODE), 
                                                                                      ibs.const_subject.ATR_BANK_CORRESP_SUB_ACCOUNT);
        SELF.obj.BENEFICIAR_BANK_S_CORR_ACC := l_b.corr_sub;
    END;
    
    OVERRIDING MEMBER PROCEDURE GENERATE_CONTENT IS
    BEGIN
        SELF.SOURCE_CONTENT := SELF.smart_ln(chr(1) || '{1:F01' || SELF.GET_MESSAGE_EMITENT_BANK || substr(SELF.obj.REFERENCE,0,10) 
                                || '}{2:I'|| SELF.obj.get_attribute_val(const_interbankpayments.ATTR_FREE_FORMAT_MT_TYPE).value_int || SELF.obj.BENEFICIAR_BANK_SWIFT || 
                                CASE WHEN length(SELF.obj.BENEFICIAR_BANK_SWIFT)<>11 THEN 'XXXXN' ELSE 'XN' END || '}{4:')
                                || SELF.smart_ln(GENERATE_BODY) || '-}' || chr(3);
    END;
    
    -- Member procedures and functions
    CONSTRUCTOR FUNCTION T_MESSAGE_STRUCT_304_99
        RETURN SELF AS RESULT IS
    BEGIN RETURN; END;
END;
/
