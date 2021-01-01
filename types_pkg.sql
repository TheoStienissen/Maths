create or replace package types_pkg
as
subtype numerator_ty    is number(36);
subtype denominator_ty  is number(36) not null;
type fraction_ty        is record (numerator numerator_ty, denominator denominator_ty default 1);
subtype integer_ty      is number(36);

type complexN_ty is record (re integer(36), im integer(36));
type complexQ_ty is record (re fraction_ty, im fraction_ty);
type complex_ty  is record (re number     , im number);

type polar_ty   is record (radius number, angle number);

type fast_int_ty is table of integer(38) index by binary_integer;
type fast_int_array_ty is table of fast_int_ty index by binary_integer;

type rowid_array_ty is table of rowid index by binary_integer;
pkg_rowid_aray rowid_array_ty;

type int_array_ty is table of integer index by binary_integer;
pkg_int_array int_array_ty;

g_fraction1 types_pkg.fraction_ty;
g_fraction2 types_pkg.fraction_ty;

end types_pkg;
/

create or replace package constants_pkg
as
-- Complex numbers. Dihedron matrices.
D1 constant matrix_pkg.matrix_ty := matrix_pkg.to_matrix_2D(1,0,0,1);
DI constant matrix_pkg.matrix_ty := matrix_pkg.to_matrix_2D(0,1,-1,0);
DJ constant matrix_pkg.matrix_ty := matrix_pkg.to_matrix_2D(0,1,1,0);
DK constant matrix_pkg.matrix_ty := matrix_pkg.to_matrix_2D(1,0,0,-1);

-- Quaternion matrices
Q1 constant matrix_pkg.matrix_ty := matrix_pkg.load_matrix('Quaternion 1');
QI constant matrix_pkg.matrix_ty := matrix_pkg.load_matrix('Quaternion I');
QJ constant matrix_pkg.matrix_ty := matrix_pkg.load_matrix('Quaternion J');
QK constant matrix_pkg.matrix_ty := matrix_pkg.load_matrix('Quaternion K');

-- Eulers constant
g_e  constant number := 2.7182818284590452353602874713526624977;

-- Pi constant
g_pi constant number := 3.1415926535897932384626433832795028841;
end constants_pkg;
/
