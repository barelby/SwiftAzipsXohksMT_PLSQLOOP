create or replace view v_interbankpayments_specfeesrc as
select "ID","CLIENT_CODE","TYPE",
CASE WHEN t.TYPE = 15900 THEN 'Bank daxili'
     WHEN t.TYPE = 15901 THEN 'Olk? daxilir'
     WHEN t.TYPE = 15902 THEN 'Olk? xarici'
     ELSE ''
END AS TYPENAME,

"OPERATION_CURRENCY",
ibs.api_currency.get_iso_name("OPERATION_CURRENCY") AS "OPERATION_CURRENCY_CODE",
"FEE_CURRENCY",
ibs.api_currency.get_iso_name(FEE_CURRENCY) AS "FEE_CURRENCY_CODE",
"FIX_AMOUNT","PERCENT","MIN_AMOUNT","MAX_AMOUNT" from INTERBANKPAYMENTS_SPECFEE_SRC t;
