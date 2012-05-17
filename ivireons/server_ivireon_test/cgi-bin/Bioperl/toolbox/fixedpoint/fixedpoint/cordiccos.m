function cos_out = cordiccos(theta, niters)
% CORDICCOS CORDIC-based approximation of COS.
%    X = CORDICCOS(THETA, NITERS) computes the cosine of THETA using a
%    CORDIC algorithm approximation. X contains the approximate result.
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
%    EXAMPLE: Compare the accuracy of CORDIC-based COS results
%
%    wrdLn = 8;
%    theta = fi(pi/2, 1, wrdLn);
%    fprintf('\n\nNITERS\tX (COS)\t ERROR\t LSBs\n');
%    fprintf('------\t-------\t ------\t ----\n');
%    for niters = 1:(wrdLn - 1)
%      x      = cordiccos(theta, niters);
%      x_FL   = x.FractionLength;
%      x_dbl  = double(x);
%      x_err  = abs(x_dbl - cos(double(theta)));
%      fprintf('  %d\t%1.4f\t %1.4f\t %1.1f\n', niters, ...
%              x_dbl, x_err, (x_err * pow2(x_FL)));
%    end
%    fprintf('\n');
%  
%    % NITERS  X (COS)  ERROR   LSBs
%    % ------  -------  ------  ----
%    %   1     0.7031   0.7105  45.5
%    %   2     0.3125   0.3198  20.5
%    %   3     0.0938   0.1011  6.5
%    %   4     -0.0156  0.0083  0.5
%    %   5     0.0312   0.0386  2.5
%    %   6     0.0000   0.0073  0.5
%    %   7     0.0156   0.0230  1.5
%
%
%    See also CORDICCEXP, CORDICSIN, CORDICSINCOS.

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.3 $  $Date: 2010/04/21 21:21:15 $

cis_out = cordiccexp(theta, niters);
cos_out = real(cis_out);

% [EOF]
