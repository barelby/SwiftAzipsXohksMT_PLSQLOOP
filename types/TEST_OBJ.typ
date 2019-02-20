create or replace type TEST_OBJ as object
(
  -- Author  : SAATAYEV
  -- Created : 28-Jan-17 4:29:40 PM
  -- Purpose : 
  
  -- Attributes
  ID NUMBER,
  NAME VARCHAR2(100),
  
  Constructor FUNCTION TEST_OBJ RETURN SELF AS RESULT
  -- Member functions and procedures
)
/
create or replace type body TEST_OBJ is
  
  -- Member procedures and functions
  member procedure <ProcedureName>(<Parameter> <Datatype>) is
  begin
    <Statements>;
  end;
  
end;
/
