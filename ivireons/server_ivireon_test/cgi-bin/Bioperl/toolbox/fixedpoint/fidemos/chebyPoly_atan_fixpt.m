function z = chebyPoly_atan_fixpt(y,x,N,constA,Tz) %#eml
% Calculate arctangent using Chebyshev polynomial approximation
% Chebyshev polynomials of the first kind are used.
% x and y must be scalar, y/x must be within [-1,+1]
% Full precision Fimath is used in all fixed-point operations
%
% Inputs:
%  y  : y coordinate or imaginary part of the input vector
%  x  : x coordinate or real part of the input vector
%  N  : order of the Chebyshev polynomial
%  constA: coefficients of the Chebyshev polynomial
%  Tz : numerictype of the output angle
% Output:
%  z  : angle that equals atan(y/x) within [-pi/4, pi/4] in radians
%
%    Copyright 1984-2009 The MathWorks, Inc.
%    $Revision: 1.1.6.2 $  $Date: 2009/02/18 02:06:31 $ 
%%
z = fi(0,'NumericType', Tz);
Tx = numerictype(x);
tmp = fi(0, 'NumericType',Tx);
tmp(:) = Tx.divide(y, x); % y/x;

tmp2 = fi(0, 'NumericType',Tx);  
tmp3 = fi(0, 'NumericType',Tx);  
tmp2(:) = tmp*tmp;  % (y/x)^2
tmp3(:) = tmp2*tmp; % (y/x)^3


z(:) = constA(1)*tmp + constA(2)*tmp3; % for order N = 3

if (N == 5) || (N == 7)
    tmp5 = fi(0, 'NumericType',Tx);
    tmp5(:) = tmp3 * tmp2; % (y/x)^5
    z(:) = z + constA(3)*tmp5; % for order N = 5
    
    if N == 7
        tmp7 = fi(0, 'NumericType',Tx);
        tmp7(:) = tmp5 * tmp2; % (y/x)^7
        z(:) = z + constA(4)*tmp7; %for order N = 7
    end   
end
