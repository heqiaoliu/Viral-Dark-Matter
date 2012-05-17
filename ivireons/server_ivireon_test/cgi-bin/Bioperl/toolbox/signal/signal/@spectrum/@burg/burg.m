function this = burg(varargin)
%BURG   Burg power spectral density (PSD) estimator.
%   H = SPECTRUM.BURG returns a Burg PSD estimator in H.
%
%   H = SPECTRUM.BURG(ORDER) returns a Burg spectral estimator with the
%   order of the autoregressive (AR) model set to the numeric value
%   specified by ORDER.
%
%   Burg PSD estimators can be passed to the following functions along with
%   the data to perform that function:
%       <a href="matlab:help spectrum/psd">psd</a>     - calculates the PSD
%       <a href="matlab:help spectrum/psdopts">psdopts</a> - returns options to calculate the PSD
%
%   EXAMPLE: Spectral analysis of a 4th order autoregressive (AR) process.
%      s1 = RandStream.create('mrg32k3a');
%      x = randn(s1,100,1); 
%      y = filter(1,[1 1/2 1/3 1/4 1/5],x); 
%      h = spectrum.burg(4);                % Create a burg estimator.
%      psd(h,y,'Fs',1000);                  % Calculate and plot the PSD.
%
%   See also SPECTRUM, DSPDATA.

%   Author(s): P. Pacheco
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2008/10/31 07:03:36 $

error(nargchk(0,2,nargin,'struct'));

% Set the properties of the object.
this = spectrum.burg;
set(this, 'EstimationMethod', 'Burg');
initialize(this,varargin{:});  % Set Nfft and Order


% [EOF]
