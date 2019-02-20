create or replace procedure cbar_status_updater is
        CURSOR messages_cursor IS   SELECT  im.created_date,
                                            api_interbankpayments.getMessageTypeObject(i.id) msg
                                            FROM interbankpayments i
                                            JOIN interbankpayments_messages im ON im.payment_id = i.id
                                            WHERE im.created_date < SYSDATE-1/24/100
                                                  -- Признак пакетности и только родителей
                                                  AND (
                                                    i.state = const_interbankpayments.STATE_PROVIDER_SENT 
                                                    AND 
                                                    ( SELECT 1 
                                                      FROM TABLE(i.attrs) attribs 
                                                      WHERE  attribs.id_attr IN(const_interbankpayments.ATTR_IS_BATCH_PARENT_MSG) 
                                                      GROUP BY 1) = 1
                                                  )
                                                  OR 
                                                  -- Одиночные платежи
                                                  (
                                                    i.state = const_interbankpayments.STATE_PROVIDER_SENT 
                                                    AND 
                                                    not exists (SELECT attribs.id_attr 
                                                                FROM TABLE(i.attrs) attribs 
                                                                WHERE attribs.id_attr = const_interbankpayments.ATTR_BATCH_PAYMENT_NUM)
                                                  )
                                                  AND i.system_id = const_interbankpayments.PAYMENT_SYSTEM_ID_XOHKS;
                                            --GROUP BY i.id
                                            --for update skip locked;
        TYPE type_provaider_msg IS RECORD(
            created_date DATE,
            message      t_intbankpays_msg);
        TYPE type_provaider_msg_col IS TABLE OF type_provaider_msg;
        l_provaider_msg_col type_provaider_msg_col;
        l_col_index         INTEGER;
        l_temp              BOOLEAN;
        l_cur_msg           t_intbankpays_msg;
        l_resp              ext_serv.t_cbar_ppg_msg_response;
        l_msg_struct        t_message_struct;
        p_batch_num         NUMBER;
    BEGIN
        ibs.api_context.set_context(1, SYSDATE, 1);
        OPEN messages_cursor;
        loop
            fetch messages_cursor BULK COLLECT INTO l_provaider_msg_col;
            exit when messages_cursor%notfound;
        end loop;
        l_col_index := l_provaider_msg_col.FIRST;
        WHILE l_col_index IS NOT NULL
        LOOP
            BEGIN
                l_cur_msg := l_provaider_msg_col(l_col_index).message;
                /**
                @TODO Пока не проверяется каждый платеж в батче по отдельности, нужно на реальном примере глянуть и реализовать
                */
                p_batch_num := l_cur_msg.obj.get_attribute_val(const_interbankpayments.ATTR_BATCH_PAYMENT_NUM).value_int;
                l_resp := ext_serv.cbar_xohks.getMessageActualStatus(p_referense => nvl(p_batch_num, l_cur_msg.obj.reference),
                                                                     p_date => l_provaider_msg_col(l_col_index).created_date);
                -- Если нет ответа от сервиса считать, что платеж не найден у ЦБ
                IF l_resp.resp_status IS NULL THEN
                   
                   jui_interbankpayments_tools.set_batch_payments_status(l_cur_msg, const_interbankpayments.STATE_PROVIDER_NOTFOUND);
                   api_interbankpayments.add_payment_change(l_cur_msg.obj,
                                                         p_action => 'cbar_payments_status_updater',
                                                         p_additional => 'ЦБ вернул пустой результат');
                -- Если вернул предыдущий код
                ELSIF l_resp.resp_status = l_cur_msg.obj.get_attribute_val(const_interbankpayments.ATTR_CBAR_RESPONSE_STATUS).value_str THEN
                    api_interbankpayments.add_payment_change(l_cur_msg.obj,
                                                             p_action => 'cbar_payments_status_updater',
                                                             p_result => 'WAITING',
                                                             p_desc => 'ЦБ вернул то же самое значение',
                                                             p_additional => l_resp.resp_status);
                -- Если ответ один из ошибочных кодов
                ELSIF l_resp.resp_status MEMBER OF ext_serv.cbar_xohks.CBAR_XOHKS_ERROR_STATUSES THEN
                         api_interbankpayments.add_payment_change(l_cur_msg.obj,
                                                         p_action => 'cbar_payments_status_updater',
                                                         p_result => 'ERROR',
                                                         p_desc => l_resp.resp_block,
                                                         p_additional => l_resp.resp_status);
                         jui_interbankpayments_tools.set_batch_payments_status( l_cur_msg, 
                                                                                const_interbankpayments.STATE_PROVIDER_ERROR,
                                                                                l_resp.resp_error);
                         api_interbankpayments.update_payment_file_content(l_cur_msg.obj.id,
                                                                           p_provider_result => l_resp.resp_block);
                         
                -- Работы по платежу завершены
                ELSIF l_resp.resp_status MEMBER OF ext_serv.cbar_xohks.CBAR_XOHKS_SUCCESS_STATUS THEN
                        jui_interbankpayments_tools.set_batch_payments_status( l_cur_msg, 
                                                                                const_interbankpayments.STATE_COMPLETED,
                                                                                l_resp.resp_error);
                        l_cur_msg.obj.update_attr_val(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_CBAR_RESPONSE_STATUS,
                                                                      value_str => l_resp.resp_status,
                                                                      value_int => NULL));
                        api_interbankpayments.update_payment_file_content(l_cur_msg.obj.id,
                                                                          p_provider_result => l_resp.resp_block);
                                                                          
                        
                ELSIF l_resp.resp_status IS NOT NULL THEN
                     api_interbankpayments.add_payment_change(l_cur_msg.obj,
                                                         p_action => 'cbar_payments_status_updater',
                                                         p_additional => 'ЦБ вернул результат ' || l_resp.resp_block);
                     l_cur_msg.obj.update_attr_val(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_CBAR_RESPONSE_STATUS,
                                                                      value_str => l_resp.resp_status,
                                                                      value_int => NULL));
                END IF;
                --l_cur_msg.obj.update_payment;
                l_col_index := l_provaider_msg_col.NEXT(l_col_index);
            EXCEPTION WHEN OTHERS THEN
                l_col_index := l_provaider_msg_col.NEXT(l_col_index);
                IF l_cur_msg.obj IS NOT NULL THEN
                    api_interbankpayments.add_payment_change(mobj => l_cur_msg.obj,
                                   p_action => 'cbar_payments_status_updater',
                                   p_autonomus => TRUE,
                                   p_result => 'ERROR',
                                   p_desc => SQLERRM || '',
                                   p_additional => dbms_utility.format_error_backtrace);
                ELSE dbms_output.put_line(SQLERRM);
                END IF;
            END;
            l_cur_msg.obj.update_payment;
        END LOOP;
        COMMIT;
        --ROLLBACK;
    END cbar_status_updater;
/
