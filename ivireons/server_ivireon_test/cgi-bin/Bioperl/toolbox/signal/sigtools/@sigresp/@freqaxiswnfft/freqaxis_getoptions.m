function [opts, xunits] = freqaxis_getoptions(this)
%FREQAXIS_GETOPTIONS Get the input options for the analysis functions

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:29:23 $

fs = getmaxfs(this);

nfft = get(this, 'NumberOfPoints');
if strcmpi(this.FastUpdate, 'On'),
    nfft = min(nfft, 128);
end

hDlg = getcomponent(this, '-class', 'siggui.parameterdlg');

if isempty(hDlg),
    opts = {};
else
    opts.nfft = getvaluesfromgui(hDlg, getnffttag(this));
    opts = {opts};
end

rangeopts = lower(getfreqrangeopts(this, opts{:}));

switch lower(get(this, 'FrequencyRange')),
case rangeopts{1},
    opts = {nfft, 'half'};
case rangeopts{2},
    opts = {nfft, 'whole'};
case rangeopts{3},
    opts = {nfft, 'fftshift'};
end

if ~isempty(fs),
    [fs, m, xunits] = engunits(fs);
    xunits = sprintf('%sHz', xunits);
else
    xunits = 'rad/sample';
end

% [EOF]
