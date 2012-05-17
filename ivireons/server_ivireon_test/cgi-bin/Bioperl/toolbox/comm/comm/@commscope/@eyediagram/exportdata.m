function [verHist eyel horHistX horHistRF] = exportdata(this)
%EXPORTDATA Export the eye diagram data
%   [VERHIST EYEL HORHISTX HORHISTRF] = EXPORTDATA(H)
%   Exports the eye diagram data collected by the eyediagram object H.
%
%   VERHIST is a matrix that holds the vertical histogram, which is also used to
%   plot '2D Color' and '3D Color' eye diagrams.
%
%   EYEL is a matrix that holds the data used to plot 2D Line eye diagram.  Each
%   row of the EYEC holds one trace of the input signal.
%
%   HORHISTX is a matrix that holds the crossing point histogram data collected
%   for the values defined by the CrossingAmplitudes property of the
%   MeasurementSetup object.  HORHISTX(i, :) represents the histogram for
%   CrossingAmplitudes(i).
%
%   HORHISTRF is a matrix that holds the crossing point histograms for rise and
%   fall time levels.  HORHISTRF(i,:) represents the histogram for
%   AmplitudeThreshold(i).
%
%   See also COMMSCOPE, COMMSCOPE.EYEDIAGRAM, COMMSCOPE.EYEDIAGRAM/ANALYZE,
%   COMMSCOPE.EYEDIAGRAM/CLOSE, COMMSCOPE.EYEDIAGRAM/COPY,
%   COMMSCOPE.EYEDIAGRAM/DISP, COMMSCOPE.EYEDIAGRAM/PLOT,
%   COMMSCOPE.EYEDIAGRAM/RESET, COMMSCOPE.EYEDIAGRAM/UPDATE.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/12/10 21:19:22 $

% Determine if rise and fall time data was collected and set number of eye
% levels.
if this.Measurements.PrivEyeLevelStable
    numEyeLevels = size(this.Measurements.EyeLevel, 2);
else
    numEyeLevels = 1;
end
horHistRe = this.PrivHorHistRe;
horHistIm = this.PrivHorHistIm;

% Get the vertical and horizontal histogram matrices
if strcmp(this.OperationMode, 'Real Signal')
    verHist = this.PrivVerHistRe;

    horHistX = horHistRe(2*(numEyeLevels-1)+1:end, :);
    horHistRF = horHistRe(1:2*(numEyeLevels-1), :);
else
    verHist = this.PrivVerHistRe + j*this.PrivVerHistIm;

    horHistX = horHistRe(2*(numEyeLevels-1)+1:end, :) + ...
        j * horHistIm(2*(numEyeLevels-1)+1:end, :);
    horHistRF = horHistRe(1:2*(numEyeLevels-1), :) + ...
        j * horHistIm(1:2*(numEyeLevels-1), :);
end

% Get the stored traces
data = this.PrivLastNTraces;
if isempty(data)
    warning([this.getErrorId ':ExportDataNoDataStored'], ['No traces '...
        'were stored for line plot.  The number of input data samples '...
        'must be\nat least the length of one trace, which is '...
        'SamplesPerSymbol*SymbolsPerTrace samples.']);
    eyel = [];
else
    M = this.PrivPeriod;
    N = length(data)/M;
    data = reshape(data, M, N);

    % Replicate the data points at t=0 at t(end+1) to obtain a symmetric eye
    eyel = [data; [data(1,2:end) NaN]];
end

%-------------------------------------------------------------------------------
% [EOF]
