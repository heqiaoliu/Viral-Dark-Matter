function varargout = plottoolfunc (type, varargin)
% This undocumented function may be removed in a future release.
  
% PLOTTOOLFUNC:  Support function for the plot tool

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.19 $

error(nargchk(1,inf,nargin,'struct'));

% initialize varargout to something useful
varargout = {};
for i=1:nargout, varargout{i} = []; end

try
    switch type,
        
    case 'makePolarAxes'
        varargout = makePolarAxes (varargin{:});

    case 'plotExpressions'
        plotExpressions (varargin{:});
        
    case 'setSelection'
        setSelection (varargin{:});

    case 'getFigureChildrenList'
        varargout = getFigureChildrenList (varargin{:});
        
    case 'getAxesTitle'
        varargout = getAxesTitle (varargin{:});

    case 'getAxisComponent'
        varargout = getAxisComponent (varargin{:});
        
    case 'prepareAxesForDnD'
        varargout = prepareAxesForDnD (varargin{:});
        
    case 'makeSubplotGrid'
        makeSubplotGrid (varargin{:});
           
    case 'setPropertyValue'
        setPropertyValue (varargin{:});
        
    case 'deleteObjects'
        %deleteObjects (varargin{:});
        scribeDeleteObjects(varargin{:});
        
    case 'getAxesHandle'
        varargout = getAxesHandle (varargin{:});

    case 'getBarAreaColor'
        varargout = getBarAreaColor (varargin{:});
        
    case 'getPlotManager'
        varargout = getPlotManager (varargin{:});
        
    case 'getNearestKnownParentClass'
        varargout = getNearestKnownParentClass (varargin{:});
            
    case 'doRefreshData'
        doRefreshData (varargin{:});
            
    case 'doInspect'
        doInspect (varargin{:});
        
    case 'setColormap'
        setColormap (varargin{:});
        
    case 'testColormap'
        varargout = testColormap (varargin{:});
        
    case 'showErrorDialog'
        if nargout
            varargout{1:nargout} = showErrorDialog (varargin{:});
        else
            showErrorDialog (varargin{:});
        end
        
    case 'addFigureSelectionManagerListeners'
        doAddFigureSelectionManagerListeners(varargin{:});
        
    case 'retargetSelectionManagerListeners'
        doRetargetSelectionManagerListeners(varargin{:}); 
        
    case 'enablePlotBrowserListeners'
        doEnablePlotBrowserListeners(varargin{:});    
        
    end

catch
    if nargout
        varargout{1:nargout} = showErrorDialog;
    else
        showErrorDialog;
    end
end


%% --------------------------------------------
function out = makePolarAxes (varargin)
% Arguments:  none; uses current figure
axes;
hline = polar ([0 2*pi], [0 1]);
% delete (hline);     % This line freezes MATLAB.  TODO: Fix it.
out = {gca};



%% --------------------------------------------
function setSelection (varargin)
% Arguments:  1. figure handle
%             2. cell array of objects to select
%This function is called from Plot Browser to change object selection.

if isempty (varargin), return, end
fig = varargin{1};
objs = varargin{2};
if ~ishghandle (fig)
     return;
end



if iscell (objs)
    objs = [objs{:}];
end
selectobject (objs, 'replace');

%Make sure we always set current axes. A user may have selected an object
%other than axis and the previous call to selectobject will leave current
%axes unchanged then. Then we get into a situation when a newly selected object
%has current axis that are not his parent axis (a leftover from the
%current axis selection). It will lead to a surprising behaviour if
%subsequent Matlab calls rely on current axis being set properly.
%(see geck 435741, aii)
if (~isempty(objs))
    %If multiple objects are selected pick the last selected object.
    lastSelectedObj=objs(length(objs));
    if (~strcmp(get(lastSelectedObj, 'type'), 'axes'))     
        anc=ancestor(lastSelectedObj, 'axes');
        if (~isempty(anc))
            set(fig,'CurrentAxes', anc);
        end
    end
end




%% --------------------------------------------
function plotExpressions (varargin)
% Arguments:  1. axes handle
%             2. plot command ('bar', 'contour', etc.)
%             3. expressions to plot
%             4. other PV pairs, e.g. 'XDataSource'
%
% Right now, this is used only by the AddDataDialog class.  Therefore,
% 'hold all' is called before the plot is made.

if isempty (varargin), return, end
axesHandle = double(varargin{1});
if ~ishghandle (axesHandle)
    showErrorDialog (xlate('The first argument to plotExpressions must be an axes handle!'));
    return;
end

%AII g453825. Don't use axes(axesHandle) because it changes Z order of
%plots messing up the original Z order and causing the other plot to be
%hidden behind the first one.
%axes (axesHandle);
fig=ancestor(axesHandle, 'figure');
set(fig, 'CurrentAxes', axesHandle);

exprs = varargin{3};
args = varargin{4};
evalExprs = {};
try
    for i = 1:length(exprs)
        evalExprs{end+1} = evalin('base', exprs{i});
    end
catch ex
    errordlg (sprintf ('%s\n\nPlease enter a variable name or a valid M expression.', ex.message), ...
        'Unknown data source');
    return;
end
for i = 1:length(args)
    if (strncmpi (args{i}, 'makedisplaynames', 16) == 1)
        evalExprs{end+1} = evalin('base', args{i});
    else
	    evalExprs{end+1} = args{i};
    end
end

%save hold status
holdStatus=ishold(axesHandle);

hold(axesHandle,'all');
feval (varargin{2}, evalExprs{:});

%restore hold status
if (~holdStatus)
    hold(axesHandle,'off');
end


%% --------------------------------------------
function out = getAxesTitle (varargin)
% Arguments:  1. axes handle

out = {};
if isempty (varargin) 
    return
end
axesHandle = varargin{1};
if ~ishghandle (axesHandle)
    showErrorDialog (xlate('The first argument to getAxesTitle must be an axes handle!'));
    return;
end
out = java (handle (get (axesHandle, 'Title')));
out = {out};


%% --------------------------------------------
function out = getAxisComponent (varargin)
% Arguments:  1. figure handle

out = {};
fig = varargin{1};
drawnow;
if ~ishghandle (fig)
    out = showErrorDialog (xlate('The first argument must be a figure handle!'));
    return;
end
fp = javaGetFigureFrame(fig);
out = fp.getAxisComponent;
out = {out};


%% --------------------------------------------
function out = getPlotManager (varargin)
% Arguments:  1. figure handle

out = {};
fig = varargin{1};
if ~ishghandle (fig)
    out = showErrorDialog (xlate('The first argument must be a figure handle!'));
    return;
end

pm = [];
if isappdata(fig, 'PlotManager')
    pm = getappdata(fig, 'PlotManager');
    if ~isa(pm, 'graphics.plotmanager')
        pm = [];
    end
end
if isempty(pm)
    pm = graphics.plotmanager;
    setappdata (fig, 'PlotManager', pm);
end

out = java (pm);
out = { out };



%% --------------------------------------------
function out = prepareAxesForDnD (varargin)
% Arguments:  1. figure handle
%             2. drop point

out = {};

%g303495 This solves a problem with drag and drop from a Figure Palette.
%Java's SelectionManager.drop() assumed that there is only one figure available
%for DnD (that's how it worked in the old plot tools when figures were just
%standalone floating windows) and acted upon this figure. SelectionManager
%is bound to a figure and DnD functionality doesn't belong there in the first
%place because drop target is not known in advance. If a drop target was
%not the current figure (bound to the SelectionManager) the DnD was
%still performed on the current figure ignoring the actual drop target.
%Now we always obtain figure under the mouse pointer independently of the
%SelectionManager, activate it and make it a drop target.

%NOTE that if HandleVisibility is off for the pointerwindow the call will
%return an empty handle. In this case take whatever SelectionManager 
%gave us for a figure.
fig = get(0, 'pointerwindow');
if (~isempty(fig))
    figure(fig);
else
    fig=varargin{1};
end

pt =  varargin{2};

% Make sure units=pixels, then set it back after the hit test:
oldUnits = get (fig, 'units');
set (fig, 'units', 'pixels');

% The Y axis is reversed, relative to the point Java found:
posn = get (fig, 'position');
pt(2) = posn(4) - pt(2);
% Dropped directly onto an axes. For MCOS graphics we should not use
% hittest because it will call a drawnow under the hood.
if feature('HGUsingMATLABClasses')
    axList = findobj(fig,'type','axes');
    for k=1:length(axList)
        axPos = hgconvertunits(fig,get(axList(k),'Position'),...
            get(axList(k),'Units'),'pixels',fig);
        ax = [];
        if axPos(1)<=pt(1) && axPos(1)+axPos(3)>=pt(1) && axPos(2)<=pt(2) && ...
                axPos(2)+axPos(4)>=pt(2)
            ax = axList(k);
            break;
        end
    end
    %ax = ancestor(plotedit({'hittestHGUsingMATLABClasses',fig,pt}),'axes');
else
    ax = ancestor(hittest(fig,pt),'axes');
end
set (fig, 'units', oldUnits);
if isempty (ax) 
    if ~isempty (get (fig, 'CurrentAxes'))
        ax = gca;                            % dropped on figure with an existing axes
    else
        ax = addsubplot (fig, 'Bottom');     % dropped on figure with no axes
        set (ax, 'Box', 'on');
    end
end
set (fig, 'CurrentAxes', ax);
set (ax, 'NextPlot', 'add');
hold all;
is3d = ~isequal (get (ax, 'View'), [0 90]);  % see also the function "is2d"
javaAx = java (handle (ax));
out = { javaAx, is3d };


%% --------------------------------------------
function makeSubplotGrid (varargin)
% Arguments:  1. figure handle
%             2. width
%             3. height
%             4. cell array of PV pairs, used for each axes created

fig = varargin{1};
if ~ishghandle (fig)
    showErrorDialog (xlate('The first argument must be a figure handle!'));
    return;
end
width  = varargin{2};
height = varargin{3};
numPlots = width * height;
existingAxes = findDataAxes (fig);

% figure out which hierarchy level we're talking about.
% does this need to be within a uipanel? a nested uipanel? the figure?
siblingAxes = existingAxes;
parent = fig;
if ~isempty(existingAxes)
    parent = get (gca, 'Parent');
    ph = handle(parent);
    if feature('HGUsingMATLABClasses')
            siblingAxes = ph.findobj ...
        ('-depth', 2, ...
         'type','axes', ...
         'handlevisibility', 'on', ...
         '-not','tag','legend','-and','-not','tag','Colorbar');
    else
        siblingAxes = ph.find ...
            ('-depth', 1, ...
             'type','axes', ...
             'handlevisibility', 'on', ...
             '-not','tag','legend','-and','-not','tag','Colorbar');
    end
end

% if necessary, delete excess axes
if length(siblingAxes) > numPlots
    % If there are Basic fitting axes put them last on the list so that
    % they are deleted last. This is needed since other (residual) axes are
    % dependent on them and if these axes are deleted the dependent axes will be
    % deleted (g418470).
    if isappdata(fig,'Basic_Fit_Axes_All')
        ind  = ismember(siblingAxes,getappdata(fig,'Basic_Fit_Axes_All'));
        siblingAxes = [siblingAxes(~ind);siblingAxes(ind)];  
    end
    delete (siblingAxes(1 : (length(siblingAxes) - numPlots)));
    % Delete all invalid axes (which may number more than
    % length(siblingAxes) - numPlots if there are deletion listeners, e.g.
    % residual axes in basic fitting
    siblingAxes(~ishghandle(siblingAxes)) = [];
end

% now call "subplot", rearranging existing plots
% (but preserving the parent/child hierarchy of those plots)
for i = 1:numPlots
    if i <= length (siblingAxes)
        h = subplot (height, width, i, ...
                     siblingAxes(length(siblingAxes) - (i-1)), ...
                     'Parent', parent);
    else
        if (nargin > 3)
            args = varargin{4};
            h = subplot (height, width, i, args{:}, 'Parent', parent);
        else
            h = subplot (height, width, i, 'Parent', parent);
        end
    end
end


%% --------------------------------------------
function out = getAxesHandle (varargin)
% Arguments:  1. series handle

out = {};
if isempty (varargin) return, end
series = varargin{1};
if ~ishghandle (series)
    showErrorDialog (xlate('The first argument to getAxesHandle must be a series handle!'));
    return;
end
out = java (handle (get (series, 'Parent')));
out = {out};



%% --------------------------------------------
function setPropertyValue (varargin)
% Arguments:  1. array of objects
%             2. property name
%             3. new property value
objs = varargin{1};
propname = varargin{2};
propval = varargin{3};
if iscell (objs)
    objs = [objs{:}];
end
objs(~ishghandle(objs)) = [];
set (objs, propname, propval);


%% --------------------------------------------
%This is a deprecated function, use scribeDeleteObjects() instead. It
%causes a bug with undo/redo g455311
function deleteObjects (varargin)
% Arguments:  1. array of objects to delete
objs = varargin{1};
if iscell (objs)
    objs = [objs{:}];
end
objs(~ishghandle(objs)) = [];

selectobject ([], 'replace');
delete (objs);


%% --------------------------------------------
function scribeDeleteObjects(varargin)

hFig=varargin{1};
if (isempty(hFig) || ~ishghandle(hFig) || (~isa(handle(hFig),'hg.figure') && ...
        ~isa(handle(hFig),'matlab.ui.Figure')))
    return;
end
scribeccp(hFig, 'Delete');


    

function out = getBarAreaColor (varargin)
% Arguments:  1. barseries or areaseries
h = varargin{1};
if ~ishghandle(h)
    showErrorDialog (xlate('The first argument to getBarAreaColor must be a figure handle!'));
    return;
end
color = get (h,'FaceColor'); 
if ischar(color) 
    if isa(h,'patch') || ~feature('HGUsingMATLABClasses')
        fig = ancestor(h,'figure'); 
        ax = ancestor(h,'axes'); 
        cmap = get(handle(fig),'Colormap'); 
        clim = get(handle(ax),'CLim'); 
        if isa(h,'patch')
            fvdata = get(h,'FaceVertexCData'); 
        else
            fvdata = get(get(h,'children'),'FaceVertexCData'); 
        end
        seriesnum = fvdata(1); 
        color = (seriesnum-clim(1))/(clim(2)-clim(1)); 
        ind = max(1,min(size(cmap,1),floor(1+color*size(cmap,1)))); 
        color = cmap(ind,:);
    else
        % For barseries/areaseries in hg2, the actual color is defined
        % in the FaceHandle. From Geometry.xml the ColorData type is:
        % ColorData property: truecolor = uint8 4xn, colormapped = float
        % vector
        color = hgcastvalue('MeshColor',h.FaceHandle.ColorData(1:3));
    end
end 
out = {color};

%% --------------------------------------------
function out = getNearestKnownParentClass (varargin)
% Arguments:  1. MATLAB object for which to find the parent class
knownClasses = {'figure', 'axes', 'graph2d.lineseries', ...
                'specgraph.barseries', 'specgraph.stemseries', ...
                'specgraph.areaseries', 'specgraph.errorbarseries', ...
                'specgraph.scattergroup', 'specgraph.contourgroup', ...
                'specgraph.quivergroup', 'graph3d.surfaceplot', ...
                'image', 'uipanel', 'uicontrol,' ...
                'scribe.line', 'scribe.arrow', 'scribe.doublearrow', ...
                'scribe.textarrow', 'scribe.textbox', 'scribe.scriberect', ...
                'scribe.scribeellipse', 'scribe.legend', 'scribe.colorbar', ...
                'line', 'text', 'rectangle', 'patch', 'surface'};
obj = varargin{1};
out = {''};
for i = 1:length(knownClasses)
    if isa (handle(obj), knownClasses{i})
        out = {knownClasses{i}};
        return;
    end
end


%% --------------------------------------------
function doRefreshData (varargin)
% Arguments:  1. array of objects to refreshdata
objs = varargin{1};
if iscell (objs)
    objs = [objs{:}];
end
objs(~ishghandle(objs)) = [];
if feature('HGUsingMATLABClasses')
   refreshdata (objs);
else
   refreshdata (double(objs));
end

%% --------------------------------------------
function doInspect (varargin)
% Arguments:  1. array of objects to inspect
objs = varargin{1};
if iscell (objs)
    objs = [objs{:}];
end
objs(~ishghandle(objs)) = [];
inspect(objs);


%% --------------------------------------------
function setColormap (varargin)
% Arguments:  1. figure
%             2. colormap name
objs = varargin{1};
if iscell (objs)
    objs = [objs{:}];
end
objs(~ishghandle(objs)) = [];
cmapName = varargin{2};
cmapSize = size(get(objs,'Colormap'),1);
cmap = feval(lower(cmapName), cmapSize);
set(objs,'Colormap',cmap);


%% --------------------------------------------
function out = testColormap (varargin)
% Arguments:  1. colormap, (an array, not a string)
cmap = (varargin{1});
cmapToTest = reshape(cmap, length(cmap)/3, 3);
colormapName = '';
known_colormaps = {'jet', 'hsv', 'hot', 'gray', 'bone', 'copper', 'pink', 'lines',  'cool', 'autumn', 'spring', 'winter', 'summer'};
for n = 1:length(known_colormaps)
    if isequal(cmapToTest, feval(known_colormaps{n}, length(cmapToTest)))
        colormapName = known_colormaps{n};
        break;
    end
end
out = {colormapName};


%% --------------------------------------------
function varargout = showErrorDialog (varargin)
% Arguments:  1. string containing details about the error

% initialize varargout to something useful
for i=1:nargout, varargout{i} = []; end

if ~isempty (lasterr)
    if ~isempty(varargin)
        details = varargin{1};
        errordlg (sprintf ('%s\n\n%s', lasterr, details), 'MATLAB Error');
    else
        errordlg (sprintf ('%s', lasterr), 'MATLAB Error');
    end
else
    lasterr ('unknown');
end



