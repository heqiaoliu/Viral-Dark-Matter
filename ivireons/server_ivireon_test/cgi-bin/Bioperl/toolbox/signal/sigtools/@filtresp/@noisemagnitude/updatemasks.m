function updatemasks(this)
%UPDATEMASKS Draw the masks onto the bottom axes

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/05 18:00:05 $

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

    fs = Hd(1).Fs;

    if isempty(fs) || strcmpi(this.NormalizedFrequency, 'on'),
        fs = 2;
    end

    m = getappdata(this.Handles.axes, 'EngUnitsFactor');

    h.masks = drawmask(Hd(1).Filter, getbottomaxes(this), 'db', fs*m);

else
    h.masks = [];
end

% Make sure that HitTest is turned off so that the data markers on the
% response line work smoothly.
set(h.masks, 'HitTest', 'Off');
set(this, 'Handles', h);

% [EOF]
