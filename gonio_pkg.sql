Doc

  Author   :  Theo Stienissen
  Date     :  August 2022
  Purpose  :  Gonio functions based on Taylor arrays. Not serious, just playing.
  Contact  :  theo.stienissen@gmail.com
  Script   :  @C:\Users\Theo\OneDrive\Theo\Project\Maths\gonio_pkg.sql

#

set serveroutput on size unlimited

alter session set plsql_warnings = 'ENABLE:ALL'; 

create or replace package gonio_pkg
is
function t_sin (p_angle in number, p_degrees_radians in varchar2 default 'D') return number;

function t_cos (p_angle in number, p_degrees_radians in varchar2 default 'D') return number;

function t_tan (p_angle in number, p_degrees_radians in varchar2 default 'D') return number;

end gonio_pkg;
/


create or replace package body gonio_pkg
is
function t_sin (p_angle in number, p_degrees_radians in varchar2 default 'D') return number
is
l_angle_radians number;
l_result number := 0;
begin
  if p_degrees_radians = 'D'
  then l_angle_radians := (p_angle / 180) * constants_pkg.g_pi;
  else l_angle_radians := p_degrees_radians;
  end if;

  if l_angle_radians between 0 and constants_pkg.g_pi / 2
  then
    for j in 0 .. 15
    loop
      l_result := l_result + power (-1, j) * power (l_angle_radians, 2 * j + 1) / maths.nfac (2 * j + 1);
    end loop;
    return l_result;
  elsif l_angle_radians < 0 then return - t_sin (- l_angle_radians);
  elsif l_angle_radians < constants_pkg.g_pi then return t_sin (constants_pkg.g_pi - l_angle_radians);
  else  return t_sin (l_angle_radians - trunc (l_angle_radians / (2 * constants_pkg.g_pi)) * 2 * constants_pkg.g_pi);
  end if;  
  
exception when others then
  util.show_error ('Error in function t_sin.', sqlerrm);
  return null;
end t_sin;

function t_cos (p_angle in number, p_degrees_radians in varchar2 default 'D') return number
is
l_angle_radians number;
l_result number := 0;
begin
  if p_degrees_radians = 'D'
  then l_angle_radians := (p_angle / 180) * constants_pkg.g_pi;
  else l_angle_radians := p_degrees_radians;
  end if;


  if l_angle_radians between 0 and constants_pkg.g_pi / 2
  then
  for j in 0 .. 15
  loop
    l_result := l_result + power (-1, j) * power (l_angle_radians, 2 * j ) / maths.nfac (2 * j);
  end loop;
  return l_result;
  elsif l_angle_radians < 0 then return t_cos (- l_angle_radians);
  elsif l_angle_radians < constants_pkg.g_pi then return - t_cos (constants_pkg.g_pi - l_angle_radians);
  else  return t_cos (l_angle_radians - trunc (l_angle_radians / (2 * constants_pkg.g_pi)) * 2 * constants_pkg.g_pi);
  end if;  
  
exception when others then
  util.show_error ('Error in function t_cos.', sqlerrm);
  return null;
end t_cos;

function t_tan (p_angle in number, p_degrees_radians in varchar2 default 'D') return number
is
begin
  return gonio_pkg.t_sin (p_angle, p_degrees_radians) / gonio_pkg.t_cos (p_angle, p_degrees_radians);

exception when others then
  util.show_error ('Error in function t_tan.', sqlerrm);
  return null;
end t_tan;
end gonio_pkg;
/


show error

