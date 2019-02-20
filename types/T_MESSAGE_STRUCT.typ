create or replace type T_MESSAGE_STRUCT FORCE as object
(
    -- Author  : RVKHALAFOV
    -- Created : 7/13/2016 20:52:33
    -- Super class of all messages types
    -- Purpose :
              
    -- Attributes
    obj                                                                           t_interbankpayments_extend,
    SOURCE_CONTENT                                                                CLOB,
    TRANSPORT_RESULT                                                              VARCHAR2(4000),
    STRUCT_IDENTIFER                                                              VARCHAR2(100),

    --- STRUCTURE MEMBERS
    MEMBER FUNCTION tag_ln                                                        RETURN VARCHAR2,
    MEMBER FUNCTION tag_20                                                        RETURN VARCHAR2,
    MEMBER FUNCTION tag_21                                                        RETURN VARCHAR2,
    MEMBER FUNCTION tag_23                                                        RETURN VARCHAR2,
    MEMBER FUNCTION tag_23b                                                       RETURN VARCHAR2,
    MEMBER FUNCTION tag_26t                                                       RETURN VARCHAR2,
    MEMBER FUNCTION tag_32a                                                       RETURN VARCHAR2,
    MEMBER FUNCTION tag_32b                                                       RETURN VARCHAR2,
    MEMBER FUNCTION tag_50k                                                       RETURN VARCHAR2,
    MEMBER FUNCTION tag_52a                                                       RETURN VARCHAR2,
    MEMBER FUNCTION tag_52d                                                       RETURN VARCHAR2,
    MEMBER FUNCTION tag_57a                                                       RETURN VARCHAR2,
    MEMBER FUNCTION tag_58d                                                       RETURN VARCHAR2,
    MEMBER FUNCTION tag_59                                                        RETURN VARCHAR2,
    MEMBER FUNCTION tag_59_get_bank_swift                                         RETURN VARCHAR2,
    MEMBER FUNCTION tag_70                                                        RETURN VARCHAR2,
    MEMBER FUNCTION tag_71a                                                       RETURN VARCHAR2,
    MEMBER FUNCTION tag_77b                                                       RETURN VARCHAR2,
    MEMBER FUNCTION tag_72                                                        RETURN VARCHAR2,
    MEMBER FUNCTION tag_72_looper(p_work_text       VARCHAR2, 
                                  p_lines           NUMBER DEFAULT 6, 
                                  p_char_per_line   NUMBER DEFAULT 35)            RETURN VARCHAR2,
    -- Utilities
    MEMBER FUNCTION format_amount(amount number)                                  RETURN VARCHAR2,
    MEMBER FUNCTION smart_ln(text VARCHAR2)                                       RETURN VARCHAR2,
    
    -- ������������� ��� ������� ���������. ������������, � �������, ��� �������� ������.
    MEMBER FUNCTION GENERATE_STRUCT_IDENTIFER                                     RETURN VARCHAR2,
    
    MEMBER FUNCTION GENERATE_BODY(SELF IN OUT T_MESSAGE_STRUCT)                   RETURN VARCHAR2,
    
    -- ��������� �������� � ����
    MEMBER PROCEDURE UPDATE_ON_DB(l_result CLOB, p_sent_date DATE DEFAULT SYSDATE),
    MEMBER PROCEDURE UPDATE_FILE_SOURCE_CONTENT (p_source_content CLOB),
    -- ���������� ���������� ���������
    MEMBER PROCEDURE GENERATE_CONTENT,
       
    -- �������������� ������ ����������
    MEMBER FUNCTION TRANSPORTER_TO_PROVIDER(SELF IN OUT T_MESSAGE_STRUCT)RETURN CLOB,
    
    MEMBER FUNCTION GET_DEFAULT_CBAR_SWIFT RETURN VARCHAR2,
    
    MEMBER FUNCTION GET_DEFAULT_BOB_SWIFT RETURN VARCHAR2,
    /************************************* DEFAULT TO FILE METHODS ************************************/
    -- �������������� ��������� � ����
    MEMBER PROCEDURE TRANSPORTER_TO_FILE, 
    -- ��� �����
    MEMBER FUNCTION GET_FILE_NAME RETURN VARCHAR2,
    -- ���������� �����
    MEMBER FUNCTION GET_FILE_EXTENSION RETURN VARCHAR2,
    -- ����� ��� ����������
    MEMBER FUNCTION GET_FILE_DIR RETURN VARCHAR2,
    -- ��������. ���������� true - ���� ��������� ������ ���� ��������� � �������.
    MEMBER FUNCTION COMPLETE(SELF IN OUT T_MESSAGE_STRUCT) RETURN BOOLEAN,
    
    MEMBER PROCEDURE SET_OBJ(pobj IN OUT NOCOPY t_interbankpayments_extend),
    
    
    MEMBER PROCEDURE init(pobj IN OUT NOCOPY t_interbankpayments_extend),
    -- Member functions and procedures
    CONSTRUCTOR FUNCTION T_MESSAGE_STRUCT/*(pobj IN OUT NOCOPY 
                                          t_interbankpayments_extend)*/ RETURN SELF AS RESULT
) NOT FINAL
/
create or replace type body T_MESSAGE_STRUCT IS

    /********************************************* TAGS ***********************************************/  
    MEMBER FUNCTION tag_ln  RETURN VARCHAR2 IS BEGIN RETURN chr(13) || chr(10);end;
    MEMBER FUNCTION tag_20  RETURN VARCHAR2 IS BEGIN RETURN ':20:' || obj.REFERENCE; end;
    MEMBER FUNCTION tag_21  RETURN VARCHAR2 IS 
        attr_linked_ref t_intbankpays_attr DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_LINKED_REFERENCE); 
    BEGIN 
        RETURN ':21:' || CASE WHEN attr_linked_ref IS NULL THEN 'NONE'
                              ELSE attr_linked_ref.VALUE_STR
                         END;
    END;
    MEMBER FUNCTION tag_23  RETURN VARCHAR2 IS BEGIN RETURN ':23:CREDIT'; END;
    MEMBER FUNCTION tag_23b RETURN VARCHAR2 IS BEGIN RETURN ':23B:CRED';  END;
    MEMBER FUNCTION tag_26t RETURN VARCHAR2 IS BEGIN RETURN ':26T:900';   END;
    
    MEMBER FUNCTION tag_70  RETURN VARCHAR2 IS
        result_str varchar2(150 char);
        lines_left NUMBER DEFAULT 4;
        line_size  NUMBER DEFAULT 35;
        work_text  varchar2(150 char) DEFAULT TRIM(TRAILING chr(10) FROM TRIM(TRAILING chr(13) FROM SELF.obj.GROUND));
        attr_budget_level VARCHAR2(250) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_BUDGET_LEVEL).value_str;
        attr_budget_dest  VARCHAR2(250) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_BUDGET_DESTINATION).value_str;
    BEGIN 
        IF attr_budget_level IS NOT NULL AND attr_budget_dest IS NOT NULL THEN
            result_str := attr_budget_level || tag_ln || attr_budget_dest || tag_ln;
            lines_left := 2;
        END IF;
        return ':70:' || result_str || SELF.obj.GROUND;
    END;
    
    MEMBER FUNCTION tag_71a RETURN VARCHAR2 IS BEGIN RETURN ':71A:OUR';   END;
    
    MEMBER FUNCTION tag_32a RETURN VARCHAR2 IS
    begin
        return ':32A:' || to_char(obj.PAYMENT_DATE, 'YYMMDD') || 
                          obj.CURRENCY_CODE || 
                          format_amount(obj.AMOUNT);
    end;

    MEMBER FUNCTION tag_32b RETURN VARCHAR2 IS
    BEGIN
        return ':32B:' || obj.CURRENCY_CODE || format_amount(obj.AMOUNT);
    END;

    MEMBER FUNCTION tag_50k RETURN VARCHAR2 IS 
    BEGIN
         RETURN ':50K:/' || obj.PAYER_IBAN_ACCOUNT || tag_ln || 
                    substr(obj.PAYER_NAME, 1,35) || tag_ln || 
                    obj.PAYER_TAX_NUMBER || '/' ||  tag_ln || 
                        obj.EMITENT_BANK_CODE || '/' ||  
                        obj.EMITENT_BANK_TAX || '/' || 
                        obj.EMITENT_BANK_SWIFT || 
                        CASE 
                            WHEN  obj.MESSAGE_TYPE = const_interbankpayments.PAYMENT_SYSTEM_ID_NPS THEN 'XXX'
                            ELSE '' 
                        END
                        || tag_ln || obj.EMITENT_BANK_CORR_ACCOUNT;                                                    
    end;

    member function tag_52a return varchar2 is
    begin
        return ':52A:/D/' || obj.EMITENT_BANK_S_CORR_ACC || tag_ln || obj.EMITENT_BANK_SWIFT;
    end;

    member function tag_52d return varchar2 is
    begin
        return ':52D:/' || obj.EMITENT_BANK_CODE || tag_ln || 
                           obj.EMITENT_BANK_NAME || tag_ln || 
                           obj.EMITENT_BANK_CORR_ACCOUNT || tag_ln || 
                           obj.EMITENT_BANK_TAX || tag_ln || 
                           obj.EMITENT_BANK_SWIFT || 'XXX';
    end;
    
    member function tag_58d return varchar2 is
    begin
        return ':58D:/' ||  obj.BENEFICIAR_BANK_CODE || tag_ln || 
                            obj.BENEFICIAR_BANK_NAME || tag_ln || 
                            obj.BENEFICIAR_BANK_CORR_ACCOUNT || tag_ln || 
                            obj.BENEFICIAR_BANK_TAX || tag_ln || 
                            obj.BENEFICIAR_BANK_SWIFT || 'XXX';
    end;

    MEMBER FUNCTION tag_57a RETURN VARCHAR2 IS 
    BEGIN
    RETURN ':57A:/C/' || obj.BENEFICIAR_BANK_S_CORR_ACC || tag_ln || obj.BENEFICIAR_BANK_SWIFT;    
    END;

    MEMBER FUNCTION tag_59 RETURN VARCHAR2 IS
       l_bn_swift   VARCHAR2(100);
       l_bn_coreacc VARCHAR2(100);
       l_receiver_name VARCHAR2(200);
    BEGIN
        l_receiver_name:= TRIM(TRAILING chr(10) FROM TRIM(TRAILING chr(13) FROM obj.RECEIVER_NAME));
        IF obj.BENEFICIAR_BANK_SWIFT IN('XXXXXXXX','XXXXXXXX','XXXXXXXX', 'XXXXXXXX','XXXXXXXX','XXXXXXXX') THEN
            l_bn_coreacc:='AXXXXXXXX0000001944';
            l_bn_swift:='NABZAZ2C';
        ELSE
            l_bn_swift:= obj.BENEFICIAR_BANK_SWIFT;
            l_bn_coreacc:=obj.BENEFICIAR_BANK_CORR_ACCOUNT;
        END IF;
        
        RETURN ':59:/' || trim(obj.RECEIVER_IBAN) || tag_ln || 
                       substr(obj.RECEIVER_NAME,1,35) || tag_ln || 
                       obj.RECEIVER_TAX || '/' || tag_ln || 
                            obj.BENEFICIAR_BANK_CODE || '/' || 
                            obj.BENEFICIAR_BANK_TAX || tag_59_get_bank_swift() || tag_ln || 
                            l_bn_coreacc;
    END;
    
    MEMBER FUNCTION tag_59_get_bank_swift RETURN VARCHAR2 IS
    BEGIN
        RETURN '';
    END;

    MEMBER FUNCTION tag_77b RETURN VARCHAR2 IS 
        attr_add_inf  t_intbankpays_attr DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_ADDITIONAL_INFO);
        result_str  VARCHAR2(150 CHAR);
        lines_left  NUMBER DEFAULT 3;
        line_size   NUMBER DEFAULT 34;
        work_text   VARCHAR2(150 CHAR) DEFAULT attr_add_inf.value_str;
    BEGIN 
        IF attr_add_inf.value_str IS NOT NULL AND LENGTH(attr_add_inf.value_str) > 0 THEN
            RETURN ':77B:' || attr_add_inf.value_str;
        ELSE RETURN NULL;
        END IF;
    END;
    
    MEMBER FUNCTION tag_72 RETURN VARCHAR2 IS
        l_var VARCHAR2(5000) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_ADDITIONAL_INFO).value_str;
    BEGIN 
        RETURN CASE WHEN l_var IS NOT NULL THEN  ':72:' || l_var ELSE NULL END;
    END;
    
    MEMBER FUNCTION tag_72_looper(p_work_text       VARCHAR2, 
                                  p_lines           NUMBER DEFAULT 6, 
                                  p_char_per_line   NUMBER DEFAULT 35) RETURN VARCHAR2 IS
        result_str      VARCHAR2(220 CHAR) DEFAULT NULL;
        lines_left      NUMBER DEFAULT p_lines;
        line_size       NUMBER DEFAULT p_char_per_line;
        work_text       VARCHAR(2000) DEFAULT p_work_text;
        new_line_index  number(3);
    BEGIN
        LOOP EXIT WHEN lines_left = 0 OR work_text IS NULL;
            new_line_index:= instr(work_text,'///');
            
            IF new_line_index BETWEEN 32 AND 35 THEN line_size:=new_line_index-1;
            ELSIF length(work_text)<35 THEN line_size:=length(work_text);
            ELSE line_size:=35;
            END IF;
             
            IF instr(substr(work_text, 1, line_size),'/////')>0 THEN
                work_text:= replace(replace(substr(work_text, 1, line_size),CHR(10),''),CHR(13),'');
            END IF;
            
            IF instr(substr(work_text, 1, line_size),'///')>0 AND new_line_index<35 THEN
                result_str := result_str || substr(work_text, 1, instr(substr(work_text, 1, line_size),'///')-1);
                work_text  :=  substr(TRIM(BOTH ' ' FROM work_text), new_line_index +1);
                
                IF work_text IS NOT NULL THEN
                    work_text := chr(13)||chr(10) || '//' || substr(work_text,3,line_size);
                END IF;
                lines_left := lines_left - 1;
            ELSE
                result_str := result_str || substr(work_text, 1, line_size);
                work_text  :=  substr(TRIM(BOTH ' ' FROM work_text), line_size + 1);

                IF work_text IS NOT NULL AND new_line_index<>36 THEN
                    work_text :=  chr(13)||chr(10)  || '//' || work_text;
                END IF;
                lines_left := lines_left - 1;
            END IF;
        END LOOP;
        RETURN result_str;
    END;
    /****************************************** GENERATORS ******************************************/
    MEMBER FUNCTION GENERATE_BODY(SELF IN OUT T_MESSAGE_STRUCT) RETURN VARCHAR2 IS 
    BEGIN RETURN ' '; END;
    
    MEMBER PROCEDURE GENERATE_CONTENT IS 
    BEGIN SELF.SOURCE_CONTENT := SELF.GENERATE_BODY(); END;

    MEMBER FUNCTION TRANSPORTER_TO_PROVIDER(SELF IN OUT T_MESSAGE_STRUCT) RETURN CLOB IS 
    BEGIN SELF.transporter_to_file; RETURN NULL; END;
    
    
    MEMBER PROCEDURE UPDATE_FILE_SOURCE_CONTENT (p_source_content CLOB) IS
    BEGIN
        UPDATE interbankpayments_messages im 
        SET im.source_content = p_source_content
        WHERE im.payment_id = SELF.obj.ID;
    END;
    
    MEMBER FUNCTION COMPLETE(SELF IN OUT T_MESSAGE_STRUCT)  RETURN BOOLEAN IS 
        l_result    CLOB DEFAULT NULL;
        l_date      DATE DEFAULT SYSDATE;
    BEGIN 
        GENERATE_CONTENT;
        UPDATE_ON_DB(l_result, l_date);
        RETURN TRUE;
    END;
    
    MEMBER FUNCTION GENERATE_STRUCT_IDENTIFER RETURN VARCHAR2 IS
    BEGIN RETURN  to_char(SELF.obj.ID, 'FM000000') || '_' || to_char(SYSDATE, 'YYMMDDHH24MISS'); END;
    
    /************************************* DEFAULT TO FILE METHODS ************************************/
    MEMBER PROCEDURE TRANSPORTER_TO_FILE IS  
    BEGIN dbms_xslprocessor.clob2file(SOURCE_CONTENT, GET_FILE_DIR, GET_FILE_NAME); END;

    MEMBER FUNCTION GET_FILE_NAME RETURN VARCHAR2 IS BEGIN RETURN GENERATE_STRUCT_IDENTIFER() || GET_FILE_EXTENSION();  END;
    MEMBER FUNCTION GET_FILE_EXTENSION RETURN VARCHAR2 IS BEGIN RETURN '.payment'; END;
    MEMBER FUNCTION GET_FILE_DIR RETURN VARCHAR2 IS BEGIN RETURN 'PAYMENT_DIR'; END;

    /********************************************* SQL ***********************************************/
    MEMBER PROCEDURE UPDATE_ON_DB(l_result CLOB, p_sent_date DATE DEFAULT SYSDATE) IS
        l_send_date DATE DEFAULT nvl(p_sent_date, SYSDATE);
    BEGIN 
        merge into INTERBANKPAYMENTS_MESSAGES m using dual on (m.PAYMENT_ID = SELF.obj.ID)
        when not matched then insert values (SELF.obj.ID, SELF.SOURCE_CONTENT, l_send_date, NULL)
        when matched then update set   m.source_content = SELF.SOURCE_CONTENT,
                                       m.provider_result = l_result,
                                       m.created_date = l_send_date;
    END;

    /******************************************** Utils ***********************************************/
    MEMBER FUNCTION format_amount(amount number) RETURN VARCHAR2 IS
    BEGIN RETURN REPLACE(TRIM(to_char(amount, '999999999990.90')), '.', ','); END;
    
    MEMBER FUNCTION smart_ln(text VARCHAR2) RETURN VARCHAR2 IS
    BEGIN RETURN text || CASE WHEN text IS NOT NULL THEN tag_ln ELSE NULL END; END;
    
    MEMBER PROCEDURE init(pobj IN OUT NOCOPY t_interbankpayments_extend) IS
        l_b bank_list%ROWTYPE;
    BEGIN
        SELF.obj := pobj;
        l_b := JUI_INTERBANKPAYMENTS_TOOLS.FIND_IN_BANKS_LIST_BY_BIK(SELF.obj.BENEFICIAR_BANK_CODE);
        SELF.STRUCT_IDENTIFER :=  GENERATE_STRUCT_IDENTIFER;
        SELF.obj.PAYER_NAME := SUBSTR(REPLACE(regexp_replace(api_interbankpayments.translit_to_swift(upper(trim(pobj.PAYER_NAME))),
                                              api_interbankpayments.as_swift_charset('x'),
                                              ''),'"',''), 0, 35);
                                              
        SELF.obj.BENEFICIAR_BANK_NAME := SUBSTR(SELF.obj.BENEFICIAR_BANK_NAME, 0, 35);
        SELF.obj.EMITENT_BANK_NAME := SUBSTR(SELF.obj.EMITENT_BANK_NAME, 0, 35);
        SELF.obj.RECEIVER_NAME := SUBSTR(SELF.obj.RECEIVER_NAME, 0, 35);

        SELF.obj.EMITENT_BANK_S_CORR_ACC := ibs.api_attribute.get_str_attribute_value(ibs.api_object.get_object_id(ibs.const_subject.OUR_BANK_CODE, 
                                                                                                                      ibs.const_subject.CODE_KIND_CODE), 
                                                                                      ibs.const_subject.ATR_BANK_CORRESP_SUB_ACCOUNT);
        SELF.obj.BENEFICIAR_BANK_S_CORR_ACC := l_b.corr_sub;
        --SELF.obj.GROUND := REPLACE(SELF.obj.GROUND, '\r\n', SELF.tag_ln);
    END;
    
    /*--Test
    MEMBER FUNCTION GET_DEFAULT_CBAR_SWIFT RETURN VARCHAR2 IS
    BEGIN RETURN 'NABZAZ2XXXXX'; END;
    
    MEMBER FUNCTION GET_DEFAULT_BOB_SWIFT RETURN VARCHAR2 IS
    BEGIN RETURN 'JBBKAZ20'; END;
    */
    
    --Production
    MEMBER FUNCTION GET_DEFAULT_CBAR_SWIFT RETURN VARCHAR2 IS
    BEGIN RETURN 'NABZAZ2CXBCS';
        --'NABZAZ2CXRTSN'*//*'NABZAZ2XXXXX' 
    END;
    
    MEMBER FUNCTION GET_DEFAULT_BOB_SWIFT RETURN VARCHAR2 IS
    BEGIN RETURN 'JBBKAZ22'; END;
    
    MEMBER PROCEDURE SET_OBJ(pobj IN OUT NOCOPY t_interbankpayments_extend) IS
    BEGIN init(pobj); END;
    
    
    /****************************************** Constructors ******************************************/
    CONSTRUCTOR FUNCTION T_MESSAGE_STRUCT/*(pobj IN OUT NOCOPY t_interbankpayments_extend)*/ RETURN SELF AS RESULT 
    IS BEGIN 
        --init(pobj);
        RETURN; 
    END;
    
end;
/
