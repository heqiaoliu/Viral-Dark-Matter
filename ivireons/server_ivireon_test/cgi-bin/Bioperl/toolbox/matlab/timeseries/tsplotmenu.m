function hmenu = tsplotmenu(hplot,plotType) 
%
% tstool utility function

%   Copyright 2004-2006 The MathWorks, Inc.

% TSPLOTMENU  Constructs right-click menus for time series plots. 

AxGrid = hplot.AxesGrid;
Size = AxGrid.Size; 
hmenu = struct(... 
   'Timeseries',[],... 
   'Characteristics',[]); 
       
%% Group #1: Data contents (waves & characteristics) 
hmenu.Timeseries = hplot.addMenu('waves','Label','Time series', 'Tag', 'Time series'); 

% Create a Characteristics menu 
if ~strcmp(plotType,'CorrPlot')
    hmenu.Characteristics = hplot.addMenu('characteristics');
    set(hmenu.Characteristics,'Label',xlate('Annotations'), 'Tag', 'Annotations');
end

%% Group #3: Annotation and Focus 
hplot.addMenu('normalize');
AxGrid.addMenu('grid','Separator','on');

% Plot specific menus
switch plotType
    case 'TimePlot'
        hplot.addTSMenu('selectrule','Separator','on'); 
        hplot.addTSMenu('merge'); 
        hplot.addTSMenu('removemissingdata');
        hplot.addTSMenu('detrend');
        hplot.addTSMenu('filter');
        hplot.addTSMenu('interpolate');
        hplot.addTSMenu('shift');
        hplot.addTSMenu('remove');
        hplot.addTSMenu('keep');
        hplot.addTSMenu('delete');
        hplot.addTSMenu('newevent');
        hplot.addTSMenu('select');
    case 'SpecPlot'
        hplot.addTsMenu('merge','Separator','on');
        hplot.addTSMenu('removemissingdata');
        hplot.addTSMenu('detrend');
        hplot.addTSMenu('filter');
        hplot.addTSMenu('interpolate');
    case 'XYPlot'
        hplot.addTsMenu('merge'); 
        hplot.addTsMenu('remove');
        hplot.addTsMenu('delete');
        hplot.addTsMenu('keep');
end

%% Last group undo-redo
undoMenu = uimenu('Parent',AxGrid.UIcontextMenu,...
    'Label','Undo','Tag','undo','Separator','on',...
    'Callback',{@localUndo hplot});
redoMenu = uimenu('Parent',AxGrid.UIcontextMenu,...
    'Label','Redo','Tag','uredo',...
    'Callback',{@localRedo hplot});
r = tsguis.recorder;
hplot.addlisteners([handle.listener(r,r.findprop('Undo'),'PropertyPostSet',...
       {@setUndoStatus undoMenu r});...
     handle.listener(r,r.findprop('Redo'),'PropertyPostSet',...
       {@setRedoStatus redoMenu r})]);
setUndoStatus([],[],undoMenu,r)
setRedoStatus([],[],redoMenu,r)

%% Plot edit mode
editMenu = uimenu('Parent',AxGrid.UIcontextMenu,...
    'Label',xlate('Edit Plot'),'Tag','edit','Separator','on',...
    'Callback',@(es,ed) propedit(hplot.AxesGrid.Parent));


%------------------ Local Functions -----------------------------

function LocalUpdateVis(eventsrc,eventdata,AxGrid,MenuHandles)
% Initializes and updates visibility of "MIMO" menus
if prod(AxGrid.Size([1 2]))==1
   %set(MenuHandles(1:2),'Visible','off')
   set(MenuHandles(1),'Visible','off')
else
   %set(MenuHandles(1:2),'Visible','on')
   set(MenuHandles(1),'Visible','on')
end
   

function localUndo(eventSrc, eventData, this)

%% Undo menu callback
recorder = tsguis.recorder;
if ~isempty(this.Parent) % Object may not have been parented initially
    undo(recorder);
end

function localRedo(eventSrc, eventData, this)

%% Redo menu callback
recorder = tsguis.recorder;
if ~isempty(this.Parent) % Object may not have been parented initially
    redo(recorder);
end

function setUndoStatus(es,ed,undoMenu,r)

%% Recorder Undo stack listener callback
if isempty(r.Undo)
    set(undoMenu,'Enable','off')
else
    set(undoMenu,'Enable','on')
end

function setRedoStatus(es,ed,redoMenu,r)

%% Recorder Redo stack listener callback
if isempty(r.Redo)
    set(redoMenu,'Enable','off')
else
    set(redoMenu,'Enable','on')
end

