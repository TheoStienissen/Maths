set serveroutput on size unlimited
declare
l_e  number := 2;
begin
  for j in 2 .. 32
  loop
    l_e := l_e + 1 / maths.nfac(j);
  end loop;
    dbms_output.put_line(' -- e = ' || l_e);
end;
/

