function calcAndSetVerticalBins(this, minVal, maxVal, delta)
%CALCANDSETVERTICALBINS Calculate vertical bin values and set properties

%   @commscope/@abstractHist2D
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:01:44 $

% Calculate bins
[binCenters binEdges] = calcBins(this, minVal, maxVal, delta);

% Set the bin values.  
this.PrivVerBinCenters = binCenters;
this.PrivVerBinEdges = binEdges;

% Reset histograms
this.resetHistograms;

%-------------------------------------------------------------------------------
% [EOF]
