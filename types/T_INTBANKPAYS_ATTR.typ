create or replace type T_INTBANKPAYS_ATTR FORCE as object
(
  -- Author  : RVKHALAFOV
  -- Created : 3/9/2016 14:06:00
  -- Purpose : 
  
    id_attr             INTEGER,
    value_str           VARCHAR2(2000),
    value_int           NUMBER,

    constructor function T_INTBANKPAYS_ATTR(p_id_attr             IN INTEGER, 
                                            p_value_str           IN VARCHAR2          DEFAULT NULL,
                                            p_value_int           IN NUMBER           DEFAULT NULL
                                            ) return self as result,
    constructor function T_INTBANKPAYS_ATTR  return self as result
)
/
create or replace type body T_INTBANKPAYS_ATTR IS
    constructor function T_INTBANKPAYS_ATTR(p_id_attr             IN INTEGER,
                                            p_value_str           IN VARCHAR2          DEFAULT NULL,
                                            p_value_int           IN NUMBER           DEFAULT NULL
                                            ) return self as RESULT
    AS BEGIN
        SELF.id_attr := p_id_attr;
        SELF.value_str := p_value_str;
        SELF.value_int := p_value_int;
        RETURN;
    END;
    constructor function T_INTBANKPAYS_ATTR  return self as result
    AS BEGIN  RETURN; END;
end;
/
