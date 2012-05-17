function [binCenters, binEdges] = calcBins(this, minVal, maxVal, delta) %#ok
%CALCBINS Calculate bin centers and edges

%   @commscope/@abstractHist2D
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/14 15:01:45 $

% Calculate bins
bins = minVal:delta:maxVal;

% Set the bin values.  
binCenters = bins;
binEdges = [bins maxVal+delta] - delta/2;

%-------------------------------------------------------------------------------
% [EOF]
