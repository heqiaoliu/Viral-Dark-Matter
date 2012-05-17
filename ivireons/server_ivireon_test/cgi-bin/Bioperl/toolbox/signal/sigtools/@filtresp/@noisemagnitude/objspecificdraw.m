function [m, xunits] = objspecificdraw(this)
%OBJSPECIFICDRAW Draw the NOISEPOWERSPECTRUM

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.12 $  $Date: 2006/11/19 21:46:02 $

h              = get(this, 'Handles');
h.axes         = h.axes(end);
[indices, msg] = checkfilters(this);
if isempty(indices)
    if ~isempty(this.Filters)
        warning(msg)
    end
    
    % Make sure we remove the old line from the structure.
    h.line = [];
    set(this, 'Handles', h);
    m      = 1;
    xunits = '';
    return;
end

Hd = get(this, 'Filters');
Hd = Hd(indices);

opts = uddpvparse('dspopts.pseudospectrum', 'NFFT', this.NumberOfPoints);

switch lower(this.FrequencyRange)
    case {'[0, pi)', '[0, Fs/2)'}
        opts.SpectrumRange = 'half';
    case {'[0, 2pi)', '[0, Fs)'}
        opts.SpectrumRange = 'whole';
    case {'[-pi, pi)', '[-Fs/2, Fs/2)'}
        opts.SpectrumRange = 'whole';
        opts.CenterDC      = true;
end

optsstruct.sosview = this.SOSViewOpts;
optsstruct.showref = strcmpi(this.ShowReference, 'on');

[H, W] = freqrespest(Hd, this.NumberOfTrials, opts, optsstruct);

[wstr, wid] = lastwarn;
if any(strcmpi(wid, {'fi:underflow', 'fi:overflow'}))
    lastwarn('');
end

% Calculate the data
[W, m, xunits] = normalize_w(this, W);

% Plot the data
if ishandlefield(this,'line') && length(h.line) == size(H{1}, 2)
    for indx = 1:size(H{1}, 2)
        set(h.line(indx), 'xdata',W{1}, 'ydata',H{1}(:,indx));
    end
else
    h.line = freqplotter(h.axes, W, H);
end

% Save the handles
set(this, 'Handles', h);

% Put up the ylabel from the subclass
ylabel(h.axes, xlate('Magnitude (dB)'));

updatemasks(this);

% [EOF]
