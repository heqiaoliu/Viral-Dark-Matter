function ax = addsubplot (varargin)
% This undocumented function may be removed in a future release.
  
% ADDSUBPLOT creates a new subplot and adds it to the figure at the given location.
%    ADDSUBPLOT (fig, WHERE) creates a cartplane at the specified location.
%    ADDSUBPLOT (fig, WHERE, CMD, ...) creates an axes using the specified command
%      with optional arguments.
% For instance, ADDSUBPLOT (fig, 'Top') puts the new axes across the top of
% the figure.  Other locations are 'Bottom', 'Left', and 'Right'.
% The remaining arguments are passed to the axes being created.

% Copyright 2002-2006 The MathWorks, Inc.

%---------------------------------------------------
% Get a figure to put the plot on:
if (nargin > 0) 
     fig = varargin{1};
     if ~ishghandle (fig,'figure')
         error ('MATLAB:addsubplot:InvalidFigureHandle',...
                'The first argument must be a handle to a figure');
     end
else
     fig = figure;
end

%---------------------------------------------------
% Get the location of the new axes:

if (nargin > 1)
     where = varargin{2};
else
     where = 'Bottom';
end

%---------------------------------------------------
% Get the command with which to make the axes:

if (nargin > 2)
     axesCmd = varargin{3};
else
     axesCmd = 'axes';
end

%---------------------------------------------------
% Figure out the "squish factor," or by how much to compress the 
% existing plots:

figH = handle(fig);
if feature('HGUsingMATLABClasses')
    children = figH.findobj ...
       ('-depth', 2, ...
        'Type','axes', ...
        'HandleVisibility', 'on', ...
        '-not','Tag','legend','-and','-not','Tag','Colorbar');
else
    children = figH.find ...
       ('-depth', 1, ...
        'Type','axes', ...
        'HandleVisibility', 'on', ...
        '-not','Tag','legend','-and','-not','Tag','Colorbar');
end
% Note:  this is the same search used in plottoolfunc.

origNum = length(children);
if origNum == 0 
    squishFactor = 1;
else
    squishFactor = origNum / (origNum + 1);
end
% TODO:  squishFactor could depend on more complicated heuristics;
% e.g. how many subplots tall is it, vs. how many total subplots

%---------------------------------------------------
% Figure out the outer position of the new axes:

newPlotX = 0;
newPlotY = 0;
newPlotWidth = 1;
newPlotHeight = 1;
if (strcmpi (where, 'Bottom') == 1)
        newPlotHeight = 1 / (origNum + 1);
elseif (strcmpi (where, 'Top') == 1)
        newPlotHeight = 1 / (origNum + 1);
	newPlotY = 1 - newPlotHeight;
elseif (strcmpi (where, 'Left') == 1)
        newPlotWidth = 1 / (origNum + 1);
elseif (strcmpi (where, 'Right') == 1)
        newPlotWidth = 1 / (origNum + 1);
	newPlotX = 1 - newPlotWidth;
end


%---------------------------------------------------
% Create the new axes:

if (nargin > 3)
     thing = feval (axesCmd, varargin{4:end}, 'Parent', fig);
else
     thing = feval (axesCmd, 'Parent', fig);
end

parent = handle (get (thing, 'parent'));
parentType = get (parent, 'type');
if (strcmp (parentType, 'axes') == 1)
     ax = parent;
elseif (strcmp (parentType, 'figure') == 1)
     ax = thing;
else
     ax = [];
end


%---------------------------------------------------
% Squish all the existing axes:

for i = 1:origNum
    theAxes = handle(children(i));
    if (isprop (theAxes, 'OuterPosition'))
	    posnPropName = 'OuterPosition';
    else
	    posnPropName = 'Position';
    end
    origPosn = get (theAxes, posnPropName);
    if (strcmpi (where, 'Bottom') == 1)
        newHeight = (origPosn(4) * squishFactor);
	    newY      = (origPosn(2) * squishFactor) + newPlotHeight;
	    set (theAxes, posnPropName, [origPosn(1) newY origPosn(3) newHeight]);
    elseif (strcmpi (where, 'Top') == 1)
        newHeight = (origPosn(4) * squishFactor);
        newY      = (origPosn(2) * squishFactor);
        set (theAxes, posnPropName, [origPosn(1) newY origPosn(3) newHeight]);
    elseif (strcmpi (where, 'Left') == 1)
        newWidth = (origPosn(3) * squishFactor);
        newX     = (origPosn(1) * squishFactor) + newPlotWidth;
        set (theAxes, posnPropName, [newX origPosn(2) newWidth origPosn(4)]);
    elseif (strcmpi (where, 'Right') == 1)
        newWidth = (origPosn(3) * squishFactor);
        newX     = (origPosn(1) * squishFactor);
        set (theAxes, posnPropName, [newX origPosn(2) newWidth origPosn(4)]);
    end
end


%---------------------------------------------------
% Finish the new axes:

if (isprop (ax, 'OuterPosition'))
     set (ax, 'OuterPosition', ...
	  [newPlotX newPlotY newPlotWidth newPlotHeight]);
else
     set (ax, 'Position', ...
	  [newPlotX newPlotY newPlotWidth newPlotHeight]);
end
title (ax, '');
hax = handle(ax);
if feature('HGUsingMATLABClasses')
    listener = event.listener(hax,'ObjectBeingDestroyed',...
                               @doDeleteAction);
    if ~isprop(ax,'AddSubplotDeleteListener')
        p = ax.addprop('AddSubplotDeleteListener');
        p.Hidden = true;
        p.Transient = true;
    end
    ax.AddSubplotDeleteListener =  listener;
else
    listener = handle.listener(hax,'ObjectBeingDestroyed',...
                           @doDeleteAction);
end
setappdata(ax,'AddSubplotDeleteListener',listener);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doDeleteAction(h, eventData) %#ok
pos = get(h,'OuterPosition');
fig = ancestor(h,'figure');
children = findobj (fig, 'type', 'axes');

% Filter out legend and colorbar from position calculations
filterFcn = @(hAxes) ( isa(handle(hAxes),'scribe.legend') || ...
                       isa(handle(hAxes),'scribe.colorbar')); 
if feature('HGUsingMATLABClasses')
    I = false(size(children));
    for k=1:length(I)
        I(k) = feval(filterFcn,children(k));
    end
    children(I) = [];
else
    children(arrayfun(filterFcn,children)) = [];
end

% only rescale other axes if the one being deleted stretches all
% the way vertically or horizontally
if (any(pos(3:4) > 1-10*eps)) && (length(children) > 1)
  nchildren = length(children);
  positions = zeros(nchildren,4);
  for i = 1:nchildren
      positions(i,:) = get(children(i),'OuterPosition'); 
  end
  
  if pos(4) < 1 % Axes removed from a vertical stack
      % Make sure the axes are ascending
      [~,I] = sort(positions(:,2));
      positions = positions(I,:);
      minY = 1;
      maxY = 0;
      ht = 0;
      for i = 1:nchildren
              pos = positions(i,:);     
              minY = min(minY,pos(2));
              maxY = min(maxY,pos(2)+pos(4));
              ht = ht+pos(4);
      end
      vgap = nchildren*(pos(4)+pos(2)-minY-ht)/(nchildren-1)^2;
      ht = ht/(nchildren-1);

      ct = 0;
      for i = 1:nchildren
           if strcmp(get(children(i),'BeingDeleted'),'off')              
              pos = get(children(i),'OuterPosition');
              set(children(i),'OuterPosition',[pos(1) minY+(ht+vgap)*ct pos(3) ht]);
              ct=ct+1;
           end
      end
  elseif pos(3) < 1 % Axes removed from a horizontal stack
      % Make sure the axes are ascending
      [~,I] = sort(positions(:,1));
      positions = positions(I,:);    
      minX = 1; 
      maxX = 0;
      wd = 0;
      for i = 1:nchildren
              pos = positions(i,:);       
              minX = min(minX,pos(1));
              maxX = min(maxX,pos(1)+pos(2));
              wd = wd+pos(3);
      end
      hgap = nchildren*(pos(3)+pos(1)-minX-wd)/(nchildren-1)^2;
      wd = wd/(nchildren-1);

      ct = 0;
      for i = 1:nchildren
           if strcmp(get(children(i),'BeingDeleted'),'off')   
              pos = get(children(i),'OuterPosition');
              set(children(i),'OuterPosition',[minX+(wd+hgap)*ct pos(2) wd pos(4)]);
              ct=ct+1;
           end
      end
  end

end
