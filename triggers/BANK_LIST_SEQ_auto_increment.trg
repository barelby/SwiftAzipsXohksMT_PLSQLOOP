CREATE OR REPLACE TRIGGER BANK_LIST_SEQ_auto_increment
BEFORE INSERT ON  BANK_LIST
FOR EACH ROW

BEGIN
  IF :new.id IS NULL THEN
      SELECT BANK_LIST_SEQ.Nextval
      INTO   :new.id
      FROM   dual;
  END IF;
END;
/
