function varargout = userdefinedmask(this)
%USERDEFINEDMASK   User Defined Mask dialog interface.

%   Author(s): J. Schickler
%   Copyright 2004-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:46:01 $

h = getcomponent(this, 'siggui.masklinedlg');

if isempty(h)
    h = siggui.masklinedlg;
    addcomponent(this, h);
    
    opts_listener(this);
    
    l = [ ...
        handle.listener(h, 'DialogApplied', @apply_listener); ...
        handle.listener(this, this.findprop('UserDefinedMask'), ...
        'PropertyPostSet', @opts_listener); ...
        handle.listener(this, 'NewPlot', @newplot_listener); ...
        ];
    set(l, 'CallbackTarget', this);
    set(this, 'MaskListeners', l);
    
    newplot_listener(this);
end

if ~isrendered(h)
    render(h);
    centerdlgonfig(h, this);
end

set(h, 'Visible', 'On');
figure(h.FigureHandle);

if nargout
    varargout = {h};
end

% -------------------------------------------------------------------------
function newplot_listener(this, eventData)

hdlg = getcomponent(this, 'siggui.masklinedlg');
if ~strcmpi(this.Analysis, 'magnitude')
    close(hdlg);
    return;
end

eu = getappdata(this.Handles.axes(2), 'EngUnitsFactor');
    
units = 'Hz';
if ~isempty(eu)
    
    % Get the units from the contained object.
    units = getunits(this.CurrentAnalysis);
    
    if isempty(units)
        units = 'Hz';
    end
    set(hdlg, 'FrequencyUnits', units);
end

% -------------------------------------------------------------------------
function opts_listener(this, eventData)

hdlg = getcomponent(this, '-class', 'siggui.masklinedlg');
opts = get(this, 'UserDefinedMask');
if ~isempty(opts)
    setmaskline(hdlg, opts);
end

% -------------------------------------------------------------------------
function apply_listener(this, eventData)

h = get(eventData, 'Source');

set(this, 'UserDefinedMask', getmaskline(h));

% [EOF]
