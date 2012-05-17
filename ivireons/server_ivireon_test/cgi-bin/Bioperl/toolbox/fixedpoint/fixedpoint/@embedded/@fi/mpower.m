function y = mpower(a, k)
%^      FI matrix power.
%   Y = A^K and Y=MPOWER(A,K) compute matrix power. The exponent K must 
%   be a positive, real-valued integer.
%
%   The fixed-point output array Y is always associated with the global
%   fimath.
%
%   Refer to the MATLAB MPOWER reference page for more information.
%
%   The following example computes the power of a 2-dimensional square
%   matrix for exponents 0, 1, 2, 3.
%
%   x = fi([0 1; 2 4], 1, 32);
%   % x is a signed FI object with a 32-bit word length, and 28-bit (best
%   % precision) fraction length.
%   px0 = x^0
%   % px0 is a FI object with the value [1 0; 0 1], a unsigned numerictype
%   % with 1-bit word length and 0 fraction length.
%   px1 = x^1
%   % px1 is same as x
%   px2 = x^2
%   % px2 is a FI object with the value [2 4; 8 18], a signed numerictype
%   % with 65-bit word length and 56-bit fraction length.
%   px3 = x^3
%   % px3 is a FI object with the value [8 18; 36 80], a signed numerictype
%   % with 98-bit word length and 84-bit fraction length.
%
%   See also EMBEDDED.FI/MPOWER, MPOWER

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2009/10/24 19:04:09 $

validateInputsToStatFunctions(a,'mpower');
if ~isreal(k)||~isequal(k , floor(k))||~isscalar(k)||(k < 0)
    
    error('fi:mpower:exponentPositiveRealInt',...
        'Exponent input to ''mpower'' must be a positive, real-valued integer.');
end
if (ndims(a) > 2)||(~isscalar(a)&&(size(a,1)~=size(a,2)))
    
    error('fi:mpower:inputMustBe2D','Input must be square 2-D matrix, or a scalar.');
end

if ~isfloat(a)
    err = validate_power_output_type(a,k,true);
    if ~isempty(err)
    
        error('fi:mpower:maxProductOrSumWordLengthMustNotBeExceeded',err);
    end
end
k = double(k);
if isfloat(a)
    
    y = fi(mpower(double(a), k), numerictype(a));
elseif (k == 1)
    
    y = a;
elseif (k == 0)
    
    tEye = numerictype(false,1,0);
    y = fi(eye(size(a)), tEye);
else

    y = a*a;
    for pwridx = 3:1:k
        y = y*a;
    end    
end
    
if isfi(y)
    
    y.fimathislocal = false;
end
