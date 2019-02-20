create or replace package tools is

  -- Author  : RVKHALAFOV
  -- Created : 12/24/2016 8:05:27 PM
  -- Purpose : 

  FUNCTION collection_constrain(p_val INTEGER, p_coll ibs.t_integer_collection) RETURN BOOLEAN;

end tools;
/
create or replace package body tools is

   FUNCTION collection_constrain(p_val INTEGER, p_coll ibs.t_integer_collection) RETURN BOOLEAN IS
       l_indx INTEGER;
   BEGIN
       IF p_coll IS NULL OR p_coll.count = 0 THEN RETURN FALSE; END IF;
       l_indx := p_coll.FIRST;
       WHILE l_indx IS NOT NULL
       LOOP
           dbms_output.put_line(p_coll(l_indx) || ' - ' || p_val);
           IF p_coll(l_indx) = p_val THEN RETURN TRUE; END IF;
           l_indx := p_coll.NEXT(l_indx);
       END LOOP;
       RETURN FALSE;
   END;
end tools;
/
