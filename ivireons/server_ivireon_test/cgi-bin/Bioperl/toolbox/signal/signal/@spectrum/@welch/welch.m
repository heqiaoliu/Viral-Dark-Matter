function this = welch(varargin)
%WELCH   Welch spectral estimator.
%   H = SPECTRUM.WELCH returns a Welch spectral estimator in H.
%
%   H = SPECTRUM.WELCH(WINNAME) returns a Welch spectral estimator in H
%   with the string specified by WINNAME as the window. Use
%   set(H,'WindowName') to get a list of valid <a href="matlab:set(spectrum.welch,'WindowName')">windows</a>. 
%
%   H = SPECTRUM.WELCH({WINNAME,WINPARAMETER}) specifies the window in
%   WINNAME and the window parameter value in WINPARAMETER in a cell array.
%
%   NOTE: Depending on the window specified by WINNAME a window parameter
%   will be dynamically added to the Welch spectral estimator H. Type "help
%   <WINNAME>" for more details.
%
%   Note also that the default window (Hamming) has a 42.5 dB sidelobe
%   attenuation. This may mask spectral content below this value (relative
%   to the peak spectral content). Choosing different windows will enable
%   you to make tradeoffs between resolution (e.g., using a rectangular
%   window) and sidelobe attenuation (e.g., using a Hann window). See
%   WinTool for more details.
%
%   H = SPECTRUM.WELCH(WINNAME,SEGMENTLENGTH) specifies the length of each
%   segment as SEGMENTLENGTH.  The length of the segment allows you to make
%   tradeoffs between resolution and variance.  A long segment length will
%   result in better resolution while a short segment length will result in
%   more averages, and therefore decrease the variance.
%
%   H = SPECTRUM.WELCH(WINNAME,SEGMENTLENGTH,OVERLAPPERCENT) specifies the
%   percentage of overlap between each segment.
%
%   Welch estimators can be passed to the following functions along with
%   the data to perform that function:
%       <a href="matlab:help spectrum/msspectrum">msspectrum</a>     - calculates the Mean-squared Spectrum (MSS)
%       <a href="matlab:help spectrum/msspectrumopts">msspectrumopts</a> - returns options to calculate the MSS
%       <a href="matlab:help spectrum/psd">psd</a>            - calculates the PSD
%       <a href="matlab:help spectrum/psdopts">psdopts</a>        - returns options to calculate the PSD
%
%   EXAMPLE: Spectral analysis of a signal that contains a 200Hz cosine
%            % plus noise.
%            Fs = 1000;   t = 0:1/Fs:.296;
%            x = cos(2*pi*t*200)+randn(size(t));  
%            h = spectrum.welch;                  % Create a Welch spectral estimator. 
%            psd(h,x,'Fs',Fs);                    % Calculate and plot the PSD.
%  
%   See also SPECTRUM, DSPDATA.

%   Author(s): P. Pacheco
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.13 $  $Date: 2009/08/11 15:48:32 $

error(nargchk(0,3,nargin,'struct'));

% Create default welch object.
this = spectrum.welch;

winName = 'Hamming';
if nargin >= 1,
	winName = varargin{1};
end
setwindownamenparam(this,winName);  % Accepts string or cell array for winName.

% Parse the rest of the inputs.
paramCell = {'SegmentLength','OverlapPercent'};
valCell = {64,50};  % Default values for corresponding properties above.
	
% Override default values with user input.  Exclude window and fftlength.
if nargin>=2,
    valCell{1}=varargin{2};
    if nargin>=3,
        valCell{2}=varargin{3};
    end
end

% Set the properties of the object.
set(this,'Estimationmethod','Welch',paramCell,valCell)

% [EOF]
