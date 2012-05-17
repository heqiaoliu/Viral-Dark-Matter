function [Px,w,units,Sxx] = periodogram(x,win,varargin)
%PERIODOGRAM  Power Spectral Density (PSD) estimate via periodogram method.
%   Pxx = PERIODOGRAM(X) returns the PSD estimate of the signal specified
%   by vector X in the vector Pxx.  By default, the signal X is windowed
%   with a rectangular window of the same length as X. The PSD estimate is
%   computed using an FFT of length given by the larger of 256 and the next
%   power of 2 greater than the length of X.
%
%   Note that the default window (rectangular) has a 13.3 dB sidelobe
%   attenuation. This may mask spectral content below this value (relative
%   to the peak spectral content). Choosing different windows will enable
%   you to make tradeoffs between resolution (e.g., using a rectangular
%   window) and sidelobe attenuation (e.g., using a Hann window). See
%   WinTool for more details.
%
%   Pxx is the distribution of power per unit frequency. For real signals,
%   PERIODOGRAM returns the one-sided PSD by default; for complex signals,
%   it returns the two-sided PSD.  Note that a one-sided PSD contains the
%   total power of the input signal.
%
%   Pxx = PERIODOGRAM(X,WINDOW) specifies a window to be applied to X.
%   WINDOW must be a vector of the same length as X.  If WINDOW is a window
%   other than a rectangular, the resulting estimate is a modified
%   periodogram.  If WINDOW is specified as empty, the default window is
%   used.
% 
%   [Pxx,W] = PERIODOGRAM(X,WINDOW,NFFT) specifies the number of FFT points
%   used to calculate the PSD estimate.  For real X, Pxx has length
%   (NFFT/2+1) if NFFT is even, and (NFFT+1)/2 if NFFT is odd.  For complex
%   X, Pxx always has length NFFT.  If NFFT is specified as empty, the 
%   default NFFT is used.
%
%   Note that if NFFT is greater than the segment the data is zero-padded.
%   If NFFT is less than the segment, the segment is "wrapped" (using
%   DATAWRAP) to make the length equal to NFFT. This produces the correct
%   FFT when NFFT < L, L being signal or segment length.                       
%
%   W is the vector of normalized frequencies at which the PSD is 
%   estimated.  W has units of rad/sample.  For real signals, W spans the
%   interval [0,Pi] when NFFT is even and [0,Pi) when NFFT is odd.  For
%   complex signals, W always spans the interval [0,2*Pi).
%
%   [Pxx,W] = PERIODOGRAM(X,WINDOW,W) where W is a vector of 
%   normalized frequencies (with 2 or more elements) computes the 
%   periodogram at those frequencies using the Goertzel algorithm. In this 
%   case a two sided PSD is returned. The specified frequencies in W are 
%   rounded to the nearest DFT bin commensurate with the signal's 
%   resolution.     
%
%   [Pxx,F] = PERIODOGRAM(X,WINDOW,NFFT,Fs) returns a PSD computed as a
%   function of physical frequency (Hz).  Fs is the sampling frequency 
%   specified in Hz. If Fs is empty, it defaults to 1 Hz.
%
%   F is the vector of frequencies at which the PSD is estimated and has
%   units of Hz.  For real signals, F spans the interval [0,Fs/2] when NFFT
%   is even and [0,Fs/2) when NFFT is odd.  For complex signals, F always
%   spans the interval [0,Fs).
%
%   [Pxx,F] = PERIODOGRAM(X,WINDOW,F,Fs) where F is a vector of 
%   frequencies in Hz (with 2 or more elements) computes the periodogram at 
%   those frequencies using the Goertzel algorithm. In this case a two
%   sided PSD is returned. The specified frequencies in F are rounded to 
%   the nearest DFT bin commensurate with the signal's resolution.     
%
%   [...] = PERIODOGRAM(...,'twosided') returns a two-sided PSD of a real
%   signal X. In this case, Pxx will have length NFFT and will be computed
%   over the interval [0,2*Pi) if Fs is not specified and over the interval
%   [0,Fs) if Fs is specified.  Alternatively, the string 'twosided' can be
%   replaced with the string 'onesided' for a real signal X.  This would
%   result in the default behavior.  The string 'twosided' or 'onesided'
%   may be placed in any position in the input argument list after WINDOW.
%
%   PERIODOGRAM(...) with no output arguments by default plots the PSD
%   estimate in dB per unit frequency in the current figure window.
%
%   EXAMPLE:
%      Fs = 1000;   t = 0:1/Fs:.3;
%      x = cos(2*pi*t*200)+randn(size(t));  % A cosine of 200Hz plus noise
%      periodogram(x,[],'twosided',512,Fs); % The default window is used
%      
%   See also PWELCH, PBURG, PCOV, PYULEAR, PMTM, PMUSIC, PMCOV, PEIG,
%   SPECTRUM, DSPDATA.

%   Author(s): R. Losada 
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.14.4.13 $  $Date: 2007/12/14 15:05:33 $

error(nargchk(1,6,nargin,'struct'));

% Look for undocumented (unsupported) window compensation flag.
if nargin>2 & any(strcmpi(varargin{end},{'ms','psd'})), %#ok
    esttype = varargin{end};  % Can only be specified as last input arg.
    varargin(end) = [];       % remove from input arg list.
else
    esttype = 'psd';     % default
end

N = length(x); % Record the length of the data

% Generate a default window if needed
winName = 'User Defined';
winParam = '';
if (nargin == 1) || isempty(win),
   win = rectwin(N);
   winName = 'Rectangular';
   winParam = N;
end

[options,msg] = periodogram_options(isreal(x),N,varargin{:}); 
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

Fs    = options.Fs;
nfft  = options.nfft;

% Compute the PS using periodogram over the whole nyquist range.
[Sxx,w] = computeperiodogram(x,win,nfft,esttype,Fs);

nrow = 1;
% If frequency vector was specified, return and plot two-sided PSD
% The computepsd function expects NFFT to be a scalar
if (length(nfft) > 1), 
    [ncol,nrow] = size(nfft); 
    nfft = max(ncol,nrow);
    if (length(options.nfft)>1 && strcmpi(options.range,'onesided'))
        warning(generatemsgid('InconsistentRangeOption'),...
            'Ignoring the ''onesided'' option. When a frequency vector is specified, a ''twosided'' PSD is computed.');
        options.range = 'twosided';
    end
end

% Compute the 1-sided or 2-sided PSD [Power/freq] or mean-square [Power].
% Also, compute the corresponding freq vector & freq units.
[Pxx,w,units] = computepsd(Sxx,w,options.range,nfft,Fs,esttype);

if nargout==0, % Plot when no output arguments are specified  
   w = {w};
   if strcmpi(units,'Hz'), w = {w{:},'Fs',options.Fs}; end
   hpsd = dspdata.psd(Pxx,w{:},'SpectrumType',options.range);

   % Create a spectrum object to store in the PSD object's metadata.
   hspec = spectrum.periodogram({winName,winParam});
   hpsd.Metadata.setsourcespectrum(hspec);

   plot(hpsd);

else
   Px = Pxx;
   % If the frequency vector was specified as a row vector, return outputs 
   % the correct dimensions
   if nrow > 1,  
       Px = Px.'; w = w.'; Sxx = Sxx.'; 
   end
end

%------------------------------------------------------------------------------
function [options,msg] = periodogram_options(isreal_x,N,varargin)
%PERIODOGRAM_OPTIONS   Parse the optional inputs to the PERIODOGRAM function.
%   PERIODOGRAM_OPTIONS returns a structure, OPTIONS, with following fields:
%
%   options.nfft         - number of freq. points at which the psd is estimated
%   options.Fs           - sampling freq. if any
%   options.range        - 'onesided' or 'twosided' psd
   
% Generate defaults 
options.nfft = max(256, 2^nextpow2(N));
options.Fs = []; % Work in rad/sample

% Determine if frequency vector specified
freqVecSpec = false;
if (~isempty(varargin) && length(varargin{1}) > 1)
    freqVecSpec = true;
end    

if isreal_x && ~freqVecSpec,
   options.range = 'onesided';
else
   options.range = 'twosided';
end

if any(strcmp(varargin, 'whole'))
    warning(generatemsgid('invalidRange'), '''whole'' is not a valid range, use ''twosided'' instead.');
elseif any(strcmp(varargin, 'half'))
    warning(generatemsgid('invalidRange'), '''half'' is not a valid range, use ''onesided'' instead.');
end

[options,msg] = psdoptions(isreal_x,options,varargin{:});

% [EOF] periodogram.m
