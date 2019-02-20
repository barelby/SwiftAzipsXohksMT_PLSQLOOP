create or replace view v_specfeesrc_clients as
select DISTINCT(t.client_code) AS CLIENT_CODE, s.subject_name AS CLIENT_NAME, 0 AS ID
from INTERBANKPAYMENTS_SPECFEE_SRC t
JOIN ibs.object_code oc ON oc.object_code = t.client_code AND oc.code_kind_id = 1
JOIN ibs.subject s ON s.id = oc.object_id;
