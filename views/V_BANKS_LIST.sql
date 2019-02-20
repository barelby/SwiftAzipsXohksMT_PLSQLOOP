CREATE OR REPLACE VIEW V_BANKS_LIST AS
SELECT bl."ID",bl."BANK_SWIFT",bl."BANK_NAME",bl."BANK_CODE",bl."CORR_ACC",bl."VOEN",bl."PARENT_ID",bl."PARENT_CODE",bl."CORR_SUB",bl."ALETERNATIVE_SWIFT",bl."ALETERNATIVE_ACCOUNT",bl."ALETERNATIVE_RULE_PAYSYS",
       (

        /*SELECT LISTAGG(bbbb.con, ';') WITHIN GROUP (ORDER BY bbbb.con) AS employees
        FROM (
            SELECT blca.bank_list_id, blca.currency_id || ':' || blca.account_number  AS con
            FROM  bank_list_corr_accounts blca
            ) bbbb
         WHERE bbbb.bank_list_id = bl.id*/

         -- Жопа?! Согласен. По другому ну никак по быстрому.
         SELECT LISTAGG(blca.currency_id || ':' || blca.account_number, ';') WITHIN GROUP (ORDER BY blca.currency_id, blca.account_number) AS employees
         FROM  bank_list_corr_accounts blca
         WHERE blca.bank_list_id = bl.id
       ) AS corr_accounts
FROM bank_list bl

--SELECT LISTAGG(l.bank_swift, ',') WITHIN GROUP (ORDER BY l.bank_swift) AS employees FROM bank_list l WHERE l.bank_name LIKE '%BANK OF BAKU%'
;
