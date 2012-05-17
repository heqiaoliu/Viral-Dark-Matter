function this = PlotNavigation(varargin)
%PLOTNAVIGATION Construct a PLOTNAVIGATION object

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/03/31 18:41:43 $

this = scopeextensions.PlotNavigation;

this.initTool(varargin{:});

% Add a listener to the VisualUpdated event so that we can perform the
% autoscale when AlwaysAutoscale is true.  For performance, this listener
% will be disabled whenever AlwaysAutoscale is false.
this.VisualUpdatedListener = handle.listener(this.Application, ...
    'VisualUpdated', @(h, ev) performAutoscale(this));
this.VisualUpdatedListener.Enabled = 'off';

this.SourceStoppedListener = handle.listener(this.Application, ...
    'sourceStop', @(h, ev) performAutoscale(this, true));
this.SourceStoppedListener.Enabled = 'off';

% Listener to reset the zoom state
this.SourceChangedListener = handle.listener(this.Application, ...
    'NewSourceEvent', @(hApp, ev) onSourceChanged(this));

this.FirstVisualUpdatedListener = handle.listener(this.Application, ...
    'VisualUpdated', @(h, ev) onVisualUpdated(this));
uiservices.setListenerEnable(this.FirstVisualUpdatedListener, false);

% Update all the properties to match those passed in the Cfg object.
this.AutoscaleXAxis = getPropValue(this, 'AutoscaleXAxis');
this.ExpandOnly     = getPropValue(this, 'ExpandOnly');

% Update the listeners
propertyChanged(this, 'AutoscaleMode');

% -------------------------------------------------------------------------
function onSourceChanged(this)
%Listener to the SourceChanged Event.

% Enable the FirstVisualUpdatedListener.  We want to respond to the first
% VisualUpdated event from the application after the source is added.
uiservices.setListenerEnable(this.FirstVisualUpdatedListener, true);

% -------------------------------------------------------------------------
function onVisualUpdated(this)
%Listener to the VisualUpdated event.

% This should only fire one time after a new source has been added.
uiservices.setListenerEnable(this.FirstVisualUpdatedListener, false);

% Reset the zoom state to whatever the new visual/data combination
% indicates.  Only perform this action if the zoom is storing old values.
hAxes = get(this.Application.Visual, 'Axes');
if ishghandle(hAxes) && ~isempty(resetplotview(hAxes, 'GetStoredViewStruct'))
    zoom(hAxes, 'reset');
end

% [EOF]
