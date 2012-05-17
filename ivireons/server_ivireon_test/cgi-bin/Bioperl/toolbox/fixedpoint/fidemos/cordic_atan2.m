function z = cordic_atan2(y,x,N) %#eml
% Calculate four quadrant arctangent using CORDIC 
% (COordinate Rotation DIgital Computer) algorithm
% Inputs:
%  y  : y coordinate or imaginary part of the input vector
%  x  : x coordinate or real part of the input vector
%  N  : total number of iterations, must be positive and const
%
% Output:
%  z  : angle that equals atan2(y,x), in radians 
%       the output angle range is within (-pi, +pi]
%
%    Copyright 1984-2009 The MathWorks, Inc.
%    $Revision: 1.1.6.3 $  $Date: 2009/11/13 04:17:52 $  

if isfi(y)
    % Fixed-point
    Ty = numerictype(y);
    Tz = numerictype(1, Ty.WordLength, Ty.WordLength - 3);
    % Build the constant angle look-up-table. Because a local fimath is not 
    % specified for the fi object 'angleLUT', it is created using the default 
    % RoundMode of nearest and OverflowMode of saturate.
    angleLUT = fi(atan(2.^-(0:N-1)), Tz);
    z = fi(zeros(size(y)),Tz);
else
    % Floating-point
    angleLUT = atan(2.^-(0:N-1));
    z = zeros(size(y));
end

for k = 1:length(y)
    z(k) = cordic_atan_kernel(y(k),abs(x(k)),N,angleLUT);
end

for k = 1:length(y)  
    % Correct for second and third quadrant
    if x(k) < 0 
        if y(k) >= 0
            % Second quadrant
            z(k) =  pi - z(k);
        else
            % Third quadrant
            z(k) = -pi - z(k);
        end    
    end
end
