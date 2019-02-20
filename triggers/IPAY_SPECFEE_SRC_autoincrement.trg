CREATE OR REPLACE TRIGGER IPAY_SPECFEE_SRC_autoincrement
BEFORE INSERT ON  INTERBANKPAYMENTS_SPECFEE_SRC
FOR EACH ROW

BEGIN
  IF :new.id IS NULL THEN
      SELECT ipay_specfeesrc_seq.Nextval
      INTO   :new.id
      FROM   dual;
  END IF;
END;
/
