Doc

  Author   : Theo Stienissen
  Date     : 2018
  contact  : theo.stienissen@gmail.com

#

set serveroutput on size unlimited

create or replace package modulo_pkg
as

function add (p_integer1 in integer, p_integer2 in integer, p_mudulus in integer) return integer;

end modulo_pkg;
/



create or replace package body modulo_pkg
as

function add (p_integer1 in integer, p_integer2 in integer, p_mudulus in integer) return integer
is
l_mod integer :=  mod(p_integer1 + p_integer2, p_mudulus);
begin
if l_mod < 0
then
  l_mod := l_mod + p_integer1 + p_integer2;
end if;

return mod(p_integer1 + p_integer2, p_mudulus);

exception when others then
  util.show_error('Error in function add. Value 1: ' || p_integer1 || ', ' || p_integer2 || ', Value 2: ' || p_mudulus || ', Modulus: ' || p_mudulus || '.', sqlerrm);
end bin2dec;

/*************************************************************************************************************************************************/



end modulo_pkg;
/



