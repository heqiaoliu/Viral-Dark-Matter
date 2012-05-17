function c = bitget(a,bit)
% Embedded MATLAB Library function.
%
% BITGET Get bit.
%    C = BITGET(A,BIT)returns the value of the bit at position b of the stored-integer of fi objects a.
%    A must be a fi object matrix, array, or a scalar fi object (signed or unsigned)
%    BIT must be a number between 1 and the fi object, A, word length.
%
% The following cases will not be handled by this function:
%    a is not a fi object
%
% The following cases will error out:
% 1. b is a fi object
% 2. b <=0 or bit > WordLength of a
%
% Note: Difference from the MATLAB Toolbox BITGET:
%   When a and b are both non-fi, the MATLAB Toolbox BITGET restricts a to be unsigned (uint8, uint16, uint32, ...).
% Here we loose the restriction because the Fixed-Point Toolbox BITSET accepts the signed case.

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.16 $ $Date: 2009/03/30 23:29:55 $

% To make sure the number of the input arguments is right
eml_assert(nargin == 2, 'No method <bitget> with matching signature found for class embedded.fi.');

if eml_ambiguous_types
    c = eml_not_const(reshape(zeros(size(a)), size(a)));
    return;
end

eml_assert(~isfi(bit), 'BITGET index only valid for built-in numeric types.');
eml_assert(isreal(a) && isreal(bit), 'Inputs must be real.');
eml_lib_assert(eml_scalexp_compatible(a,bit), 'fixedpoint:fi:dimagree', 'Inputs must have the same size.');
eml_assert(~isfi(bit) && isnumeric(bit), 'BITGET index only valid for built-in numeric types');

Ta = eml_typeof(a);
eml_prefer_const(bit);
if eml_is_const(bit)
    eml_assert(all(bit(:) > 0) && all(bit(:) <= Ta.WordLength), 'Invalid bit position: 1 <= bit_position <= wordlength(input)');
end

if isfixed(a)
    % Fixed FI

    Tbit = numerictype(0,1,0);
    Fbit = fimath(a);

    % First decide the output size
    % If a is a fimath-less fi then c is also one.
    if ~isscalar(a)
        c1 = eml_cast(zeros(size(a)),Tbit,Fbit);
    else
        c1 = eml_cast(zeros(size(bit)),Tbit,Fbit);
    end
    
    if eml_const(eml_fimathislocal(a))
        c = c1;
    else
        c = eml_fimathislocal(c1,false);
    end
    
    if isscalar(c)
        eml_must_inline;
    end


    for k = 1:eml_numel(c)
        % Here we trust the compiler to optimize invariant cases inside the loop.
	a1 = eml_scalexp_subsref(a,k);
	bit1 = eml_scalexp_subsref(bit,k);
        
        zero = eml_cast(0,Tbit,Fbit);

        if bit1 >= 1 && bit1 <= Ta.wordLength
            
            bit_idx = eml_minus(uint8(bit1),uint8(1),'uint8');
            c(k) = eml_bitslice(a1, bit_idx, bit_idx);
            
        else

            eml_error('MATLAB:bitSetGet:BITOutOfRange','BIT must be integers between 1 and %i for %s.',...
                      Ta.wordLength, class(a1));
            c(k) = zero;
        end
    end

else
    % FI datatype not supported
    eml_fi_assert_dataTypeNotSupported('BITGET','fixed-point');
end
