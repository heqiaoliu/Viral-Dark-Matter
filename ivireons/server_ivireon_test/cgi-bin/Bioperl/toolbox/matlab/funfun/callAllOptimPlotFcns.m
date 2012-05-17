function state = callAllOptimPlotFcns(functions,x,optimvalues,flag,varargin)
%callAllOptimPlotFcns Helper function that manages the plot functions.
%   STOP = callAllOptimPlotFcns(FUNCTIONS, X,OPTIMVALUES,flag) runs 
%   each of the plot functions.
%
%   This function is private to Optimization solvers.

%   Copyright 2006-2010 The MathWorks, Inc. 
%   $Revision: 1.1.6.8 $  $Date: 2010/05/10 17:23:42 $

persistent plotNo plotNames isNew fig position menuitem

state = false;
fname = 'Optimization PlotFcns';

if (isempty(functions)) || ...
        (strcmpi(flag,'done') && isempty(findobj(0,'Type','figure','name',fname)))
    return;
end
% Check if called with 'iter' flag and no figure is present.
if (strcmpi(flag,'iter') && isempty(findobj(0,'Type','figure','name',fname)))
    state = true;
    return;
end

functions = removeDup(functions);
% Called with 'init' flag or the figure is not present
if(strcmp(flag,'init')) || isempty(findobj(0,'Type','figure','name',fname))
    fig = findobj(0,'type','figure','name',fname);
    if isempty(fig)
        fig = figure('visible','off');
        if ~isempty(position) && ~strcmpi(get(fig,'WindowStyle'),'docked')
            set(fig,'Position',position);
        end
    end
    set(0,'CurrentFigure',fig);
    clf;
    set(fig,'numbertitle','off','name',fname,'userdata',[]);
    % Initialize the persistent variables
    [plotNames,plotNo,menuitem,isNew] = updatelist(functions);
   
    % Give a stop button in the figure
    stopBtnXYLoc = [5 10];
    stopBtn = uicontrol('string',sprintf('Stop'),'Position',[stopBtnXYLoc 50 20],'callback',@buttonStop);
    % Make sure the full text of the button is shown
    stopBtnExtent = get(stopBtn,'Extent');
    stopBtnPos = [stopBtnXYLoc stopBtnExtent(3:4)+[3 3]]; % Read text extent of stop button
    % Set the position, using the initial hard coded position, if it is long enough
    set(stopBtn,'Position',max(stopBtnPos,get(stopBtn,'Position'))); 
    
    % Give a pause button in the figure
    pauseBtn = uicontrol('string',sprintf('Pause'),'Position',[60 10 50 20],'callback',{@buttonPauseContinue,fname});
    pauseBtnExtent = get(pauseBtn,'Extent');
    pauseBtnXYLoc = stopBtnXYLoc + [stopBtnPos(3) 0] + [10 0]; % Offset for space in between stop and pause buttons
    pauseBtnPos = [pauseBtnXYLoc pauseBtnExtent(3:4)+[3 3]];
    % Set the position, using the initial hard coded position, if it is long enough
    set(pauseBtn,'Position',max(pauseBtnPos,get(pauseBtn,'Position')));
        
    set(fig,'CloseRequestFcn',@beforeClose);
    % Reset the appdata if it exist
    if isappdata(fig,'data')
        rmappdata(fig,'data')
    end
    set(gcf,'visible','on')
    shg
end
% Determine the layout size in the figure
rows  = ceil(sqrt(length(functions)));
cols  = ceil(length(functions)/rows);
% Set the current figure to fig
set(0,'CurrentFigure',fig);

% Initialize the output argument from plot functions
state = false(length(plotNames),1);
% Call each plot function
for i = 1:length(plotNames)
    handle = subplot(rows,cols,plotNo(i));
    if isNew(i)
        % Do not delete the axis (which is the default settings)
        set(handle,'NextPlot','replacechildren');
        state(i) = feval(plotNames{i},x,optimvalues,'init',varargin{:});
        isNew(i)=false;
        if ~strcmpi(flag,'init')
            state(i) = feval(plotNames{i},x,optimvalues,flag,varargin{:});
        end
        cmenu = uicontextmenu;
        set(handle,'UIContextMenu', cmenu);
        % Provide a uicontext menu item to open the axes in a new figure
        % window
        cmenuCallback = {@mouseaction,handle,plotNames{i}};
        uimenu(cmenu,'Label', sprintf('Open this plot in a new window'), ...
            'Callback', cmenuCallback,'Tag','OpenInNewWindow');
        menuitem(i) = get(cmenu,'Children');
        set(menuitem(i),'Visible','off');
    else
        state(i) = feval(plotNames{i},x,optimvalues,flag,varargin{:});
    end
end
% If any state(i) is true we set the state to true
state = any(state);

drawnow
% Check if the figure is still alive
if isempty(findobj(0,'Type','figure','name',fname))
    state = true;
    return;
end
% Remember the position
position = get(fig,'Position');

% If stop button was pressed, handle the callback
if(strcmpi('stop',getappdata(fig,'data')))
    state = true;
    setappdata(fig,'data','')
end

if strcmpi(flag,'done') || state
    % reset the closerequest function
    set(fig,'CloseRequestFcn','closereq');
    % Enable menu item at the end
    for i = 1:length(plotNames)
        set(menuitem(i),'Visible','on');
    end
end

%-------------------------------------------------------
% UPDATELIST updates the function list and plot numbers
%-------------------------------------------------------
function [plotNames, plotNo,menuitem, isNew] = updatelist(functions)

plotNames = functions;
plotNo   = 1:length(functions);
isNew = true(length(plotNames),1);
menuitem = zeros(length(plotNames),1);
%-----------------------------------------------------------
% REMOVEDUP remove the duplicate entries in a cell array of function handle
%-----------------------------------------------------------
function functions = removeDup(functions)
i = 1;
while i <= length(functions)
      [found,index] = foundfunc(functions{i},functions);
      if found 
        functions(index(1:end-1)) = [];
      end
    i = i+1;
end

%-------------------------------------------------------------------------
% FOUNDFUNC Finds if STR is in FUNCNAMES, returns a boolean and index
%-------------------------------------------------------------------------
function [bool,index] = foundfunc(str,funcNames)

bool = false;
index = 0;
for i = 1:length(funcNames)
    if strcmpi(func2str(str),func2str(funcNames{i}))
        bool = true;
        if nargout > 1
            index(end+1) = i;
        end
    end
end
index(1) = [];
%-----------------------------------------------------------
% STOP button callback
%-----------------------------------------------------------
function buttonStop(~,~)
setappdata(gcf,'data','stop');

%-----------------------------------------------------------
% PAUSE/CONTINUE button callback
%-----------------------------------------------------------
function buttonPauseContinue(hObj,~,fname)
if length(dbstack) <=2
    return;
elseif isempty(getappdata(gcf,'data'))
    setappdata(gcf,'data','pause');
    % To avoid dynamically re-sizing the Pause/Resume button, we leave
    % the button size unchanged from it's size at creation.
    set(hObj,'String',sprintf('Resume'));
else
    rmappdata(gcf,'data');
    return;
end
% If in pause state keeping looping here.
while true
    drawnow
    fig = findobj(0,'type','figure','name',fname);
    % Figure window is closed; return
    if isempty (fig)
        return;
    end
    % When 'Resume' button is pressed
    if isempty(getappdata(gcf,'data'))
        set(hObj,'String',sprintf('Pause'));
        return;
    end
    % When 'Stop' button is pressed
    if strcmpi('stop',getappdata(fig,'data'))
        set(hObj,'String',sprintf('Pause'));
        return;
    end
end % End while
%-----------------------------------------------------------
% MOUSEACTION callback function
%-----------------------------------------------------------
function mouseaction(~,~,axes_handle,Name)
% Determine the length of stack. If length is one then need to open a new
% figure with axes copied from the current object
callStack = dbstack;
if length(callStack) == 1 % The solver has stopped
    newFigName = func2str(Name);
    fig = findobj(0,'type','figure','name',newFigName);
    if isempty(fig) % Create a new figure
        fig = figure('numbertitle','off','name',newFigName);
    end
    set(0,'CurrentFigure',fig); clf;
    % Get the position of new axes (to be created)
    tempaxis = axes('visible','off');
    axisPosition = get(tempaxis,'Position');
    delete(tempaxis);
    % Copy the axes to the new figure
    parent = get(axes_handle,'parent');
    copiedPlot = copyobj(axes_handle,parent);
    set(copiedPlot,'parent',fig,'position',axisPosition);
    figure(fig);
    return;
end


%-----------------------------------------------------------
% BEFORECLOSE CloseRequestFcn for main figure window
%-----------------------------------------------------------
function beforeClose(obj,~)
% Determine the length of stack. If length is one then we don't
% need a question dialog; we simply delete the obj (close the figure)
if length(dbstack) ==1
    delete(obj)
    return;
end

msg = sprintf(['YES will stop the solver (if running) and close the figure.\n',...
                           'NO will cancel this request.']);
handle = questdlg(msg,'Close dialog', 'YES','NO','NO');
switch handle
    case 'YES'
        delete(obj)
    case 'NO' 
        return;
    otherwise
        return;
end
%-------------------------------------------------------------------------

