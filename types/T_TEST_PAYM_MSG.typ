create or replace type T_TEST_PAYM_MSG as object
(
  -- Author  : SAATAYEV
  -- Created : 28-Jan-17 3:52:23 PM
  -- Purpose : 
  
  -- Attributes
  p_obj TEST_OBJ,
  
  -- Member functions and procedures
  member procedure CHECK_PARAMS(p_value IN VARCHAR2),
    CONSTRUCTOR FUNCTION T_TEST_PAYM_MSG RETURN SELF AS RESULT
)
/
create or replace type body T_TEST_PAYM_MSG is

  -- Member procedures and functions
  member procedure CHECK_PARAMS(p_value VARCHAR2) is
  begin
    null;
  end;

  CONSTRUCTOR FUNCTION T_TEST_PAYM_MSG RETURN SELF AS RESULT IS
  BEGIN
  SELF.p_obj:=TEST_OBJ();
  END;
end;
/
