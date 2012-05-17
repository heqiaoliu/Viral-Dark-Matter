function c = bitshift(a,k,n)
% Embedded MATLAB Library function.
%
% BITSHIFT bitwise shift.
%    C = BITSHIFT(A,K) returns a fi object whose stored-integer is equal
%    to the stored-integer of the input fi object A shifted by K bits.
%    A must be a fi object matrix, array, or a scalar fi object (signed or unsigned)
%    K can be any scalar number.
%
% The following cases will not be handled by this function:
%    A is not a fi object
%
% The following cases will error out:
% 1. A is a fi object with DataType of double
% 2. k is a complex number
% 3. k is a vector
%
% Note: Difference from the MATLAB Toolbox BITSHIFT:
%   the MATLAB Toolbox BITSHIFT restricts a to be unsigned (uint8, uint16, uint32, ...). Here we loose the restriction
%   just to be consistent with the Fixed-Point Toolbox BITSHIFT.
%
%   bitshift(a,K,N) format is not supported to be consistent with the Fixed-Point Toolbox BITSHIFT.
%

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.12 $  $Date: 2009/03/30 23:29:56 $  

% To make sure the number of the input arguments is right

fnname = 'bitshift';

eml_assert(nargin == 2, ['No method ''' fnname ''' with matching signature found for class ''embedded.fi''.']);
eml_prefer_const(k);

if eml_ambiguous_types
    c = eml_not_const(reshape(zeros(size(a)), size(a)));
    return;
end

eml_shift_checks(fnname, a, k); 


if ~isfixed(a)
    % FI datatype not supported
    eml_fi_assert_dataTypeNotSupported('BITSHIFT','fixed-point');
end

% Inline the generated code if a is a scalar
if isscalar(a)
    eml_must_inline;
end

if isreal(a)
    c = localBitShift(a,k);
else
    cr = localBitShift(real(a),k);
    ci = localBitShift(imag(a),k);
    c = complex(cr,ci);
end

%--------------------------------------------------------------------------------
function yout = localBitShift(xin,kin)

eml_prefer_const(kin);

eml_must_inline;

x = rescale(xin,1,0);% x is the stored integer

y = x;
if kin>0 % kin may be a run-time value, test it once per input.
    k = uint8(kin);
    for m = 1 : numel(y)
        y(m) = intLeftShift(x(m),k);
    end
else
    if kin <= -128
        k = uint8(128);
    else 
        k = uint8(-kin);
    end
    for m = 1 : numel(y)
        y(m) = intRightShift(x(m),k);
    end
end

Tin = numerictype(xin);
Fin = fimath(xin);
yHasLocalFimath = eml_fimathislocal(xin);
yout = eml_fimathislocal(eml_dress(y, Tin, Fin),yHasLocalFimath);

%--------------------------------------------------------------------------------
function y = intLeftShift(x,k)

eml_prefer_const(k);

T = eml_typeof(x);
F = eml_fimath(x);

doSaturate = eml_const(isequal(F.OverflowMode,'saturate'));

% Actually performing throw-away shifts (ie, a shift that throws away all
% the bits in the input) is not safe in C.
% isThrowAwayShift = (k >= T.WordLength);
% We don't use the temporary isThrowAwayShift because it generates poor HDL code.

if doSaturate
    zero = eml_fimathislocal(eml_cast(0,T,F),eml_fimathislocal(x));
    one = eml_fimathislocal(eml_cast(1,T,F),eml_fimathislocal(x));

    % We are shifting left and might drop non-zero bits or change the
    % sign-bit.
    % If that happens saturate.
    if (k >= T.WordLength)
        if T.Signed
           % We have not dropped the sign bit.
           droppedBits = eml_lshift(x,uint8(1));
        else
           droppedBits = x;
        end 
        k(1) = 0; % Can be any valid shift amount.
    else
        if T.Signed
            % We have to see if the bit we are going to shift into the sign
            % position is different than the one currently there.
            droppedBits = eml_rshift(x,int8(T.WordLength - k - 1));
        else
            droppedBits = eml_rshift(x,int8(T.WordLength - k));
        end
    end

    % It would be cool to do the saturation case with out any control-flow.
    %  This is possible, but my best attempt so far is too hideous to
    %  contemplate.
    if T.Signed
        signBitVector = eml_rshift(x,uint8(T.WordLength - 1)); % Does sign extension.
        
        % If saturation is needed the result is
        %      if  signBit then 100000 (ie signBit not(signBitVector))
        %      if ~signBit then 011111 (ie signBit not(signBitVector))
        % If saturation is not needed the result is
        %      y << k but msb(y) == signBit

        if droppedBits ~= signBitVector % if saturationNeeded.
            msbone = eml_lshift(one,uint8(T.WordLength - 1));
            y = eml_bitnot(eml_bitxor(msbone,signBitVector));
        else
            y = eml_lshift(x,k);
        end
    else % unsigned case.
        if droppedBits == zero
            y = eml_lshift(x,k);
        else % Saturate.
            y = eml_bitnot(zero);
        end
    end
else %Wrap
    if (k >= T.WordLength)
        y = eml_fimathislocal(eml_cast(0,T,F),eml_fimathislocal(x));
    else
        y = eml_lshift(x,k);
    end
end

%--------------------------------------------------------------------------------
function y = intRightShift(x,k)

eml_must_inline;

T = eml_typeof(x);

if k>=T.WordLength
    if T.Signed        
        % Right shifting preserves the sign-bit.
        y = eml_rshift(x,uint8(T.WordLength - 1));        
    else
        F = fimath(x);
        y = eml_fimathislocal(eml_cast(0,T,F),eml_fimathislocal(x));
    end
else
    y = eml_rshift(x,k);
end
 
%---------------------------------------------------------------------------------
