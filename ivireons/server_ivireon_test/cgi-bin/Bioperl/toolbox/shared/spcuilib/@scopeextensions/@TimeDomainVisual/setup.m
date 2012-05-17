function setup(this, hVisParent)
%SETUP    Set up the Axes and children.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/03/31 18:43:04 $

setupLine(this, hVisParent);

% Update the xlimits based on the timeoffset and the
set(this.Axes, 'XLim', calculateXLim(this));

% Update the XLabel.
updateXLabel(this);

str = uiscopes.message('TimeOffset');
pixf = get(0, 'ScreenPixelsPerInch')/96;
pos = [0 0 largestuiwidth({str}) 20*pixf];

behavior = uiservices.getPlotEditBehavior('disabled');

this.TimeOffsetLabel = uicontrol('Parent', hVisParent, ...
    'String', str, ...
    'Position', pos, ...
    'HitTest', 'off', ...
    'style','text', ...
    'Tag', 'TimeOffsetLabel', ...
    'Visible', 'off');

hgaddbehavior(this.TimeOffsetLabel, behavior);

pos(1) = pos(1)+pos(3)+5*pixf;
this.TimeOffsetReadout = uicontrol('Parent', hVisParent, ...
    'String', sprintf('0 (%s)', this.TimeUnits), ...
    'style','text', ...
    'HitTest', 'off', ...
    'HorizontalAlignment', 'left', ...
    'Position', pos, ...
    'Tag', 'TimeOffsetReadout', ...
    'Visible', 'off');

hgaddbehavior(this.TimeOffsetReadout, behavior);

% Update for the current source (if there is one);
onDataSourceChanged(this);

% Add a listener on the XTick to update the labels.
addlistener(this.Axes, 'XTick', 'PostSet', makeXLimCallback(this));

% -------------------------------------------------------------------------
function cb = makeXLimCallback(this)

cb = @(h,ev) updateXTickLabels(this);

% [EOF]
