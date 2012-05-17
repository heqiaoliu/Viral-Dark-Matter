function resetHistograms(this)
%RESETHISTOGRAMS Reset the histograms

%   @commscope/@abstractHist2D
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/11/07 18:17:42 $

% Reset PrivLastSampleIndex
this.PrivLastSampleIndex = 0;

% Get the histogram size
VM = length(this.PrivVerBinCenters);
VN = this.PrivNumVerHist;
HM = this.PrivNumHorHist;
HN = length(this.PrivHorBinCenters);

% Set histograms to zeros
this.PrivVerHistRe = zeros(VM, VN);
this.PrivHorHistRe = zeros(HM, HN);
this.PrivLastValidSampleRe = zeros(HM, 1);
this.PrivLastValidSampleIdxRe = zeros(HM, 1);
this.PrivLastValidSampleIm = zeros(HM, 1);
this.PrivLastValidSampleIdxIm = zeros(HM, 1);

if ( this.PrivOperationMode )
    this.PrivVerHistIm = zeros(VM, VN);
    this.PrivHorHistIm = zeros(HM, HN);
else
    this.PrivVerHistIm = [];
    this.PrivHorHistIm = [];
end


%-------------------------------------------------------------------------------
% [EOF]
