function build(this)
%BUILD  Builds diagram

%   Authors: C. Buhr
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2008/12/04 22:22:04 $

% Create figure
hfig = figure('Name',xlate('Control Architecture'),...
   'MenuBar','none', ...
   'Resize','off', ...
   'Units','pixel', ...% 'Position',FigSize, ...
   'IntegerHandle','off', ...
   'HandleVisibility','callback',...
   'NumberTitle','off', ...
   'Visible','off',...
   'CloseRequestFcn', {@LocalHide this});
this.Figure = handle(hfig);

this.Handles.DiagramPanel = uipanel('parent',hfig, ...
            'position',[0, 0.4, 1, 0.6],'bordertype','none');

this.Handles.Axes = axes('Parent',this.Handles.DiagramPanel, ...
    'Units','normalized', ...
    'Position',[0 0 1 1],...
    'visible','off',...
    'Ylim',[0 1],...
    'Xlim',[0 1]);

PanelPos = get(hfig,'position');
TableModel = com.mathworks.toolbox.control.tableclasses.DiagramDisplayTableModel({'a','b'},{xlate('Identifier'),xlate('Name')});
% EditableColumns = javaArray('java.lang.Boolean',2);
% EditableColumns(1) = java.lang.Boolean(false);
% EditableColumns(2) = java.lang.Boolean(false);
% TableModel.Editablecolumns=EditableColumns;
Table = javaObjectEDT('com.mathworks.mwswing.MJTable',TableModel);
TableScrollPane = javaObjectEDT('com.mathworks.mwswing.MJScrollPane',Table);
[HCOMPONENT, HCONTAINER] = javacomponent(TableScrollPane,[0,0,PanelPos(3),PanelPos(4)*.4],hfig);
this.Handles.TableModel = TableModel;

% Listener to figure visibility to sync up
this.Listeners = [handle.listener(this.Parent,'ObjectBeingDestroyed',{@LocalDestroy this});
    handle.listener(this.Parent,'ConfigChanged',{@LocalRefresh this})];


%--------------- Callback functions -----------------------------

function LocalDestroy(eventsrc,eventdata,this)
% delete figure
delete(this.Figure)

function LocalHide(eventsrc,eventdata,this)
% Hides window
this.Figure.Visible = 'off';

function LocalRefresh(eventsrc,eventdata,this)
% Hides window
this.refreshDiagram;