function [sin_out, cos_out] = cordicsincos(theta, niters)
% [y, x] = CORDICCSINCOS(theta, niters) Compute the CORDIC-based approximation to [SIN(theta), COS(theta)].

% Copyright 2009-2010 The MathWorks, Inc.
%#eml

eml.allowpcode('plain');

if eml_ambiguous_types
    sin_out = eml_not_const(reshape(zeros(size(theta)),size(theta)));
    cos_out = eml_not_const(reshape(zeros(size(theta)),size(theta)));
else
    eml_prefer_const(theta);
    eml_prefer_const(niters);
    
    eml_assert(isnumeric(theta) && isreal(theta), ...
        'The angle (theta) argument values must be real, numeric, non-empty, and in the range [-2*pi, 2*pi).');

    if eml_is_const(theta)
        eml_assert(all(~isempty(theta)) ...
            && all(double(theta) >= (-2*pi - 2*eps)) ...
            && all(double(theta) <  ( 2*pi + 2*eps)), ...
            'The angle (theta) argument values must be real, numeric, non-empty, and in the range [-2*pi, 2*pi).');
    end
    
    % Only constant-valued NITERS arguments are supported for code generation.
    % Check for that here (as well positive-integer-valued NITERS arg ranges).
    eml_assert((eml_is_const(niters) && isscalar(niters) && isnumeric(niters) ...
        && isreal(niters) && (double(niters) == floor(double(niters))) && (double(niters) > 0) ...
        && ~isempty(niters) && isfinite(niters)), ...
        'The number of iterations argument must be a positive, integer-valued, scalar constant.');
    
    % Compute "real-world-values" for constant initializations
    numIters_dbl = double(niters);
    intArray_dbl = (0:(numIters_dbl-1))';
    inputLUT_dbl = atan(2 .^ (-intArray_dbl));
    preNrmIC_dbl = 1 / prod(sqrt(1 + 2.^(-2*intArray_dbl)));
    
    % Initialize constants
    sz            = size(theta);
    needToReshape = ~isvector(theta) || (length(sz) > 2);
    if isa(theta, 'double')
        needTempXYOut = needToReshape;
        lut           = inputLUT_dbl;
        K             = preNrmIC_dbl;
        x0            = double(K);
        y0            = 0.0;
        if needTempXYOut
            xout = eml.nullcopy(zeros(sz));
            yout = eml.nullcopy(zeros(sz));
        end
        cos_out = eml.nullcopy(zeros(sz));
        sin_out = eml.nullcopy(zeros(sz));
    elseif isa(theta, 'single')
        needTempXYOut = needToReshape;
        lut           = single(inputLUT_dbl);
        K             = single(preNrmIC_dbl);
        x0            = single(K);
        y0            = single(0.0);
        if needTempXYOut
            xout = eml.nullcopy(single(zeros(sz)));
            yout = eml.nullcopy(single(zeros(sz)));
        end
        cos_out = eml.nullcopy(single(zeros(sz)));
        sin_out = eml.nullcopy(single(zeros(sz)));
    else
        needTempXYOut = true; % Due to use of LOCAL FIMATH for CORDIC internals
        thetaNT       = numerictype(theta);
        
        % Check that THETA data type is signed
        eml_assert(thetaNT.Signedness == 'Signed', ...
            'The angle (theta) argument data type must be signed.');
        
        ioWordLength  = thetaNT.WordLength;
        ioFracLength  = ioWordLength - 2;
        ioNT          = numerictype(1, ioWordLength, ioFracLength);
        
        % Check NITERS versus THETA word length
        eml_assert(ioWordLength > numIters_dbl, ...
            'The number of iterations value must be less than the word length of the input angle.');
        
        % First initialize all values using the "fimathless FI" rules
        % (i.e. cast "real-world-values" using NEAREST and SATURATE)
        lutTmp = fi(inputLUT_dbl, ioNT);
        kTmp   = fi(preNrmIC_dbl, ioNT);
        
        % Use same LOCAL FIMATH for CORDIC arithmetic
        Fm      = eml_al_cordic_fimath(theta);
        lut     = fi(lutTmp, ioNT, Fm);
        K       = fi(kTmp,   ioNT, Fm);
        x0      = fi(K,      ioNT, Fm);
        y0      = fi(0,      ioNT, Fm);
        xout    = eml.nullcopy(fi(zeros(sz), ioNT, Fm));
        yout    = eml.nullcopy(fi(zeros(sz), ioNT, Fm));
        cos_out = eml.nullcopy(fi(zeros(sz), ioNT)); % NOT using local Fm
        sin_out = eml.nullcopy(fi(zeros(sz), ioNT)); % NOT using local Fm
    end
    
    % Type for numerical operation and intermediate results
    if isfloat(theta)
        lutValues = lut;
    else
        lutValues = fi(lut, ioNT, Fm);
    end
    
    if needToReshape
        % FULL MATRIX or N-D cases: Form column vector and reshape afterward.
        % (NOTE: this will likely generate extra input and output copy code...)
        angle = theta(:);
        
        for idx=1:length(angle)
            % Correct input angle to [-pi/2, pi/2]
            if isfloat(angle)
                [negate, z0] = eml_al_cordic_quad_correction_before_float(angle(idx));
            else
                [negate, z0] = eml_al_cordic_quad_correction_before(angle(idx), K);
            end
            
            % CORDIC computing
            [xn, yn] = eml_al_cordic_kernel_loop(x0, y0, z0, lutValues, niters);
            
            % Restore signs of output sin and cos
            % (NOTE: using temp xout, yout since needToReshape == TRUE)
            [xout(idx), yout(idx)] = eml_al_cordic_quad_correction_after(xn, yn, negate);
        end
    else
        % No input-copy/reshape required
        for idx=1:length(theta)
            % Correct input angle to [-pi/2, pi/2]
            if isfloat(theta)
                [negate, z0] = eml_al_cordic_quad_correction_before_float(theta(idx));
            else
                [negate, z0] = eml_al_cordic_quad_correction_before(theta(idx), K);
            end
            
            % CORDIC computing
            [xn, yn] = eml_al_cordic_kernel_loop(x0, y0, z0, lutValues, niters);
            
            % Restore signs of output sin and cos
            if needTempXYOut
                % Using temp variables, e.g., for LOCAL FIMATH.
                % (NOTE: may generate extra output copy code below...)
                [xout(idx), yout(idx)] = eml_al_cordic_quad_correction_after(xn, yn, negate);
            else
                % No extra output copies required
                [cos_out(idx), sin_out(idx)] = eml_al_cordic_quad_correction_after(xn, yn, negate);
            end
        end
    end
    
    if needTempXYOut
        % Need to copy temp XOUT and YOUT vars to actual SIN_OUT and COS_OUT
        if isa(theta, 'double') || isa(theta, 'single') || (~isfimathlocal(yout))
            if needToReshape
                sin_out = reshape(yout, sz);
                cos_out = reshape(xout, sz);
            else
                sin_out = yout;
                cos_out = xout;
            end
        else
            % Remove local fimath
            if needToReshape
                sin_out = fi(reshape(yout, sz), 'fimath', []);
                cos_out = fi(reshape(xout, sz), 'fimath', []);
            else
                sin_out = fi(yout, 'fimath', []);
                cos_out = fi(xout, 'fimath', []);
            end
        end
    end
end % if eml_ambiguous_types

end % function
