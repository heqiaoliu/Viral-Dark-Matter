function c = bitget(a,bit)
%Embedded MATLAB Library Function

%   Limitations:
%       Floating point input for A is not supported.

%   Copyright 1984-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin == 2, 'Not enough input arguments.');
eml_assert(isreal(a) && isreal(bit), 'Inputs must be real.');
c = eml_scalexp_alloc(eml_scalar_eg(a),a,bit);
if eml_ambiguous_types
    % Compiler only needs output of the appropriate size.
    c(:) = 0;
    return
end
eml_assert(eml_isa_uint(a), 'First argument must be an unsigned integer.');
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
codingForHdl = strcmp(eml.target(),'hdl');
for k = 1:eml_numel(c)
    ak = eml_scalexp_subsref(a,k);
    bitkm1 = eml_minus(eml_scalexp_subsref(bit,k),1,'uint8');
    if codingForHdl
        c(k) = eml_bitslice(ak,bitkm1,bitkm1) ~= 0;
    else
        c(k) = eml_bitand(ak,eml_lshift(ones(class(a)),bitkm1)) ~= 0;
    end
end
