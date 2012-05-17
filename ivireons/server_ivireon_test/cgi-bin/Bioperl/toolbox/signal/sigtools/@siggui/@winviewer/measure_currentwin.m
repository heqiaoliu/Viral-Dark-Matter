function [FLoss, RSAttenuation, MLWidth] = measure_currentwin(hView, index)
%MEASURE_CURRENTWIN Measure the currentwindow

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2009/03/09 19:35:38 $

if ~isrendered(hView),
    FLoss = [];
    RSAttenuation  = [];
    MLWidth = [];
    return
end

hndls = get(hView, 'Handles');

if ~isempty(index),
    % Get the data
    haxtd = hndls.axes.td;
    htline = findobj(haxtd, 'Tag' , 'tline');
    t = get(htline(index), 'XData');
    data = get(htline(index), 'YData');
    [f, fresp] = computefresp(hView, data(:));
    
    % Do the measurement
    % Loss Factor (%)
    FLoss = LossFactor(fresp);
    % Main Lobe Width (at -3dB)
    MLWidth = bandwidth(f, fresp);
    % Relative Side Lobe Attenuation (dB)
    RSAttenuation = attenuation(fresp);
else
    % If there's no data in the viewer
    MLWidth = [];
    RSAttenuation = [];
    FLoss = [];
end

%---------------------------------------------------------------------
function [f, fresp] = computefresp(hView, data)

M = 1;
N = length(data);
Nfft = getparameter(hView, 'nfft');
Nfft = Nfft.Value;

% Remove  NaN
data(isnan(data)) = 0;

% Normalization
% data = data ./ (ones(N,1)*sum(data));

% Padding
P = round((Nfft-N)/2);
datapad = data;
if P>0,
    datapad = [zeros(P,M); data; zeros(Nfft-N-P, M)];
end

% Make sure that there enough points in the frequency domain for reasonnable accuracy of the measurements
Nfft = max(16*2^nextpow2(N),Nfft); 
fresp = freqz(datapad,1,Nfft,'whole');
f = [0:Nfft-1]/Nfft*2;

if rem(Nfft,2),
    % Nfft odd
    L=(Nfft-1)/2;
else
    % Nfft even
    L = Nfft/2;
end

% Frequency units
fs = getparameter(hView, 'sampfreq');
if ~isempty(fs.Value),
    f = f*fs.Value/2;
    freqmode = getparameter(hView, 'freqmode');
    if strcmpi(freqmode.Value, 'Normalized'),
        f = 2*f/fs.Value;
    end
end

% Keep only the positive frequencies
f = f(1:L);
fresp = fresp(1:L);
    

%--------------------------------------------------------------------
function FLoss = LossFactor(fresp)
%POWERLOSS Compute the loss factor(%) of a frequency response
% We define the loss factor by the ratio of side lobe power over
% total power 

firstzero = find(diff(abs(fresp))>0);
if ~isempty(firstzero),
    firstzero = firstzero(1);
    FLoss = 1 - (sum(abs(fresp(1:firstzero).^2))/sum(abs(fresp.^2)));
    % Keep 2 digits after the coma
    FLoss = round(1e4*FLoss)/1e2;
else
    % If the frequency response is strictly positive
    FLoss = NaN;
end

%--------------------------------------------------------------------
function MLWidth = bandwidth(f, fresp)
%BANDWIDTH Measure the bandwidth at -3dB
%   Determine the resolution power a the window

fresp = convert2db(fresp);
% The 3dB are relative to the maximum
MLWidth = 2*f(max(find((fresp-fresp(1))>=-3)));

    
%--------------------------------------------------------------------
function RSAttenuation = attenuation(fresp)
%ATTENUATION Relative side lobe attenuation (dB)
%   Determine the rejection power of the window

fresp = convert2db(fresp);
% Find the peaks in fresp
ind = findpeaks(fresp);
% Keep the highest peak
RSAttenuation = max(fresp(ind))-fresp(1);
% Keep 1 digit after the coma
RSAttenuation = round(10*RSAttenuation)/10;


%--------------------------------------------------------------------
function ind = findpeaks(fresp)
% Find the local maximum

deriv = diff(fresp);
% Looking for transition from positive to negative
ind = find(diff(sign(deriv))==-2);
% Add 1 to compensate the diff
ind = ind + 1;
% Keep the 10 first peaks
if length(ind)>=10,
    ind = ind(1:10);
end


% [EOF]
