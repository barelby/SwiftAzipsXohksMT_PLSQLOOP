CREATE OR REPLACE TRIGGER interbankpayment_autoincrement
BEFORE INSERT ON  interbankpayments
FOR EACH ROW

BEGIN
  IF :new.id IS NULL THEN
      SELECT interbankspayments_seq.Nextval
      INTO   :new.id
      FROM   dual;
  END IF;
END;
/
