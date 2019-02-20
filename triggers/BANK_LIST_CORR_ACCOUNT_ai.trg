CREATE OR REPLACE TRIGGER 
BANK_LIST_CORR_ACCOUNT_ai
BEFORE INSERT ON  BANK_LIST_CORR_ACCOUNT
FOR EACH ROW

BEGIN
    IF :new.id IS NULL THEN
      SELECT mt113_corr_banks_seq.Nextval
      INTO   :new.id
      FROM   dual;
    END IF;
END;
/
