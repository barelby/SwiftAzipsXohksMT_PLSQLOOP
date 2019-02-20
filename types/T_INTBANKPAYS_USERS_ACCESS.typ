create or replace type T_INTBANKPAYS_USERS_ACCESS FORCE as object
(
  -- Author  : RVKHALAFOV
  -- Created : 3/9/2016 11:21:31
  -- Purpose : 
  
  -- Attributes
  USER_ID       INTEGER,
  MT_TYPE       INTEGER,
  ACCESS_MODES  ibs.t_integer_collection,
  -- Member functions and procedures

  constructor function T_INTBANKPAYS_USERS_ACCESS(p_user_id IN INTEGER, 
                                           p_mt_type   IN INTEGER,
                                           p_access_modes      IN ibs.t_integer_collection) return self as result
) NOT FINAL
/
create or replace type body T_INTBANKPAYS_USERS_ACCESS is
  
  -- Member procedures and functions
 constructor function T_INTBANKPAYS_USERS_ACCESS(p_user_id      IN INTEGER, 
                                                 p_mt_type      IN INTEGER,
                                                 p_access_modes IN ibs.t_integer_collection) return self as result
    IS BEGIN
       SELF.USER_ID         := p_user_id;
       SELF.MT_TYPE         := p_mt_type;
       SELF.ACCESS_MODES    := p_access_modes;
       RETURN;
    END;
  
end;
/
