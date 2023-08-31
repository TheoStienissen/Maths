
set serveroutput on size unlimited
declare
l_test1 types_pkg.complexN_ty;
l_test2 types_pkg.complexQ_ty;
l_test3 types_pkg.complexQ_ty;
l_test4 types_pkg.complexQ_ty;
l_test5 types_pkg.complexQ_ty;
l integer := 1;
begin
  l_test1 := complex.to_complexN(7,4);
  complex.print(l_test1);
  l_test2 := complex.to_complex(1,1,1,1);
    complex.print(l_test2);
  l_test3 := complex.to_complex(3,1,3,1);
    complex.print(l_test3);
 -- l_test2 := complex.divideQ(l_test2, l_test3);
  complex.print(l_test2);
  complex.print(l_test3);
  l_test4 := l_test2;
  l_test5 := l_test3;
  
  if complex.gt(l_test3, l_test2)
  then dbms_output.put_line('Greater');
  else dbms_output.put_line('Smaller');
  end if; 
  
  if not complex.gt0(l_test2) then l_test2 := complex.multiply (-1, l_test2); end if;
  if not complex.gt0(l_test3) then l_test3 := complex.multiply (-1, l_test3); end if;
  complex.print(l_test2);
  complex.print(l_test3);
 
for j in 1 .. 20 -- l_test3.re.numerator > 0 and l_test2.re.numerator > 0 and l > 0
 loop
    if complex.gt(l_test3, l_test2)
   then
     l := trunc((l_test3.re.numerator/l_test3.re.denominator) / (l_test2.re.numerator/l_test2.re.denominator));
     dbms_output.put_line ('--  ' || l);
     l_test3 := complex.subtract(l_test3,  complex.multiply(1,l_test2));
   end if;
   l_test4 := l_test2;
   l_test2 := l_test3;
   l_test3 := l_test4;
   complex.print(l_test2);
   complex.print(l_test3);
  end loop;
 
 
 dbms_output.put_line ('++++++++++++++++++++++');
 if not complex.eq0 (l_test2) then  complex.print(complex.divide(l_test4, l_test2)); end if;
 if not complex.eq0 (l_test3) then  complex.print(complex.divide(l_test4, l_test3)); end if;
 if not complex.eq0 (l_test2) then  complex.print(complex.divide(l_test5, l_test2)); end if;
 if not complex.eq0 (l_test3) then  complex.print(complex.divide(l_test5, l_test3)); end if;
end;
/

begin
  complex.print(complex.divide(complex.to_complex(73,17,3,19), complex.to_complex(1,187,6461,114)));
  complex.print(complex.divide(complex.to_complex(73,1,3,-1), complex.to_complex(1,1,-1,1)));
end;
/
 
-- Multiply complex numbers with whole numbers
declare
l_test2 types_pkg.complexQ_ty;
begin
  l_test2 := complex.to_complex(2,7,1,3);
 for j in 1 .. 10
 loop
  complex.print(complex.multiply(j,l_test2));
 end loop;
 end;
 /
  
