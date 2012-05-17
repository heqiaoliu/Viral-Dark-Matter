function c = bitshift(a,k,n)
%Embedded MATLAB Library Function

%   Limitations:
%   Floating point inputs for A are not supported.

%   Copyright 1984-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 2, 'Not enough input arguments.');
if eml_ambiguous_types
    % Compiler needs output of the appropriate size.
    if nargin < 3
        n = 0;
    end
    c = eml_not_const(eml_scalexp_alloc(eml_scalar_eg(a),a,k,n));
    c(:) = 0;
    return
end
eml_assert(eml_isa_uint(a), 'First argument must be an unsigned integer.');
nbits = eml_int_nbits(class(a));
if nargin < 3
    n = nbits;
end
eml_assert(isreal(a) && isreal(k) && isreal(n), 'Inputs must be real.');
c = eml_scalexp_alloc(eml_scalar_eg(a),a,k,n);
if isempty(c)
    eml_must_inline;
    return
end
if isscalar(c)
    eml_must_inline;
end
for m = 1:eml_numel(k)
    if k(m) ~= floor(k(m))
        eml_error('MATLAB:bitshift:inputsMustBeIntegers','Inputs must be integers.');
    end
end
for m = 1:eml_numel(n)
    if n(m) ~= floor(n(m))
        eml_error('MATLAB:bitshift:inputsMustBeIntegers','Inputs must be integers.');
    end
end
codingForHdl = strcmp(eml.target(),'hdl');
for m = 1:eml_numel(c)
    a1 = eml_scalexp_subsref(a,m);
    k1 = eml_scalexp_subsref(k,m);
    n1 = eml_scalexp_subsref(n,m);
    c(m) = 0;
    if n1 > 0
        if k1 < 0
            absk1 = uint8(-k1);
            if absk1 < nbits
                c(m) = eml_rshift(a1,absk1);
            end
        else
            absk1 = uint8(k1);
            if absk1 < nbits
                c(m) = eml_lshift(a1,absk1);
            end
        end
        if n1 < nbits
            if codingForHdl
                c(m) = eml_bitslice(c(m),eml_minus(n1,1,'uint8'),uint8(0));
            else
                mask = eml_bitnot(eml_lshift(intmax(class(a)),uint8(n1)));
                c(m) = eml_bitand(c(m),mask);
            end
        end
    end
end
