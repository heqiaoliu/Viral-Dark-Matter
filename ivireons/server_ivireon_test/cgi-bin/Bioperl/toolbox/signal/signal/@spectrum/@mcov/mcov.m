function this = mcov(varargin)
%MCOV   Modified covariance power spectral density (PSD) estimator.
%   H = SPECTRUM.MCOV returns a modified covariance (mcov) PSD estimator in
%   H.
%
%   H = SPECTRUM.MCOV(ORDER) returns a modified covariance spectral
%   estimator with the order of the autoregressive (AR) model set to the
%   numeric value specified by ORDER.
%
%   MCOV PSD estimators can be passed to the following functions along with
%   the data to perform that function:
%       <a href="matlab:help spectrum/psd">psd</a>     - calculates the PSD
%       <a href="matlab:help spectrum/psdopts">psdopts</a> - returns options to calculate the PSD
%
%   EXAMPLE: Spectral analysis of a 4th order autoregressive (AR) process.
%      s1 = RandStream.create('mrg32k3a');
%      x = randn(s1,100,1);
%      y = filter(1,[1 1/2 1/3 1/4 1/5],x);  
%      h = spectrum.mcov(4);                 % Create an mcov estimator.
%      psd(h,y,'Fs',1000);                   % Calculate and plot the PSD.
%
%   See also SPECTRUM, DSPDATA.

%   Author(s): P. Pacheco
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2008/10/31 07:03:43 $

error(nargchk(0,2,nargin,'struct'));

% Set the properties of the object.
this = spectrum.mcov;
set(this, 'EstimationMethod', 'Modified Covariance');
initialize(this,varargin{:});  % Set Nfft and Order

% [EOF]
