function c = bitand(a,b)
%Embedded MATLAB Library Function
%   Limitations:
%   Floating point inputs are not supported.

%   Copyright 1984-2007 The MathWorks, Inc.
%#eml 

eml_assert(nargin == 2, 'Not enough input arguments.');
eml_lib_assert(eml_scalexp_compatible(a,b), ...
    'MATLAB:andOrXor:sizeMismatch', ...
    'Inputs must have the same size.');
if eml_ambiguous_types
    % Compiler needs output of the appropriate size.
    if isscalar(a) 
        c = zeros(size(b),class(a));
    else
        c = zeros(size(a),class(a));
    end
    return
end
eml_assert(isreal(a) && isreal(b), 'Inputs must be real.');
eml_must_inline;
if eml_isa_uint(a) 
    if isa(a,class(b))
        c = eml_bitand(a,b);
        return
    elseif isa(b,'double') && isscalar(b)
        c = eml_bitand(a,cast(b,class(a)));
        return
    end
elseif eml_isa_uint(b) && isa(a,'double') && isscalar(a)
    c = eml_bitand(cast(a,class(b)),b);
    return
end
eml_assert(false,'Inputs must be unsigned integers of the same class or one input may be a scalar double.');
