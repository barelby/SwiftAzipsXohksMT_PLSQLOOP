create or replace type T_MESSAGE_STRUCT_304_103 FORCE UNDER T_MESSAGE_STRUCT_304
(
    OVERRIDING MEMBER FUNCTION tag_59_get_bank_swift RETURN VARCHAR2,
   -- OVERRIDING MEMBER FUNCTION tag_72 RETURN VARCHAR2,
    OVERRIDING MEMBER FUNCTION GENERATE_BODY(SELF IN OUT T_MESSAGE_STRUCT_304_103) RETURN VARCHAR2,
    CONSTRUCTOR FUNCTION T_MESSAGE_STRUCT_304_103 RETURN SELF AS RESULT
) NOT FINAL
/
create or replace type body T_MESSAGE_STRUCT_304_103 IS

    /****************************************** OVERRIDINGS ******************************************/
    
    OVERRIDING MEMBER FUNCTION tag_59_get_bank_swift RETURN VARCHAR2 IS
    BEGIN
        RETURN '/' || obj.BENEFICIAR_BANK_SWIFT || 'XXX';
    END;

    OVERRIDING MEMBER FUNCTION GENERATE_BODY(SELF IN OUT T_MESSAGE_STRUCT_304_103) RETURN VARCHAR2 IS 
        attr_add_info t_intbankpays_attr DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_ADDITIONAL_INFO);
    BEGIN
        RETURN  SELF.smart_ln(SELF.tag_20)  || SELF.smart_ln(SELF.tag_23b) || SELF.smart_ln(SELF.tag_32a) ||
                SELF.smart_ln(SELF.tag_50k) || SELF.smart_ln(SELF.tag_59)  || SELF.smart_ln(SELF.tag_70)  ||
                SELF.tag_71a || 
                CASE WHEN attr_add_info.value_str IS NOT NULL OR LENGTH(TRIM(attr_add_info.value_str)) > 0 THEN
                    SELF.tag_ln || SELF.tag_72
                    ELSE ''
                END;
    END;

    -- Member procedures and functions
    CONSTRUCTOR FUNCTION T_MESSAGE_STRUCT_304_103 RETURN SELF AS RESULT 
    IS BEGIN RETURN; END;
end;
/
