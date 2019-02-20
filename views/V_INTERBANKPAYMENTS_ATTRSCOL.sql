CREATE OR REPLACE VIEW V_INTERBANKPAYMENTS_ATTRSCOL AS
SELECT i.id as payment_id,coll."ID_ATTR",coll."VALUE_STR",coll."VALUE_INT" FROM ipay.interbankpayments i, TABLE(i.attrs) coll;
