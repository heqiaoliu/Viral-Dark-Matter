function determineRefAmpLevels(this, eyeLevels, ...
    ampHeight, ampRes)
%DETERMINEREFAMPLEVELS Determine the reference amplitude levels
%   DETERMINEREFAMPLEVELS(THIS, EYELEVELS, AMPHEIGHT, AMPRES) datermines the
%   reference amplitude levels for rise/fall time measurements and also in a
%   band around the values defined in ReferenceAmplitude property.  The band is
%   defined by the CrossingBandWidth property.

%   @commscope/@eyemeaurementsetup
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:19:50 $

% First calculate lower and upper boundaries for rise/fall time measurements
[numRows numEyeLevels] = size(eyeLevels);
riseFallLevels = zeros(numRows, 2*(numEyeLevels-1));
eyeAmp = diff(eyeLevels, [], 2);
ampThreshold = this.AmplitudeThreshold / 100;

for p=1:(numEyeLevels-1)
    for q=1:numRows
        riseFallLevels(q, 2*p-1:2*p) = eyeLevels(q, p) ...
            + eyeAmp(q, p)*ampThreshold;
    end
end

% Calculate half of the band width
bw2 = this.CrossingBandWidth*ampHeight/2;

% Calculate boundaries of the band
refAmp = this.ReferenceAmplitude;
[refAmpQ, numLevels] = size(refAmp);
isRefAmpQ = refAmpQ > 1;
bMin = refAmp - bw2;
bMax = refAmp + bw2;

% Calculate the band grid and make sure that both bMin and bMax are covered by
% the band
bw = 2*floor(bw2/ampRes)+1;
crossingLevels = zeros(refAmpQ, numLevels*bw);
levels = zeros(refAmpQ, bw);
for p=1:numLevels
    levels(1, :) = [fliplr(refAmp(1,1) : -ampRes : bMin(1)) ...
        refAmp(1,1)+ampRes : ampRes : bMax(1)];

    if ( isRefAmpQ )
        levels(2, :) = [fliplr(refAmp(2,1) : -ampRes : bMin(2)) ...
            refAmp(2,1)+ampRes : ampRes : bMax(2)];
    end

    crossingLevels(:, bw*(p-1)+1:bw*p) = levels;
end

if ~isempty(riseFallLevels)
    if ( refAmpQ == 2 ) && ( numRows == 1 )
        riseFallLevels = [riseFallLevels; riseFallLevels];
    end
    this.PrivRefAmpLevels = [riseFallLevels crossingLevels];
else
    this.PrivRefAmpLevels = crossingLevels;
end

%-------------------------------------------------------------------------------
% [EOF]
