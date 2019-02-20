create or replace type T_MESSAGE_STRUCT_303 FORCE UNDER T_MESSAGE_STRUCT
(
    --OVERRIDING MEMBER FUNCTION tag_57a RETURN VARCHAR2,
    OVERRIDING MEMBER FUNCTION tag_23  RETURN VARCHAR2,
    OVERRIDING MEMBER PROCEDURE GENERATE_CONTENT,
    CONSTRUCTOR FUNCTION T_MESSAGE_STRUCT_303 RETURN SELF AS RESULT
) NOT FINAL
/
create or replace type body T_MESSAGE_STRUCT_303 IS
    OVERRIDING MEMBER FUNCTION tag_23  RETURN VARCHAR2 IS
        attr_budget_level VARCHAR2(250) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_BUDGET_LEVEL).value_str;
        attr_budget_dest  VARCHAR2(250) DEFAULT SELF.obj.get_attribute_val(const_interbankpayments.ATTR_BUDGET_DESTINATION).value_str; 
    BEGIN 
        IF SELF.obj.BENEFICIAR_BANK_SWIFT = 'XXXXXXXX2' AND (attr_budget_level IS NOT NULL AND attr_budget_dest IS NOT NULL)
            THEN RETURN ':23:TREZ'; 
        ELSE RETURN (SELF AS T_MESSAGE_STRUCT).tag_23;
        END IF;
    END;
    OVERRIDING MEMBER PROCEDURE GENERATE_CONTENT IS
    BEGIN
        SELF.SOURCE_CONTENT := '<?xml version="1.0" encoding="UTF-8"?>' ||
                                            '<SWIFT_msg_fields>' ||
                                                '<msg_sender>' || SELF.GET_DEFAULT_BOB_SWIFT() || 'AXXX</msg_sender>' ||
                                                '<msg_receiver>' || SELF.GET_DEFAULT_CBAR_SWIFT() ||'</msg_receiver>' || 
                                                '<msg_user_reference>'|| SELF.OBJ.REFERENCE ||'</msg_user_reference>' ||
                                                '<msg_type>150</msg_type>'||
                                                '<msg_num_of_batches>1</msg_num_of_batches>' || 
                                                '<msg_amount>' || SELF.format_amount(SELF.OBJ.AMOUNT) || '</msg_amount>' || 
                                            '<block4><batch><body>' || SELF.GENERATE_BODY || '</body></batch></block4></SWIFT_msg_fields>';
    END;

    -- Member procedures and functions
    CONSTRUCTOR FUNCTION T_MESSAGE_STRUCT_303 RETURN SELF AS RESULT 
    IS BEGIN RETURN; END;
end;
/
