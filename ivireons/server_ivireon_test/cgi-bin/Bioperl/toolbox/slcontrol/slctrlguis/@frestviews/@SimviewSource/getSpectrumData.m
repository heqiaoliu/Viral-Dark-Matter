function getSpectrumData(this,selection,resp,gridsize)
%  GETSPECTRUMDATA obtains the spectrum data corresponding to the selection
%  and places it in the data of the response.
%
%

% Author(s): Erman Korkut 12-Mar-2009
% Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2009/05/23 08:21:47 $

frequnits = resp.Parent.AxesGrid.XUnits;
magunits = resp.Parent.AxesGrid.YUnits;

% Handle empty selection for chirp
if isempty(selection)
    resp.Data.Magnitude = zeros(0,gridsize(1),gridsize(2));
    resp.Data.Phase = zeros(0,gridsize(1),gridsize(2));
    resp.Data.Frequency = zeros(0,1);
    return;
end
% Wipe out all amplitudes to avoid assignment dimension mismatch
NFFT = selection(2)-selection(1)+1;
resplen = floor(NFFT/2)-1;
resp.Data.Magnitude = zeros(resplen,gridsize(1),gridsize(2));
resp.Data.Phase = zeros(resplen,gridsize(1),gridsize(2));
% Take the FFT of the selected portion for all I/O pairs
for ctin = 1:gridsize(2)
    for ctout = 1:gridsize(1)
        ssSig = this.Output{ctout,ctin}.Data(selection(1):selection(2));
        % Compute FFT
        Y = fft(ssSig(:),NFFT)/NFFT;                
        % Write one-sided spectrum ignoring DC
        resp.Data.Magnitude(:,ctout,ctin) = 2*abs(Y(2:floor(NFFT/2)));
        resp.Data.Phase(:,ctout,ctin) = angle(Y(2:floor(NFFT/2)));        
    end
end

% Write common frequency
sigTs = this.Output{1,1}.Time(selection(1)+1)-...
    this.Output{1,1}.Time(selection(1));
sigFs = 1/sigTs;
F = (sigFs/2)*linspace(0,1,floor(NFFT/2)+1);F = F(:);
% Convert units of frequency
F = unitconv(F(:),'Hz',frequnits);
resp.Data.Frequency = F(2:end-1);
resp.Data.FreqUnits = frequnits;
% Protect against the case where F is empty because NFFT < 4
if F(end-1) ~= 0
    resp.Data.Focus = [0 F(end-1)];
else
    resp.Data.Focus = [0 F(end)];
end
% Convert units of magnitude
resp.Data.Magnitude = unitconv(resp.Data.Magnitude,'abs',magunits);
resp.Data.MagUnits = magunits;



