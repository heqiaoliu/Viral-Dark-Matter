function cis_out = cordiccexp(theta, niters)
% CORDICCEXP CORDIC-based approximation of complex exponential e^(j*THETA).
%    CIS = CORDICCEXP(THETA, NITERS) computes COS(THETA) + j*SIN(THETA)
%    using a CORDIC algorithm approximation and returns the complex result.
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
%    EXAMPLE: Compare the accuracy of CORDIC-based SIN and COS results
%
%    wrdLn = 8;
%    theta = fi(pi/2, 1, wrdLn);
%    fprintf('\n\nNITERS\t\tY (SIN)\t ERROR\t LSBs\t\tX (COS)\t ERROR\t LSBs\n');
%    fprintf('------\t\t-------\t ------\t ----\t\t-------\t ------\t ----\n');
%    for niters = 1:(wrdLn - 1)
%      cis    = cordiccexp(theta, niters);
%      fl     = cis.FractionLength;
%      x      = real(cis);
%      y      = imag(cis);
%      x_dbl  = double(x);
%      x_err  = abs(x_dbl - cos(double(theta)));
%      y_dbl  = double(y);
%      y_err  = abs(y_dbl - sin(double(theta)));
%      fprintf('  %d\t\t%1.4f\t %1.4f\t %1.1f\t\t%1.4f\t %1.4f\t %1.1f\n', niters, ...
%              y_dbl, y_err, (y_err * pow2(fl)), ...
%              x_dbl, x_err, (x_err * pow2(fl)));
%    end
%    fprintf('\n');
%
%    % NITERS    Y (SIN)  ERROR   LSBs    X (COS)  ERROR   LSBs
%    % ------    -------  ------  ----    -------  ------  ----
%    %   1       0.7031   0.2968  19.0     0.7031  0.7105  45.5
%    %   2       0.9375   0.0625   4.0     0.3125  0.3198  20.5
%    %   3       0.9844   0.0156   1.0     0.0938  0.1011   6.5
%    %   4       0.9844   0.0156   1.0    -0.0156  0.0083   0.5
%    %   5       1.0000   0.0000   0.0     0.0312  0.0386   2.5
%    %   6       1.0000   0.0000   0.0     0.0000  0.0073   0.5
%    %   7       1.0000   0.0000   0.0     0.0156  0.0230   1.5
%
%
%    See also CORDICSINCOS, CORDICSIN, CORDICCOS.

% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2010/05/20 02:17:39 $

% =================
% Argument Checking
% =================
localCORDICCEXPInputArgChecking(theta, niters);

if isfi(theta)
    length_Theta = numberofelements(theta);
else
    length_Theta = numel(theta);
end

% =====================================================================
% Quadrant Correction for input angle(s); correct to range [-pi/2 pi/2]
% =====================================================================
[theta_in_range needToNegate] = ...
    embedded.cordiccexpInputQuadrantCorrection(theta(:), length_Theta);

% =====================================================
% Off-line initializations for CORDIC sin-cos algorithm
% =====================================================

% First compute initial values in double precision floating-point
numIters_dbl = double(niters);
size_Theta   = size(theta);
x_dbl        = ones( size_Theta ) / cordic_compute_gain(numIters_dbl);
y_dbl        = zeros(size_Theta);
intArray_dbl = (0:(numIters_dbl-1))';
inputLUT_dbl = atan(2 .^ (-intArray_dbl));

if isa(theta, 'double')
    cis_out = double(complex(x_dbl, y_dbl));
    inpLUT  = double(inputLUT_dbl);
    z       = double(theta_in_range);
elseif isa(theta, 'single')
    cis_out = single(complex(x_dbl, y_dbl));
    inpLUT  = single(inputLUT_dbl);
    z       = single(theta_in_range);
else
    % Fixed-point or builtin integer
    if isfi(theta)
        valueWithThetaNumType = theta;
    else
        valueWithThetaNumType = fi(theta);
    end
    
    if ~strcmpi(valueWithThetaNumType.Signedness, 'Signed')
        error('fixedpoint:cordiccexp:invalidtheta', ...
            'The angle (theta) argument data type must be signed.');
    end

    % Compute I-O word length and fraction length for CORDIC kernel
    ioLoopNumTyp = valueWithThetaNumType.numerictype;
    ioWordLength = ioLoopNumTyp.WordLength;
    ioFracLength = ioWordLength - 2;
    ioLoopNumTyp.FractionLength = ioFracLength;
    
    % Error if Number of Iterations >= Word Length to avoid less
    % comprehensible errors in BITSRA deep inside the CORDIC kernel.
    if (numIters_dbl >= ioWordLength)
        error('fixedpoint:cordiccexp:invalidniters', ...
            ['The number of iterations (niters) argument must be ', ...
            'less than the word length of the angle (theta) argument.']);
    end

    % First initialize all values using the "fimathless FI" rules
    % (i.e. float-to-fixed value casts use round to nearest and saturate)
    cis_out = fi(complex(x_dbl, y_dbl), ioLoopNumTyp);
    inpLUT  = fi(inputLUT_dbl,          ioLoopNumTyp);
    z       = fi(theta_in_range,        ioLoopNumTyp);
    
    % Make every variable involved in arithmetic use same localFimath
    % (Note: I-O WL/FL could be different than for quadrant corr above)
    localFimath = ...
        embedded.computeFimathForCORDIC(...
        valueWithThetaNumType, ioWordLength, ioFracLength);
    
    cis_out.fimath = localFimath;
    inpLUT.fimath  = localFimath;
    z.fimath       = localFimath;
end

% =========================================
% Perform CORDIC Iterations and Form Output
% =========================================
for idx = 1:length_Theta
    [xRe, yIm] = cordic_kernel_private( ...
        real(cis_out(idx)), imag(cis_out(idx)), z(idx), ...
        inpLUT, numIters_dbl);

    if needToNegate(idx)
        cis_out(idx) = complex(-xRe, -yIm);
    else
        cis_out(idx) = complex( xRe,  yIm);
    end
end

if isfi(cis_out)
    cis_out.fimath = []; % remove local fimath
end


% =========================================================================
function localCORDICCEXPInputArgChecking(theta, niters)

% CHECK theta dims, numeric, real, non-empty, non-nan, non-inf
if ~( isnumeric(theta) && isreal(theta) && ...
        ~(isempty(theta) || any(isnan(theta(:))) || any(isinf(theta(:)))) )
    error('fixedpoint:cordiccexp:invalidtheta', ...
        ['The angle (theta) argument values must be real, numeric, ', ...
        'non-empty, and in the range [-2*pi, 2*pi).']);
end

% CHECK theta range [-2PI, 2PI)
dbl_theta_array = double(theta(:));
if any(dbl_theta_array < -2*pi) || any(dbl_theta_array >= (2*pi + 2*eps))
    error('fixedpoint:cordiccexp:invalidtheta', ...
        ['The angle (theta) argument values must be in the range ', ...
        '[-2*pi, 2*pi).']);
end

% CHECK niters: scalar, numeric, real, integer-valued, positive
if ~( isscalar(niters) && isnumeric(niters) && isreal(niters) && ...
        ~( isempty(niters) || any(isnan(niters(:))) || any(isinf(niters(:))) ) && ...
        isequal(floor(niters), niters) && (niters > 0) )
    error('fixedpoint:cordiccexp:invalidniters', ...
        ['The number of iterations (niters) argument ', ...
        'must be a positive integer-valued scalar.']);
end

% LocalWords:  CORDIC CIS NITERS wrd Bs niters cis CORDICSINCOS CORDICSIN
% LocalWords:  CORDICCOS fixedpoint invalidtheta invalidniters fimathless WL
