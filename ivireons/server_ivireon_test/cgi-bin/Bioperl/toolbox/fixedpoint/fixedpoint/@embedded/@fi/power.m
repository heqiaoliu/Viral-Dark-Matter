function y = power(a,k)
%.^     FI array power.
%   Y = A.^K, and Y = POWER(A,K) compute element-by-element power. The 
%   exponent K must be a positive, real-valued integer.
%
%   The fixed-point output array Y is always associated with the global
%   fimath.
%
%   Refer to the MATLAB POWER reference page for more information.
%
%   The following example computes the power of a 2-dimensional array for
%   exponents 0, 1, 2 and 3.
%
%   x = fi([0 1 2; 3 4 5], 1, 32);
%   % x is a signed FI object with a 32-bit word length, and 28-bit (best
%   % precision) fraction length.
%   px0 = x.^0
%   % px0 is a FI object with the value [1 1 1; 1 1 1], a unsigned
%   % numerictype with 1-bit word length and 0 fraction length.
%   px1 = x.^1
%   % px1 is same as x
%   px2 = x.^2
%   % px2 is a FI object with the value of [0 1 4; 9 16 25], a signed
%   % numerictype with 64-bit word length, and 56-bit fraction length.
%   px3 = x.^3
%   % px2 is a FI object with the value of [0 1 8; 27 64 125], a signed 
%   % numerictype with 96-bit word length and 84-bit fraction length.
%
%   See also EMBEDDED.FI/POWER, POWER

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2009/10/24 19:04:10 $

validateInputsToStatFunctions(a,'power');
if ~isreal(k)||~(isequal(k , floor(k)))||~isscalar(k)||(k < 0)
    
    error('fi:power:exponentMustBeRealIntScalar',...
        'Exponent input to ''power'' must be a positive, real-valued integer.');
end
if ~isfloat(a)
    err = validate_power_output_type(a, k,false);
    if ~isempty(err)
    
        error('fi:power:maxProductOrSumWordLengthMustNotBeExceeded',err);
    end
end
k = double(k);
if isfloat(a)
    
    y = fi(power(double(a),k), numerictype(a));
elseif (k == 1)
    
    y = a;
elseif (k == 0)
    
    tOnes = numerictype(false,1,0);
    y = fi(ones(size(a)), tOnes);
else
    
    y = a.*a;
    for pwridx = 3:1:k
        y = y.*a;
    end 
end
    
y.fimathislocal = false;
