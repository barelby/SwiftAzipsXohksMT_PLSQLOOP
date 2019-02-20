create or replace procedure CBAR_PAYMENT_QUEE_SENDER IS
    CURSOR messages_cursor IS   SELECT  id
                                        FROM interbankpayments i 
                                        WHERE -- Признак пакетности и только родителей
                                              (
                                                i.state = const_interbankpayments.STATE_PROVIDER_IN_QUEEE 
                                                AND 
                                                ( SELECT 1 
                                                  FROM TABLE(i.attrs) attribs 
                                                  WHERE  attribs.id_attr IN(const_interbankpayments.ATTR_IS_BATCH_PARENT_MSG) 
                                                  GROUP BY 1) = 1
                                              )
                                              OR 
                                              -- Одиночные платежи
                                              (
                                                i.state = const_interbankpayments.STATE_PROVIDER_IN_QUEEE 
                                                AND 
                                                not exists (SELECT attribs.id_attr 
                                                            FROM TABLE(i.attrs) attribs 
                                                            WHERE attribs.id_attr = const_interbankpayments.ATTR_BATCH_PAYMENT_NUM)
                                              )
                                              AND i.system_id = const_interbankpayments.PAYMENT_SYSTEM_ID_XOHKS
                                              for update skip locked;
    l_result CLOB;
BEGIN
    ibs.api_context.set_context(1, SYSDATE, 1);
    FOR l_fetched in messages_cursor
    LOOP
        BEGIN
            dbms_output.put_line('Payment id: ' || l_fetched.id);
            l_result := jui_interbankpayments_tools.send_cbar_xohks_payment(l_fetched.id);
        EXCEPTION WHEN OTHERS THEN 
            dbms_output.put_line(dbms_utility.format_error_backtrace);
            ibs.logger.log(p_procedure_name => 'IPAY.CBAR_PAYMENT_QUEE_SENDER',
                         p_log_message => dbms_utility.format_error_backtrace);
        END;
    END LOOP;
    COMMIT;
end CBAR_PAYMENT_QUEE_SENDER;
/
