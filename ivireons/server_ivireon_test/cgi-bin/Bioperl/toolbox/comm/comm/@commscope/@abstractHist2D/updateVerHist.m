function updateVerHist(this, y)
%UPDATEVERHIST Update the vertical histogram entries
%   based on the input Y.

%   @commscope/@abstractHist2D
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/10 21:19:15 $

% Get parameters
period = this.PrivPeriod;
verBins = this.PrivVerBinEdges;

% Update real vertical histograms
yMat = reshape(real(y), period, length(y)/period)';
data = histc(yMat, verBins);
this.PrivVerHistRe = this.PrivVerHistRe + data(1:end-1,:);

% If the operation mode is "Complex Signal"
if ( this.PrivOperationMode )
    % Update imaginary vertical histograms
    yMat = reshape(imag(y), period, length(y)/period)';
    data = histc(yMat, verBins);
    this.PrivVerHistIm = this.PrivVerHistIm + data(1:end-1,:);
end
%-------------------------------------------------------------------------------
% [EOF]
