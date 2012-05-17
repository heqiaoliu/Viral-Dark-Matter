function c = bitcmp(a,bit)
%Embedded MATLAB Library Function

%   Limitations:
%       Floating point inputs are not supported.

%   Copyright 1984-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 1, 'Not enough input arguments.');
eml_assert(nargin == 1 || (isscalar(bit) && isreal(bit)),...
    'The BIT argument to BITCMP must be a real scalar integer.');
if eml_ambiguous_types
    % Compiler needs output of the appropriate size.
    c = zeros(size(a),class(a));
    return
end
eml_assert(isreal(a), 'Inputs must be real.');
eml_assert(eml_isa_uint(a), 'First argument must be an unsigned integer.');
c = eml_bitnot(a);
if nargin == 1
    eml_must_inline;
else
    ulen = eml_int_nbits(class(a));
    if bit < 0 || bit > ulen || bit ~= floor(bit)
        eml_error('MATLAB:bitcmp:bitArgMustBeIntInAppropriateRange', ...
            'The BIT argument to BITCMP must be a real scalar integer in the appropriate range.');
        % Note that bit is cast to uint8 before being used.
        % The case bit > ulen is OK.
    end
    if bit < ulen
        codingForHdl = strcmp(eml.target(),'hdl');
        if codingForHdl
            if bit >= 1
                bitm1 = eml_minus(bit,1,'uint8');
                for k = 1:eml_numel(c)
                    c(k) = eml_bitslice(c(k),bitm1,uint8(0));
                end
            else
                c(:) = 0;
            end
        else
            mask = eml_bitnot(eml_lshift(intmax(class(a)),uint8(bit)));
            c = eml_bitand(mask,c);
        end
    end
end
