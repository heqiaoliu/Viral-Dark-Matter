function [pdfRe pdfIm] = calcPDF(this)
%CALCPDF Calculate the probability density function

%   @commscope/@abstractHist2D
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/10/31 05:55:23 $

% Calculate average number of samples per time instance
numSampsPerTimeInstance = (this.PrivSampsProcessed/this.PrivPeriod);

% If the last period of the histogram was not a full period, then first
% PrivLastSampleIndex columns have one more sample then the rest
idx = this.PrivLastSampleIndex;
norm1 = ceil(numSampsPerTimeInstance);
norm2 = floor(numSampsPerTimeInstance);
if ( norm1 == 0 )
    norm1 = 1;
    norm2 = 1;
elseif ( norm2 == 0 )
    norm2 = 1;
end

% Normalize histogram to obtain PDF
verHistRe = this.PrivVerHistRe;
pdfRe = [verHistRe(:, 1:idx) / norm1, verHistRe(:, idx+1:end) / norm2];

verHistIm = this.PrivVerHistIm;
if ~isempty(verHistIm)
    pdfIm = [verHistIm(:, 1:idx) / norm1, verHistIm(:, idx+1:end) / norm2];
else
    pdfIm = [];
end
%-------------------------------------------------------------------------------
% [EOF]
