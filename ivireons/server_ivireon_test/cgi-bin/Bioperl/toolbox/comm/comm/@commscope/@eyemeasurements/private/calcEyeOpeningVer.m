function calcEyeOpeningVer(this, verHistI, verHistQ, ampRes, BER)
%CALCEYEOPENINGVER Calculate the vertical eye opening
%   CALCEYEOPENINGVER utilizes the dual-Dirac model to estimate the
%   deterministic, random, and total amplitude values.  Assumes two distinct eye
%   levels.

%   @commscope/@eyemeasurements
%
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/11/13 04:14:22 $

try
    % Check if eye levels are valid
    eyeLevels = this.PrivEyeLevel;
    if any(any(isnan(eyeLevels))) || any(any(isinf(eyeLevels)))
        this.issueAnalyzeError([this.getErrorId ':InvalidEyeLevel'], ...
            'eye levels');
    end

    % Reset properties
    this.PrivNoiseMu = [];
    this.PrivNoiseSigma = [];
    this.PrivNoiseRho = [];

    % Determine the eye delay index.
    samplingIdx = round(this.PrivEyeDelay);

    % Adjust the histogram so that the eye opening is in the middle
    midPoints = diff(this.PrivEyeLevel, [], 2)/2 + this.PrivEyeLevel(:, 1:end-1);
    histLen = size(verHistI, 1);
    histLen2 = floor(histLen / 2);
    histI = circshift(verHistI(:, samplingIdx(1,1)), [0 round(histLen2-midPoints(1, 1))]);

    % Get mu and sigma estimates from the first crossing point
    refAmpIdx = 1:histLen2;
    [muL1 muR1 sigma1 rhoL1 rhoR1] = ...
        dualDiracTailFitting(this, histI(refAmpIdx)');

    % Get mu and sigma estimates from the second crossing point
    refAmpIdx = histLen2+1:histLen;
    [muL2 muR2 sigma2 rhoL2 rhoR2] = ...
        dualDiracTailFitting(this, histI(refAmpIdx)');
    muL2 = muL2 + histLen2;
    muR2 = muR2 + histLen2;

    % Get the average
    dd1 = abs(muR1-muL1);
    dd2 = abs(muR2-muL2);
    dd = (dd1+dd2)/2;
    sigma = (sigma1+sigma2)/2;
    rhoL = (rhoL1+rhoL2)/2;
    rhoR = (rhoR1+rhoR2)/2;

    % Calculate RJ, DJ, and TJ values for defined BER
    QBERL = sqrt(2)*erfcinv(2*BER/rhoL);
    QBERR = sqrt(2)*erfcinv(2*BER/rhoR);
    NoiseRandom(1) = ((QBERL+QBERR)*sigma)*ampRes;
    NoiseDeterministic(1) = dd*ampRes;
    NoiseTotal(1) = NoiseRandom(1) + NoiseDeterministic(1);
    this.EyeOpeningVertical(1, 1) = (this.EyeAmplitude(1, 1) - NoiseTotal(1));

    % Store sigma, and mu values for bathtub calculations
    this.PrivNoiseSigma(1, :) = sigma;
    this.PrivNoiseMu(1, :, :) = [muL1 muL2; muR1 muR2];
    this.PrivNoiseRho(1, :, :) = [rhoL1 rhoL2; rhoR1 rhoR2];

    % If required, calculate for the quadrature signal
    if ~isempty(verHistQ)
        % Adjust the histogram so that the eye opening is in the middle
        histQ = circshift(verHistQ(:, samplingIdx(2,1)), [0 round(histLen2-midPoints(2, 1))]);

        % Get mu and sigma estimates from the first crossing point
        refAmpIdx = 1:histLen2;
        [muL1 muR1 sigma1 rhoL1 rhoR1] = ...
            dualDiracTailFitting(this, histQ(refAmpIdx)');

        % Get mu and sigma estimates from the second crossing point
        refAmpIdx = histLen2+1:histLen;
        [muL2 muR2 sigma2 rhoL2 rhoR2] = ...
            dualDiracTailFitting(this, histQ(refAmpIdx)');
        muL2 = muL2 + histLen2;
        muR2 = muR2 + histLen2;

        % Get the average
        dd1 = abs(muR1-muL1);
        dd2 = abs(muR2-muL2);
        dd = (dd1+dd2)/2;
        sigma = (sigma1+sigma2)/2;
        rhoL = (rhoL1+rhoL2)/2;
        rhoR = (rhoR1+rhoR2)/2;

        % Calculate RJ, DJ, and TJ values for defined BER
        QBERL = sqrt(2)*erfcinv(2*BER/rhoL);
        QBERR = sqrt(2)*erfcinv(2*BER/rhoR);
        NoiseRandom(2) = ((QBERL+QBERR)*sigma)*ampRes;
        NoiseDeterministic(2) = dd*ampRes;
        NoiseTotal(2) = NoiseRandom(2) + NoiseDeterministic(2);
        this.EyeOpeningVertical(2, 1) = (this.EyeAmplitude(2, 1) - NoiseTotal(2));

        % Store sigma, and mu values for bathtub calculations
        this.PrivNoiseSigma(2, :) = sigma;
        this.PrivNoiseMu(2, :, :) = [muL1 muL2; muR1 muR2];
        this.PrivNoiseRho(2, :, :) = [rhoL1 rhoL2; rhoR1 rhoR2];
    end

catch exception %#ok<NASGU>
    this.issueAnalyzeError([this.getErrorId ':EyeOpenVerFailed'], ...
        'vertical eye opening');
end

%-------------------------------------------------------------------------------
% [EOF]
