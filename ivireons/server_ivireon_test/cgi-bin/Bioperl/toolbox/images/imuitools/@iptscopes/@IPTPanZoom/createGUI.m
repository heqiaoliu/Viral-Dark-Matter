function plugInGUI = createGUI(this)
%CreateGUI Build and cache UI plug-in for IPTZoom plug-in.
%   This adds the button and menu to the scope.
%   No install/render needs to be done here.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/09/09 21:17:20 $

% Do not associate callbacks with menus
% These get sync'd to the buttons, which have the callbacks

% Pan/zoom group plug-in
mZoomIn = uimgr.spctogglemenu('ZoomIn', '&Zoom In');
mZoomIn.WidgetProperties = { ...
    'Callback', @(hcbo, ev) toggle(this, 'ZoomIn')};

mZoomOut = uimgr.spctogglemenu('ZoomOut', 'Zoom &Out');
mZoomOut.WidgetProperties = { ...
    'Callback', @(hcbo, ev) toggle(this, 'ZoomOut')};

mPan = uimgr.spctogglemenu('Pan', 'Pa&n');
mPan.WidgetProperties = { ...
    'Callback', @(hcbo, ev) toggle(this, 'Pan')};

mZoomPan = uimgr.uimenugroup('PanZoom', mZoomIn, mZoomOut, mPan);
mZoomPan.SelectionConstraint = 'SelectZeroOrOne';

mMaintain = uimgr.spctogglemenu('Maintain', '&Maintain Fit to Window');
mMaintain.WidgetProperties = { ...
    'Callback', @(hcbo, ev) toggle(this, 'FitToView')};

mMag = uimgr.uimenugroup('Mag', mMaintain);

% Overall zoom group, position 1 (just after Tools/Standard menu group)
mZoom = uimgr.uimenugroup('Zoom', 1, mZoomPan, mMag);

% Group of Pan/Zoom
b1 = uimgr.uitoggletool('ZoomIn');
b1.IconAppData = 'zoom_in';
b1.WidgetProperties = {...
    'tooltip',       'Zoom in', ...
    'busyaction',    'cancel', ...
    'interruptible', 'off', ...
    'click',         @(hco,ev) toggle(this, 'ZoomIn')};

b2 = uimgr.uitoggletool('ZoomOut');
b2.IconAppData = 'zoom_out';
b2.WidgetProperties = {...
    'tooltip',       'Zoom out', ...
    'busyaction',    'cancel', ...
    'interruptible', 'off', ...
    'click',         @(hco,ev) toggle(this, 'ZoomOut')};

b3 = uimgr.uitoggletool('Pan');
b3.IconAppData = 'open_hand';
b3.WidgetProperties = {...
    'tooltip', 'Drag image to pan', ...
    'click',   @(hco,ev) toggle(this, 'Pan')};

b4 = uimgr.uitoggletool('Maintain');
b4.IconAppData = 'fit_to_view';
b4.WidgetProperties = {...
    'tooltip',       'Maintain fit to window', ...
    'busyaction',    'cancel', ...
    'interruptible', 'off', ...
    'click',         @(hco,ev) toggle(this, 'FitToView')};

bZoomPan = uimgr.uibuttongroup('PanZoom', b1, b2, b3, b4);
bZoomPan.SelectionConstraint = 'SelectZeroOrOne';

% Group of Magnification

if usejava('awt')
    b5 = uimgr.spcmagcombobox('MagCombo');
    b5.StateName = 'SelectedItem';
    b5.WidgetProperties = {'SelectedItem', ...
        sprintf('%d%%', round(100*get(findProp(this, 'Magnification'), 'Value')))};
    bMag = uimgr.uibuttongroup('Mag', b4, b5);
else
    bMag = uimgr.uibuttongroup('Mag', b4);
end

% Overall zoom group, take position after Standard/Tools
bZoom = uimgr.uibuttongroup('Zoom', bZoomPan, bMag);

% Add state synchronizers
sync2way(mZoomPan, bZoomPan);
sync2way(mMaintain, b4);

% Create plug-in installer
plan = { ...
    mZoom, 'base/Menus/Tools';
    bZoom, 'base/Toolbars/Main/Tools'};
plugInGUI = uimgr.uiinstaller(plan);

% -------------------------------------------------------------------------
function toggle(this, mode)

% If we are toggling the current mode, then turn it off.  Otherwise, set
% the current mode to what we are toggling.
if strcmpi(mode, this.Mode)
    this.Mode = 'off';
else
    this.Mode = mode;
end

% [EOF]
