CREATE OR REPLACE VIEW V_INTERBANKPAYMENTS_CHANGESCOL AS
SELECT i.id as payment_id, coll."CHANGE_DATE",coll."CHANGE_INITIATOR",coll."CHANGE_DESC",coll."CHANGE_ACTION",coll."CHANGE_RESULT",coll."CHANGE_ADDITIONAL"
FROM ipay.interbankpayments i, TABLE(i.changes) coll;
