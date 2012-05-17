function processEvents(this, eventData)
%PROCESSEVENTS Process the events received through listeners.
%   PROCESSEVENTS(THIS, EVENTDATA) decides on the event source based on the
%   EVENTDATA and acts accordingly.

%   @commscope/@eyediagram
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/05/31 23:15:09 $

resetEventSources = {'AmplitudeThreshold', ...
    'JitterHysteresis'};

refAmpCalculateEvents = {'ReferenceAmplitude', ...
    'CrossingBandWidth'};

recalculateEvents = {'BERThreshold', 'EyeLevelBoundary'};

eventSource = eventData.Source.Name;

if strmatch(eventData.Source.Name, resetEventSources)
    this.reset;
elseif strmatch(eventSource, recalculateEvents)
    % Recalculate only if the results were stable
    if this.Measurements.PrivEyeLevelStable
        this.analyze;
    end
elseif strmatch(eventSource, refAmpCalculateEvents)
    determineRefAmpLevels(this.MeasurementSetup, ...
        this.Measurements.EyeLevel, ...
        this.MaximumAmplitude-this.MinimumAmplitude, ...
        this.AmplitudeResolution);
    this.PrivNumHorHist = size(this.MeasurementSetup.PrivRefAmpLevels, 2);
    this.reset;
elseif strcmp(eventSource, 'PrivRefAmpLevels')
    this.PrivNumHorHist = size(this.MeasurementSetup.PrivRefAmpLevels, 2);
    this.PrivSampsProcessed = 0;
    this.PrivLastNTraces = zeros(this.NumberOfStoredTraces*this.PrivPeriod, 1);
    this.resetHistograms;
else
    % This should never happen
    error([this.getErrorId ':unknownEventSource'], ['Eye diagram object '...
        'received an EyeMeasurementSetupPropertiesChanged event from an '...
        'unknown source']);
end

%-------------------------------------------------------------------------------
% [EOF]
