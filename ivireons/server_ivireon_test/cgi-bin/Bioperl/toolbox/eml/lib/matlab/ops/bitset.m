function c = bitset(a,bit,v)
%Embedded MATLAB Library Function

%   Limitations:
%   Floating point inputs for A are not supported.

%   Copyright 1984-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 2, 'Not enough input arguments.');
if nargin < 3
    v = true;
end
if eml_ambiguous_types
    % Compiler needs output of the appropriate size
    c = eml_scalexp_alloc(0,a,bit,v);
    c(:) = 0;
    return
end
eml_assert(eml_isa_uint(a), 'First argument must be an unsigned integer.');
eml_assert(isreal(a) && isreal(bit) && isreal(v), 'Inputs must be real.');
c = eml_scalexp_alloc(eml_scalar_eg(a),a,bit,v);
if isempty(c)
    eml_must_inline;
    return
end
if isscalar(c)
    eml_must_inline;
end
for k = 1:eml_numel(bit)
    if bit(k) < 1 || bit(k) > eml_int_nbits(class(a)) || bit(k) ~= floor(bit(k))
        eml_error('MATLAB:bitSetGet:BITOutOfRange', ...
            'BIT must be integers between 1 and %i for %s.',...
            eml_int_nbits(class(a)),class(a));
    end
end
for k = 1:eml_numel(c)
    ak = eml_scalexp_subsref(a,k);
    bitk = eml_scalexp_subsref(bit,k);
    mask = eml_lshift(ones(class(a)),eml_minus(bitk,1,'uint8'));
    biton = logical(eml_scalexp_subsref(v,k));
    if biton
        c(k) = eml_bitor(ak,mask);
    else
        c(k) = eml_bitand(ak,eml_bitnot(mask));
    end
end
