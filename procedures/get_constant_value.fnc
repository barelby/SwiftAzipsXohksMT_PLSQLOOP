create or replace function get_constant_value(p_const_name VARCHAR) RETURN INTEGER is
  l_result INTEGER;
begin
  /*��� ������-��� � ������� ���� ����������� � ������� � ��� �������������� ������ � ������� ����
  �� ������� ���� ������ ���������� �����������, � �.�. ����� ���������� �� � ������ �� ��������
  ��� ����� ��� �������� :)
  */
  EXECUTE IMMEDIATE 'begin :result := const_interbankpayments.' || p_const_name || '; end;' 
        USING OUT l_result;
        RETURN l_result;
end get_constant_value;
/
