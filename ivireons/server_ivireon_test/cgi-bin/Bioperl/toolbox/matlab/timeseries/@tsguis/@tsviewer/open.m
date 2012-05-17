function open(h,varargin)
% Configures and opens tstool with the Timeseries data and View nodes.

%   Copyright 2004-2010 The MathWorks, Inc. 
%   $Revision: 1.1.6.13 $ $Date: 2010/04/21 21:33:57 $

persistent isSimulinkInstalled;
mlock 

import java.awt.dnd.*
import com.mathworks.toolbox.timeseries.*;
import javax.swing.tree.*;

% Wait bar for monitoring
if nargin==1
    wb = waitbar(0,'Initializing Time Series Tools...',...
        'Name','Time Series Tools');
else
    wb = varargin{1};
end

try
    % Check if Simulink is installed       
    if isempty(isSimulinkInstalled)
        isSimulinkInstalled = license('test', 'Simulink') && exist('bdclose', 'file');
    end
    if ishandle(wb)
       waitbar(.05,wb,'Initializing classes...');
    end
    % Clean up any invalid objects
    if ~isempty(h.TreeManager) && ishandle(h.TreeManager)
        delete(h.TreeManager)      
    end
    h.TreeManager = [];
    if ishandle(wb)
       waitbar(.1,wb,'Building graphics...');
    end
    % Build the tree
    rootNode = tsexplorer.Workspace(xlate('Time Series Session'));
    rootNode.TsViewer = h;
    timeseriesNode = tsguis.tsparentnode(xlate('Time Series'));
    rootNode.addNode(timeseriesNode);

    if isSimulinkInstalled
        simulinkTsNode = tsguis.simulinkTsParentNode(xlate('Simulink Time Series'));
        rootNode.addNode(simulinkTsNode);
    end
    if ishandle(wb)
       waitbar(.2,wb,'Creating nodes...');
    end
    % View nodes
    viewsNode = tsexplorer.node(xlate('Views'));
    rootNode.addNode(viewsNode);
    timeViewsNode = tsguis.viewcontainer(xlate('Time Plots'),'tsguis.tsseriesview');
    viewsNode.addNode(timeViewsNode);
    specViewsNode = tsguis.viewcontainer(xlate('Spectral Plots'),'tsguis.tsspecnode');
    viewsNode.addNode(specViewsNode);
    xyViewsNode = tsguis.viewcontainer(xlate('XY Plots'),'tsguis.tsxynode');
    viewsNode.addNode(xyViewsNode);
    corrViewsNode = tsguis.viewcontainer(xlate('Correlations'),'tsguis.tscorrnode');
    viewsNode.addNode(corrViewsNode);
    histViewsNode = tsguis.viewcontainer(xlate('Histograms'),'tsguis.tshistnode');
    viewsNode.addNode(histViewsNode);
    tsexplorer.node('Macros');
    if ishandle(wb)
       waitbar(.4,wb,'Setting up the main figure...');
    end
    % Create a figure with an inspector panel and tree widget.
    thisFigure = figure('NumberTitle', 'off', 'Name', 'Time Series Tools',...
        'Units','Characters','Menubar','none','WindowStyle','normal',...
        'HandleVisibility','off','Visible','off','KeyPressFcn',...
        {@localRedoUndo h},'DockControls','off','IntegerHandle','off','Tag',...
        'tstool');
    h.TreeManager = tsexplorer.TreeManager(rootNode,'Figure',thisFigure,'DialogPosition',...
        30,'HelpDialogPosition',30);
    screenSizeinChars = hgconvertunits(thisFigure,get(0,'screenSize'),...
                                 'Pixels','Characters',thisFigure);
    posW = screenSizeinChars(3)*0.72;    
    posW = max(posW,h.TreeManager.DialogPosition+strcmp(h.TreeManager.HelpShowing,'on')*...
            h.TreeManager.HelpDialogPosition-1 + h.TreeManager.Minwidth);        
    posH = max(screenSizeinChars(4).*0.64,h.TreeManager.Minheight);
    set(thisFigure,'Position',[0 0 posW posH]);
    centerfig(thisFigure);
    % Add the motion detector to show the resize arrow for mouse
    set(thisFigure,'WindowButtonMotionFcn',{@tshoverfig h.TreeManager});
    
    % Store the last warning thrown
    [ lastWarnMsg lastWarnId ] = lastwarn;

    % Disable the warning when using the 'JavaFrame' property
    % this is a temporary solution
    oldJFWarning = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
    jf = get(thisFigure, 'JavaFrame');
    warning(oldJFWarning.state, 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

    % Restore the last warning thrown
    lastwarn(lastWarnMsg, lastWarnId);

    ic = fullfile(matlabroot,'toolbox/matlab/timeseries/matlabicon.gif'); %#ok<MCTBX,MCMLR>
    jf.setFigureIcon(javax.swing.ImageIcon(java.lang.String(ic)));

    % Populate the viewer with the top level node handles
    set(h,'TSNode', timeseriesNode,'ViewsNode', viewsNode);
    if isSimulinkInstalled
        set(h, 'SimulinkTSNode', simulinkTsNode);
    end
    if ishandle(wb)
       waitbar(.6,wb,'Installing menus...');
    end
    % Install menus
    figmenus(h)
    set(thisFigure,'Userdata',h);
    if ishandle(wb)
       waitbar(.8,wb,'Building cached figures...');
    end
    % Set style manager
    h.StyleManager = wavepack.WaveStyleManager;

    % Open the Views node
    h.TreeManager.Tree.expand(viewsNode.getTreeNodeInterface);

    % Prevent selection of the root node
    customTreeSelectionModel  = awtcreate('com.mathworks.toolbox.timeseries.tsTreeSelectionModel',...
        '[Ljavax/swing/tree/TreePath;Lcom/mathworks/mwswing/MJTree;',...
        [TreePath(rootNode.getTreeNodeInterface);...
        TreePath([rootNode.getTreeNodeInterface;viewsNode.getTreeNodeInterface])],...
        h.TreeManager.Tree.getTree);       
    awtinvoke(h.TreeManager.Tree.getTree,'setSelectionModel(Ljavax/swing/tree/TreeSelectionModel;)',...
        customTreeSelectionModel);
    drawnow 
    
    if ishandle(wb)
       waitbar(1,wb,'Completed...');
    end
catch me
    errordlg(sprintf('Error opening Time Series Tools: %s',...
       me.message),'Time Series Tools')
end

% If the waitbar was created in this method - close it
if nargin==1
   close(wb)
end

% Update udd from java Prefs
h.utUpdateMaxPlotLength;

function localRedoUndo(~,eventData,h)

% KeyPress callback for redo/undo
if strcmp(eventData.Key,'z') && isequal(eventData.Modifier,{'control'})
    h.undo;
elseif strcmp(eventData.Key,'y') && isequal(eventData.Modifier,{'control'})
    h.redo;
end
