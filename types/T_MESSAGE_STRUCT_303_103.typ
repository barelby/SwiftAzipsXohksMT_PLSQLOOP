create or replace type T_MESSAGE_STRUCT_303_103 FORCE UNDER T_MESSAGE_STRUCT_303
(
    OVERRIDING MEMBER FUNCTION tag_50k  RETURN VARCHAR2,
    OVERRIDING MEMBER FUNCTION tag_21   RETURN VARCHAR2,
    OVERRIDING MEMBER FUNCTION tag_72   RETURN VARCHAR2,
    
    OVERRIDING MEMBER FUNCTION GENERATE_BODY(SELF IN OUT T_MESSAGE_STRUCT_303_103)            RETURN VARCHAR2,
    CONSTRUCTOR FUNCTION T_MESSAGE_STRUCT_303_103 RETURN SELF AS RESULT
) NOT FINAL
/
create or replace type body T_MESSAGE_STRUCT_303_103 IS
	
    OVERRIDING MEMBER FUNCTION tag_50k RETURN VARCHAR2 IS 
    BEGIN
         RETURN ':50K:/' || obj.PAYER_IBAN_ACCOUNT || SELF.tag_ln || 
                    substr(obj.PAYER_NAME,1,35) || SELF.tag_ln || 
                    obj.PAYER_TAX_NUMBER || '/' ||  SELF.tag_ln || 
                    obj.EMITENT_BANK_CODE || '/' ||  obj.EMITENT_BANK_TAX || SELF.tag_ln || 
                    obj.EMITENT_BANK_CORR_ACCOUNT;
    end;
    
    OVERRIDING MEMBER FUNCTION tag_21  RETURN VARCHAR2 IS 
    BEGIN RETURN ':21:' || SELF.obj.REFERENCE; END;
    /****************************************** OVERRIDINGS ******************************************/
    OVERRIDING MEMBER FUNCTION GENERATE_BODY(SELF IN OUT T_MESSAGE_STRUCT_303_103) RETURN VARCHAR2 IS 
    BEGIN
        RETURN  SELF.smart_ln(SELF.tag_20)  || SELF.smart_ln(SELF.tag_23)  || 
                SELF.smart_ln(SELF.tag_52a) || SELF.smart_ln(SELF.tag_21)  || 
                SELF.smart_ln(SELF.tag_32b) || SELF.smart_ln(SELF.tag_50k) ||
                SELF.smart_ln(SELF.tag_57a) || SELF.smart_ln(SELF.tag_59)  || 
                SELF.smart_ln(SELF.tag_70)  || SELF.smart_ln(SELF.tag_26t) || 
                SELF.smart_ln(SELF.tag_77b) || SELF.smart_ln(SELF.tag_32a) || 
                tag_72;
    END;

    OVERRIDING MEMBER FUNCTION tag_72 RETURN VARCHAR2 IS
    BEGIN 
        RETURN ':72:/BNF/1';
    END;
    -- Member procedures and functions
    CONSTRUCTOR FUNCTION T_MESSAGE_STRUCT_303_103 RETURN SELF AS RESULT 
    IS BEGIN RETURN; END;
end;
/
