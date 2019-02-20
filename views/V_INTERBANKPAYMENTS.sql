CREATE OR REPLACE VIEW V_INTERBANKPAYMENTS AS
SELECT     -- COMMON PAYMENT INFORMATION
           IP."ID",
           IP."REFERENCE",
           IP."STATE",
           EV.ENUM_NAME AS STATE_NAME,
           IP."PAYMENT_DATE",
           --TO_CHAR(IP.PAYMENT_DATE, 'DD.MM.YYYY') PAYMENT_DATE_FORMATED,
           IP."SYSTEM_ID",IBS.API_PAYMENT.GET_PAYMENT_SYSTEM_NAME(IP.SYSTEM_ID) SYSTEM_NAME,
           IP."MESSAGE_TYPE",
           -- PAYER INFO
           OB.OBJECT_CODE PAYER_CLIENT_CODE,
           IP."PAYER_BRANCH_ID",
           IP."PAYER_ACCOUNT",
           CASE WHEN (SELECT COUNT(1) FROM TABLE(ip.attrs) a WHERE a.id_attr = get_constant_value('ATTR_113_PAYER_BANK_SWIFT')
                                                          AND a.value_str IS NOT NULL) > 0 THEN
                        (SELECT a.value_str
                         FROM TABLE(ip.attrs) a
                         WHERE a.id_attr = get_constant_value('ATTR_113_PAYER_BANK_NAME'))
                ELSE IBS.API_SUBJECT.GET_SUBJECT_NAME(A.OWNER_ID)
           END  PAYER_NAME,
           A.ID PAYER_ACCOUNT_ID,
           A.CURRENCY_ID PAYER_ACCOUNT_CURRENCY,
           A.BRANCH_ID PAYER_ACCOUNT_BRANCH,
           IBS.API_OBJECT.GET_OBJECT_CODE(OB.OBJECT_ID, 16) PAYER_TAX_NUMBER,
           IBS.API_ACCOUNT.GET_IBAN(IP.PAYER_ACCOUNT) PAYER_IBAN_ACCOUNT,
           -- RECEIVER INFO
           IP."RECEIVER_NAME",
           IP."RECEIVER_IBAN",--CASE WHEN ip.message_type = 123 THEN IBS.API_ACCOUNT.GET_IBAN(IP."RECEIVER_IBAN") ELSE IP."RECEIVER_IBAN" END RECEIVER_IBAN,
           IP."RECEIVER_TAX",
           -- BENEFICIAR BANK
           IP.BENEFICIAR_BANK_NAME,
           IP."BENEFICIAR_BANK_CODE",
           IP."BENEFICIAR_BANK_SWIFT",
           IP."BENEFICIAR_BANK_TAX",
           IP.BENEFICIAR_BANK_CORR_ACCOUNT,
           -- EMITENT BANK INFO
           IP."EMITENT_BANK_CODE",
           BL.BANK_SWIFT    EMITENT_BANK_SWIFT,
           BL.VOEN          EMITENT_BANK_TAX,
           BL.BANK_NAME
           -- ??????? ???????, ?? ???? ????????
           /*CASE WHEN IP.MESSAGE_TYPE <> 123 THEN BL.BANK_NAME
                ELSE (SELECT br.branch_name FROM ibs.branch br WHERE br.id = IP.PAYER_BRANCH_ID)
           END*/ EMITENT_BANK_NAME,
           -- /??????? ??????? ???????????

            NVL(ip.EMITENT_BANK_CORR_ACCOUNT,
                bl.corr_acc
               /*CASE WHEN BL.PARENT_ID IS NULL THEN (SELECT BI.ACCOUNT
                                                    FROM BANK_IBAN Bi
                                                    WHERE Bi.BANK_CODE = Bl.Bank_Code
                                                          AND Bi.Currency_Id = ip.Currency )
                    ELSE (  SELECT BI.ACCOUNT
                            FROM BANK_IBAN BI
                            WHERE BI.BANK_CODE = (SELECT BANK_CODE
                                                    FROM bank_list
                                                    WHERE ID = BL.PARENT_ID)
                                AND Bi.Currency_Id = ip.Currency)
               END*/) EMITENT_BANK_CORR_ACCOUNT,
           -- FINANCIAL INFO
           IP."AMOUNT",
           IP."CURRENCY",
           CUR.ISO_NAME CURRENCY_CODE,
           IP.FEE_COLLECTION,
           IP."GROUND",
           (SELECT SUM(T.FEE_AMOUNT) FROM TABLE(IP.FEE_COLLECTION) T) FEE_SUM_AMOUNT,
           -- CREATOR INFO
           IP."CONTEXT_ID",
           IP."CREATOR_ID",
           SU.USER_NAME,
           SU.LOGIN_NAME,
           -- OTHERS
           IP.CHANGES,
           IP.ATTRS,
           IP."STATE_HISTORY",
           IP."OPERATION_ID",
           IP.CREATION_DATE,
           im.source_content    AS payment_file_struct,
           im.provider_result   AS provider_result
    FROM INTERBANKPAYMENTS IP
    LEFT JOIN BANK_LIST BL                  ON BL.BANK_CODE = IP.EMITENT_BANK_CODE
    LEFT JOIN IBS.SWA_USER SU               ON SU.ID = IP.CREATOR_ID
    LEFT JOIN IBS.ACCOUNT A                 ON A.ACCOUNT_NUMBER = IP.PAYER_ACCOUNT
    LEFT JOIN IBS.OBJECT_CODE OB            ON OB.OBJECT_ID = A.OWNER_ID AND OB.CODE_KIND_ID = 1
    LEFT JOIN IBS.CURRENCY CUR              ON CUR.ID = IP.CURRENCY
    LEFT JOIN IBS.ENUMERATION_VALUE EV      ON EV.ENUM_TYPE_ID = 15100 AND EV.ENUM_ID = IP.STATE
    LEFT JOIN INTERBANKPAYMENTS_MESSAGES im ON im.payment_id = ip.id
;
