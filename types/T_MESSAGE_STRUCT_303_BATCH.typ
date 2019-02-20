create or replace type T_MESSAGE_STRUCT_303_BATCH FORCE UNDER T_MESSAGE_STRUCT_BATCH
(
    OVERRIDING MEMBER PROCEDURE GENERATE_CONTENT,
    CONSTRUCTOR FUNCTION T_MESSAGE_STRUCT_303_BATCH(pobj_collection IN OUT NOCOPY t_interbankpayments_ext_col) RETURN SELF AS RESULT
) NOT FINAL
/
create or replace type body T_MESSAGE_STRUCT_303_BATCH IS
    
    OVERRIDING MEMBER PROCEDURE GENERATE_CONTENT IS
    BEGIN
        SELF.SOURCE_CONTENT := '<?xml version="1.0" encoding="UTF-8"?>' ||
                                            '<SWIFT_msg_fields>' ||
                                                '<msg_sender>' || SELF.GET_DEFAULT_BOB_SWIFT() || 'AXXX</msg_sender>' || 
                                                '<msg_receiver>' || SELF.GET_DEFAULT_CBAR_SWIFT() ||'</msg_receiver>' || 
                                                '<msg_type>150</msg_type>' ||
                                                '<msg_priority>N</msg_priority>' ||
                                                '<msg_del_notif_rq>N</msg_del_notif_rq>' ||
                                                '<msg_user_priority>0100</msg_user_priority>' ||
                                                '<msg_user_reference>' 
                                                    || SELF.obj_collection(SELF.obj_collection.first)
                                                            .get_attribute_val(const_interbankpayments.ATTR_BATCH_PAYMENT_NUM)
                                                                .value_int || 
                                                '</msg_user_reference>' ||
                                                '<msg_copy_srv_id/>' ||
                                                '<msg_fin_validation/>' ||
                                                '<msg_pde>N</msg_pde>' ||
                                                '<msg_amount>' || SELF.format_amount(SELF.GET_BATCH_AMOUNT_SUM()) || '</msg_amount>' ||
                                                '<msg_num_of_batches>' || SELF.obj_collection.count || '</msg_num_of_batches>' || 
                                                '<block4>' || 
                                                    '<batch>' || 
                                                        '<msg_subtype>102</msg_subtype>' || 
                                                        '<body>' || 
                                                            SELF.GENERATE_BODY || 
                                                        '</body>' || 
                                                    '</batch>' || 
                                                '</block4>' || 
                                            '</SWIFT_msg_fields>';
    END;

    CONSTRUCTOR FUNCTION T_MESSAGE_STRUCT_303_BATCH(pobj_collection IN OUT NOCOPY t_interbankpayments_ext_col) RETURN SELF AS RESULT IS 
        l_index INTEGER;
        l_b     bank_list%ROWTYPE;
    BEGIN 
        SELF.SET_COLLECTION(pobj_collection);
    RETURN; END;
end;
/
