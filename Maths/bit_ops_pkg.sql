Doc
  Bytewise logical operations demo
  Implementation of boolean array
  
  The first character of a binary string denotes the sign. 0: >= 0, 1 := < 0
  
  INTEGERS IN REVERSE ORDER. So index 1 comes at the end.
  
function bitvalue (p_array in word_ty, p_position in integer) return integer; -- boolean?

/

#


-- Bitwise logical operations

create or replace package bit_ops_pkg
is
type word_ty    is table of number(36) index by pls_integer;
g_base          constant integer := 1e18;

function decimal_to_bin (p_value in integer)  return varchar2;
function bin_to_decimal (p_value in varchar2) return integer;

function bitand         (p_x in integer, p_y in integer) return integer;
function bitand         (p_x in word_ty, p_y in word_ty) return word_ty;

function bitor          (p_x in integer, p_y in integer) return integer;
function bitor          (p_x in word_ty, p_y in word_ty) return word_ty;

function bitxor         (p_x in integer, p_y in integer) return integer;
function bitxor         (p_x in word_ty, p_y in word_ty) return word_ty;

function bitnot         (p_x in integer)                 return integer;
function bitnot         (p_x in word_ty)                 return word_ty;

function bitshift_left  (p_x in integer, p_y in integer) return integer;
function bitshift_left  (p_x in word_ty, p_y in integer) return word_ty;

function bitshift_right (p_x in integer, p_y in integer) return integer;
function bitshift_right (p_x in word_ty, p_y in integer) return word_ty;
end bit_ops_pkg;
/


create or replace package body bit_ops_pkg
is
--
-- Binary to decimal
--
function bin_to_decimal (p_value in varchar2) return integer
is
begin
  if p_value is null or p_value in ('0', '1') then return null;
  else
    if    substr (p_value, 1, 1) = '1' then return - maths.bin_to_decimal (substr (p_value, 2));
    elsif substr (p_value, 1, 1) = '0' then return   maths.bin_to_decimal (substr (p_value, 2));
	else  raise_application_error (-20001, 'Invalid sign: ' || substr (p_value, 1, 1));
    end if;
  end if; 

exception when others then
  util.show_error ('Error in function bin_to_decimal for value: ' || p_value || '.', sqlerrm);
  return null;
end bin_to_decimal;

/*************************************************************************************************************************************************/

--
-- Decimal to binary
--
function decimal_to_bin (p_value in integer) return varchar2
is
l_value      integer (38) := p_value;
l_bin_string varchar2 (100);
begin
  case when p_value is null then return null;
  when p_value >= 0 then return '0' || maths.decimal_to_bin (p_value);
  else return '1' || maths.decimal_to_bin (- p_value); end case;

exception when others then
  util.show_error ('Error in function decimal_to_bin. For value: ' || to_char(p_value) || '.', sqlerrm);
  return null;
end decimal_to_bin;

/*************************************************************************************************************************************************/

--
-- Both bits must be 1 to return 1 else return 0
--
function bitand  (p_x in integer, p_y in integer) return integer
is
begin
  return sys.standard.bitand (p_x, p_y);

exception when others then
  util.show_error ('Error in function bitand for value: ' || to_char(p_x) || ' and ' || to_char(p_y) || '.', sqlerrm);
  return null;
end bitand;

/*************************************************************************************************************************************************/

--
-- Array version of bitand
--
function bitand (p_x in word_ty, p_y in word_ty) return word_ty
is
l_array  word_ty;
begin
  for j in 1 .. least (p_x.count, p_y.count)
  loop 
    l_array (j) := sys.standard.bitand (p_x (j), p_y (j));
  end loop;
  return l_array;

exception when others then
  util.show_error ('Error in function bitand.', sqlerrm);
  return l_array;
end bitand;

/*************************************************************************************************************************************************/

--
-- Logical OR function for integers represented as bits
--
function bitor (p_x in integer, p_y in integer) return integer
is
begin
  return p_x + p_y - bitand (p_x, p_y);

exception when others then
  util.show_error ('Error in function bitor for value: ' || to_char(p_x) || ' and ' || to_char(p_y) || '.', sqlerrm);
  return null;
end bitor;

/*************************************************************************************************************************************************/

--
-- Array logical OR
--
function bitor (p_x in word_ty, p_y in word_ty) return word_ty
is
l_array  word_ty;
begin
  for j in 1 .. greatest (p_x.count, p_y.count)
  loop
    if p_x.count <=	p_y.count
	then 
	  if j > p_x.count then l_array (j) := p_y (j); else l_array (j) := bitor (p_x (j), p_y (j)); end if;	
	else 
	  if j > p_y.count then l_array (j) := p_x (j); else l_array (j) := bitor (p_x (j), p_y (j)); end if;	
	end if;  
  end loop;
  return l_array;

exception when others then
  util.show_error ('Error in function bitor.', sqlerrm);
  return l_array;
end bitor;

/*************************************************************************************************************************************************/

--
-- Exclusive or
--
function bitxor (p_x in integer, p_y in integer) return integer
is
begin
  return bitor (p_x, p_y) - bitand (p_x, p_y);

exception when others then
  util.show_error ('Error in function bitxor for value: ' || to_char(p_x) || ' and ' || to_char(p_y) || '.', sqlerrm);
  return null; 
end bitxor;

/*************************************************************************************************************************************************/

--
-- Array exclusive or
--
function bitxor (p_x in word_ty, p_y in word_ty) return word_ty
is
l_array  word_ty;
begin
  for j in 1 .. least (p_x.count, p_y.count)
  loop
    l_array (j) := bitxor (p_x (j), p_y (j));
  end loop;
  return l_array;

exception when others then
  util.show_error ('Error in function bitxor.', sqlerrm);
  return l_array;  
end bitxor;

/*************************************************************************************************************************************************/

--
-- Inconsistent with previous functions
--
function bitnot (p_x in integer) return integer
is
begin
  return - p_x - 1;

exception when others then
  util.show_error ('Error in function bitnot for value: ' || to_char(p_x) || '.', sqlerrm);
  return null;  
end bitnot;

/*************************************************************************************************************************************************/

--
--
--
function bitnot (p_x in word_ty) return word_ty
is
l_array  word_ty;
begin
  for j in 1 .. p_x.count
  loop
    l_array (j) := bitnot (p_x (j));
  end loop;
  return l_array;

exception when others then
  util.show_error ('Error in function bitnot.', sqlerrm);
  return l_array;
end bitnot;

/*************************************************************************************************************************************************/

--
-- ToDo
--
function bitshift_left (p_x in integer, p_y in integer) return integer
is
begin
  return p_x * power (2, p_y);

exception when others then
  util.show_error ('Error in function bitshift_left for value: ' || to_char(p_x) || ' and ' || to_char(p_y) || '.', sqlerrm);
  return null;   
end bitshift_left;

/*************************************************************************************************************************************************/

--
-- ToDo
--
function bitshift_left (p_x in word_ty, p_y in integer) return word_ty
is
l_array  word_ty;
begin
  for j in 1 .. p_x.count
  loop
    l_array (j) := p_x (j) * power(2, p_y);
  end loop;
  return l_array;

exception when others then
  util.show_error ('Error in function bitshift_left.', sqlerrm);
  return l_array;  
end bitshift_left;

/*************************************************************************************************************************************************/

--
--
--
function bitshift_right (p_x in integer, p_y in integer) return integer
is
begin
  return trunc(p_x / power(2, p_y));

exception when others then
  util.show_error ('Error in function bitshift_right for value: ' || to_char(p_x) || ' and ' || to_char(p_y) || '.', sqlerrm);
  return null;
end bitshift_right;

/*************************************************************************************************************************************************/

--
-- ToDo
--
function bitshift_right (p_x in word_ty, p_y in integer) return word_ty
is
l_array  word_ty;
begin
  for j in 1 .. p_x.count
  loop
    l_array (j) := trunc (p_x (j) / power(2, p_y));
  end loop;
  return l_array;

exception when others then
  util.show_error ('Error in function bitshift_right.', sqlerrm);
  return l_array;   
end bitshift_right;

end bit_ops_pkg;
/

