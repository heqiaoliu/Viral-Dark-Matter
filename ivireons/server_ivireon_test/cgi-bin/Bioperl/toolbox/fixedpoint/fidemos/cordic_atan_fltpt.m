function [z, x, y] = cordic_atan_fltpt(y,x,N, angleLUT) %#eml
% Calculate arctangent in range [-pi/2, pi/2] using Vectoring mode CORDIC 
% algorithm. Both x and y inputs must be real scalar, x must >= 0
%
% Inputs:
%  y  : y coordinate or imaginary part of the input vector
%  x  : x coordinate or real part of the input vector
%  N  : total number of iterations, must be a non-negative integer
% angleLUT : the angle look-up table
%
% Output:
%  z  : angle that equals atan2(y,x), in radians 
%       the output angle range is within [-pi/2, +pi/2]
%  x  : x coordinate of the last vector at the end of the iterations
%  y  : y coordinate of the last vector at the end of the iterations
%
%    Copyright 1984-2009 The MathWorks, Inc.
%    $Revision: 1.1.6.3 $  $Date: 2009/11/13 04:17:54 $

% initialization
z = 0; % assume z_{0} is 0

for i = 0:N-1,   
    x0 = x;
    if y < 0  % negative y leads to counter clock-wise rotation       
        x = x0 - bitsra(y,i); % x_{i+1} = x_{i} - y_{i}*2^{-i}
        y = y + bitsra(x0,i);  % y_{i+1} = y_{i} + x_{i}*2^{-i}
        z = z - angleLUT(i+1); % z_{i+1} = z_{i} + atan(2^{-i})       
        
    else % positive y leads to clock-wise rotation              
        x = x0 + bitsra(y,i); % x_{i+1} = x_{i} + y_{i}*2^{-i}
        y = y - bitsra(x0,i); % y_{i+1} = y_{i} - x_{i}*2^{-i}
        z = z + angleLUT(i+1); % z_{i+1} = z_{i} - atan(2^{-i})
    end
    
end

