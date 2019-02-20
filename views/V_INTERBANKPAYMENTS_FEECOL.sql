CREATE OR REPLACE VIEW V_INTERBANKPAYMENTS_FEECOL AS
SELECT i.id as payment_id, fee_coll."FEE_ID",fee_coll."FEE_NAME",fee_coll."OPERATION_AMOUNT",fee_coll."OPERATION_CURRENCY_ID",fee_coll."TARIFF_ID",fee_coll."INCOME_CATEGORY_ID",fee_coll."GROUND_TEMPLATE",fee_coll."FEE_AMOUNT",fee_coll."CURRENCY_ID",fee_coll."PAYER_AMOUNT",fee_coll."PAYER_CURRENCY_ID",fee_coll."ACCOUNT_ID",fee_coll."GROUND",fee_coll."IS_READ_ONLY",fee_coll."TARIFF_VALUE_ID"
FROM ipay.interbankpayments i, TABLE(i.fee_collection) fee_coll;
