function hThis = scribepin(varargin)
% Create an instance of a pin object

%   Copyright 2006-2007 The MathWorks, Inc.

args = varargin;
args(1:2:end) = lower(args(1:2:end));
parentind = find(strcmpi(args,'parent'));
if isempty(parentind)
  parent = findScribeLayer(gcf);
else
  parent = args{parentind(end)+1}; % take last parent specified
  args(unique([parentind parentind+1]))=[];
end

% We are going to give the pin properties to look like the pin affordance
% when visible.
hThis = scribe.scribepin('parent',parent, 'HandleVisibility','off',...
                     'HitTest','off',...
                     'XLimInclude', 'off', ...
                     'YLimInclude', 'off', ...
                     'ZLimInclude', 'off', ...
                     'IncludeRenderer', 'off', ...
                     'Visible', 'off', ...
                     'Tag','ScribePinObject', ...
                     'LineWidth', 0.01, ...
                     'Color', [0 0 0], ...
                     'Marker', 'Square', ...
                     'MarkerSize', 4, ...
                     'MarkerFaceColor', [0 0 0], ...
                     'MarkerEdgeColor', [1 1 0]);
if ~isempty(args)
  set(hThis,args{:})
end

hax = handle(hThis.DataAxes);
l = [ handle.listener(hThis,'ObjectBeingDestroyed',{@localRemovePin,hThis});
    handle.listener(hax,'ObjectBeingDestroyed',{@localRemovePin,hThis})
    handle.listener(hThis.Target,'ObjectBeingDestroyed',{@localDeletePin,hThis})];
axes_prop = [];
axes_prop = [axes_prop;findprop(hax,'XTick')];
axes_prop = [axes_prop;findprop(hax,'YTick')];
axes_prop = [axes_prop;findprop(hax,'ZTick')];
l(end+1) = handle.listener(hax,axes_prop, ...
    'PropertyPostSet',{@localUpdateTarget,hThis});

hThis.Listeners = l;

%-------------------------------------------------------%
function localDeletePin(hSrc,eventData,hThis) %#ok<INUSL>
% Called when the target is destroyed:
delete(hThis);

%-------------------------------------------------------%
function localRemovePin(hSrc,eventData,hThis) %#ok<INUSL>

% Update the properties of the target scribe object
if ishandle(hThis.Target)
  pins = hThis.Target.Pin;
  ind = hThis == pins;
  if ~isempty(ind)
    pins(ind) = [];
    if ~any(ishandle(hThis.Target.Pin))
      hThis.Target.Pin = [];
    else
      hThis.Target.Pin = pins;
    end
  end
  delete(hThis.Listeners);
  delete(hThis.AffordanceListeners);
end

%-------------------------------------------------------%
function localUpdateTarget(hProp,eventData,hThis) %#ok<INUSL>

hThis.updateTarget;