create or replace type T_MESSAGE_STRUCT_304_205 FORCE UNDER T_MESSAGE_STRUCT_304
(
    OVERRIDING MEMBER FUNCTION tag_59_get_bank_swift RETURN VARCHAR2,
    OVERRIDING MEMBER FUNCTION tag_72 RETURN VARCHAR2,
    OVERRIDING MEMBER FUNCTION GENERATE_BODY(SELF IN OUT T_MESSAGE_STRUCT_304_205) RETURN VARCHAR2,
    CONSTRUCTOR FUNCTION T_MESSAGE_STRUCT_304_205 RETURN SELF AS RESULT
) NOT FINAL
/
create or replace type body T_MESSAGE_STRUCT_304_205 IS

    /****************************************** OVERRIDINGS ******************************************/
    
    OVERRIDING MEMBER FUNCTION tag_59_get_bank_swift RETURN VARCHAR2 IS
    BEGIN
        RETURN '/' || obj.BENEFICIAR_BANK_SWIFT || 'XXX';
    END;
    
    OVERRIDING MEMBER FUNCTION tag_72 RETURN VARCHAR2 IS
        attr_add_info t_intbankpays_attr DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_ADDITIONAL_INFO);
        work_text  varchar2(220 char);
    BEGIN 
        RETURN  ':72:' || SELF.obj.GROUND;
    END;

    OVERRIDING MEMBER FUNCTION GENERATE_BODY(SELF IN OUT T_MESSAGE_STRUCT_304_205) RETURN VARCHAR2 IS 
    BEGIN
        RETURN  SELF.smart_ln(SELF.tag_20) 
                || SELF.smart_ln(SELF.tag_21)
                || SELF.smart_ln(SELF.tag_32a) 
                || SELF.smart_ln(SELF.tag_52d) 
                || SELF.smart_ln(SELF.tag_58d) 
                || SELF.tag_72;
    END;

    -- Member procedures and functions
    CONSTRUCTOR FUNCTION T_MESSAGE_STRUCT_304_205 RETURN SELF AS RESULT 
    IS BEGIN RETURN; END;
end;
/
