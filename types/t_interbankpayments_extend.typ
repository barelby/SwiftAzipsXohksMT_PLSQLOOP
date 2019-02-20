create or replace type t_interbankpayments_extend FORCE UNDER t_interbankpayments
(
    STATE_NAME                  VARCHAR(100),
    SYSTEM_NAME                 VARCHAR(200),
    PAYER_NAME                  VARCHAR(200),
    PAYER_ACCOUNT_ID            INTEGER,
    PAYER_ACCOUNT_CURRENCY      INTEGER,
    PAYER_ACCOUNT_BRANCH        INTEGER,
    PAYER_TAX_NUMBER            VARCHAR(50),
    PAYER_IBAN_ACCOUNT          VARCHAR(100),
    EMITENT_BANK_SWIFT          VARCHAR(100),
    EMITENT_BANK_TAX            VARCHAR(50),
    EMITENT_BANK_NAME           VARCHAR(200),
    EMITENT_BANK_S_CORR_ACC     VARCHAR(100),
    BENEFICIAR_BANK_S_CORR_ACC  VARCHAR(100),
    CURRENCY_CODE               VARCHAR(10),
    FEE_SUM_AMOUNT              NUMBER,
    USER_NAME                   VARCHAR(100),
    USER_LOGIN                  VARCHAR(50),
    PAYER_CLIENT_CODE           VARCHAR(50),
    OVERRIDING MEMBER PROCEDURE reload(p_id INTEGER),
    -- Constructors
    CONSTRUCTOR FUNCTION t_interbankpayments_extend(p_id INTEGER, p_raise_error BOOLEAN DEFAULT TRUE)    RETURN SELF AS RESULT,
    CONSTRUCTOR FUNCTION t_interbankpayments_extend RETURN SELF AS RESULT
) NOT FINAL
/
create or replace type body t_interbankpayments_extend IS
    OVERRIDING MEMBER PROCEDURE reload(p_id INTEGER) IS
    BEGIN
        SELECT  ibp.id,ibp.reference, ibp.state, ibp.payment_date, ibp.system_id,ibp.message_type, ibp.amount, ibp.currency,
                ibp.fee_collection,ibp.ground, ibp.operation_id, ibp.payer_branch_id, ibp.payer_account,
                ibp.receiver_name, ibp.receiver_iban, ibp.receiver_tax, ibp.emitent_bank_code, ibp.beneficiar_bank_code,
                ibp.beneficiar_bank_swift,ibp.beneficiar_bank_tax,ibp.context_id, ibp.creator_id, ibp.state_history, ibp.attrs, ibp.changes,
                -- View
                STATE_NAME, SYSTEM_NAME,PAYER_NAME,PAYER_ACCOUNT_ID,PAYER_ACCOUNT_CURRENCY,
                PAYER_ACCOUNT_BRANCH,PAYER_TAX_NUMBER,PAYER_IBAN_ACCOUNT,EMITENT_BANK_SWIFT,
                EMITENT_BANK_TAX,EMITENT_BANK_NAME,CURRENCY_CODE,FEE_SUM_AMOUNT,USER_NAME,USER_LOGIN,
                PAYER_CLIENT_CODE, ibp.beneficiar_bank_name, ibp.EMITENT_BANK_CORR_ACCOUNT,ibp.BENEFICIAR_BANK_CORR_ACCOUNT
        INTO    SELF.ID, SELF.REFERENCE, SELF.STATE,SELF.PAYMENT_DATE,SELF.SYSTEM_ID,SELF.MESSAGE_TYPE,SELF.AMOUNT,SELF.CURRENCY,
                SELF.FEE_COLLECTION,SELF.GROUND,SELF.OPERATION_ID,SELF.PAYER_BRANCH_ID,
                SELF.PAYER_ACCOUNT,SELF.RECEIVER_NAME,SELF.RECEIVER_IBAN,SELF.RECEIVER_TAX,SELF.EMITENT_BANK_CODE,
                SELF.BENEFICIAR_BANK_CODE,SELF.BENEFICIAR_BANK_SWIFT,SELF.BENEFICIAR_BANK_TAX,SELF.CONTEXT_ID,SELF.CREATOR_ID,
                SELF.STATE_HISTORY, SELF.ATTRS, SELF.CHANGES,
                -- t_interbankpayments_view
                SELF.STATE_NAME, SELF.SYSTEM_NAME,SELF.PAYER_NAME,SELF.PAYER_ACCOUNT_ID,SELF.PAYER_ACCOUNT_CURRENCY,
                SELF.PAYER_ACCOUNT_BRANCH,SELF.PAYER_TAX_NUMBER,SELF.PAYER_IBAN_ACCOUNT,SELF.EMITENT_BANK_SWIFT,
                SELF.EMITENT_BANK_TAX,SELF.EMITENT_BANK_NAME,SELF.CURRENCY_CODE,SELF.FEE_SUM_AMOUNT,SELF.USER_NAME,SELF.USER_LOGIN,
                SELF.PAYER_CLIENT_CODE, SELF.BENEFICIAR_BANK_NAME, SELF.EMITENT_BANK_CORR_ACCOUNT, SELF.BENEFICIAR_BANK_CORR_ACCOUNT
        FROM v_interbankpayments ibp WHERE ibp.id = p_id;
    END;
    ---------------------------------------------------------------------------
    CONSTRUCTOR FUNCTION t_interbankpayments_extend(p_id INTEGER, p_raise_error BOOLEAN DEFAULT TRUE) RETURN SELF AS RESULT
    AS 
    BEGIN 
        reload(p_id);
        RETURN;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF p_raise_error = TRUE THEN
                raise_application_error(ibs.const_exception.NO_DATA_FOUND, 'Платеж с идентификатором {' || p_id || '} не найден');
            ELSE RETURN;
            END IF; 
    END;
    CONSTRUCTOR FUNCTION t_interbankpayments_extend RETURN SELF AS RESULT
    AS BEGIN  RETURN; END;
    
END;
/
