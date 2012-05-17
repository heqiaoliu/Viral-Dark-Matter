function calcAndSetHorizontalBins(this, minVal, maxVal, delta)
%CALCANDSETHORIZONTALBINS Calculate horizontal bin values and set properties

%   @commscope/@abstractHist2D
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:01:43 $

% Calculate bins
[binCenters binEdges] = calcBins(this, minVal, maxVal, delta);

% Set the bin values.  
this.PrivHorBinCenters = binCenters;
this.PrivHorBinEdges = binEdges;

% Reset histograms
this.resetHistograms;

%-------------------------------------------------------------------------------
% [EOF]
