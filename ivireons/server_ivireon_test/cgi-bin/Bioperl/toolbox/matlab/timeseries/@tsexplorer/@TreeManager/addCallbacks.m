function addCallbacks( this )
% ADDCALLBACKS Add Java related callbacks

%  Copyright 2004-2010 The MathWorks, Inc.
%  $Revision: 1.1.6.11 $ $Date: 2010/04/21 21:33:38 $


% Add event listeners
set(this.Figure,'Color',...
    get(this.TreePanel,'backgroundColor'))
set(this.Tree,'NodeSelectedCallback',{ @LocalSelectionChanged, this});
set(handle(this.Tree.getTree,'callbackproperties'),'KeypressedCallback',...
    {@localKeyPressed this})

% PopupTriggered event is fired from java by the uitreePopupListener class

%--------------------------------------------------------------------------
function LocalSelectionChanged(hSrc, hData, this)

try
    % hData must be wrapped in handle() to avoid memory leak in the uitree
    h = get(handle(get(handle(hData),'CurrentNode')),'Value');

    hh = handle(h);
    if ~isempty(h)
       % Hide panel, turning off any uitable containers
       %hh.setContentsVisible(this,'off'); 
       %set(findobj(this.Panel,'type','hgjavacomponent'),'Visible','off')
       set(findobj(this.Panel,'type','uitabgroup'),'Visible','off')
       set(this.Panel,'Visible','off');
       %oldPanel = this.Panel;
       set(this.HelpPanel,'Visible','off');
       drawnow expose; drawnow expose;
       % Protection against interruption in a previous selection callback which
       % could have left a previous panel visible
       %set(cell2mat(get(this.Root.find('-depth',inf),{'Dialog'})),'visible','off');

       %set the visibility of children uis of newly selected node's panel and
       %force redraw
       hh.setContentsVisible(this,'on'); 

       % Update menu status
       setMenusEnabled(hh,this);

       % Margin bars must remain on top for the hit test to fire properly
       figchildren = get(this.Figure,'children');
       [junk,I] = ismember(this.Margin,figchildren);
       figchildren(I) = [];
       figchildren = [this.Margin(:);figchildren];
       set(this.Figure,'children',figchildren);

%%%%%%%%%% Do not cache >12 panels. Suspended due to slugish call to find %%%%%%%%%%%%% 
%        allNodes = this.Root.Tsviewer.Tsnode.find('-depth',inf,'-isa','tsguis.tsnode');
%        xnodes = find(allNodes,'Dialog',[],'-depth',0);
%        allNodes = setdiff(allNodes,xnodes);
% 
%        % If the number of nodes > 12 delete the last panel
%        %
%        if numel(allNodes)>12
%            deletedNode = allNodes(floor(rand*length(allNodes)+1));
%            if ~isequal(deletedNode.Dialog,this.Panel)
%                delete(deletedNode.Listeners)
%                delete(deletedNode.Dialog);
%                deletedNode.Dialog = [];
%                deletedNode.Listeners = [];
%            end
%        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % Release the tree
       thisModel = this.Tree.getTree.getSelectionModel;
       thisModel.fCurrentPath = [];   

    end 
catch
   thisModel = this.Tree.getTree.getSelectionModel; 
   thisModel.fCurrentPath = [];   
end
this.Tree.repaint

%--------------------------------------------------------------------------
function localKeyPressed(es,ed,this)

%% Get selected node
selnodes = this.Tree.getSelectedNodes;
if length(selnodes)>0
    thisnode = handle(selnodes(1).getValue);
end

%% Node deletion
if ed.getKeyCode == ed.VK_DELETE
    if ~isOKtoDelete(thisnode)
        return
    end
    ButtonName = questdlg(sprintf('Do you want to delete object ''%s''?',thisnode.Label), ...
        xlate('Confirm Deletion'), xlate('OK'),xlate('Cancel'),xlate('OK'));
    ButtonName = xlate(ButtonName);
    if strcmp(ButtonName,xlate('OK'))
        remove(thisnode,this);
    end
end

%% CTRL-C
if ed.isControlDown && ed.getKeyCode == ed.VK_C
    copynode(thisnode,this);
end

%% CTRL_V
if ed.isControlDown && ed.getKeyCode == ed.VK_V
    objnode = this.Root.TsViewer.Clipboard;
    if isempty(thisnode) || isempty(thisnode.up) || isempty(objnode)
        return
    end
    if strcmp(class(objnode),'tsguis.tsnode') && isa(thisnode,'tsguis.tscollectionNode')
        %  if collection node is selected for a timeseries node in
        %  clipboard , paste underneath..
        Target = thisnode;
    elseif strcmp(class(objnode),'tsguis.tsnode') && isa(thisnode.up,'tsguis.tscollectionNode')
        Target = thisnode.up;
    elseif ~isempty(objnode.getParentNode)
        %paste underneath the "parent" node
        Target = objnode.getParentNode;
    else
        %paste under the parent, but "objnode" (the copied node) was detached
        % this can happen if it was deleted after copying
        if strcmp(class(thisnode),'tsguis.tscollectionNode') || strcmp(class(thisnode),'tsguis.tsnode')
            viewer = tsguis.tsviewer;
            Target = viewer.TSnode;
        else
            %simulink node
            viewer = tsguis.tsviewer;
            Target = viewer.SimulinkTSnode;
        end
    end

    ButtonName = questdlg(sprintf('A copy of object ''%s'' will be added to ''%s''. Do you want to proceed?',...
        objnode.Label,Target.Label), xlate('Confirm Paste'), xlate('OK'),xlate('Cancel'),xlate('OK'));
    ButtonName = xlate(ButtonName);
    if strcmp(ButtonName,xlate('OK'))
        pastenode(Target,this);
    end
end
