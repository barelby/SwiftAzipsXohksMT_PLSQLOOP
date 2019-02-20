create or replace procedure NPS_STATUS_UPDATER is
    l_path      varchar2 (2000 char);
    l_result    clob;
    l_matches   ibs.t_clob_collection;
    l_m_indx    INTEGER;
    l_parser    SWIFT_TAG_PARSER DEFAULT SWIFT_TAG_PARSER();
    l_msg       t_intbankpays_msg;
    l_pid       INTEGER;
    l_tag_value CLOB;
    l_temp      BOOLEAN;
    l_files     ibs.t_string_collection DEFAULT ibs.t_string_collection();
    l_file_ind  INTEGER;
    l_curdir    VARCHAR(100) DEFAULT '/prog/shares/copy_processed_inpayments/' || to_char(TRUNC(SYSDATE), 'ddMMYYYY');
begin 
  dbms_output.put_line('Current date folder ' || l_curdir);
  ibs.api_context.set_context(1, SYSDATE, 1);  
  
  EXECUTE IMMEDIATE 'create or replace directory '|| const_interbankpayments.CFG_NPS_STATUS_UPDATER_INP_DIR||' as ''' || l_curdir || '''';

  select directory_path into l_path 
  from all_directories 
  where directory_name = const_interbankpayments.CFG_NPS_STATUS_UPDATER_INP_DIR;
  
  dbms_output.put_line('Folder ' || l_path);
  
  ibs.get_dir_list(l_path);
  
  FOR l_cur IN (select * from ibs.directory_list order by mod_date desc)
  loop
      l_files.extend;
      l_files(l_files.LAST) := l_cur.filename;
  END LOOP;
  ROLLBACK;

  l_file_ind := l_files.FIRST;
  WHILE l_file_ind IS NOT NULL
  loop
    l_result := ibs.get_clob_from_file(const_interbankpayments.CFG_NPS_STATUS_UPDATER_INP_DIR, l_files(l_file_ind));
    l_matches := ibs.regexp_match_clob_collection(p_pattern => const_interbankpayments.CFG_NPS_STATUS_UPDATER_REG,
                                                  p_text => l_result);
    IF l_matches IS NOT NULL AND l_matches.count > 0 THEN
        IF TO_NUMBER(TRIM(l_matches(3))) = 
            const_interbankpayments.CFG_NPS_STATUS_UPDATER_RM_TYPE 
        THEN
            l_parser.update_block4_source(l_matches(5));
            l_pid := api_interbankpayments.get_payment_id(l_parser.get_tag_value('21'), FALSE);
            IF l_pid IS NOT NULL THEN
                l_msg := api_interbankpayments.getMessageTypeObject(l_pid);
                
                IF l_msg IS NULL THEN CONTINUE; END IF;
                
                IF l_msg.obj.STATE = const_interbankpayments.STATE_PROVIDER_SENT THEN
                    dbms_output.put_line(l_msg.obj.reference || ' detecting response from file');
                    BEGIN
                        CASE 
                            WHEN l_parser.get_tag_value('77E', FALSE) IS NOT NULL THEN
                                l_temp := l_msg.set_state(const_interbankpayments.STATE_PROVIDER_ERROR);
                                l_msg.update_attribute(p_attr_id => const_interbankpayments.ATTR_CBAR_RESP_ERROR_MSG, 
                                                       p_value_str => l_parser.get_tag_value('77E'));
                                                       
                            WHEN  l_parser.isset_tag('77A') AND l_parser.get_tag_value('77A', FALSE) IS NOT NULL THEN
                                l_temp := l_msg.set_state(const_interbankpayments.STATE_PROVIDER_ERROR);
                                l_msg.update_attribute(p_attr_id => const_interbankpayments.ATTR_CBAR_RESP_ERROR_MSG, 
                                                       p_value_str => l_parser.get_tag_value('77A'));
                            ELSE l_temp := l_msg.set_state(const_interbankpayments.STATE_COMPLETED);
                        END CASE;
                    EXCEPTION WHEN OTHERS THEN
                        dbms_output.put_line(SQLERRM);
                        api_interbankpayments.add_payment_change(mobj => l_msg.obj, 
                                                       p_action => 'NPS_STATUS_UPDATER', 
                                                       p_autonomus => TRUE,
                                                       p_result => SQLERRM || '',
                                                       p_additional => dbms_utility.format_error_backtrace);
                    END;
                    l_msg.obj.update_payment(TRUE);
                ELSE dbms_output.put_line(l_msg.obj.reference || ' skipped because state of the payment is ' || l_msg.obj.STATE);
                END IF;
            END IF;
        END IF;
    END IF;
    l_matches.delete;
   l_file_ind := l_files.NEXT(l_file_ind);  
  end loop;
end NPS_STATUS_UPDATER;
/
