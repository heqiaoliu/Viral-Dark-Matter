function addListeners( this )
% ADDLISTENERS Add UDD related listeners

% Author(s): 
% Revised:
% Copyright 2004-2008 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2008/12/29 02:10:52 $

% Add property listeners
L = [ handle.listener(this.Root, 'PropertyChange', {@LocalTreeUpdate this.Tree}); ...
      handle.listener(this,'ObjectBeingDestroyed', @LocalObjectBeingDestroyed);...
      handle.listener(this,this.findprop('Visible'),'PropertyPostSet',...
         @(es,ed) set(get(this,'Figure'),'Visible',get(this,'Visible')))];
set(L, 'CallbackTarget', this);
this.Listeners.replaceListeners(L);
this.Listeners.addListeners(addlistener(this.Figure,'ObjectBeingDestroyed',@(es,ed) delete(this)));

% ---------------------------------------------------------------------------- %
% Clean up @node and java objects
function LocalObjectBeingDestroyed(this, hData)

import com.mathworks.mwswing.desk.*;
import com.mathworks.mde.desk.*;

try % Prevent unforseen command line errors 

    % Select the root
    this.reset
    this.Tree.setSelectedNode(this.Root.getTreeNodeInterface);
    drawnow % Force the node to show seelcted
    this.Tree.repaint
    this.Tree.getTree.removeMouseListener(this.Cmenulistener);
    
    % Delete singletop dialogs which may be listening to tree nodes
    dlgs = {tsguis.preprocdlg; tsguis.arithdlg; tsguis.datamergedlg;...
        tsguis.datapreprocdlg;  tsguis.mergedlg; tsguis.shiftdlg; ...
        tsguis.selectrules; tsguis.statsdlg; tsguis.allExportdlg};
    for k=1:length(dlgs) 
        dlgs{k}.Handles = [];
        if ~isempty(dlgs{k}.Figure) && ishghandle(dlgs{k}.Figure)
            delete(dlgs{k}.Figure)
        end
        if ~isempty(dlgs{k}) || ishandle(dlgs{k})
            delete(dlgs{k})
        end
    end
    % Delete macro recorder
    dlg = tsguis.recorder;
    if ~isempty(dlg.Dialog) && isjava(dlg.Dialog)
        awtinvoke(dlg.Dialog,'dispose');
        drawnow
    end
    delete(dlg);
    dlg = tsguis.ImportWizard('destroy');
    if ~isempty(dlg.Figure) && ishghandle(dlg.Figure)
        delete(dlg.Figure);
    end
    delete(dlg);
    drawnow % Make sure deletions are complete befre removing nodes

    % Cache mdi name
    mdiName = this.Root.Tsviewer.MDIGroupName;
    
    % Delete cached figures
    timePlotNode = this.Root.Tsviewer.ViewsNode.getChildren('label',xlate('Time Plots'));
    specPlotNode = this.Root.Tsviewer.ViewsNode.getChildren('label',xlate('Spectral Plots'));
    if ~isempty(timePlotNode.PlotCache) && ~isempty(timePlotNode.PlotCache.Panel) && ...
            ishghandle(timePlotNode.PlotCache.Panel) 
        delete(timePlotNode.PlotCache.Plot.PropEditor)
        delete(timePlotNode.PlotCache.Plot)
        timePlotNode.PlotCache.Plot = [];
        delete(ancestor(timePlotNode.PlotCache.Panel,'figure'));
        timePlotNode.PlotCache.Panel = [];
    end
    if ~isempty(specPlotNode.PlotCache) && ~isempty(specPlotNode.PlotCache.Panel) && ...
            ishghandle(specPlotNode.PlotCache.Panel)
        delete(specPlotNode.PlotCache.Plot.PropEditor)
        delete(specPlotNode.PlotCache.Plot)
        specPlotNode.PlotCache.Plot = [];
        delete(ancestor(specPlotNode.PlotCache.Panel,'figure'));
        specPlotNode.PlotCache.Panel = [];
    end

    %% Remove all nodes from the tree bypassing node selection.Listeners
    %% should be allowed to fire to be sure that any plots/calendars etc are
    %% closed. Prune from the bottom up.
    allNodes = [];
    nodeDepth = 2;
    newNodes = setdiff(this.Root.find('-depth',1),this.Root);
    while ~isempty(newNodes)        
        allNodes = [allNodes;newNodes];
        newNodes = setdiff(this.Root.find('-depth',nodeDepth),this.Root.find('-depth',nodeDepth-1));
        nodeDepth = nodeDepth+1;
    end
    allNodes = allNodes(end:-1:1);
    
    %% Strip callbacks to prevent memory leaks
    for k=1:length(allNodes)
        % Callbacks must be removed to prevent java memory leaks
        allNodes(k).removePopup;
    end    
    
    %% Remove nodes
    for k=1:length(allNodes)
        % Note ishandle(allNodes(k)) may not be true if removeNode
        % had destroyed any descendents
         if ishandle(allNodes(k)) && ~isempty(allNodes(k).up) && ishandle(allNodes(k).up)
            allNodes(k).up.removeNode(allNodes(k));
            drawnow % Selection events in tables need to fully process
         end
    end
    delete(allNodes(ishandle(allNodes)));

    if ~isempty(this.Figure) && ishghandle(this.Figure)
        delete(this.Figure);
    end
    
    % Free the selection model
    selModel = this.Tree.getTree.getSelectionModel;
    selModel.fTree = [];
    
    delete(this.Root.Tsviewer);
    delete(this.Root);
    delete(this.Tree);
    
    % Close Time Series Plots group
    if ~isempty(mdiName)
        mld = MLDesktop.getInstance;
        mld.closeGroup(xlate(mdiName));
    end
end

% ---------------------------------------------------------------------------- %
% Update the Java tree when nodes are added or removed
function LocalTreeUpdate(this, hEvent, Tree)

Model = Tree.getModel;

switch hEvent.propertyName
case 'NODES_WERE_INSERTED'
  newData = hEvent.newValue;
  Model.insertNodes( newData{1}, newData{2} );
case 'NODES_WERE_REMOVED'
  oldData = hEvent.oldValue;
  %Model.removeNodes( oldData{1}, oldData{2}, oldData(3)  );
  Model.removeNodeFromParent(oldData{3})
case 'NODE_CHANGED'
  newData = hEvent.newValue;
  Model.changeNode( newData{1} );
end
