function sin_out = cordicsin(theta, niters)
% CORDICSIN CORDIC-based approximation of SIN.
%    Y = CORDICSIN(THETA, NITERS) computes the sine of THETA using a
%    CORDIC algorithm approximation. Y contains the approximate result.
%
%    THETA can be a scalar, vector, matrix, or N-dimensional array
%    containing the angle values in radians. All THETA values must be in
%    the range [-2*pi, 2*pi).
%
%    NITERS is the number of CORDIC algorithm iterations. NITERS
%    must be a positive integer-valued scalar and less than the word length
%    of THETA. More iterations may produce more accurate results at the
%    expense of more computation/latency.
%
%    EXAMPLE: Compare the accuracy of CORDIC-based SIN results
%
%    wrdLn = 8;
%    theta = fi(pi/2, 1, wrdLn);
%    fprintf('\n\nNITERS\tY (SIN)\t ERROR\t LSBs\n');
%    fprintf('------\t-------\t ------\t ----\n');
%    for niters = 1:(wrdLn - 1)
%      y      = cordicsin(theta, niters);
%      y_FL   = y.FractionLength;
%      y_dbl  = double(y);
%      y_err  = abs(y_dbl - sin(double(theta)));
%      fprintf('  %d\t%1.4f\t %1.4f\t %1.1f\n', niters, ...
%              y_dbl, y_err, (y_err * pow2(y_FL)));
%    end
%    fprintf('\n');
%  
%    % NITERS  Y (SIN)  ERROR   LSBs
%    % ------  -------  ------  ----
%    %   1     0.7031   0.2968  19.0
%    %   2     0.9375   0.0625  4.0 
%    %   3     0.9844   0.0156  1.0 
%    %   4     0.9844   0.0156  1.0 
%    %   5     1.0000   0.0000  0.0 
%    %   6     1.0000   0.0000  0.0 
%    %   7     1.0000   0.0000  0.0 
%
%
%    See also CORDICCEXP, CORDICCOS, CORDICSINCOS.

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2010/04/21 21:21:18 $

cis_out = cordiccexp(theta, niters);
sin_out = imag(cis_out);

% [EOF]
