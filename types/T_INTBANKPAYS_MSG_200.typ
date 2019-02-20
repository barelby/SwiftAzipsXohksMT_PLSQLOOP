create or replace type T_INTBANKPAYS_MSG_200 UNDER t_intbankpays_msg_113
(  
  OVERRIDING MEMBER FUNCTION get_ground_max_lines_count RETURN INTEGER,

    CONSTRUCTOR FUNCTION T_INTBANKPAYS_MSG_200(pobj IN OUT NOCOPY t_interbankpayments_extend) RETURN SELF AS RESULT
)
/
create or replace type body T_INTBANKPAYS_MSG_200 IS
    
    OVERRIDING MEMBER FUNCTION get_ground_max_lines_count RETURN INTEGER IS
    BEGIN RETURN const_interbankpayments.CFG_DEF_GROUND_MAXLINES; END;
    
    CONSTRUCTOR FUNCTION T_INTBANKPAYS_MSG_200(pobj IN OUT NOCOPY t_interbankpayments_extend) RETURN SELF AS RESULT 
    IS BEGIN  SELF.obj := pobj; RETURN; END;
     
end;
/
