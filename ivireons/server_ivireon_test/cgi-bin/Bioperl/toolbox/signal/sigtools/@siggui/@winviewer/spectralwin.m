function [t, f, fresp] = spectralwin(this, data)
%SPECTRALWIN Compute the equivalent spectral window

%   Author(s): V.Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.13.4.5 $  $Date: 2010/01/25 22:53:28 $

if isempty(data),
    t = [];
    f =[];
    fresp = [];
    return;
end

[N,M] = size(data);
Nfft = getparameter(this, 'nfft');
Nfft = Nfft.Value;

% Force the Nfft to be a power of two greater or equal to the number of
% elements, unless the user specified the NFFT.
if Nfft < N && Nfft == 512
    Nfft = 2.^nextpow2(numel(data));
end

% Remove  NaN
data(isnan(data)) = 0;

% Normalization
% data = data ./ (ones(N,1)*sum(data));

% Range
freqrange = getparameter(this, 'unitcircle');
index = find(strcmpi(freqrange.Value, freqrange.ValidValues));
if index == 1,
    Nfft = 2*Nfft;
end

% Padding
P = round((Nfft-N)/2);
datapad = data;
if P>0,
    datapad = [zeros(P,M); data; zeros(Nfft-N-P, M)];
end

for col=1:M,
    fresp(:,col) = freqz(datapad(:,col),1,Nfft,'whole');
end
f = (0:Nfft-1)/Nfft*2;


if rem(Nfft,2),
    % Nfft odd
    L=(Nfft-1)/2;
else
    % Nfft even
    L = Nfft/2;
end

if strcmpi(get(getparameter(this, 'normmag'), 'Value'), 'on')
    for indx = 1:size(fresp, 2)
        fresp(:, indx) = fresp(:, indx)/max(fresp(:, indx));
    end
end

% Y Units
p  = getparameter(this, 'magnitude');
possibleUnits = p.ValidValues;
FrespUnits = p.Value;
if strcmpi(FrespUnits, possibleUnits{1}),
    % Magnitude
    fresp = abs(fresp);
elseif strcmpi(FrespUnits, possibleUnits{2}),
    % Magnitude(dB)
    fresp = convert2db(fresp);
elseif strcmpi(FrespUnits, possibleUnits{3}),
    % Magnitude Squared
    fresp = abs(convert2sq(fresp));
elseif  strcmpi(FrespUnits, possibleUnits{4}),
    fresp = [];
    % Zero-phase
    for i=1:M,
        w = warning('off');
        if index == 1,
            fresp(:,i) = zerophase(data(:,i), 1, 2*Nfft, 'whole');
        elseif index == 2,
            fresp(:,i) = zerophase(data(:,i), 1, Nfft, 'whole');
        else
            ww = linspace(-pi, pi, Nfft);
            fresp(:,i) = zerophase(data(:,i), 1, ww(:), 'whole');
        end
        warning(w);
    end
    
    % Reapply the normalization.
    if strcmpi(get(getparameter(this, 'normmag'), 'Value'), 'on')
        for indx = 1:size(fresp, 2)
            fresp(:, indx) = fresp(:, indx)/max(fresp(:, indx));
        end
    end
end

if index == 1,
    % Keep only the positive frequencies
    f = (0:L-1)/Nfft*2;
    fresp = fresp(1:L, :);
elseif index == 3
    fresp = fftshift(fresp);
    f = f - f(L+1);
end

% Frequency units
fs = getparameter(this, 'sampfreq');
t = 1:size(data,1);
if ~isempty(fs.Value),
    t = t/fs.Value;
    f = f*fs.Value/2;
    freqmode = getparameter(this, 'freqmode');
    if strcmpi(freqmode.Value, 'Normalized'),
        t = t * fs.Value;
        f = 2*f/fs.Value;
    end
end

% [EOF]
