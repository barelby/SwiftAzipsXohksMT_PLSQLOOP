create or replace procedure copy_to_ibsres(p_date DATE DEFAULT NULL) is
  l_cur_id  integer;
  l_context ibs.context_value%rowtype;
  l_sername VARCHAR(100);
begin
  l_sername := SYS_CONTEXT('USERENV','SERVER_HOST');
  
  IF l_sername <> 'orasrv2' THEN
      raise_application_error(-20000, 'Копирование на резерв нужно запускать только с резерва!');
  END IF;

  -- Test statements here
  FOR recur IN (SELECT  id,
                        reference,
                        state,
                        payment_date,
                        system_id,
                        message_type,
                        amount,
                        currency,
                        ibs.t_fee_amount_collection() fee_collection,
                        ground,
                        NULL operation_id,
                        payer_branch_id,
                        payer_account,
                        receiver_name,
                        receiver_iban,
                        receiver_tax,
                        emitent_bank_code,
                        emitent_bank_corr_account,
                        beneficiar_bank_name,
                        beneficiar_bank_code,
                        beneficiar_bank_swift,
                        beneficiar_bank_tax,
                        beneficiar_bank_corr_account,
                        context_id,
                        creator_id,
                        ipay.t_intbankpays_state_collection() state_history,
                        ipay.t_intbankpays_attr_collection() attrs,
                        ipay.t_intbankpays_changes_col() changes,
                        creation_date
                        FROM ipay.interbankpayments@ibsdb_1 ibp
                        WHERE NOT EXISTS (SELECT NULL FROM ipay.interbankpayments s WHERE s.reference = ibp.reference) AND
                              (ibp.creation_date = TRUNC(p_date) OR p_date IS NULL))
  LOOP
      BEGIN
         dbms_output.put_line('ID ' || recur.id || ' - ' || recur.payment_date);
          
          -- Coping attributes
         SELECT ipay.t_intbankpays_attr(id_attr => v.id_attr,
                                         value_str => v.value_str,
                                         value_int => v.value_int) BULK COLLECT INTO recur.attrs
         FROM ipay.v_interbankpayments_attrscol@ibsdb_1 v
         WHERE v.payment_id = recur.id;

          -- Coping states history
         SELECT ipay.t_intbankpays_state(STATE => v.STATE,
                                          CHANGE_DATE => v.CHANGE_DATE,
                                          USER_ID => v.USER_ID) BULK COLLECT INTO recur.state_history
         FROM ipay.v_interbankpayments_statescol@ibsdb_1 v
         WHERE v.payment_id = recur.id;
          -- Coping changes
         SELECT ipay.t_intbankpays_changes(change_date => v.change_date,
                                            change_initiator => v.change_initiator,
                                            change_desc => v.change_desc,
                                            change_action => v.change_action,
                                            change_result => v.change_result,
                                            change_additional => v.change_additional) BULK COLLECT INTO recur.changes
         FROM ipay.v_interbankpayments_changescol@ibsdb_1 v
         WHERE v.payment_id = recur.id;

         recur.id := NULL;
         l_cur_id := ipay.interbankspayments_seq.nextval@ibsdb_1;
          
         l_context := ibs.api_context.read_context_value@ibsdb_1(recur.context_id); 
         ibs.api_context.set_context(l_context.USER_ID, TRUNC(SYSDATE), l_context.BRANCH_ID);
         recur.context_id := ibs.api_context.get_context_value_id(l_context.USER_ID, TRUNC(SYSDATE), l_context.BRANCH_ID);
         
         merge into ipay.interbankpayments m using dual on (m.reference = recur.reference)
         when not matched then insert ( id,
                                        reference,
                                        state,
                                        payment_date,
                                        system_id,
                                        message_type,
                                        amount,
                                        currency,
                                        fee_collection,
                                        ground,
                                        operation_id,
                                        payer_branch_id,
                                        payer_account,
                                        receiver_name,
                                        receiver_iban,
                                        receiver_tax,
                                        emitent_bank_code,
                                        emitent_bank_corr_account,
                                        beneficiar_bank_name,
                                        beneficiar_bank_code,
                                        beneficiar_bank_swift,
                                        beneficiar_bank_tax,
                                        beneficiar_bank_corr_account,
                                        context_id,
                                        creator_id,
                                        state_history,
                                        attrs,
                                        changes,
                                        creation_date) 
                               values ( l_cur_id,
                                        recur.reference,
                                        recur.state,
                                        recur.payment_date,
                                        recur.system_id,
                                        recur.message_type,
                                        recur.amount,
                                        recur.currency,
                                        recur.fee_collection,
                                        recur.ground,
                                        recur.operation_id,
                                        recur.payer_branch_id,
                                        recur.payer_account,
                                        recur.receiver_name,
                                        recur.receiver_iban,
                                        recur.receiver_tax,
                                        recur.emitent_bank_code,
                                        recur.emitent_bank_corr_account,
                                        recur.beneficiar_bank_name,
                                        recur.beneficiar_bank_code,
                                        recur.beneficiar_bank_swift,
                                        recur.beneficiar_bank_tax,
                                        recur.beneficiar_bank_corr_account,
                                        recur.context_id,
                                        recur.creator_id,
                                        recur.state_history,
                                        recur.attrs,
                                        recur.changes,
                                        recur.creation_date)
         when matched then update set   state                       = recur.state,
                                        payment_date                = recur.payment_date,
                                        system_id                   = recur.system_id,
                                        message_type                = recur.message_type,
                                        amount                      = recur.amount,
                                        currency                    = recur.currency,
                                        --fee_collection  = recur.fee_collection,
                                        ground                      = recur.ground,
                                        operation_id                = NULL, --recur.operation_id,
                                        payer_branch_id             = recur.payer_branch_id,
                                        payer_account               = recur.payer_account,
                                        receiver_name               = recur.receiver_name,
                                        receiver_iban               = recur.receiver_iban,
                                        receiver_tax                = recur.receiver_tax,
                                        emitent_bank_code           = recur.emitent_bank_code,
                                        emitent_bank_corr_account   = recur.emitent_bank_corr_account,
                                        beneficiar_bank_name        = recur.beneficiar_bank_name,
                                        beneficiar_bank_code        = recur.beneficiar_bank_code,
                                        beneficiar_bank_swift       = recur.beneficiar_bank_swift,
                                        beneficiar_bank_tax         = recur.beneficiar_bank_tax,
                                        beneficiar_bank_corr_account= recur.beneficiar_bank_corr_account,
                                        context_id                  = recur.context_id,
                                        creator_id                  = recur.creator_id,
                                        state_history               = recur.state_history,
                                        attrs                       = recur.attrs,
                                        changes                     = recur.changes,
                                        creation_date               = recur.creation_date;
            -- Update fee collection
            dbms_output.put_line('NEW ID ' || l_cur_id);
            BEGIN
                ipay.jui_interbankpayments.update_fee_collection(pid => l_cur_id);
                dbms_output.put_line('FEE have been updated');
            EXCEPTION WHEN OTHERS THEN dbms_output.put_line('FEE havenot been updated ' || SQLERRM);
            END;
        EXCEPTION WHEN OTHERS THEN 
                dbms_output.put_line(SQLERRM);
                dbms_output.put_line(dbms_utility.format_error_backtrace);
        END;

        dbms_output.put_line('-------------------------------------');
  END LOOP;
end;
/
