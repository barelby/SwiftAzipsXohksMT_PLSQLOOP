CREATE OR REPLACE VIEW V_BANKS_LIST_CORR_ACC AS
SELECT blca."ID",blca."BANK_LIST_ID",blca."CURRENCY",blca."ACCOUNT",blca."ACC_TYPE",blca."ACCOUNT_BOB",
       bl.bank_name,
       bl.bank_swift,
       c.iso_name AS currency_name
FROM bank_list_corr_account blca
JOIN bank_list bl ON bl.id = blca.bank_list_id
JOIN ibs.currency c ON c.id = blca.currency
ORDER BY bl.bank_name ASC;
