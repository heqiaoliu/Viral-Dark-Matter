function c = bitset(a,bit,v)
% Embedded MATLAB Library function.
%
% BITSET Set bit.
%    C = BITSET(A,BIT) sets bit position BIT in A to 1 (on). 
%    A must be a fi object matrix, array, or a scalar fi object (signed or unsigned)
%    BIT must be a number between 1 and the fi object, A, word length.
% 
%    C = BITSET(A,BIT,V) sets the bit at position BIT to the value V.
%    V must be either 0 or 1.
%
% The following cases will not be handled by this function:
%    a is not a fi object
%
% The following cases will error out:
% 1. b is a fi object
% 2. b <=0 or bit > WordLength of a 
% 3. V is a value other thatn "0" or "1"
%
% Note: Difference from the MATLAB Toolbox BITSET:
%   When a and b are both non-fi, the MATLAB Toolbox BITSET restricts a and b 
%   to be unsigned (uint8, uint16, uint32, ...). Here we loose the restriction 
%   because the Fixed-Point Toolbox BITSET accepts the signed case.

% Copyright 2002-2009 The MathWorks, Inc.
%#eml
% $Revision: 1.1.6.15 $  $Date: 2009/06/16 03:45:40 $

% To make sure the number of the input arguments is right
eml_assert(nargin >= 2, 'Not enough input arguments.');

eml_prefer_const(bit); % g421453

eml_assert(nargin <= 3, 'No method ''bitset'' with matching signature found for class ''embedded.fi''.');

if eml_ambiguous_types
    c = eml_not_const(reshape(zeros(size(a)), size(a)));
    return;
end

eml_assert(isfi(a), 'Input must be fi object.');
eml_assert(~isfi(bit) && isnumeric(bit), 'BITSET index only valid for built-in numeric types');


if nargin < 3
    v = int8(ones(size(bit)));
end

eml_assert(isnumeric(v) || islogical(v), 'BITSET value only valid for built-in numeric types');


eml_assert(isreal(a) && isreal(bit) && isreal(v), 'Inputs must be real.');

if isfixed(a)
    % Fixed FI

    Ta = eml_typeof(a);
    Fa = fimath(a);

    %c = a;
    c = eml_scalexp_alloc(eml_scalar_eg(a),a,bit,v);

    if isscalar(c)
        eml_must_inline;
    end
    
    aWL = Ta.WordLength;

    lsbOne = lsb(fi(0, Ta, Fa));
    
    for k = 1:numel(c)
        % Here we trust the compiler to optimize invariant cases inside the loop.
        a1 = eml_scalexp_subsref(a,k);      
        bit1 = eml_scalexp_subsref(bit,k);
        biton = eml_scalexp_subsref(v,k);
        
        
        if bit1 >= 1 && bit1 <= aWL
            
            % compute mask; shift 'lsbOne' left by 'pos-1'
            % the type of mask should be same as lsbOne which is 
            % inturn same as 'a'; this is requrired for 
            % eml_bitor and eml_bitand to work
            
            mask = eml_lshift(lsbOne, uint8(bit1-1));        
            
            if biton
                c(k) = eml_bitor(a1,mask);
            else
                c(k) = eml_bitand(a1,eml_bitnot(mask));
            end
        else
            eml_error('MATLAB:bitSetGet:BITOutOfRange','BIT must be integers between 1 and %i for %s.',...
                  aWL,class(a1));
            %%%Do nothing.
            % c(k) will remain uninitialized.
        end
    end

else
    % FI datatype not supported
    eml_fi_assert_dataTypeNotSupported('BITSET','fixed-point');
end
