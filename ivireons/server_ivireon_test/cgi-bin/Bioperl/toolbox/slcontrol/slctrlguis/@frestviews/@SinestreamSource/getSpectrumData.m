function getSpectrumData(this,selection,resp,gridsize)
%  GETSPECTRUMDATA obtains the spectrum data corresponding to the selection
%  and places it in the data of the response.
%
%

% Author(s): Erman Korkut 12-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2009/05/23 08:21:48 $

frequnits = resp.Parent.AxesGrid.XUnits;
magunits = resp.Parent.AxesGrid.YUnits;

% Wipe out all amplitudes to avoid assignment dimension mismatch
NFFT = this.FreqSwitchInd(selection)-this.SSSwitchInd(selection);
if strcmp(this.Input.ApplyFilteringInFRESTIMATE,'on') && strcmp(this.ShowFilteredOutput,'on')
    % Scalar expand samples per period
    samps = this.Input.SamplesPerPeriod.*ones(size(this.Input.Frequency));
    samps = samps(selection);
    % Compute ts
    ts = unitconv(this.Input.Frequency(selection),this.Input.FreqUnits,'Hz');
    NFFT = NFFT-samps;
end
resplen = floor(NFFT/2)-1;
resp.Data.Magnitude = zeros(resplen,gridsize(1),gridsize(2));
resp.Data.Phase = zeros(resplen,gridsize(1),gridsize(2));
% Take the FFT of the steady state portion for each channel
for ctin = 1:gridsize(2)
    for ctout = 1:gridsize(1)
        % Get the steady state portion
        ssSig = this.Output{ctout,ctin}.Data(1+this.SSSwitchInd(selection):...
            this.FreqSwitchInd(selection));
        % Run filtering if it is on
        if strcmp(this.Input.ApplyFilteringInFRESTIMATE,'on') && strcmp(this.ShowFilteredOutput,'on')
            % Get the filter
            filt = this.Input.designFIRFilter(ts,samps);
            % Run the filter
            ssSig = filter(filt,1,ssSig(:));
            % Compute FFT ignoring first period.
            Y = fft(ssSig(samps+1:end),NFFT)/(NFFT);
        else
            % Compute FFT
            Y = fft(ssSig(1:end),NFFT)/(NFFT);
        end
        % Write one-sided spectrum ignoring DC
        resp.Data.Magnitude(:,ctout,ctin) = 2*abs(Y(2:floor(NFFT/2)));
        resp.Data.Phase(:,ctout,ctin) = angle(Y(2:floor(NFFT/2)));
    end
end

%  Write common frequency
ssSigFs = 1/this.Ts(selection);
F = (ssSigFs/2)*linspace(0,1,floor(NFFT/2)+1);
% Convert units of frequency
F = unitconv(F(:),'Hz',frequnits);
resp.Data.Frequency = F(2:end-1);
resp.Data.FreqUnits = frequnits;
% Convert units of magnitude
resp.Data.Magnitude = unitconv(resp.Data.Magnitude,'abs',magunits);
resp.Data.MagUnits = magunits;
% Set the focus of the data to be up to 6th harmonic
resp.Data.Focus = [0 unitconv(3.5*this.Input.Frequency(selection),this.Input.FreqUnits,frequnits)];


