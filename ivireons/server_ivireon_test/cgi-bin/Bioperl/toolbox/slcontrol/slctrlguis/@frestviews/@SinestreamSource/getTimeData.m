function getTimeData(this,selection,resp,gridsize)
%  GETTIMEDATA obtains the data corresponding to the selection and places
%  it in the data of the response.
%
%


% Author(s): Erman Korkut 12-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2009/04/21 04:50:06 $

% Write the full data
% Account for the first frequency for the full sine
freqswitchpoints = [0;this.FreqSwitchInd(:)];

if strcmp(this.Input.ApplyFilteringInFRESTIMATE,'off') || strcmp(this.ShowFilteredOutput,'off')
    % Filtering is OFF, show full signal
    % Wipe out all amplitudes to avoid assignment dimension mismatch
    resp.Data.Amplitude = zeros(freqswitchpoints(selection+1)-freqswitchpoints(selection),gridsize(1),gridsize(2));
    % Full sine data for all I/O pairs
    for ctin = 1:gridsize(2)
        for ctout = 1:gridsize(1)
            resp.Data.Amplitude(:,ctout,ctin) = this.Output{ctout,ctin}.Data(...
                1+freqswitchpoints(selection):freqswitchpoints(selection+1));
        end
    end
    % Write common time vector
    resp.Data.Time = this.Output{1,1}.Time(1+freqswitchpoints(selection):freqswitchpoints(selection+1));
    resp.Data.Ts = this.Ts(selection);
    resp.Data.Focus = [resp.Data(1).Time(1) resp.Data(1).Time(end)];
    
    % Mark steady state portion in the view
    resp.View.SSIndex = this.SSSwitchInd(selection)-freqswitchpoints(selection);
else
    % Filtering is ON, show steady state portion only.    
    % Get the filtering data
    % Scalar expand samples per period
    samps = this.Input.SamplesPerPeriod.*ones(size(this.Input.Frequency));
    samps = samps(selection);
    % Compute ts
    ts = unitconv(this.Input.Frequency(selection),this.Input.FreqUnits,'Hz');
    % Wipe out all amplitudes to avoid assignment dimension mismatch
    resp.Data.Amplitude = zeros(this.FreqSwitchInd(selection)-this.SSSwitchInd(selection)-samps,gridsize(1),gridsize(2));
    % Full steady state data for all I/O pairs
    for ctin = 1:gridsize(2)
        for ctout = 1:gridsize(1)
            % Get the steady state portion
            ssSig = this.Output{ctout,ctin}.Data(1+this.SSSwitchInd(selection):...
                this.FreqSwitchInd(selection));
            % Get the filter
            filt = this.Input.designFIRFilter(ts,samps);
            % Filter it
            ssSig = filter(filt,1,ssSig(:));
            % Write after the first frequency
            resp.Data.Amplitude(:,ctout,ctin) = ssSig(1+samps:end);
        end
    end
    % Write common time vector
    resp.Data.Time = this.Output{1,1}.Time(1+this.SSSwitchInd(selection)+samps:...
                this.FreqSwitchInd(selection));
    resp.Data.Ts = this.Ts(selection);
    resp.Data.Focus = [resp.Data(1).Time(1) resp.Data(1).Time(end)];
    
    % Mark steady state portion in the view
    % Show everything thick
    resp.View.SSIndex = 1;
    
    
end

% Update the view's frequency and frequency units fields
resp.View.Frequency = this.Input.Frequency(selection);
resp.View.FreqUnits = this.Input.FreqUnits;







