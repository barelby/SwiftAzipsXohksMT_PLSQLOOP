create or replace function get_constant_value(p_const_name VARCHAR) RETURN INTEGER is
  l_result INTEGER;
begin
  /*Все потому-что у пакетов есть зависимость с вьюшкой и при перекомпиляции вьюшки и очистке кеша
  со стороны ядра пакеты становятся невалидными, а т.к. пакет невалидный то и вьюшка не валидная
  Вот такая вот рекурсия :)
  */
  EXECUTE IMMEDIATE 'begin :result := const_interbankpayments.' || p_const_name || '; end;' 
        USING OUT l_result;
        RETURN l_result;
end get_constant_value;
/
