CREATE OR REPLACE VIEW V_INTERBANKPAYMENTS_STATESCOL AS
SELECT i.id as payment_id,coll."STATE",coll."CHANGE_DATE",coll."USER_ID" FROM interbankpayments i, TABLE(i.state_history) coll;
