function fvtoolopts = spectrumopts2fvtool(this,opts)
%SPECTRUMOPTS2FVTOOL   Convert options for NOISEPSD and FREQRESPEST to
%   FVTool options.

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:44:37 $

npts = opts.NFFT;

fvtoolopts = {};
spectrumprop = get(findprop(opts,'spectrum'),'Name');

if opts.NormalizedFrequency,
    nf = 'on';
    if any(strcmpi(get(opts,spectrumprop),{'whole','twosided'})) && CenterDC,
        fr = '[-pi, pi)';
    elseif any(strcmpi(get(opts,spectrumprop),{'whole','twosided'})) && ~CenterDC,
        fr = '[0, 2pi)';
    else
        % get(opts,spectrumprop) = {'half','Onesided'}
        fr = '[0, pi)';
    end
else
    fvtoolopts = {'Fs',opts.Fs};
    nf = 'off';
    if any(strcmpi(get(opts,spectrumprop),{'whole','twosided'})) && CenterDC,
        fr = '[-Fs/2, Fs/2)';
    elseif any(strcmpi(get(opts,spectrumprop),{'whole','twosided'})) && ~CenterDC,
        fr = '[0, Fs)';
    else
        % get(opts,spectrumprop) = {'half','Onesided'}
        fr = '[0, Fs/2)';
    end
end

fvtoolopts = {fvtoolopts{:},'NumberofPoints',npts,...
    'NormalizedFrequency',nf,'FrequencyRange',fr};

% [EOF]
