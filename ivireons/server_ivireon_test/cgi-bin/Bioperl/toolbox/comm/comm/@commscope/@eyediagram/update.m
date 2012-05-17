function update(this, y)
%UPDATE Update the eye diagram scope data.
%   UPDATE(H, X) updates the collected data of the eye diagram scope object H
%   with the input X. 
%
%   If the RefreshPlot property is set to 'on', the UPDATE method also refreshes
%   the eye diagram figure.
%
%   EXAMPLES:
%
%     % Create an eye diagram scope object
%     h = commscope.eyediagram('RefreshPlot', 'off')
%          
%     % Prepare a noisy sinusoidal as input
%     x = awgn(0.5*sin(2*pi*(0:1/100:10))+j*0.5*cos(2*pi*(0:1/100:10)), 20);
%     update(h, x);             % update the eyediagram
%     h.SamplesProcessed        % Check the number of processed samples
%
%   See also COMMSCOPE, COMMSCOPE.EYEDIAGRAM, COMMSCOPE.EYEDIAGRAM/ANALYZE,
%   COMMSCOPE.EYEDIAGRAM/CLOSE, COMMSCOPE.EYEDIAGRAM/COPY,
%   COMMSCOPE.EYEDIAGRAM/DISP, COMMSCOPE.EYEDIAGRAM/EXPORTDATA,
%   COMMSCOPE.EYEDIAGRAM/PLOT, COMMSCOPE.EYEDIAGRAM/RESET.

%   @commscope/@eyediagram
%
%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/05/20 01:58:25 $

numRcvdSamps = this.PrivNumReceivedSamples;
delay = this.PrivMeasurementDelay;
yLen = length(y);

if ( (numRcvdSamps+yLen) > delay )
    % Discard samples which are received before MeasurementDelay expired
    if ( numRcvdSamps < delay )
        y = y(delay-numRcvdSamps+1:end);
        yLen = length(y);
    end

    % Update histograms
    this.updateHistograms(y, ...
        this.MeasurementSetup.PrivRefAmpLevels, ...
        this.MeasurementSetup.JitterHysteresis);

    % Check if eye levels stabilized
    if ~this.Measurements.PrivEyeLevelStable
        mObj = this.Measurements;
        getEyeLevel(mObj, this);
        if this.Measurements.PrivEyeLevelStable
            % Update horizontal histogram crossing levels to collect rise/fall time
            % data
            determineRefAmpLevels(this.MeasurementSetup, ...
                mObj.EyeLevel, ...
                this.MaximumAmplitude-this.MinimumAmplitude, ...
                this.AmplitudeResolution);

            % Update histograms
            this.updateHistograms(y, ...
                this.MeasurementSetup.PrivRefAmpLevels, ...
                this.MeasurementSetup.JitterHysteresis);
        end
    end

    % Store last NumberOfStoredTraces traces
    numTraces = this.NumberOfStoredTraces;
    if ( numTraces )
        yNumTraces = floor(yLen / this.PrivPeriod);
        % If the input has less traces, then stored only the available traces
        if ( numTraces > yNumTraces )
            numTraces = yNumTraces;
        end
        yTemp = y(1:this.PrivPeriod*numTraces);
        this.PrivLastNTraces = yTemp(:);
    end

    % Update number of processed samples
    this.PrivSampsProcessed = this.PrivSampsProcessed + yLen;

    % If RefreshPlot is on, then plot
    if ( this.PrivRefreshPlot )
        this.plot;
    end
end

% Update number of received samples
this.PrivNumReceivedSamples = this.PrivNumReceivedSamples + yLen;

% Check if there was clipping
checkClipping(this)

% Flag that analysis is out of date
this.PrivAnalysisUpToDate = false;

%-------------------------------------------------------------------------------
% [EOF]
