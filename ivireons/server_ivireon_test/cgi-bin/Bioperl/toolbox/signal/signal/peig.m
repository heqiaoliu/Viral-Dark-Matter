function varargout = peig( varargin )
%PEIG  Frequency estimate via the eigenvector method.
%   S = PEIG(X,P) returns the pseudospectrum of a discrete-time signal
%   vector X in the vector S. P is the number of complex sinusoids in
%   the signal X.  If X is a data matrix, each row is interpreted as
%   a separate sensor measurement or trial.  You can use the function
%   CORRMTX to generate data matrices to be used here.
%
%   S = PEIG(R,P,'corr') returns the pseudospectrum of a discrete-time
%   signal whose correlation matrix estimate is given by the positive
%   definite matrix R. Exact conjugate-symmetry of R is ensured by forming
%   (R+R')/2 inside the function.
%
%   If P is a two element vector, P(2) is used as a cutoff for signal and
%   noise subspace separation.  All eigenvalues greater than P(2) times
%   the smallest eigenvalue are designated as signal eigenvalues.  In 
%   this case, the signal subspace dimension is at most P(1).
%
%   For real signals, PEIG returns half the pseudospectrum by default;
%   for complex signals, it returns the whole pseudospectrum.  To return
%   the whole pseudospectrum for real signals use PEIG(X,P,'whole').
%   Note that the strings 'whole' and 'corr' can be specified at any
%   position after P.
%
%   S = PEIG(X,P,NFFT) specifies the FFT length used to calculate the
%   pseudospectrum.  For real X, S has length (NFFT/2+1) if NFFT is even,
%   and (NFFT+1)/2 if NFFT is odd.  For complex X, S always has length 
%   NFFT.  If empty, the default NFFT is 256.
%
%   [S,W] = PEIG(...) returns the vector of normalized angular 
%   frequencies, W, at which the pseudospectrum is evaluated.  W has units
%   of rad/sample.  For real signals, W spans the interval [0,Pi] when
%   NFFT is even and [0,Pi) when NFFT is odd.  For complex signals, W
%   always spans the interval [0,2*Pi).
%
%   [S,W] = PEIG(X,P,W) where W is a vector of normalized frequencies 
%   (with 2 or more elements) computes the pseudospectrum at 
%   those frequencies.  In this case the whole pseudospectrum is returned. 
%
%   [S,F] = PEIG(...,Fs) specifies a sampling frequency Fs in Hz and
%   returns the pseudospectrum as a function of frequency in Hz.  F is a
%   vector of frequencies, in Hz, at which the pseudospectrum is computed.
%   For real signals, F spans the interval [0,Fs/2] when NFFT is even and
%   [0,Fs/2) when NFFT is odd.  For complex signals, F always spans the
%   interval [0,Fs).  If Fs is empty, [], the sampling frequency defaults
%   to 1 Hz. 
%
%   [S,F] = PEIG(X,P,F,Fs) where F is a vector of frequencies in Hz 
%   (with 2 or more elements) computes the pseudospectrum at 
%   those frequencies.  In this case the whole pseudospectrum is returned. 
%
%   [S,F] = PEIG(...,NW,NOVERLAP) divides the signal vector, X, into
%   sections of length NW which overlap by NOVERLAP samples.  The sections 
%   are concatenated as the rows of a matrix that multiplied times its
%   transposed results in an estimate of the NW by NW correlation matrix of
%   X.  If NW is a scalar, it is ignored if X is already a matrix. NOVERLAP
%   is also ignored in this case. If NW is a vector, the rows of the data
%   matrix are windowed with NW.  The window length must equal the number
%   of columns in the data matrix.  If empty or omitted, NW = 2*P, and
%   NOVERLAP = NW-1. In order to obtain a valid data matrix, the following
%   condition must be satisfied: NW <= (ceil((Lx-NW)/(NW-NOVERLAP))+1)
%   where Lx is the length of the signal vector X.
%
%   [S,W,V,E] = PEIG(...) returns a matrix V whose columns are the
%   eigenvectors corresponding to the noise subspace and a vector E with
%   all eigenvalues. This syntax is useful to determine the frequencies
%   and powers of the sinusoids.
%
%   PEIG(...) with no output arguments plots the pseudospectrum in the
%   current figure window.
%
%   EXAMPLES:
%      [s1 s2] = RandStream.create('mrg32k3a','NumStreams',2);
%      n=0:99;   
%      s=exp(1i*pi/2*n)+2*exp(1i*pi/4*n)+exp(1i*pi/3*n)+randn(s1,1,100);  
%      X=corrmtx(s,12,'mod');   % Estimate the correlation matrix using
%                               % the modified covariance method.
%      peig(X,3,'whole')        % Uses the default NFFT of 256.
%
%      n=0:99; figure;
%      s2=sin(pi/3*n)+2*sin(pi/4*n)+randn(s2,1,100);
%      X2=corrmtx(s2,20,'cov'); % Estimate the correlation matrix using
%                               % the covariance method.            
%      peig(X2,4,'whole')       % Use twice the signal space dimension
%                               % for real sinusoids.
%   
%   See also ROOTEIG, PMUSIC, PMTM, PCOV, PMCOV, PBURG, PYULEAR, PWELCH,
%   CORRMTX, SPECTRUM, DSPDATA.

%   Reference: M. H. Hayes, Statistical Digital Signal Processing and
%              Modeling. John Wiley & Sons, 1996.

%   Author(s): R. Losada
%   Copyright 1988-2010 The MathWorks, Inc.
%   $Revision: 1.13.4.13 $  $Date: 2010/02/17 19:00:17 $

error(nargchk(2,8,nargin,'struct'));

try
	if nargout==0,
   	pmusic(varargin{:},'ev');
	else
   	[varargout{1:max(1,nargout)}] = pmusic(varargin{:},'ev');
	end
catch ME
   throw(ME);
end

% [EOF] peig.m

