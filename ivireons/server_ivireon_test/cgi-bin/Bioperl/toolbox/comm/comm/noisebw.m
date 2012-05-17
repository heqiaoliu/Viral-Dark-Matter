function bw = noisebw(num, den, numSamp, Fs)
%NOISEBW Calculate the equivalent noise bandwidth of a digital lowpass filter.
%   BW = NOISEBW(NUM, DEN, NUMSAMP, Fs) returns the two-sided equivalent noise
%   bandwidth, in Hz, of a digital lowpass filter given in descending powers of z by
%   numerator vector NUM and denominator vector DEN.  The bandwidth is calculated
%   over NUMSAMP samples of the impulse response.  Fs is the sampling rate of the
%   signal that the filter would process; this is used as a scaling factor to convert
%   a normalized unitless quantity into a bandwidth in Hz.
%
%   Reference:  Simulation of Communication Systems, by Jeruchim, et. al., 1992.

%   Copyright 1996-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/05/20 01:58:02 $

% Error checking --------------------------------------------------
% Total number of arguments
if (nargin ~= 4)
    error('comm:noisebw:InvalidNumberOfArgs','NOISEBW requires four input arguments.');
end

% num 
validateattributes(num, {'numeric'}, {'vector', 'nonempty', 'real'}, 'NOISEBW', 'NUM')

% den
validateattributes(den, {'numeric'}, {'vector', 'nonempty', 'real'}, 'NOISEBW', 'DEN')

% numSamp
if (isempty(numSamp) || ~isscalar(numSamp) || ~is(numSamp, 'integer') || ~isnumeric(numSamp) || numSamp<=0)
    error('comm:noisebw:InvalidNumSamp','NUMSAMP must be a positive integer scalar.');
end

% Fs
if (isempty(Fs) || ~isscalar(Fs) || ~isreal(Fs) || ~isnumeric(Fs) || Fs<=0)
    error('comm:noisebw:InvalidFs','Fs must be a positive real scalar.');
end

% Check that the filter is lowpass by finding the -10 dB point, then by checking if
% any frequencies beyond that point have a filter magnitude greater than -10 dB
h = freqz(num, den);
hMag = 20 * log10(eps + abs(h) ./ max(abs(h)));
startIndex = find(hMag <= -10, 1 );
if (any(hMag(startIndex:end) > -10))
    error('comm:noisebw:InvalidFilter','The filter is not lowpass.');
end    
% End of error checking -----------------------------------------------

% Create the impulse
impulse = zeros(numSamp, 1);
impulse(1) = 1;

% Create the impulse response
response = filter(num, den, impulse);

% Calculate the noise bandwidth
numBW = cumsum(response .* conj(response));
numBW = numBW(end) * Fs;
denBW = cumsum(response) .* cumsum(conj(response));
denBW = denBW(end);

bw = numBW / denBW;
return;

% EOF -- noisebw.m
