function calcQualityFactor(this)
%CALCQUALITYFACTOR Calculate the quality factor of the eye diagram
%   The Quality Factor is calculated using the Dual-Dirac method.  It is defined
%   as the ratio of the distance between to deterministic eye levels (muL2 and
%   muR1) and the noise (sigma).

%   @commscope/@eyemeasurements
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/06/13 15:11:54 $

% Calculate (mean2-mean1)/(std2+std1)
sigma = this.PrivNoiseSigma;
mu = this.PrivNoiseMu;
muL2 = mu(1,1,2);
muR1 = mu(1,2,1);
if sigma(1,:)
    this.QualityFactor(1,1) = (muL2 - muR1) / (2*sigma(1,:));
else
    this.QualityFactor(1,1) = inf;
end

if size(mu,1) == 2
    muL2 = mu(2,1,2);
    muR1 = mu(2,2,1);
    if sigma(2,:)
        this.QualityFactor(2,1) = (muL2 - muR1) / (2*sigma(2,:));
    else
        this.QualityFactor(2,1) = inf;
    end
end

%-------------------------------------------------------------------------------
% [EOF]
