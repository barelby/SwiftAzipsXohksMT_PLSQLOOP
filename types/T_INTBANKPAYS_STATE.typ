create or replace type T_INTBANKPAYS_STATE FORCE as object
(
  -- Author  : RVKHALAFOV
  -- Created : 3/9/2016 11:21:31
  -- Purpose : 
  
  -- Attributes
  STATE         INTEGER,
  CHANGE_DATE   DATE,
  USER_ID       INTEGER,
  -- Member functions and procedures

  constructor function T_INTBANKPAYS_STATE(p_state IN INTEGER, 
                                           p_user_id   IN INTEGER,
                                           p_date      IN DATE DEFAULT SYSDATE) return self as result
) NOT FINAL
/
create or replace type body T_INTBANKPAYS_STATE is
  
  -- Member procedures and functions
  constructor function T_INTBANKPAYS_STATE( p_state IN INTEGER, 
                                            p_user_id   IN INTEGER,
                                            p_date      IN DATE DEFAULT SYSDATE) return self as result
    IS BEGIN
       SELF.STATE       := p_state;
       SELF.CHANGE_DATE := p_date;
       SELF.USER_ID     := p_user_id;
       RETURN;
    END;
  
end;
/
