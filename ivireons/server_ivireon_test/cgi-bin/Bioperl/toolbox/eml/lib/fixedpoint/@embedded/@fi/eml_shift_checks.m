function eml_shift_checks(fnname, a, shift_idx)

%   Copyright 2002-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2010/05/20 02:16:09 $

%#eml

eml_prefer_const(fnname, a, shift_idx);

% To make sure the number of the input arguments is right
eml_assert(isfi(a), [fnname ' input must be of fixed point type.']);

eml_assert(isscalar(shift_idx), [fnname ' shift index operand must be a real integer-valued scalar.']);
eml_assert(isreal(shift_idx),   [fnname ' shift index operand must be a real integer-valued scalar.']);
eml_assert(~isfi(shift_idx),    [fnname ' shift index operand must be a real integer-valued scalar.']);

aNT = numerictype(a);
eml_assert(aNT.WordLength > 1, [fnname ' not supported for 1-bit input operand']);

% except bitshift none of the new functions support slope bias
if ~strcmp(fnname, 'bitshift')
    eml_assert(~eml_isslopebiasscaled(a), [fnname ' does not support slope-bias scaled fis.']);
end

if eml_is_const(shift_idx)
    eml_assert(isequal(double(shift_idx), eml_const(double(int32(shift_idx)))), ...
               [fnname ' shift index operand must be a real integer-valued scalar.']);
end
