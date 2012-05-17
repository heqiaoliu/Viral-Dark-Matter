function varargout = powerest(this,x,Fs)
%POWEREST   Computes the powers and frequencies of sinusoids.
%   POW = POWEREST(H,X) returns the vector POW containing the estimates
%   of the powers of the complex sinusoids contained in the data
%   represented by X.  H must be a <a href="matlab:help spectrum.music">music</a> or <a href="matlab:help spectrum.eigenvector">eigenvector</a> estimator. 
%
%   X can be a vector or a matrix. If it's a vector it is a signal, if it's
%   a matrix it may be either a data matrix such that X'*X=R, or a
%   correlation matrix R.  How X is interpreted depends on the spectral
%   estimator's (H) input type, which can be any one of the following:
%       'Vector'  (default)
%       'DataMatrix'
%       'CorrelationMatrix'
%
%   [POW,W] = POWEREST(...) returns in addition a vector of frequencies W
%   of the sinusoids contained in X.  W is in units of rad/sample.
%
%   [POW,F] = POWEREST(...,Fs) uses the sampling frequency Fs in the
%   computation and returns the vector of frequencies, F, in Hz.
%
%   EXAMPLE:
%      s1 = RandStream.create('mrg32k3a');
%      n = 0:99;   
%      s = exp(i*pi/2*n)+2*exp(i*pi/4*n)+exp(i*pi/3*n)+randn(s1,1,100);  
%      H = spectrum.music(3);
%      [P,W] = powerest(H,s);
%   
%   See also SPECTRUM/PSEUDOSPECTRUM, SPECTRUM, DSPDATA. 

%   Author(s): P. Pacheco
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/10/31 07:03:32 $

% Help for powerest.m

% [EOF]
