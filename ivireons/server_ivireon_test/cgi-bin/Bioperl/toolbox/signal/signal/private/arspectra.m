function [Pxx,w,msg,units,Sxx,options] = arspectra(method,x,p,varargin)
%ARSPECTRA Power Spectral Density estimate via a specified parametric method.
%   Pxx = ARSPECTRA(METHOD,X,P) returns the order P parametric PSD estimate of 
%   vector X in vector Pxx.  It uses the method specified in METHOD.  METHOD 
%   can be one of: 'arcov', 'arburg', 'armcov' and 'aryule'.
%
%   For real signals, ARSPECTRA returns the one-sided PSD by default; for 
%   complex signals, it returns the two-sided PSD.  Note that a one-sided PSD
%   contains the total power of the input signal.
%
%   Pxx = ARSPECTRA(...,NFFT) specifies the FFT length used to calculate the
%   PSD estimates.  For real X, Pxx has length (NFFT/2+1) if NFFT is even, 
%   and (NFFT+1)/2 if NFFT is odd.  For complex X, Pxx always has length NFFT.
%   If empty, the default NFFT is 256.
%
%   [Pxx,W] = ARSPECTRA(...) returns the vector of normalized angular
%   frequencies, W, at which the PSD is estimated.  W has units of 
%   radians/sample.  For real signals, W spans the interval [0,Pi] when NFFT
%   is even and [0,Pi) when NFFT is odd.  For complex signals, W always 
%   spans the interval [0,2*Pi).
%
%   [Pxx,F] = ARSPECTRA(...,Fs) specifies a sampling frequency Fs in Hz and
%   returns the power spectral density in units of power per Hz.  F is a
%   vector of frequencies, in Hz, at which the PSD is estimated.  For real 
%   signals, F spans the interval [0,Fs/2] when NFFT is even and [0,Fs/2)
%   when NFFT is odd.  For complex signals, F always spans the interval 
%   [0,Fs).  If Fs is empty, [], the sampling frequency defaults to 1 Hz.  
%
%   [Pxx,W] = ARSPECTRA(...,'twosided') returns the PSD over the interval
%   [0,2*Pi), and [Pxx,F] = PBURG(...,Fs,'twosided') returns the PSD over
%   the interval [0,Fs).  Note that 'onesided' may be optionally specified,
%   but is only valid for real X.  The optional, trailing, string argument
%   'twosided' or 'onesided' may be placed in any position in the input 
%   argument list after the input argument P.
%
%   [...,MSG] = ARSPECTRA(...) returns an optional output string argument, MSG,
%   which contains the error message string, if any.
%
%   [...,MSG,UNITS] = ARSPECTRA(...) returns an optional output string argument, 
%   UNITS, which contains the string describing the units of the frequency 
%   vector returned.
%
%   [...,Sxx] = ARSPECTRA(...) returns the Power Spectrum (PS) estimate Sxx
%   via the specified parametric method.
%
%   ARSPECTRA complies with the general specs. for all AR PSD functions.

%   Author(s): D. Orofino and R. Losada
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.22.4.10 $  $Date: 2008/04/21 16:30:55 $ 

nargs = 3; % Number of explicit args (not included in varargin)
error(nargchk(nargs,8,nargin,'struct'));

if any(strcmp(varargin, 'whole'))
    warning(generatemsgid('invalidRange'), '''whole'' is not a valid range, use ''twosided'' instead.');
elseif any(strcmp(varargin, 'half'))
    warning(generatemsgid('invalidRange'), '''half'' is not a valid range, use ''onesided'' instead.');
end

% Generate an options structure with all the info. we need
if nargin == nargs,
   varargin = {}; 
end
isreal_x = isreal(x);
[options,msg] = arspectra_options(isreal_x,varargin{:}); 
if ~isempty(msg),
   Pxx = [];
   w = [];
   units = '';
   return
end

% Determine the AR model
[a,v] = feval(method,x,p); 

% Compute the power spectrum via freqz. Always use the 'whole' option in order
% to be able to return the Nyquist point.
if isempty(options.Fs)
    Fs = {};
else
    Fs = {options.Fs};
end
[h,w] = freqz(1,a,options.nfft,'whole',Fs{:});

if v<0,
    error(generatemsgid('MustBePositive'), ...
        ['The variance estimate of the white noise input to the AR model is negative. ', ...
        'Try to lower the order of the AR model.']);
end
Sxx = v*abs(h).^2; % This is the power spectrum [Power] (input variance*power of AR model)

% Compute the 1-sided or 2-sided PSD [Power/freq], or mean-square [Power].
% Also, compute the corresponding frequency and frequency units.
[Pxx,w,units] = computepsd(Sxx,w,options.range,options.nfft,options.Fs,'psd');

%-----------------------------------------------------------------------------------
function [options,msg] = arspectra_options(isreal_x,varargin)
%ARSPECTRA_OPTIONS   Parse the optional inputs to the ARSPECTRA function.
%   ARSPECTRA_OPTIONS returns a structure, OPTIONS, with following fields:
%
% Inputs:
%   isreal_x       - flag which is set to 1 if x is real and 0 if x is complex
%   varagin        - contains optional inputs to ARSPECTRA, such as NFFT, Fs, 
%                    and the string 'onesided' or 'twosided'
%
% Outputs:
%   options.nfft   - number of freq. points at which the psd is estimated
%   options.Fs     - sampling freq. if any
%   options.range  - 'onesided' or 'twosided' psd

% Generate defaults   
options.nfft = 256;
options.Fs = []; % Work in radians/sample
if nargin > 1
    nfft_freqs = varargin{1}; 
else
    nfft_freqs = options.nfft;
end
if isreal_x && (length(nfft_freqs) <= 1),
   options.range = 'onesided';
else
   options.range = 'twosided';
end
msg = '';

[options,msg] = psdoptions(isreal_x,options,varargin{:});

if (length(nfft_freqs)>1 && strcmpi(options.range,'onesided'))
    warning(generatemsgid('InconsistentRangeOption'),...
        'Ignoring the ''onesided'' option. When a frequency vector is specified, a ''twosided'' PSD is computed');
    options.range = 'twosided';
end

% [EOF] arspectra.m
