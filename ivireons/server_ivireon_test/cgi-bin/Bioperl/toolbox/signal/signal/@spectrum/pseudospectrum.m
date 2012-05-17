function varargout = pseudospectrum(this,x,varargin)
%PSEUDOSPECTRUM  Pseudospectrum estimate.
%    Hps = PSEUDOSPECTRUM(H,X) returns a DSP data object (<a href="matlab:help dspdata">dspdata</a>) that
%    contains a pseudospectrum estimate of X estimated using the
%    pseudospectrum estimator specified by H. X can be a vector or a
%    matrix. If X is a vector it is a signal, if it's matrix it may be
%    either a data matrix such that X'*X=R, or a correlation matrix R.
%
%    Valid pseudospectrum estimators:
%           <a href="matlab:help spectrum.eigenvector">eigenvector</a>
%           <a href="matlab:help spectrum.music">music</a>
%
%    For real signals, PSEUDOSPECTRUM returns half the range of the Nyquist
%    interval by default; for complex signals, it returns the whole range.
%
%    Hps = PSEUDOSPECTRUM(H,X) returns the object Hps that contains a
%    vector of normalized frequencies at which the pseudospectrum is
%    estimated.  The frequency has units of rad/sample. For real signals,
%    the frequency spans the interval [0,Pi] when NFFT is even and [0,Pi)
%    when NFFT is odd.  For complex signals, the frequency always spans the
%    interval [0,2*Pi).
%
%    Hps = PSEUDOSPECTRUM(H,X,'Fs',Fs) returns an object with the
%    pseudospectrum computed as a function of physical frequency (Hz).  Fs
%    is the sampling frequency specified in Hz.
%
%    Hps = PSEUDOSPECTRUM(...,'SpectrumRange','whole') returns an object
%    with the pseudospectrum for the whole Nyquist range of a real signal
%    X. In this case, the spectrum will be computed over the interval
%    [0,2*Pi) if Fs is not specified and over the interval [0,Fs) if Fs is
%    specified.  The SpectrumRange can also be 'half' for a real signal X,
%    which is the default behavior.
%
%    Hps = PSEUDOSPECTRUM(...,'NFFT',nfft) specifies nfft as the number of
%    FFT points to use to calculate the pseudospectrum.
%
%    Hps = PSEUDOSPECTRUM(...,'CenterDC',true) specifies that the spectrum
%    should be shifted so that the zero-frequency component is in the
%    center of the spectrum.  CenterDC is false by default.
%
%    Hps = PSEUDOSPECTRUM(...,'FreqPoints','User Defined','FrequencyVector',f) 
%    returns a pseudospectrum object evaluated at the frequencies defined
%    by the vector f of frequencies
%
%    PSEUDOSPECTRUM(...) with no output arguments plots the pseudospectrum
%    estimate in dB in the current figure window.
%
%    An alternative to specifying the individual input arguments to
%    PSEUDOSPECTRUM is to create an options object using <a href="matlab:help spectrum/pseudospectrumopts">pseudospectrumopts</a>.
%
%   EXAMPLE: Spectral analysis of a signal containing complex sinusoids
%            % and noise.
%            s1 = RandStream.create('mrg32k3a');
%            n = 0:99;   
%            s = exp(i*pi/2*n)+2*exp(i*pi/4*n)+exp(i*pi/3*n)+randn(s1,1,100);  
%            h = spectrum.music(3);    % Create a MUSIC spectral estimator.
%            pseudospectrum(h,s);      % Calculate and plot the pseudospectrum.
%
%    See also SPECTRUM/POWEREST, SPECTRUM, DSPDATA.

%   Author(s): P. Pacheco
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $Date: 2008/10/31 07:03:33 $

% Help for MUSIC and EIGENVECTOR's PSEUDOSPECTRUM method.

% [EOF]
