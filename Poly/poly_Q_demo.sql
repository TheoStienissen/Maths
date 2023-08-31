set serveroutput on size unlimited
l_poly1 := polynome_Q_pkg.add_polynome_elt (1, 17, 3,3);
l_poly1 := polynome_Q_pkg.add_polynome_elt (1, 3, 8,2);
l_poly1 := polynome_Q_pkg.add_polynome_elt (1, 1, 5,1);
l_poly1 := polynome_Q_pkg.add_polynome_elt (1, -6,7, 0);
exec polynome_Q_pkg.print_polynome (polynome_Q_pkg.random_polynome, false)

declare
l_poly1 polynome_Q_pkg.polynome_row_ty;
l_id integer;
l_count integer;
begin
execute immediate 'truncate table polynomes_q';
l_poly1 := polynome_Q_pkg.random_polynome;
--
polynome_Q_pkg.print_polynome(l_poly1);
dbms_output.put_line ('Degree: '|| polynome_Q_pkg.degree (l_poly1));
l_id := polynome_Q_pkg.save_polynome (l_poly1);
polynome_Q_pkg.print_polynome(l_id);
dbms_output.put_line ('Degree: '|| polynome_Q_pkg.degree (l_id));
--
l_id    := polynome_Q_pkg.save_temp_polynome (l_poly1);
l_poly1 := polynome_Q_pkg.load_temp_polynome (l_id);
polynome_Q_pkg.print_polynome(l_poly1);
--
dbms_output.put_line ('Deleting 2-nd element');
l_poly1 := polynome_Q_pkg.delete_element (l_poly1, 2);
polynome_Q_pkg.print_polynome(l_poly1);
--
l_poly1 := polynome_Q_pkg.delete_element (l_id, 2);
l_id := polynome_Q_pkg.save_polynome (l_poly1);
polynome_Q_pkg.print_polynome(l_id);
--
dbms_output.put_line ('Deleting 3-rd power');
l_poly1 := polynome_Q_pkg.delete_power (l_poly1, 3);
polynome_Q_pkg.print_polynome(l_poly1);
--
l_id := polynome_Q_pkg.save_polynome (l_poly1);
l_poly1 := polynome_Q_pkg.delete_power (l_id, 3);
polynome_Q_pkg.print_polynome(l_id);
end;
/

-- Add, Subtract and Multiply
declare
l_poly1 polynome_Q_pkg.polynome_row_ty;
l_poly2 polynome_Q_pkg.polynome_row_ty;
l_poly3 polynome_Q_pkg.polynome_row_ty;
l_id1   integer;
l_id2   integer;
l_id3   integer;
l_id4   integer := polynome_Q_pkg.new_id;
l_count integer;
begin
execute immediate 'truncate table polynomes_q';
l_poly1 := polynome_Q_pkg.random_polynome;
l_poly2 := polynome_Q_pkg.random_polynome;
polynome_Q_pkg.print_polynome(l_poly1);
polynome_Q_pkg.print_polynome(l_poly2);
--
l_id1 := polynome_Q_pkg.save_polynome (l_poly1);
l_id2 := polynome_Q_pkg.save_polynome (l_poly2);
--
dbms_output.put_line ('Adding polynomes');
l_poly3 := polynome_Q_pkg.add_polynomes (l_id1, l_id2, l_id4);
polynome_Q_pkg.print_polynome(l_poly3);
--
dbms_output.put_line ('Subtracting polynomes');
l_poly3 := polynome_Q_pkg.subtract_polynomes (l_id1, l_id2, l_id4);
polynome_Q_pkg.print_polynome(l_poly3);
--
dbms_output.put_line ('Multiplying polynomes');
l_poly3 := polynome_Q_pkg.multiply_polynomes (l_id1, l_id2, l_id4);
polynome_Q_pkg.print_polynome(l_poly3);
--
dbms_output.put_line ('Dividing polynomes');
l_id3 := polynome_Q_pkg.divide_polynomes (l_id1, l_id2, l_id4);
polynome_Q_pkg.print_polynome(l_id3);
polynome_Q_pkg.print_polynome(l_id4);
end;
/


-- Add and Multiply
declare
l_poly1 polynome_Q_pkg.polynome_row_ty;
l_poly2 polynome_Q_pkg.polynome_row_ty;
l_poly3 polynome_Q_pkg.polynome_row_ty;
l_poly4 polynome_Q_pkg.polynome_row_ty;
l_poly_r1 polynome_Q_pkg.polynome_row_ty;
l_poly_r2 polynome_Q_pkg.polynome_row_ty;
l_poly_r3 polynome_Q_pkg.polynome_row_ty;
begin
execute immediate 'truncate table polynomes_q';
  l_poly1 := polynome_Q_pkg.add_polynome_elt (1, 1, 5,1);
  l_poly1 := polynome_Q_pkg.add_polynome_elt (1, -6,4, 0);
  polynome_Q_pkg.print_polynome(l_poly1);
  
  l_poly2 := polynome_Q_pkg.add_polynome_elt (2, 1, 7,1);
  l_poly2 := polynome_Q_pkg.add_polynome_elt (2, -12,11, 0);
  polynome_Q_pkg.print_polynome(l_poly2);
  
  l_poly3 := polynome_Q_pkg.add_polynome_elt (3, 1, 3,1);
  l_poly3 := polynome_Q_pkg.add_polynome_elt (3, -18,17, 0);
  polynome_Q_pkg.print_polynome(l_poly3);

  l_poly4 := polynome_Q_pkg.add_polynome_elt (4, 1, 1,1);
  l_poly4 := polynome_Q_pkg.add_polynome_elt (4, -24,1, 0);
  polynome_Q_pkg.print_polynome(l_poly4);

  l_poly_r1 := polynome_Q_pkg.multiply_polynomes(l_poly1,l_poly2, 5);
  polynome_Q_pkg.print_polynome(l_poly_r1);

  l_poly_r2 := polynome_Q_pkg.multiply_polynomes(l_poly3,l_poly4, 6);
  polynome_Q_pkg.print_polynome(l_poly_r2);
  
  l_poly_r3 := polynome_Q_pkg.multiply_polynomes(l_poly_r1,l_poly_r2, 7);
  polynome_Q_pkg.print_polynome(l_poly_r3);  

  dbms_output.put_line ('F(1/4):   '); fractions_pkg.print (polynome_Q_pkg.result_for_x (l_poly_r3, 1,4));
  dbms_output.put_line ('F(2/7):   '); fractions_pkg.print (polynome_Q_pkg.result_for_x (l_poly_r3, 2,7));
  dbms_output.put_line ('F(3/6):   '); fractions_pkg.print (polynome_Q_pkg.result_for_x (l_poly_r3, 3,6));
  dbms_output.put_line ('F(4/8):   '); fractions_pkg.print (polynome_Q_pkg.result_for_x (l_poly_r3, 4,8));
  dbms_output.put_line ('F(6/9):   '); fractions_pkg.print (polynome_Q_pkg.result_for_x (l_poly_r3, 6,9));
  dbms_output.put_line ('F(12/13): '); fractions_pkg.print (polynome_Q_pkg.result_for_x (l_poly_r3, 12,13));
  dbms_output.put_line ('F(22/25): '); fractions_pkg.print (polynome_Q_pkg.result_for_x (l_poly_r3, 22,25));
  dbms_output.put_line ('F(40/11): '); fractions_pkg.print (polynome_Q_pkg.result_for_x (l_poly_r3, 40,11));
end;
/

declare
l_poly1 polynome_Q_pkg.polynome_row_ty;
l_poly2 polynome_Q_pkg.polynome_row_ty;
l_poly3 polynome_Q_pkg.polynome_row_ty;
begin
execute immediate 'truncate table polynomes_q';
  l_poly1 := polynome_Q_pkg.add_polynome_elt (1, 1, 1, 3);
  l_poly1 := polynome_Q_pkg.add_polynome_elt (1, 1, 1, 0);
  
  l_poly2 := polynome_Q_pkg.add_polynome_elt (2, 1, 1, 5);
  l_poly2 := polynome_Q_pkg.add_polynome_elt (2, -1, 1, 4);
  l_poly2 := polynome_Q_pkg.add_polynome_elt (2, 1, 1, 3);
  l_poly2 := polynome_Q_pkg.add_polynome_elt (2,-1, 1, 2);
  l_poly2 := polynome_Q_pkg.add_polynome_elt (2, 1, 1, 1);
  l_poly2 := polynome_Q_pkg.add_polynome_elt (2, -1, 1, 0);

  polynome_Q_pkg.print_polynome(l_poly1, false);
  polynome_Q_pkg.print_polynome(l_poly2, false);
  
  l_poly3 := polynome_Q_pkg.multiply_polynomes(l_poly1,l_poly2, 3);
  polynome_Q_pkg.print_polynome(l_poly3, false);
end;
/

-- Degree
declare
l_poly2 polynome_Q_pkg.polynome_row_ty;
l_poly3 polynome_Q_pkg.polynome_row_ty;
l_id    integer;
begin
l_poly2 := polynome_Q_pkg.random_polynome;
l_poly3 := polynome_Q_pkg.random_polynome;
  
  polynome_Q_pkg.print_polynome(l_poly2, false); 
  l_id := polynome_Q_pkg.save_polynome (l_poly2);
  dbms_output.put_line ('Degree1: ' || polynome_Q_pkg.degree (l_poly2));
  dbms_output.put_line ('Degree2: ' || polynome_Q_pkg.degree (l_id));
end;
/

--  delete_element
declare
l_poly2 polynome_Q_pkg.polynome_row_ty;
l_poly3 polynome_Q_pkg.polynome_row_ty;
begin
  load_polynome (2);
  l_poly2 := polynome_Q_pkg.load_polynome (2);
  polynome_Q_pkg.print_polynome(l_poly2, false);
  polynome_Q_pkg.save_polynome (l_poly2);
--  l_poly3 := l_poly2;
  l_poly3 := polynome_Q_pkg.delete_element (l_poly2, 2);
  polynome_Q_pkg.print_polynome(l_poly3, false);
  l_poly3 := polynome_Q_pkg.delete_element (2, 2, 2);
 -- l_poly3 := polynome_Q_pkg.load_polynome (2);
  polynome_Q_pkg.print_polynome(l_poly3, false);
end;
/

--  delete_power
declare
l_poly2 polynome_Q_pkg.polynome_row_ty;
l_poly3 polynome_Q_pkg.polynome_row_ty;
begin
  load_polynome (2);
  l_poly2 := polynome_Q_pkg.load_polynome (2);
  polynome_Q_pkg.print_polynome(l_poly2, false);
  polynome_Q_pkg.save_polynome (l_poly2);
--  l_poly3 := l_poly2;
  l_poly3 := polynome_Q_pkg.delete_power (l_poly2, 3, 2);
  polynome_Q_pkg.print_polynome(l_poly3, false);
  l_poly3 := polynome_Q_pkg.delete_power (2, 3, 2);
  polynome_Q_pkg.print_polynome(l_poly3, false);
end;
/

-- divide_polynomes 1
declare
l_poly1 polynome_Q_pkg.polynome_row_ty;
l_poly2 polynome_Q_pkg.polynome_row_ty;
l_id1   number (8);
l_id2   number (8);
begin
execute immediate 'truncate table polynomes_q';
  l_poly1 := polynome_Q_pkg.add_polynome_elt (1, 3, 1, 5);
  l_poly1 := polynome_Q_pkg.add_polynome_elt (1, 1, 1, 3);
  l_poly1 := polynome_Q_pkg.add_polynome_elt (1, 2, 1, 2);
  l_poly1 := polynome_Q_pkg.add_polynome_elt (1, 1, 1, 0);
  polynome_Q_pkg.print_polynome(l_poly1, false);
--
  l_poly2 := polynome_Q_pkg.add_polynome_elt (2, 1, 1, 1);
  l_poly2 := polynome_Q_pkg.add_polynome_elt (2, 1, 1, 0);
  polynome_Q_pkg.print_polynome(l_poly2, false);
-- 
  l_id1 := polynome_Q_pkg.divide_polynomes (1, 2, l_id2, 3);
  dbms_output.put ('Result: ');
  polynome_Q_pkg.print_polynome(l_id1, true);
  dbms_output.put ('Remainder: ');
  polynome_Q_pkg.print_polynome(l_id2, true);
end;
/

-- divide_polynomes 2
declare
l_poly1 polynome_Q_pkg.polynome_row_ty := polynome_Q_pkg.random_polynome;
l_poly2 polynome_Q_pkg.polynome_row_ty;
l_id1   number (8);
l_id2   number (8);
l_id3   number (8);
l_id4   number (8);
begin
execute immediate 'truncate table polynomes_q';
  polynome_Q_pkg.print_polynome(l_poly1, false);
  l_id1 := polynome_Q_pkg.save_polynome (l_poly1);
--
  l_poly2 := polynome_Q_pkg.add_polynome_elt (2, 1, 1, 2);
  l_poly2 := polynome_Q_pkg.add_polynome_elt (2, 1, 1, 0);
  polynome_Q_pkg.print_polynome(l_poly2, false);
  l_id2 := polynome_Q_pkg.save_polynome (l_poly2);
-- 
  l_id4 := polynome_Q_pkg.divide_polynomes (l_id1 , l_id2, l_id3, 3);
  dbms_output.put ('Result: ');
  polynome_Q_pkg.print_polynome(l_id4, true);
  dbms_output.put ('Remainder: ');
  polynome_Q_pkg.print_polynome(l_id3, true);
end;
/


declare
l_id integer (8) := 1;
l_poly polynome_Q_pkg.polynome_row_ty;
begin
l_poly := polynome_Q_pkg.load_polynome(l_id);
--
for j in 0 .. 5
loop
  dbms_output.put_line(rpad('-',100, '+-'));
  polynome_Q_pkg.print_polynome(polynome_Q_pkg.move_x_axis (l_poly, j));
end loop;
end;
/

declare
l_poly1 polynome_Q_pkg.polynome_row_ty;
l_poly2 polynome_Q_pkg.polynome_row_ty;
l_poly3 polynome_Q_pkg.polynome_row_ty;
l_poly4 polynome_Q_pkg.polynome_row_ty;
l_id1   integer;
l_id2   integer;
l_id3   integer;
l_id4   integer;
l_factor     types_pkg.fraction_ty;
begin
execute immediate 'truncate table polynomes_q';
  l_poly1 := polynome_Q_pkg.add_polynome_elt (1, 5, 1, 5);
  l_poly1 := polynome_Q_pkg.add_polynome_elt (1, 4, 1, 0);
  l_id1   := polynome_Q_pkg.save_polynome (l_poly1);
  polynome_Q_pkg.print_polynome(l_poly1);
  
  l_poly2 := polynome_Q_pkg.add_polynome_elt (2, 2, 1, 1);
  l_poly2 := polynome_Q_pkg.add_polynome_elt (2, 1, 1, 0);
  l_id2   := polynome_Q_pkg.save_polynome (l_poly2);
  polynome_Q_pkg.print_polynome(l_poly2);
  
  
--  divide_polynomes (p_id1 in integer, p_id2 in integer, p_remainder in out integer, p_result in integer default null) return integer
  for j in 1 .. 1
  loop
    l_id3 := polynome_Q_pkg.divide_polynomes (l_id1, l_id2, l_id4);	
    l_factor    := fractions_pkg.to_fraction (l_poly2 (1).denominator * l_poly1 (1).numerator, l_poly2 (1).numerator * l_poly1 (1).denominator);
    dbms_output.put_line ('Factor: '); fractions_pkg.print (l_factor);
	dbms_output.put_line ('Power: ' || to_char(l_poly1 (1).poly_power - l_poly2 (1).poly_power));
    dbms_output.put_line ('After subtraction: ');
	polynome_Q_pkg.print_polynome(l_id3);
    dbms_output.put_line ('Remainder: ');
	polynome_Q_pkg.print_polynome(l_id4);
-- Switch
  end loop;
end;
/
