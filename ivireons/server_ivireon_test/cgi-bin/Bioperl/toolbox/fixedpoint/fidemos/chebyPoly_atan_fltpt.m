function z = chebyPoly_atan_fltpt(y,x,N,constA,Tz) %#eml
% Calculate arctangent using Chebyshev polynomial approximation
% Chebyshev polynomials of the first kind are used.
% x and y must be scalar, y/x must be within [-1,+1]
%
% Inputs:
%  y  : y coordinate or imaginary part of the input vector
%  x  : x coordinate or real part of the input vector
%  N  : order of the Chebyshev polynomial
%  constA: coefficients of the Chebyshev polynomial
%  Tz    : ignored for floating-point algorithm, 
%       numerictype of the output angle Only used for fixed-point algorithm
% Output:
%  z  : angle that equals atan(y/x) within [-pi/4, pi/4], in radians
%
%    Copyright 1984-2009 The MathWorks, Inc.
%    $Revision: 1.1.6.2 $  $Date: 2009/02/18 02:06:32 $  
%%
tmp = y/x;

switch N
    case 3
        z = constA(1)*tmp + constA(2)*tmp^3;
    case 5
        z = constA(1)*tmp + constA(2)*tmp^3 + constA(3)*tmp^5;
    case 7
        z = constA(1)*tmp + constA(2)*tmp^3 + constA(3)*tmp^5 + constA(4)*tmp^7;
    otherwise
        disp('Supported order of Chebyshev polynomials are 3, 5 and 7');
end 
