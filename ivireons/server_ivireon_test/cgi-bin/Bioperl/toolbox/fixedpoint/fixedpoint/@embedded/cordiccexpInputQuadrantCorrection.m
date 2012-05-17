function [theta_in_range needToNegate] = cordiccexpInputQuadrantCorrection(theta, length_Theta)
% cordiccexpInputQuadrantCorrection

% Copyright 2009-2010 The MathWorks, Inc.

theta_in_range = theta;
needToNegate   = zeros(length_Theta, 1);

% Get the correct NumericType "flavors" of pi/2 constants
if isa(theta, 'double')
    piOver2inThetaNumType = pi/2;
    onePiInThetaNumrcType = pi;
    twoPiInThetaNumrcType = 2*pi;
elseif isa(theta, 'single')
    piOver2inThetaNumType = single(pi/2);
    onePiInThetaNumrcType = single(pi);
    twoPiInThetaNumrcType = single(2*pi);
else
    theta_in_range = fi(theta); % make sure this is a FI (could be int*)
    nt             = theta_in_range.numerictype;
    qcWordLength   = nt.WordLength;
    qcFracLength   = nt.FractionLength;
    nonFracBits    = qcWordLength - qcFracLength;
    
    if nonFracBits <= 1
        % Already guaranteed to be in range [-pi/2 pi/2]
        return;
    elseif nonFracBits < 4
        % Not enough bits to represent 2*pi (need to increase word length)
        qcWordLength   = qcFracLength + 4; % increase WL; do not change FL
        nt.WordLength  = qcWordLength;
        theta_in_range = fi(theta, 1, qcWordLength, qcFracLength);
    end
    
    % Initialize constants using default rounding (nearest) and saturate
    piOver2inThetaNumType = fi(pi/2, nt);
    onePiInThetaNumrcType = fi(pi,   nt);
    twoPiInThetaNumrcType = fi(2*pi, nt);
    
    % Make sure that FIMATH settings use FLOOR and WRAP
    localFimath = ...
        embedded.computeFimathForCORDIC(...
        theta_in_range, qcWordLength, qcFracLength);
    
    theta_in_range.fimath        = localFimath;
    piOver2inThetaNumType.fimath = localFimath;
    onePiInThetaNumrcType.fimath = localFimath;
    twoPiInThetaNumrcType.fimath = localFimath;
end

if any(theta_in_range > piOver2inThetaNumType) || any(theta_in_range < (-piOver2inThetaNumType))
    thetaMinusOnePi = theta_in_range - onePiInThetaNumrcType;
    thetaMinusTwoPi = theta_in_range - twoPiInThetaNumrcType;
    thetaPlusOnePi  = theta_in_range + onePiInThetaNumrcType;
    thetaPlusTwoPi  = theta_in_range + twoPiInThetaNumrcType;
    
    for idx = 1:length_Theta
        if theta_in_range(idx) > piOver2inThetaNumType
            % Convert an angle in range (pi/2 2*pi]
            %  to an angle in range [-pi/2 pi/2]:
            if (thetaMinusOnePi(idx) <= piOver2inThetaNumType)
                % Need to subtract PI to get into [-pi/2 pi/2] range
                theta_in_range(idx) = thetaMinusOnePi(idx);
                needToNegate(idx)   = 1;
            else
                % Need to subtract 2*PI to get into [-pi/2 pi/2] range
                theta_in_range(idx) = thetaMinusTwoPi(idx);
            end
            
        elseif (theta_in_range(idx) < (-piOver2inThetaNumType))
            % Convert an angle in range [-2*pi -pi/2)
            %  to an angle in range [-pi/2 pi/2]:
            if (thetaPlusOnePi(idx) >= (-piOver2inThetaNumType))
                % Need to add PI to get into [-pi/2 pi/2] range
                theta_in_range(idx) = thetaPlusOnePi(idx);
                needToNegate(idx)   = 1;
            else
                % Need to add 2*PI to get into [-pi/2 pi/2] range
                theta_in_range(idx) = thetaPlusTwoPi(idx);
            end
        end
    end
end

% [EOF]
