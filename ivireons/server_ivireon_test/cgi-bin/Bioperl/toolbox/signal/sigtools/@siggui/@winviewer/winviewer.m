function hView = winviewer(hPrm)
%WINVIEWER Constructor for the winviewer object.

%   Author(s): V.Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2005/06/16 08:46:43 $

% Instantiate the object
hView = siggui.winviewer;

% Install analysis parameters
if nargin < 1, hPrm = []; end

for indx = 1:length(hPrm),
    addparameter(hView, hPrm(indx), true);
end

installanalysisparameters(hView);

% Set up the default
set(hView, 'Version', 1);
set(hView, 'Timedomain', 'on');
set(hView, 'Freqdomain', 'on');
set(hView, 'Legend', 'off');


% -------------------------------------------------------------------------
function installanalysisparameters(hView)

% Turn warnings off because ADDPARAMETER may warn if the parameter already
% exists.
w = warning('off');

hNFFT = sigdatatypes.parameter('Number of points', 'nfft', [1 1 inf], 512);
addparameter(hView, hNFFT);

opts = {'[0, pi)', '[0, 2pi)', '[-pi, pi)'};
hUnit = sigdatatypes.parameter('Range', 'unitcircle', opts);
addparameter(hView, hUnit);
setvalidvalues(hUnit, opts);

hMag  = sigdatatypes.parameter('Response', 'magnitude', ...
    {'Magnitude', 'Magnitude (dB)', 'Magnitude squared', 'Zero-phase'}, ...
    'Magnitude (db)');
addparameter(hView, hMag);

addparameter(hView, sigdatatypes.parameter('Frequency Units', ...
    'freqmode', {'Normalized', 'Hz'}));

addparameter(hView, sigdatatypes.parameter('Frequency Scale', ...
    'freqscale', {'Linear', 'Log'}));

addparameter(hView, sigdatatypes.parameter('Sampling Frequency', ...
    'sampfreq', [0 inf], 1));

addparameter(hView, sigdatatypes.parameter('Normalize Magnitude', ...
    'normmag', 'on/off', 'off'));

usedefault(hNFFT, 'winviewer');

warning(w);

% [EOF]
