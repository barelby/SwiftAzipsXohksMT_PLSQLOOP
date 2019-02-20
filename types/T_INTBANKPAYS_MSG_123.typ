create or replace type T_INTBANKPAYS_MSG_123 UNDER t_intbankpays_msg
(
    /**
    *************************** Замечания *************************** 
    -- Для внутрибакнвоских платежей ИБАН является счетом (к примеру 38*) получателя
    */
    OVERRIDING MEMBER PROCEDURE onCreate,
    OVERRIDING MEMBER FUNCTION get_receiver_id(SELF IN OUT T_INTBANKPAYS_MSG_123) RETURN INTEGER,
    OVERRIDING MEMBER PROCEDURE check_state(p_new_state IN INTEGER),
    OVERRIDING MEMBER PROCEDURE state_to_authorization,
    OVERRIDING MEMBER PROCEDURE state_to_verification,
    OVERRIDING MEMBER PROCEDURE set_payer_account(p_var IN VARCHAR2),
    OVERRIDING MEMBER PROCEDURE set_receiver_iban (p_var IN VARCHAR2),
    OVERRIDING MEMBER FUNCTION get_addinfo_max_lines_count RETURN INTEGER,
    OVERRIDING MEMBER PROCEDURE CHECK_RECEIVER_TAX,
    OVERRIDING MEMBER PROCEDURE CHECK_RECEIVER_IBAN,
    OVERRIDING MEMBER PROCEDURE CHECK_RECEIVER_NAME,
    OVERRIDING MEMBER PROCEDURE CHECK_PAYER_ACCOUNT,
    OVERRIDING MEMBER FUNCTION get_account_tpl_lgform(p_lg_form INTEGER DEFAULT NULL) RETURN VARCHAR2,
    OVERRIDING MEMBER PROCEDURE genereate_fees_by_rules(l_fee_kind IN OUT ibs.t_integer_collection, p_special_fee OUT ibs.t_fee_amount) ,
    CONSTRUCTOR FUNCTION T_INTBANKPAYS_MSG_123(pobj IN OUT NOCOPY t_interbankpayments_extend) RETURN SELF AS RESULT
)
/
create or replace type body T_INTBANKPAYS_MSG_123 IS
    OVERRIDING MEMBER PROCEDURE CHECK_RECEIVER_IBAN IS 
        l_rec_account ibs.account%rowtype DEFAULT ibs.api_account.read_account(SELF.obj.RECEIVER_IBAN);
        l_pay_account ibs.account%rowtype;
    BEGIN
        IF l_rec_account.close_date IS NOT NULL THEN const_exceptions.raise_exception(const_exceptions.ACC_CLOSED); END IF;
        
        IF SELF.obj.PAYER_ACCOUNT IS NOT NULL THEN
            l_pay_account := ibs.api_account.read_account(SELF.obj.PAYER_ACCOUNT);
            IF l_rec_account.currency_id <> l_pay_account.currency_id THEN
                const_exceptions.raise_exception(const_exceptions.MT123_REC_PAY_DIF_CUR, 
                                                 ibs.api_currency.get_iso_name(l_rec_account.currency_id),
                                                 l_rec_account.account_number,
                                                 ibs.api_currency.get_iso_name(l_pay_account.currency_id),
                                                 l_pay_account.account_number);
            END IF;
        END IF;
    END;
    
    OVERRIDING MEMBER PROCEDURE CHECK_PAYER_ACCOUNT IS 
        l_rec_account   ibs.account%rowtype;
        l_pay_account   ibs.account%rowtype DEFAULT ibs.api_account.read_account(SELF.obj.PAYER_ACCOUNT);
    BEGIN
        (SELF AS T_INTBANKPAYS_MSG).CHECK_PAYER_ACCOUNT();
        IF SELF.obj.RECEIVER_IBAN IS NOT NULL THEN
            l_rec_account := ibs.api_account.read_account(SELF.obj.RECEIVER_IBAN);
            IF l_rec_account.currency_id <> l_pay_account.currency_id THEN
                const_exceptions.raise_exception(const_exceptions.MT123_REC_PAY_DIF_CUR, 
                                                 ibs.api_currency.get_iso_name(l_rec_account.currency_id),
                                                 l_rec_account.account_number,
                                                 ibs.api_currency.get_iso_name(l_pay_account.currency_id),
                                                 l_pay_account.account_number);
            END IF;
        END IF;
    END;

    OVERRIDING MEMBER PROCEDURE check_state(p_new_state IN INTEGER) IS 
    BEGIN
        IF SELF.obj.STATE = CONST_INTERBANKPAYMENTS.STATE_VERIFICATION AND 
            p_new_state IN
              ( CONST_INTERBANKPAYMENTS.STATE_AUTHORIZATION,
                CONST_INTERBANKPAYMENTS.STATE_COMPLETED,
                CONST_INTERBANKPAYMENTS.STATE_DRAFT,
                CONST_INTERBANKPAYMENTS.STATE_CHANGING,
                CONST_INTERBANKPAYMENTS.STATE_CANCELED,
                CONST_INTERBANKPAYMENTS.STATE_PROVIDER_SENT) 
           THEN 
               RETURN;
        ELSE
            (SELF AS T_INTBANKPAYS_MSG).check_state(p_new_state);
        END IF;
    END;

    OVERRIDING MEMBER PROCEDURE onCreate IS BEGIN 
        SELF.obj.update_attr_val(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_IS_WITHOUT_REM_TRANSFER,
                                                    value_int => 1,
                                                    value_str => NULL));
        IF SELF.obj.RECEIVER_IBAN IS NOT NULL THEN
            set_receiver_iban(SELF.obj.RECEIVER_IBAN);
        END IF;
    END;
    
    OVERRIDING MEMBER FUNCTION get_addinfo_max_lines_count RETURN INTEGER IS
    BEGIN RETURN 4; END;
    
    OVERRIDING MEMBER FUNCTION get_receiver_id(SELF IN OUT T_INTBANKPAYS_MSG_123) RETURN INTEGER IS 
        l_rec_id            INTEGER DEFAULT ibs.api_account.read_account(obj.RECEIVER_IBAN).id;
        is_deposit          IBS.DEPOSIT_CONTRACT%rowtype DEFAULT IBS.API_DEPOSIT.READ_DEPOSIT_CONTRACT(obj.RECEIVER_IBAN, false);
    BEGIN
        IF is_deposit.ID IS NOT NULL THEN l_rec_id := is_deposit.ID; END IF;
    	RETURN l_rec_id;
        --RETURN ibs.api_account.get_account_id(SELF.obj.RECEIVER_IBAN);
    END;
    
    OVERRIDING MEMBER PROCEDURE state_to_authorization IS
    BEGIN
        (SELF AS T_INTBANKPAYS_MSG).state_to_authorization();
        (SELF AS T_INTBANKPAYS_MSG).state_to_complete();
    END;
    
    OVERRIDING MEMBER PROCEDURE state_to_verification
    IS 
        l_rcode VARCHAR(20) DEFAULT ibs.api_object.get_object_code(ibs.api_account.read_account(SELF.OBJ.RECEIVER_IBAN).OWNER_ID,ibs.const_subject.CODE_KIND_CODE);
        l_pcode VARCHAR(20) DEFAULT ibs.api_object.get_object_code(ibs.api_account.read_account(SELF.OBJ.PAYER_ACCOUNT).OWNER_ID,ibs.const_subject.CODE_KIND_CODE);
    BEGIN 

        IF jui_interbankpayments_tools.is_IB_payment(SELF.obj) THEN
            IF NOT SELF.SET_STATE(const_interbankpayments.STATE_VERIFICATION) THEN RETURN; END IF;
            
            IF  (l_pcode = l_rcode AND SELF.obj.AMOUNT <= 100000) OR SELF.obj.AMOUNT <= 5000
            THEN
                 api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                               p_action => 'T_INTBANKPAYS_MSG_123.state_to_verification', 
                               p_additional => CASE WHEN l_pcode = l_rcode AND SELF.obj.AMOUNT <= 100000 
                                                         THEN 'Receiver and payer is the same - sending to authorization and amount is ' || SELF.obj.AMOUNT || ' <= 100000'
                                                    WHEN SELF.obj.AMOUNT <= 5000 THEN 'Amount is <= 5000'
                                                END);
                 SELF.state_to_authorization();
            END IF;
        ELSE
            (SELF AS T_INTBANKPAYS_MSG).state_to_verification();
        END IF;
    END;
    
    OVERRIDING MEMBER PROCEDURE set_payer_account(p_var IN VARCHAR2) IS 
        l_acc ibs.account%rowtype;
        l_var VARCHAR2(1000) DEFAULT jui_interbankpayments_tools.TRIMMING(p_var);
    BEGIN 
        IF l_var IS NOT NULL THEN
            IF  ibs.api_object.get_object_code(p_object_id => ibs.API_ACCOUNT.READ_ACCOUNT(l_var).owner_id,
                                              p_code_kind_id => ibs.const_subject.CODE_KIND_CODE) = ibs.const_subject.OUR_BANK_CODE 
            THEN
                api_interbankpayments.add_payment_change(mobj => obj, 
                                                   p_action => 'set_payer_account',
                                                   p_desc => 'Our bank detected - fee for 103 payments must be null'
                                                   );
                SELF.update_attribute(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_IS_WITHOUT_FEE,
                                                         value_str => NULL,
                                                         value_int => NULL));    
            END IF;
            l_acc := ibs.api_account.read_account(l_var, p_is_raise_ndf =>  false);
            IF l_acc.id IS NOT NULL THEN 
                SELF.set_currency(l_acc.currency_id); 
             END IF;
        END IF;
        (SELF AS t_intbankpays_msg).set_payer_account(l_var);
    END;
    
    OVERRIDING MEMBER PROCEDURE set_receiver_iban (p_var IN VARCHAR2)
    IS  l_acc       ibs.account%ROWTYPE;
        l_branch    ibs.branch%ROWTYPE;
        l_var       VARCHAR2(1000) DEFAULT jui_interbankpayments_tools.TRIMMING(p_var);
    BEGIN 
        SELF.obj.RECEIVER_IBAN := l_var;
        IF l_var IS NOT NULL THEN
            SELF.CHECK_RECEIVER_IBAN;
            l_acc :=  ibs.api_account.read_account(TRIM(l_var));
            IF  ibs.api_deposit.account_dc(SELF.obj.RECEIVER_IBAN) OR
                ibs.api_object.get_object_code(p_object_id => ibs.API_ACCOUNT.READ_ACCOUNT(l_var).owner_id,
                                                                                         p_code_kind_id => ibs.const_subject.CODE_KIND_CODE) 
                                                          = ibs.const_subject.OUR_BANK_CODE 
            THEN
                SELF.update_attribute(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_IS_WITHOUT_FEE,
                                                         value_str => NULL,
                                                         value_int => NULL));
            ELSE
                /*IF SELF.obj.PAYER_ACCOUNT IS NULL THEN
                    SELF.remove_attribute(const_interbankpayments.ATTR_IS_WITHOUT_FEE);
                END IF;*/
                SELF.remove_attribute(const_interbankpayments.ATTR_IS_WITHOUT_FEE);
            END IF;
            
            self.SET_RECEIVER_NAME(ibs.api_subject.get_subject_name(l_acc.owner_id));
            SELF.set_receiver_tax(ibs.api_object.get_object_code(l_acc.owner_id, ibs.const_subject.CODE_KIND_VOEN));
            SELF.update_attribute(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_RECIEVER_IBAN_FOR_123, 
                                                    value_str => ibs.api_account.get_IBAN(l_var),
                                                    value_int => NULL
                                                    ));
            l_branch := ibs.api_branch.read_branch(l_acc.branch_id);
            SELF.set_beneficiar_bank_code(jui_interbankpayments_tools.get_branch_bik(l_acc.branch_id));
            SELF.obj.BENEFICIAR_BANK_NAME := l_branch.branch_name;
        ELSE
            SELF.obj.RECEIVER_IBAN := NULL;
            SELF.obj.RECEIVER_NAME := NULL;
            SELF.obj.RECEIVER_TAX := NULL;
            SELF.remove_attribute(const_interbankpayments.ATTR_RECIEVER_IBAN_FOR_123);
        END IF;
        api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                           p_action => 'T_INTBANKPAYS_MSG_123.set_receiver_iban', 
                           p_additional => SELF.obj.RECEIVER_NAME || ' ' || SELF.obj.RECEIVER_TAX);
        SELF.update_fee_collection();        
    END;
    
    OVERRIDING MEMBER PROCEDURE CHECK_RECEIVER_NAME IS BEGIN NULL; END;
    
    OVERRIDING MEMBER PROCEDURE CHECK_RECEIVER_TAX IS BEGIN
        NULL;
    END;

    OVERRIDING MEMBER FUNCTION get_account_tpl_lgform(p_lg_form INTEGER DEFAULT NULL) RETURN VARCHAR2
    IS BEGIN
        RETURN '17';
    END;  
    
    OVERRIDING MEMBER PROCEDURE genereate_fees_by_rules(l_fee_kind IN OUT ibs.t_integer_collection, p_special_fee OUT ibs.t_fee_amount)
    IS 
       l_payer_acc_row      ibs.account%ROWTYPE;
       l_receiver_acc_row   ibs.account%ROWTYPE;
       l_legal_form         INTEGER;
       l_payer_branch       ibs.branch%ROWTYPE;
       l_receiver_branch    ibs.branch%ROWTYPE;
       l_sender_dep_row ibs.deposit_contract%ROWTYPE;
       l_receiver_dep_row   ibs.deposit_contract%ROWTYPE;
    BEGIN
        IF SELF.OBJ.RECEIVER_IBAN IS NOT NULL AND SELF.OBJ.PAYER_ACCOUNT IS NOT NULL THEN
            l_payer_acc_row     := ibs.api_account.read_account(SELF.OBJ.PAYER_ACCOUNT, FALSE);
            l_receiver_acc_row  := ibs.api_account.read_account(SELF.OBJ.RECEIVER_IBAN, FALSE);
            l_legal_form        := ibs.api_subject.get_subject_legal_form(l_payer_acc_row.owner_id);
            l_payer_branch      := ibs.api_branch.read_branch(l_payer_acc_row.branch_id);
            l_receiver_branch   := ibs.api_branch.read_branch(l_receiver_acc_row.branch_id);
            l_sender_dep_row    := ibs.api_deposit.read_deposit_contract(ibs.api_deposit.get_contract_id(SELF.obj.PAYER_ACCOUNT), FALSE);
            l_receiver_dep_row  := ibs.api_deposit.read_deposit_contract(ibs.api_deposit.get_contract_id(SELF.obj.RECEIVER_IBAN), FALSE);
            
            SELF.OBJ.remove_attr(const_interbankpayments.ATTR_IS_WITHOUT_FEE);
            
            -- Для интернет банкинга
            IF jui_interbankpayments_tools.is_IB_payment(SELF.OBJ) THEN
                -- Комиссия не предусмотрена для интернет-банкинга
                SELF.OBJ.fee_collection := ibs.t_fee_amount_collection();
                SELF.OBJ.update_attr_val(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_IS_WITHOUT_FEE,
                                                            value_int => 1,
                                                            value_str => NULL));
                api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                                                           p_action => 'T_INTBANKPAYS_MSG_123.update_fee_collection',
                                                           p_result => 'Iternet banking user have detected - Without fee');
                SELF.obj.update_payment;
                RETURN;
            -- Спец комиссии для внутрибанквоских платежей
            -- Перенести на табличную форму
            ELSIF   (l_sender_dep_row.contract_number='XXXXXXXX74' AND l_receiver_dep_row.contract_number='XXXXXXXX00184') OR
                    (l_sender_dep_row.contract_number='XXXXXXXX74' AND l_receiver_dep_row.contract_number='XXXXXXXX03274') OR
                    (l_sender_dep_row.contract_number='XXXXXXXX74' AND l_receiver_dep_row.contract_number='XXXXXXXX03694') OR
                    (l_sender_dep_row.contract_number='XXXXXXXX74' AND l_receiver_dep_row.contract_number='XXXXXXXX00914') OR
                    (l_sender_dep_row.contract_number='XXXXXXXX74' AND l_receiver_dep_row.contract_number='XXXXXXXX00944') OR
                    (l_sender_dep_row.contract_number='XXXXXXXX74' AND l_receiver_dep_row.contract_number='XXXXXXXX00934') OR
                    (l_sender_dep_row.contract_number='XXXXXXXX74' AND l_receiver_dep_row.contract_number='XXXXXXXX05344') OR
                    (l_sender_dep_row.contract_number='XXXXXXXX84' AND l_receiver_dep_row.contract_number='XXXXXXXX00114') OR
                    (l_sender_dep_row.contract_number='XXXXXXXX74' AND l_receiver_dep_row.contract_number='XXXXXXXX11844') OR
                    (l_sender_dep_row.contract_number='XXXXXXXX94' AND l_receiver_dep_row.contract_number='XXXXXXXX13154') OR
                    (l_sender_dep_row.contract_number='XXXXXXXX14' AND l_receiver_dep_row.contract_number='XXXXXXXX18594') OR
                    (l_sender_dep_row.contract_number='XXXXXXXX44' AND l_receiver_dep_row.contract_number='XXXXXXXX26094') OR
                    (l_sender_dep_row.contract_number='XXXXXXXX34' AND l_receiver_dep_row.contract_number='XXXXXXXX01224') OR
                    (l_sender_dep_row.contract_number='XXXXXXXX44' AND l_receiver_dep_row.contract_number='XXXXXXXX24464') OR
                    (l_sender_dep_row.contract_number='XXXXXXXX94I56') OR
                    (l_sender_dep_row.contract_number='XXXXXXXX04I56') OR
                    (l_sender_dep_row.contract_number='XXXXXXXX24I56') OR
                    (l_sender_dep_row.contract_number='XXXXXXXX34I56') OR
                    (l_sender_dep_row.contract_number='XXXXXXXX9I44')  OR
                    (l_sender_dep_row.contract_number='XXXXXXXX0I44')  OR
                    (l_sender_dep_row.contract_number='XXXXXXXX7I56')  OR
                    (l_sender_dep_row.contract_number='XXXXXXXX8I56')  OR
                    (ibs.api_object.get_object_id('028094',1) IN (l_sender_dep_row.client_id)) OR 
                    (ibs.api_object.get_object_id('573922',1) IN (l_sender_dep_row.client_id)) OR
                    (ibs.api_object.get_object_id('604651',1) IN (l_sender_dep_row.client_id)) OR
                    (ibs.api_object.get_object_id('610747',1) IN (l_sender_dep_row.client_id)) OR
                    (ibs.api_object.get_object_id('609298',1) IN (l_sender_dep_row.client_id)) OR
                    (ibs.api_object.get_object_id('452370',1) IN (l_sender_dep_row.client_id)) OR
                    (ibs.api_object.get_object_id('575641',1) IN (l_sender_dep_row.client_id)) OR
                    (ibs.api_object.get_object_id('597164',1) IN (l_sender_dep_row.client_id)) OR
                    (ibs.api_object.get_object_id('859276',1) IN (l_sender_dep_row.client_id)) OR
                    (ibs.api_object.get_object_id('115228',1) IN (l_sender_dep_row.client_id)) OR
                    (ibs.api_object.get_object_id('575569',1) IN (l_sender_dep_row.client_id)) 
           THEN
                SELF.OBJ.update_attr_val(t_intbankpays_attr(id_attr => const_interbankpayments.ATTR_IS_WITHOUT_FEE,
                                                            value_int => 1,
                                                            value_str => NULL));
                api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                                                           p_action => 'T_INTBANKPAYS_MSG_123.update_fee_collection - Without fee',
                                                           p_result => 'Special fee have detected',
                                                           p_additional => 'SENDER DEPOSIT CONTRACT: ' || l_sender_dep_row.contract_number || chr(10) ||
                                                                           'RECEIVER DEPOSIT CONTRACT: ' || l_receiver_dep_row.contract_number|| chr(10) ||
                                                                           'SENDER CLIENT CODE: ' || l_sender_dep_row.client_id);
                SELF.obj.update_payment;
                RETURN;
            -- Для частных пользователей
            ELSIF l_legal_form = ibs.const_subject.LEGAL_FORM_PERSON THEN
                IF l_payer_branch.id = l_receiver_branch.id THEN 
                    l_fee_kind.extend;
                    l_fee_kind(l_fee_kind.last) := const_interbankpayments.FEE_KIND_INBNK_PHS_SAME_BR; -- Fiziki şəxslər üzrə bütün şəhər və rayonlarda yerləşən fiiallarda filialdaxili  köçürmə
                ELSIF l_payer_branch.region = l_receiver_branch.region THEN
                    IF  l_payer_branch.region = 'A'   THEN  
                        l_fee_kind.extend;
                        l_fee_kind(l_fee_kind.last) := const_interbankpayments.FEE_KIND_INBNK_PHS_REG_A;       -- Fiziki şəxslər üzrə Bakı, Xırdalan və Sumqayıt şəhərlərində yerləşən istənilən filiallararası köçürmə 
                    ELSIF l_payer_branch.region = 'D' THEN  
                        l_fee_kind.extend;
                        l_fee_kind(l_fee_kind.last) := const_interbankpayments.FEE_KIND_INBNK_PHS_REG_D;       -- Fiziki şəxslər üzrə Gəncə şəhərində yerləşən filiallararası köçürmə
                    ELSE                                    
                        l_fee_kind.extend;
                        l_fee_kind(l_fee_kind.last) := const_interbankpayments.FEE_KIND_INBNK_PHS_REG_OT;  -- Fiziki şəxslər üzrə digər filiallararası köçürmə
                    END IF;
                ELSE
                    l_fee_kind.extend;
                        l_fee_kind(l_fee_kind.last) := const_interbankpayments.FEE_KIND_INBNK_PHS_REG_OT;      -- Fiziki şəxslər üzrə digər filiallararası köçürmə
                END IF;
            -- Для юриков
            ELSIF l_legal_form IN (ibs.const_subject.LEGAL_FORM_COMPANY, ibs.const_subject.LEGAL_FORM_ENTERPRISER) THEN
                IF l_payer_branch.id = l_receiver_branch.id THEN 
                    l_fee_kind.extend;
                        l_fee_kind(l_fee_kind.last) := const_interbankpayments.FEE_KIND_INBNK_JUR_SAME_BR;         -- Hüquqi şəxslər üzrə bütün şəhər və rayonlarda yerləşən fiiallarda filialdaxili  köçürmə 
                ELSIF l_payer_branch.region = l_receiver_branch.region THEN
                    IF  l_payer_branch.region = 'A'   THEN  
                        l_fee_kind.extend;
                        l_fee_kind(l_fee_kind.last) := const_interbankpayments.FEE_KIND_INBNK_JUR_REG_A;       -- Hüquqi şəxslər üzrə Bakı, Xırdalan və Sumqayıt şəhərlərində yerləşən istənilən filiallararası köçürmə  
                    ELSIF l_payer_branch.region = 'D' THEN  
                        l_fee_kind.extend;
                        l_fee_kind(l_fee_kind.last) := const_interbankpayments.FEE_KIND_INBNK_JUR_REG_D;       -- Hüquqi şəxslər üzrə Gəncə şəhərində yerləşən filiallararası köçürmə
                    ELSE                                    
                        l_fee_kind.extend;
                        l_fee_kind(l_fee_kind.last) := const_interbankpayments.FEE_KIND_INBNK_JUR_REG_OT;   -- Hüquqi şəxslər üzrə digər filiallararası köçürmə
                    END IF;
                ELSE
                    l_fee_kind.extend;
                        l_fee_kind(l_fee_kind.last) := const_interbankpayments.FEE_KIND_INBNK_JUR_REG_OT;       -- Hüquqi şəxslər üzrə digər filiallararası köçürmə
                END IF;
            END IF;
        ELSE
             api_interbankpayments.add_payment_change(mobj => SELF.obj, 
                                                       p_action => 'T_INTBANKPAYS_MSG_123.update_fee_collection',
                                                       p_result => 'Can not calculate fee - one of important fields is empty',
                                                       p_additional => 'PAYER ACCOUNT    : ' || SELF.OBJ.PAYER_ACCOUNT || chr(10) ||
                                                                       'RECEIVER ACCOUNT : ' || SELF.OBJ.RECEIVER_IBAN);
        END IF;
    NULL;
    END;
    
    CONSTRUCTOR FUNCTION T_INTBANKPAYS_MSG_123(pobj IN OUT NOCOPY t_interbankpayments_extend) RETURN SELF AS RESULT 
    IS BEGIN  SELF.obj := pobj; RETURN; END;
end;
/
