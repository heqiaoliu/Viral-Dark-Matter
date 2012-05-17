function updateHistograms(this, y, horRef, hysteresis)
%UPDATEHISTOGRAMS Update the histogram entries

%   @commscope/@abstractHist2D
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/11/28 17:44:43 $

% Check if y is a vector
if ( ~(any(size(y) == 1)) )
    error([this.getErrorId ':InputNotVector'], 'Input vector must be a vector');
end

% Get parameters
period = this.PrivPeriod;

% Convert y to a column vector
y = y(:);

% If last processing stopped in the middle of a period, prepend with NaN
y = [(NaN+j*NaN)*ones(this.PrivLastSampleIndex, 1); y];

% Store the padded input length.  We will use this to determine
% PrivLastSampleIndex
yLen = length(y);

% If length of y is not an integer multiple of input, then pad with NaN.  Add a
% row of NaNs to make sure that the result is a matrix
tailLength = 2*period - rem(length(y), period);
y = [y; (NaN+j*NaN)*ones(tailLength, 1)];

% Update the histograms
this.updateVerHist(y);
this.updateHorHist(y, horRef, hysteresis);

% Update the last sample index
this.PrivLastSampleIndex = rem(yLen, period);

%-------------------------------------------------------------------------------
% [EOF]
