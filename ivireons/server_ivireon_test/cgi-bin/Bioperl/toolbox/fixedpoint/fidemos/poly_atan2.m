function z = poly_atan2(y,x,N,constA,Tz)
% Calculate the four quadrant inverse tangent via Chebyshev polynomial 
% approximation. Chebyshev polynomials of the first kind are used.
%
% Inputs:
%  y  : y coordinate or imaginary part of the input vector
%  x  : x coordinate or real part of the input vector
%  N  : order of the Chebyshev polynomial
%  constA : coefficients of the Chebyshev polynomial
%  Tz     : numerictype of the output angle only required for fixed-point
%           algorithm
% Output:
%  z  : angle that equals atan2(y,x), in radians
%       the output angle range is within (-pi, +pi]
%
%    Copyright 1984-2009 The MathWorks, Inc.
%    $Revision: 1.1.6.2 $  $Date: 2009/02/18 02:06:42 $ 

%% Apply angle correction to obtain four quadrants output
if nargin<5, 
    % floating-point algorithm
    fhandle = @chebyPoly_atan_fltpt;
    Tz = [];
    z = zeros(size(y));
else
    % fixed-point algorithm
    fhandle = @chebyPoly_atan_fixpt;
    %pre-allocate output
    z = fi(zeros(size(y)), 'NumericType', Tz);
end

for idx = 1:length(y)  
   % fist quadrant 
   if abs(x(idx)) >= abs(y(idx)) 
       % (0, pi/4]
       z(idx) = feval(fhandle, abs(y(idx)), abs(x(idx)), N, constA, Tz);
   else
       % (pi/4, pi/2)
       z(idx) = pi/2 - feval(fhandle, abs(x(idx)), abs(y(idx)), N, constA, Tz);
   end
   
   if x(idx) < 0 
        % second and third quadrant
        if y(idx) < 0
          z(idx) = -pi + z(idx);
        else
          z(idx) = pi - z(idx);
        end      
   else % fourth quadrant
       if y(idx) < 0
           z(idx) = -z(idx);
       end
   end
   
end
