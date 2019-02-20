create or replace type t_mt113_corr_bank_acc as object
(
       id           INTEGER,
       bank_list_id integer,
       bank_name    varchar(500),
       bank_swift   varchar(100),
       currency     integer,
       account      varchar(200),
       acc_type     varchar(50),
       account_bob  varchar(200)
) NOT FINAL 
/
