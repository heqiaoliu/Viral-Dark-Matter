function scrollToVisible(obj,ensure_fit)
%Simulink.scrollToVisible - Makes an object visible in its parent System
%
% Simulink.scrollToVisible(obj);
%
%  Scrolls and zooms the window containing the specified Simulink object
%  so that the entire object is visible.  The window will zoom out only if
%  necessary.  The object can be a block, line or annotation, specified by
%  name or handle.
%
%  Multiple objects can be specified, and all the windows containing them
%  will be scrolled and zoomed.  Where multiple objects are in the same window,
%  the window will be scrolled and zoomed so that all the objects are visible
%  at once.
%   
% See also: hilite_system

%   Copyright 2009 The MathWorks, Inc.

% Modify the inputs to make them easier to manage.  If we have a single input,
% duplicate it so that we can be sure that get_param will return a cell array.
if ischar(obj)
  obj = { obj, obj };
elseif iscell(obj) && (length(obj) == 1),
  obj = { cell2mat(obj(1)), cell2mat(obj(1)) };
elseif isreal(obj) && (length(obj) == 1),
  obj = [obj obj];
end

if nargin<2
    ensure_fit = true;
end

% It's easier to use handles instead of strings.
obj = get_param(obj,'Handle');
obj = [ obj{:} ];

parents = get_param(obj,'Parent');
hiliteBounds = LocalConstructHiliteBoundsRect(obj, parents);

LocalPanSystem(hiliteBounds,ensure_fit)

%
%===============================================================================
% LocalConstructHiliteBoundsRect
% Returns a structure array with the fields:
%   System:  name of a unique system that has some highlighting done within it
%   Bounds:  a rectangle that is the union of all object bounds  within the
%            system
%
%===============================================================================
%
function hiliteBounds = LocalConstructHiliteBoundsRect(sys, parents)

%
% if no parents, return an empty struct
%
if isempty(parents),
  hiliteBounds = cell2struct({ nan, nan }, { 'Name', 'Bounds' }, 2);
  hiliteBounds(1) = [];
  return;
end

%
% construct the basis for the return argument, a structure array with
% the unique systems
%
uniqSys = unique(parents);
hiliteBounds = struct('Name',cell(size(uniqSys)),'Bounds',cell(size(uniqSys)));
for i=1:length(uniqSys),
  hiliteBounds(i).Name   = uniqSys{i};
  hiliteBounds(i).Bounds = Simulink.rect;
end

%
% for each sys, get the location and union it with the highlight bounds already
% computed for the system
%
for i=1:length(sys),
  dad = get_param(sys(i),'Parent');
  dadID = find(strcmp(uniqSys, dad));
  
  switch get_param(sys(i),'type'),
   case 'block',
    pos = Simulink.rect(get_param(sys(i),'Position'));

   case 'line',
    thisLine = LocalFindLine(dad,sys(i),get_param(dad,'Lines'));
    pos = LocalLinePosition(thisLine);
          
   case 'annotation',
    pos = get_param(sys(i),'Position');
    pos = Simulink.rect(pos, pos);
    
   otherwise,
    DAStudio.error('Simulink:utility:hilite_sysInvInputType');
  end
  
  hiliteBounds(dadID).Bounds = hiliteBounds(dadID).Bounds + pos;

end

%
%===============================================================================
% LocalFindLine
% Finds the line from the Lines structure in the system.
%===============================================================================
%
function l = LocalFindLine(sys, lineHandle, lines)

l = [];
if isempty(lines),
  return;
end

lineIdx = find([lines(:).Handle] == lineHandle);
if ~isempty(lineIdx),
  l = lines(lineIdx);
  return;
end

for i = 1:size(lines,1),
  l = LocalFindLine(sys, lineHandle, lines(i).Branch);
  if ~isempty(l),
    return;
  end
end
  
%
%===============================================================================
% LocalLinePosition
% Constructs the bounding rectangle for a line (returned by the Lines
% parameter of a system.
%===============================================================================
%
function pos = LocalLinePosition(l)

pos = Simulink.rect;
for i = 1:size(l.Points,1)-1,
  pos = pos + Simulink.rect(l.Points(i,:), l.Points(i+1,:));
end

for i=1:size(l.Branch,1),
  pos = pos + LocalLinePosition(l.Branch(i));
end


function LocalPanSystem(hiliteBounds,ensure_fit)

%
% for each highlight bounds element, determine the scroll and zoom factor to
% bring it into view (i.e., pan)
% 
for i = 1:length(hiliteBounds),
  sys = hiliteBounds(i).Name;
  
  %
  % get the current location of the system, so that we know how big the
  % window is.
  %
  sysLoc = Simulink.rect(get_param(sys,'Location'));
  
  %
  % add some padding and calculate a suitable zoom factor
  %
  bounds = inset(hiliteBounds(i).Bounds, -10, -10);
  start_zoom = str2double(get_param(sys,'ZoomFactor')) / 100;
  % Zoom out if necessary to ensure that the whole object is visible.
  fit_zoom = min([abs(width(sysLoc)/width(bounds)), abs(height(sysLoc)/height(bounds))]);
  zoom = min([start_zoom, fit_zoom]);
  if ~ensure_fit
      % hilite_system has always used a minimum zoom factor of 100%, meaning:
      %  It does not "zoom out" if the object is bigger than the window
      %  It always zooms to 100% if it started off "zoomed out".
      zoom = max([1,zoom]);
  else
      % Otherwise, if we are zooming in, don't go to more than 100%
      if start_zoom<fit_zoom && start_zoom<1 && fit_zoom>1
          zoom = 1;
      end
  end
  
  %
  % compute the panning now
  %
  bounds = scale(hiliteBounds(i).Bounds, zoom);
  hLoc = round(bounds.left - (width(sysLoc) - width(bounds))/2);
  vLoc = round(bounds.top  - (height(sysLoc) - height(bounds))/2);
    
  newScroll = max(0, [hLoc, vLoc]);
  set_param(sys,'ZoomFactor',sprintf('%d',round(zoom * 100)),...
                'ScrollBarOffset',newScroll);
  
end
