function varargout = cpsd(x,y,varargin)
%CPSD   Cross Power Spectral Density (CPSD) estimate via Welch's method.
%   Pxy = CPSD(X,Y) returns the Cross Power Spectral Density estimate,
%   Pxy, of the discrete-time signal vectors X and Y using Welch's
%   averaged,  modified periodogram method.  By default, X and Y are
%   divided into eight sections with 50% overlap, each section is windowed
%   with a Hamming window and eight modified periodograms are computed and
%   averaged.
%
%   If the length of X and Y are such that it cannot be divided exactly
%   into eight sections with 50% overlap, X and Y will be truncated
%   accordingly. 
%
%   Pxy is the distribution of power per unit frequency. For real signals,
%   CPSD returns the one-sided Cross PSD by default; for complex signals,
%   it returns the two-sided Cross PSD.  Note that a one-sided Cross PSD
%   contains the total power of the input signal.
%
%   Pxy = CPSD(X,Y,WINDOW), when WINDOW is a vector, divides X into
%   overlapping sections of length equal to the length of WINDOW, and then
%   windows each section with the vector specified in WINDOW.  If WINDOW is
%   an integer, X and Y are divided into sections of length equal to that
%   integer value, and a Hamming window of equal length is used.  If the
%   length of  X and Y are such that it cannot be divided exactly into
%   integer number of  sections with 50% overlap, they will be truncated
%   accordingly.  If WINDOW is omitted or specified as empty, a default
%   window is used to obtain eight sections of X and Y.
%
%   Pxy = CPSD(X,Y,WINDOW,NOVERLAP) uses NOVERLAP samples of overlap from
%   section to section.  NOVERLAP must be an integer smaller than the
%   WINDOW if WINDOW is an integer.  NOVERLAP must be an integer smaller
%   than the length of WINDOW if WINDOW is a vector.  If NOVERLAP is
%   omitted or specified as empty, the default value is used to obtain a
%   50% overlap.
%
%   [Pxy,W] = CPSD(X,Y,WINDOW,NOVERLAP,NFFT) specifies the number of FFT
%   points used to calculate the Cross PSD estimate.  For real signals, Pxy
%   has length (NFFT/2+1) if NFFT is even, and (NFFT+1)/2 if NFFT is odd.
%   For complex signals, Pxy always has length NFFT.  If NFFT is specified
%   as empty, the  default NFFT -the maximum of 256 or the next power of
%   two greater than the length of each section of X (and Y)- is used.
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
%   [Pxy,F] = CPSD(X,Y,WINDOW,NOVERLAP,NFFT,Fs) returns a Cross PSD
%   computed as a function of physical frequency (Hz).  Fs is the sampling
%   frequency specified in Hz.  If Fs is empty, it defaults to 1 Hz.
%
%   F is the vector of frequencies at which the Cross PSD is estimated and
%   has units of Hz.  For real signals, F spans the interval [0,Fs/2] when
%   NFFT is even and [0,Fs/2) when NFFT is odd.  For complex signals, F
%   always spans the interval [0,Fs).
%
%   [...] = CPSD(...,'twosided') returns a two-sided Cross PSD of the real
%   signals X and Y. In this case, Pxy will have length NFFT and will be
%   computed over the interval [0,2*Pi) if Fs is not specified and over
%   the interval [0,Fs) if Fs is specified.  Alternatively, the string
%   'twosided' can be replaced with the string 'onesided' for real
%   signals.  This would result in the default behavior.  The string
%   'twosided' or 'onesided' may be placed in any position in the input
%   argument list after NOVERLAP. 
%
%   CPSD(...) with no output arguments by default plots the Cross PSD
%   estimate in dB per unit frequency in the current figure window.
%
%   EXAMPLE:
%      Fs = 1000;   t = 0:1/Fs:.296;
%      x = cos(2*pi*t*200)+randn(size(t));  % A cosine of 200Hz plus noise
%      y = cos(2*pi*t*100)+randn(size(t));  % A cosine of 100Hz plus noise
%      cpsd(x,y,[],[],[],Fs,'twosided');    % Uses default window, overlap & NFFT. 
% 
%   See also PWELCH, PERIODOGRAM, PCOV, PMCOV, PBURG, PYULEAR, PEIG, PMTM,
%   PMUSIC, SPECTRUM, DSPDATA.

%   Author(s): P. Pacheco
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2007/12/14 15:04:09 $ 

%   References:
%     [1] Petre Stoica and Randolph Moses, Introduction To Spectral
%         Analysis, Prentice-Hall, 1997, pg. 15
%     [2] Monson Hayes, Statistical Digital Signal Processing and 
%         Modeling, John Wiley & Sons, 1996.

error(nargchk(1,7,nargin,'struct'));
error(nargoutchk(0,3,nargout,'struct'));

esttype = 'cpsd';
% Possible outputs are:
%       Plot
%       Pxx
%       Pxx, freq
[varargout{1:nargout}] = welch({x,y},esttype,varargin{:});

% [EOF]
