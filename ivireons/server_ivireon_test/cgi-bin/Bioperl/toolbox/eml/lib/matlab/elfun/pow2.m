function y = pow2(a,b)
%Embedded MATLAB Library Function

%   Copyright 2005-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(a,'float'), ...
    ['Function ''pow2'' is not defined for values of class ''' class(a) '''.']);
if nargin == 1
    y = eml.nullcopy(a);
    for k = 1:eml_numel(a)
        y(k) = eml_scalar_pow2(a(k));
    end
else
    eml_assert(isa(b,'float'), ...
        ['Function ''pow2'' is not defined for values of class ''' class(b) '''.']);
    if ~isreal(a) || ~isreal(b)
        eml_warning('MATLAB:pow2:ignoredImagPart','Imaginary part is ignored.');
    end
    % Initialize output Y with processed exponents.
    y = eml_scalexp_alloc(eml_scalar_eg(real(a),real(b)),a,b);
    y(:) = limit_exponent(real(b));
    for k = 1:eml_numel(y)
        % y(k) = real(a(k)) * (2 ^ fix(real(b(k))));
        y(k) = eml_scalar_pow2(real(eml_scalexp_subsref(a,k)),y(k));
    end
end

%--------------------------------------------------------------------------

function b = limit_exponent(b)
% Currently, eml_ldexp requires a float for the second argument and does
% a straight cast to int32.  We need to saturate the cast, at least, but
% it turns out that ldexp implementations may not be reliable with very
% large exponent arguments.  So we confine the exponent to a
% a limited range and hope the C compiler's ldexp will get it right.
% The 'int16' limits are generous for double precision IEEE floating
% point, but they might not be correct for other exponent ranges.
for k = 1:eml_numel(b)
    if b(k) < 0
        b(k) = eml_scalar_ceil(b(k));
        if b(k) < intmin('int16')
            b(k) = intmin('int16');
        end
    else
        b(k) = eml_scalar_floor(b(k));
        if b(k) > intmax('int16')
            b(k) = intmax('int16');
        end
    end
end

%--------------------------------------------------------------------------
