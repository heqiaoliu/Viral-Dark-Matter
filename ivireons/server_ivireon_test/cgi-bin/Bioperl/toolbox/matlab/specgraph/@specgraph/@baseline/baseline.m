function h = baseline(varargin)
%BASELINE baseline constructor
%  This function is an internal helper function for Handle Graphics
%  and shouldn't be called directly.
  
%   Copyright 1984-2008 The MathWorks, Inc. 

h = specgraph.baseline(...
    'xliminclude','off',...
    'yliminclude','off',...
    'zliminclude','off',varargin{:});
ax = ancestor(h,'axes');
h.color = get(ax,'xcolor');
h.xdata = get(ax,'xlim');
h.ydata = [0 0];
hasbehavior(double(h),'legend',false);

hax = handle(ax);
props = [findprop(hax,'XLim'),findprop(hax,'YLim')];
l = handle.listener(hax,props,'PropertyPostSet',{@doLimAction,h});
h.listener = l;

% Set up a listener on the axes "*Scale" properties
props = [findprop(hax,'XScale'),findprop(hax,'YScale')];
l = handle.listener(hax,props,'PropertyPostSet',{@doScaleAction,h});
h.AxesListener = l;

h.BaseValueMode = 'Auto';

% Turn off the "DataCursor" behavior
hb = hggetbehavior(h,'DataCursor');
hb.Enable = false;

function doLimAction(hSrc,eventData,h)
hax = eventData.affectedObject;
if strcmp(h.Orientation,'X')
  set(h,'XData',get(hax,'XLim'),'YData',[h.BaseValue h.BaseValue]);
else
  set(h,'YData',get(hax,'YLim'),'XData',[h.BaseValue h.BaseValue]);
end

function doScaleAction(hSrc,eventData,h)
hax = eventData.affectedObject;
if strcmpi(h.BaseValueMode,'Manual')
    return;
end
h.InternalSet = true;
if strcmp(h.Orientation,'X')
    if strcmpi(get(hax,'YScale'),'log')
        h.BaseValue = 1;
    else
        h.BaseValue = 0;
    end
else
    if strcmpi(get(hax,'XScale'),'log')
        h.BaseValue = 1;
    else
        h.BaseValue = 0;
    end
end
h.InternalSet = false;