function calcJitterRJDJTJ(this, horHistI, horHistQ, Fs, BER)
%CALCJITTERRJDJTJ Calculate the deterministic, random, and total jitter values.
%   CALCJITTERRJDJTJ utilizes the dual-Dirac model to estimate jitter values.
%   Assumes that SymbolsPerTrace is 2.

%   @commscope/@eyemeasurements
%
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/11/13 04:14:23 $

try
    % Reset properties
    if isempty(horHistQ)
        n = 1;
    else
        n = 2;
    end
    this.PrivJitterMu = NaN(n,2,2);
    this.PrivJitterSigma = NaN(n,1);
    this.PrivJitterRho = NaN(n,2,2);

    % Determine the reference amplitude index.  Note that the reference amplitude
    % band is calculated around the reference amplitude index.
    refAmpIdx = (size(horHistI, 1)+1)/2;

    % Adjust the histogram so that the eye opening is in the middle
    midPoint = this.PrivEyeDelay;
    histLen = size(horHistI, 2);
    histLen2 = floor(histLen / 2);
    histI = circshift(horHistI(refAmpIdx, :), [0 round(histLen2-midPoint(1,1))]);

    % Get mu and sigma estimates from the first crossing point
    refTimeIdx = 1:histLen2;
    [muL1 muR1 sigma1 rhoL1 rhoR1] = ...
        dualDiracTailFitting(this, histI(refTimeIdx));

    % Get mu and sigma estimates from the second crossing point
    refTimeIdx = histLen2+1:histLen;
    [muL2 muR2 sigma2 rhoL2 rhoR2] = ...
        dualDiracTailFitting(this, histI(refTimeIdx));
    muL2 = muL2 + histLen2;
    muR2 = muR2 + histLen2;

    % Get the average
    dd1 = (muR1-muL1);
    dd2 = (muR2-muL2);
    dd = (dd1+dd2)/2;
    sigma = (sigma1+sigma2)/2;
    rhoL = (rhoL1+rhoL2)/2;
    rhoR = (rhoR1+rhoR2)/2;

    % Calculate RJ, DJ, and TJ values for defined BER
    QBERL = sqrt(2)*erfcinv(2*BER/rhoL);
    QBERR = sqrt(2)*erfcinv(2*BER/rhoR);
    this.JitterRandom(1,1) = ((QBERL+QBERR)*sigma)/Fs;
    this.JitterDeterministic(1,1) = dd/Fs;
    this.JitterTotal(1,1) = this.JitterRandom(1,1) + this.JitterDeterministic(1,1);

    % Store sigma, and mu values for bathtub calculations
    this.PrivJitterSigma(1, :) = sigma;
    this.PrivJitterMu(1, :, :) = [muL1 muL2; muR1 muR2];
    this.PrivJitterRho(1, :, :) = [rhoL1 rhoL2; rhoR1 rhoR2];

    % If required, calculate for the quadrature signal
    if ~isempty(horHistQ)
        % Adjust the histogram so that the eye opening is in the middle
        refAmpIdx = (size(horHistQ, 1)+1)/2;
        histLen = size(horHistQ, 2);
        histLen2 = floor(histLen / 2);
        histQ = circshift(horHistQ(refAmpIdx, :), [0 round(histLen2-midPoint(2,1))]);

        % Get mu and sigma estimates from the first crossing point
        refTimeIdx = 1:histLen2;
        [muL1 muR1 sigma1 rhoL1 rhoR1] = ...
            dualDiracTailFitting(this, histQ(refTimeIdx));

        % Get mu and sigma estimates from the second crossing point
        refTimeIdx = histLen2+1:histLen;
        [muL2 muR2 sigma2 rhoL2 rhoR2] = ...
            dualDiracTailFitting(this, histQ(refTimeIdx));
        muL2 = muL2 + histLen2;
        muR2 = muR2 + histLen2;

        % Get the average
        dd1 = (muR1-muL1);
        dd2 = (muR2-muL2);
        dd = (dd1+dd2)/2;
        sigma = (sigma1+sigma2)/2;
        rhoL = (rhoL1+rhoL2)/2;
        rhoR = (rhoR1+rhoR2)/2;

        % Calculate RJ, DJ, and TJ values for defined BER
        QBERL = sqrt(2)*erfcinv(2*BER/rhoL);
        QBERR = sqrt(2)*erfcinv(2*BER/rhoR);
        this.JitterRandom(2,1) = ((QBERL+QBERR)*sigma)/Fs;
        this.JitterDeterministic(2,1) = dd/Fs;
        this.JitterTotal(2,1) = this.JitterRandom(2,1) + this.JitterDeterministic(2,1);

        % Store sigma, and mu values for bathtub calculations
        this.PrivJitterSigma(2,:) = sigma;
        this.PrivJitterMu(2,:,:) = [muL1 muL2; muR1 muR2];
        this.PrivJitterRho(2,:,:) = [rhoL1 rhoL2; rhoR1 rhoR2];
    end
catch exception %#ok<NASGU>
    this.issueAnalyzeError([this.getErrorId ':JitterRJDJTJFailed'], ...
        'random, deterministic, and total jitter');
end

%-------------------------------------------------------------------------------
% [EOF]
