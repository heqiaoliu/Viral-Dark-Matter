function this = periodogram(winName)
%PERIODOGRAM   Periodogram spectral estimator.
%   H = SPECTRUM.PERIODOGRAM returns a periodogram spectral estimator in H.
%
%   H = SPECTRUM.PERIODOGRAM(WINNAME) returns a periodogram spectral
%   estimator in H with the string specified by WINNAME as the window. Use
%   set(H,'WindowName') to get a list of valid <a href="matlab:set(spectrum.periodogram,'WindowName')">windows</a>. 
%
%   H = SPECTRUM.PERIODOGRAM({WINNAME,WINPARAMETER}) specifies the window
%   in WINNAME and the window parameter value in WINPARAMETER both in a
%   cell array.
%
%   NOTE: Depending on the window specified by WINNAME a window parameter
%   will be dynamically added to the periodogram spectral estimator H. Type
%   "help <WINNAME>" for more details.
%
%   Note that the default window (rectangular) has a 13.3 dB sidelobe
%   attenuation. This may mask spectral content below this value (relative
%   to the peak spectral content). Choosing different windows will enable
%   you to make tradeoffs between resolution (e.g., using a rectangular
%   window) and sidelobe attenuation (e.g., using a Hann window). See
%   WinTool for more details.
%
%   Periodogram estimators can be passed to the following functions along
%   with the data to perform that function:
%       <a href="matlab:help spectrum/msspectrum">msspectrum</a>     - calculates the Mean-squared Spectrum (MSS)
%       <a href="matlab:help spectrum/msspectrumopts">msspectrumopts</a> - returns options to calculate the MSS
%       <a href="matlab:help spectrum/psd">psd</a>            - calculates the PSD
%       <a href="matlab:help spectrum/psdopts">psdopts</a>        - returns options to calculate the PSD
%
%   EXAMPLE: Spectral analysis of a complex signal plus noise.
%      Fs = 1000;   t = 0:1/Fs:.296;
%      x = exp(i*2*pi*200*t)+randn(size(t));  
%      h = spectrum.periodogram;      % Create a periodogram spectral estimator. 
%      psd(h,x,'Fs',Fs);              % Calculates and plots the two-sided PSD.
%
%   See also SPECTRUM, DSPDATA.

%   Author(s): P. Pacheco
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2009/08/11 15:48:31 $

error(nargchk(0,1,nargin,'struct'));

% Create default periodogram object.
this = spectrum.periodogram;

if nargin < 1,
    winName = 'rectangular';
end

% Set the properties of the object.
set(this,'EstimationMethod', 'Periodogram');

setwindownamenparam(this,winName);  % Accepts string or cell array for winName.

% [EOF]
