function this = loadobj(s)
%LOADOBJ Load the object THIS

%   @commscope\@eyediagram

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/20 01:58:22 $

% Construct the new class
this = feval(s.class);

% Save Measurements to use later
measurements = copy(s.Measurements);

% Add Measurements and MeasurementsSetup
this.Measurements = copy(measurements);
this.MeasurementSetup = copy(s.MeasurementSetup);

% Remove unnecessary and read-only fields
if isstruct(s)
    s = rmfield(s, 'class');
    s = rmfield(s, 'Measurements');
    s = rmfield(s, 'MeasurementSetup');

    % Set the remaining fields
    set(this,s);
else
    this = copy(s);
end

% Set private fields that need to be loaded
this.PrivSampsProcessed = s.SamplesProcessed;
if isfield(s, 'PrivNumReceivedSamples')
    this.PrivNumReceivedSamples = s.PrivNumReceivedSamples;
else
    this.PrivNumReceivedSamples = s.SamplesProcessed;
end
this.PrivVerHistRe = s.PrivVerHistRe;
this.PrivVerHistIm = s.PrivVerHistIm;
this.PrivHorHistRe = s.PrivHorHistRe;
this.PrivHorHistIm = s.PrivHorHistIm;
this.PrivLastNTraces = s.PrivLastNTraces;
this.PrivPlotFunction = s.PrivPlotFunction;

% Added for R2008a.  Check for compatibility with 7b
if isfield(s, 'PrivLastValidSampleIdxIm')
    % This was saved with R2008a
    this.PrivLastValidSampleIdxIm = s.PrivLastValidSampleIdxIm;
    this.PrivLastValidSampleIm = s.PrivLastValidSampleIm;
    this.PrivLastValidSampleIdxRe = s.PrivLastValidSampleIdxRe;
    this.PrivLastValidSampleRe = s.PrivLastValidSampleRe;
    this.PrivNumHorHist = s.PrivNumHorHist;
end

% Reassign measurements since it was reset due to property updates
this.Measurements = measurements;

%-------------------------------------------------------------------------------
% [EOF]
