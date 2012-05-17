function updatemasks(this)
%UPDATEMASKS Draw the masks onto the bottom axes

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/01/05 18:00:00 $

h = get(this, 'Handles');

if isfield(h, 'masks')
    h.masks(~ishghandle(h.masks)) = [];
    delete(h.masks);
end

Hd = this.Filters;
if strcmpi(this.DisplayMask, 'On') && ...
        ~(isa(Hd(1).Filter, 'dfilt.abstractsos') && ...
        ~isempty(this.SOSViewOpts) && ...
        ~strcmpi(this.SOSViewOpts.View, 'Complete')),
    
    if isa(Hd(1).Filter, 'dfilt.basefilter')
        hfd = Hd(1).Filter.privgetfdesign;
        hfm = Hd(1).Filter.getfmethod;
    else
        hfd = [];
        hfm = [];
    end

    % If we have the FDESIGN and FMETHOD object, use them, otherwise use
    % the old code with filtdes.
    if isempty(hfd) || isempty(hfm)
        h.masks = drawfiltdesmask(this);
    else
        h.masks = drawfdesignmask(this);
    end
    for indx = 1:length(h.masks)
        if ishghandle(h.masks(indx))
            setappdata(h.masks(indx), 'AffectsFullView', 'off');
        end
    end
else
    h.masks = [];
end

% Make sure that HitTest is turned off so that the data markers on the
% response line work smoothly.
set(h.masks, 'HitTest', 'Off');
set(this, 'Handles', h);

% -------------------------------------------------------------------------
function h = drawfdesignmask(this)

Hd = this.Filters;
fs = Hd(1).Fs;

if isempty(fs) || strcmpi(this.NormalizedFrequency, 'on'),
    fs = 2;
end

m = getappdata(this.Handles.axes, 'EngUnitsFactor');

fs = fs*m;

switch lower(this.MagnitudeDisplay)
    case 'magnitude'
        units = 'linear';
    case 'zero-phase'
        units = 'zerophase';
    case 'magnitude (db)'
        units = 'db';
    case 'magnitude squared'
        units = 'squared';
end

if strcmpi(this.NormalizeMagnitude, 'on')
    normflag = {'normalize'};
else
    normflag = {};
end

h = drawmask(Hd(1).Filter, getbottomaxes(this), units, fs, normflag{:});

if strcmpi(units, 'zerophase')
    ydata = get(this.Handles.line, 'YData');
    if ~iscell(ydata) && abs(min(ydata)) > abs(max(ydata))
        mask_ydata = get(h, 'ydata');
        if any(mask_ydata > 0)
            set(h, 'ydata', -get(h, 'ydata'))
        end
    end
end

% -------------------------------------------------------------------------
function h = drawfiltdesmask(this)

Hd = this.Filters;

fs = Hd.Fs;
mi = Hd.Filter.MaskInfo;
if isempty(fs) || strcmpi(this.NormalizedFrequency, 'on'),
    fs = 2;
    mi.frequnit = 'Hz'; % Fool it into using 2 Hz so it looks normalized
end

% Convert the frequency depending on the new frequency.
for indx = 1:length(mi.bands),
    mi.bands{indx}.frequency = mi.bands{indx}.frequency*fs/mi.fs;
end
mi.fs = fs;

h = info2mask(mi, getbottomaxes(this));

% [EOF]
