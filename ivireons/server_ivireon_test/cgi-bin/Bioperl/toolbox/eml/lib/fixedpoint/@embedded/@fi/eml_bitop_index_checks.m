function eml_bitop_index_checks(fnname, a,lidx,ridx)

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.6 $ $Date: 2008/04/14 19:34:04 $

% To make sure the number of the input arguments is right
eml_assert(nargin == 4, 'Internal error: no matching signature found for class embedded.fi.');

eml_prefer_const(lidx);
eml_prefer_const(ridx);

eml_assert(isfi(a), [fnname ' input must be of fixed point type.']);

eml_assert(~eml_isslopebiasscaled(a), [fnname ' does not support slope-bias scaled fis.']);

Ta = eml_typeof(a);

eml_assert(~isfi(lidx), [fnname ' left index only valid for built-in numeric types.']);
eml_assert(~isfi(ridx), [fnname ' right index only valid for built-in numeric types.']);

eml_assert(isequal(class(lidx), class(ridx)), 'index constants must be of the same class');

eml_assert(isreal(a) && isreal(lidx) && isreal(ridx), 'Inputs must be real.');

eml_assert(eml_scalexp_compatible(a,lidx), 'Inputs must have the same size.');
eml_assert(eml_scalexp_compatible(a,ridx), 'Inputs must have the same size.');

eml_assert(isnumeric(lidx), [fnname ' left index only valid for built-in numeric types']);
eml_assert(isnumeric(ridx), [fnname ' right index only valid for built-in numeric types']);

eml_assert(eml_is_const(lidx), 'left index needs to be a constant');
eml_assert(eml_is_const(ridx), 'right index needs to be a constant');

eml_assert(isscalar(lidx), 'left index needs to be a scalar');
eml_assert(isscalar(ridx), 'right index needs to be a scalar');

eml_assert(eml_const(lidx) <= eml_const(Ta.WordLength), 'left index should be less than or equal to wordlength of input operand');
eml_assert(eml_const(lidx) > 0, 'left index should be greater than zero');
eml_assert(eml_const(ridx) > 0, 'right index should be greater than zero');
eml_assert(eml_const(lidx) >= eml_const(ridx), 'left index should be greater or equal to right index');

