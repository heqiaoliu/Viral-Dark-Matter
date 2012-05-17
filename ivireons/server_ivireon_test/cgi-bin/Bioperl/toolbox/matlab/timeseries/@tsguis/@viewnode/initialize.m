function initialize(h,manager,f,varargin)

% Copyright 2005-2008 The MathWorks, Inc.

%% Common initialization functions for all view nodes

import java.awt.dnd.*
import com.mathworks.toolbox.timeseries.*;
import javax.swing.tree.*;

%% Assign the Figure and Tree properties
set(f,'Units','Characters','closeRequestFcn',{@localClose h manager},'Toolbar', ...
    'figure')
h.Handles.InitTXT = uicontrol('style','text','string',...
    'Drag and drop a time series node to view','BackgroundColor',...
    [.4 .4 .4],'ForegroundColor',[1 1 1],...
    'Parent',f);
set(f,'ResizeFcn',{@localTxtResize h.Handles.InitTXT})
localTxtResize(f,[],h.Handles.InitTXT);
set(h,'Tree',manager.tree,'Figure',f);
% h.HelpFile = fullfile(matlabroot, 'toolbox', 'matlab', 'timeseries', ...
%                          '@tsguis', '@viewnode','tshelp.htm');
                     
%% Add tools menus
h.addToolsMenus(f)

%% Create drop target
jf = tsguis.getJavaFrame(h.Figure);
drawnow
h.AxisCanvas = getAxisComponent(jf);
if isjava(manager.root.getTreeNodeInterface)
    ParentTreePath = TreePath([manager.root.getTreeNodeInterface; ...
        manager.root.down.getTreeNodeInterface]);
    simParentTreePath = TreePath([manager.root.getTreeNodeInterface; ...
        manager.root.down.right.getTreeNodeInterface]);
else
    ParentTreePath = TreePath([java(manager.root.getTreeNodeInterface); ...
        java(manager.root.down.getTreeNodeInterface)]);
    simParentTreePath = TreePath([java(manager.root.getTreeNodeInterface); ...
        java(manager.root.down.right.getTreeNodeInterface)]);
end              
h.DropAdaptor = AxisDropAdaptor(h,'dropCallback',manager.tree.getTree,...
    ParentTreePath,simParentTreePath);
h.DropTarget = DropTarget(h.AxisCanvas,h.DropAdaptor);
h.AxisCanvas.setDropTarget(h.DropTarget);

%% Node detachment listener
h.addListeners(handle.listener(h,'ObjectParentChanged', ...
    {@localHideView h manager}));

%% Add node name
if nargin == 3 
  h.Label = 'View Node';
elseif nargin == 4
  h.Label = varargin{1};
elseif nargin >= 5 
  h.Label = h.createDefaultName( varargin{1}, varargin{2} );
else
  error('viewnode:initialize:noNode',...
      'Node name and an optional parent node handle should be provided')
end

%% Set node properties
set(h,'AllowsChildren',true,'Editable',true,'Icon', ...
    fullfile(matlabroot, 'toolbox', 'matlab', 'timeseries', ...
                          'plot_op_conditions.gif')) %#ok<MCTBX,MCMLR>

% Build tree node. Note in the CETM there is no need to do this because the
% Explorer calls it when building the tree
h.getTreeNodeInterface;

function localTxtResize(eventSrc,eventData,txt) %#ok<INUSL>

%% Resize fcn to ensure that the text is always in the center of the figure
pos = get(eventSrc,'Position');
pos = hgconvertunits(ancestor(eventSrc,'figure'),pos,get(eventSrc,'Units'),...
    'characters',get(txt,'Parent'));
 
%% Set the text to the middle of the figure
len1 = length(get(txt,'String'));
if pos(3)/2-len1/2>10
    set(txt,'Units','Characters','Position', [pos(3)/2-len1/2 pos(4)/2 len1+5 2.5])
elseif pos(3)>20
    set(txt,'Units','Characters','Position', [10 pos(4)/2 pos(3)-20 2.5])
else
    set(txt,'Visible','off')
end

function localClose(eventSrc,eventData,h,manager) %#ok<INUSL,INUSL>

%% Figure closing listener detaches view node. The node detachement
%% listener then disposes of the view

%% Select the view parent. This ensures that the New Plot panels onm
%% all @tsnodes will update to reflect the new list of plots since they
%% must be reselected on the tree
manager.reset
selNode = manager.Tree.getSelectedNodes;
if length(selNode)>=1 && isequal(handle(selNode(1).getValue),h)
   manager.Tree.setSelectedNode(h.up.getTreeNodeInterface);
   drawnow % Force the node to show seelcted
   manager.Tree.repaint
end
h.up.removeNode(h);


function localHideView(eventSrc,eventData,h,manager) %#ok<INUSL>

%% Node detachement listener. Sets plot and view invisible and destroys the
%% figure
if ~isempty(eventData.NewParent)
    return
end
if ishghandle(h.Dialog)
    set(h.Dialog,'Visible','off')
end
% Remove any drop adaptors
h.DropAdaptor.targetTree = [];
% Destroy the plot first so that linked axes callbacks dont fire
p = [];
if ~isempty(h.Plot) && ishandle(h.Plot) 
   p = h.plot.PropEditor;
   if ~isempty(h.Plot.findprop('xaxeslink'))
       delete(h.Plot.xaxeslink);
       h.Plot.xaxeslink = [];
   end
   delete(h.Plot)
end

% Remove drop target and axesCanvas so that figure deletion can destroy all
% java peers
h.AxisCanvas = [];
h.DropTarget = [];
h.removePopup;
% Destroy figures
if ~isempty(h.Figure) && ishghandle(h.Figure)
    delete(h.Figure)
end

% Destroy property editor
if ~isempty(p) && ishandle(p)
    delete(p);
end

% If a timeseries or tscollection node is selected, refresh the 
% list of plots in the view combo
if ishandle(manager)
     manager.getselectednode.getDialogInterface(manager);
end

