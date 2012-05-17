function this = TreeManager(rootnode,varargin)
% TREEMANAGER Constructor for @TreeManager object

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.12 $ $Date: 2008/06/24 17:14:56 $

import com.mathworks.toolbox.timeseries.*;
import java.awt.dnd.*
import java.awt.*;
import javax.swing.tree.*;

mlock 
persistent isSimulinkInstalled;
if isempty(isSimulinkInstalled)
    isSimulinkInstalled = license('test', 'Simulink') && exist('bdclose', 'file');
end


% TO DO: Tree manager should create the tree not the tsviewer constructior

%% Create class instance
this = tsexplorer.TreeManager;

% Assign specified properties
for k=1:(nargin-1)/2
    set(this,varargin{2*k-1},varargin{2*k});
end

% Create the margin buttons
this.Margin = [uipanel('Parent',this.Figure,'Units','Characters'),...
               uipanel('Parent',this.Figure,'Units','Characters')];
set(this.Margin,'HighlightColor',get(this.Margin(1),'BackgroundColor'),...
    'ShadowColor',get(this.Margin(1),'BackgroundColor'))
set(this.Margin(1),'ButtonDownFcn',{@localMarginDown this 1})
set(this.Margin(2),'ButtonDownFcn',{@localMarginDown this 2})
this.DragMargin = {[],[]};

% Create the tree
if isempty(this.Root)
    this.Root = rootnode;
end
[this.Tree, this.Treepanel] = ...
     uitree('v0',this.Figure,'Root',rootnode.getTreeNodeInterface);
% Remove component resizing listener since we are not using normalized
% units (performance reasons). Exclode MAC g289891
if ~ismac
    L = get(this.Treepanel,'Listeners__');
    for k=1:length(L)
        if strcmp(L(k).SourceObject.Name,'PixelBounds')
            L(k).Enable = 'off'; %#ok<NASGU>
            break
        end
    end
end
this.Tree.setDndEnabled(true); % Enable drag & drop
set(this.Treepanel,'Units','Characters','Hittest','off')
this.Tree.getTree.setCursor(java.awt.Cursor(java.awt.Cursor.DEFAULT_CURSOR));

% Prevent nodes being shaded in unix
if isunix % Do not use on pc since Color.white may not look ok in high contrast mode
    this.Tree.getTree.getCellRenderer.setBackgroundNonSelectionColor(Color.white); 
end

% Figure resize behavior
set(this.Figure,'Units','Characters','ResizeFcn',{@localResize this})

% Help panel visibility listener
this.HelpListener = handle.listener(this,this.findprop('HelpShowing'),...
    'PropertyPostSet',{@localHelpVisCallback this});

% Show a lower scrollbar
this.Tree.getScrollPane.setHorizontalScrollBarPolicy(32)

% treemanager dropCallback method should be the target of drops
if isSimulinkInstalled
    vrootpath =  rootnode.down.right.right.getTreeNodeInterface;
else
    vrootpath = rootnode.down.right.getTreeNodeInterface;
end
if isjava(rootnode.getTreeNodeInterface)   
    tsRootPath =  TreePath([rootnode.getTreeNodeInterface;...
        rootnode.down.getTreeNodeInterface]);
    viewRootPath = TreePath([rootnode.getTreeNodeInterface; vrootpath]);
else
    tsRootPath =  TreePath([java(rootnode.getTreeNodeInterface);...
        java(rootnode.down.getTreeNodeInterface)]);
    viewRootPath = TreePath([java(rootnode.getTreeNodeInterface);...
        java(vrootpath)]);
end
dropAdaptor = TreeDropAdaptor(this,'dropCallback',this.Tree,...
    tsRootPath,viewRootPath);
dropHandler = DropTarget(this.Tree.getTree,dropAdaptor);
this.Tree.getTree.setDropTarget(dropHandler);
 
% Add Java related callbacks
this.addCallbacks;

% Build node context menu listener 
this.Cmenulistener = uitreePopupListener(this.Tree.getTree,this);

% Add UDD related listeners
this.addListeners

% Size it
localResize(this.Figure,[],this)

function localResize(es,ed,h)

% Main figure resize fcn
 
% Enforce minimum width to prevent panels uicontrols showing outside their
% permited extent
minwidth = h.Minwidth;
minheight = h.Minheight;
minmarginwidth = h.Minmarginwidth;

% Get sizes
pos = hgconvertunits(es,get(es,'Position'),get(es,'Units'),'Characters',es);
screesize = hgconvertunits(es,get(0,'ScreenSize'),'pixels','Characters',es);
if ~isempty(h.Panel)
    
    % Enforce minimum height
    if pos(4)<minheight
        pos = [pos(1:3) minheight];
        pos = localResetFigPos(pos,screesize);
        set(es,'Position',pos);
    end
    
    % If the main panel size < minimum: First shrink the margins to honor
    % the new requested size up to a minimum of 5 characters. After that,
    % force the figure back to its mininum width
    if pos(3)-h.DialogPosition-strcmp(h.HelpShowing,'on')*...
            h.HelpDialogPosition-1 <= minwidth
        marginwith = max(max(0.5*(pos(3)-1-minwidth),5),minmarginwidth); 
        pos(3) = minwidth+1+2*marginwith;
        h.HelpDialogPosition = marginwith;
        h.DialogPosition = marginwith;
        pos = localResetFigPos(pos,screesize);
        % Figure must be at its final size for hgconvertunits to handle the
        % normalized case
        set(es,'Position',pos);        
        pnlpos = hgconvertunits(get(h.Panel,'Parent'),...
             [h.DialogPosition 0 pos(3)-marginwith-1-strcmp(h.HelpShowing,'on')*h.HelpDialogPosition pos(4)],...
            'Characters',get(h.Panel,'Units'),get(h.Panel,'Parent'));
    else   
        pnlpos = hgconvertunits(get(h.Panel,'Parent'),...
           [max(h.DialogPosition,1) 0 pos(3)-max(h.DialogPosition,1)-...
           strcmp(h.HelpShowing,'on')*h.HelpDialogPosition-1 pos(4)],...
           'Characters',get(h.Panel,'Units'),get(h.Panel,'Parent'));
    end    
    set(h.Panel,'Position',pnlpos)
end

set(h.Treepanel,'Position',[0 0 max(1,h.DialogPosition-1) pos(4)])
set(h.Margin(1),'Position',[max(1,h.DialogPosition-1) 0 1 pos(4)])
if strcmp(h.HelpShowing,'on')
     set(h.HelpPanel,'Position',[max(1,pos(3)-h.HelpDialogPosition) 0 ...
           h.HelpDialogPosition pos(4)])
     set(h.Margin(2),'Position',[max(1,pos(3)-h.HelpDialogPosition-1) 0 ...
         1 pos(4)])
end   

function localMarginDown(es,ed,this,pos)

import javax.swing.*;

set(this.Figure,'WindowButtonMotionFcn',{@localSlideMargin this pos},'WindowButtonUpFcn',...
    {@localMarginUp this pos},'BusyAction','Cancel','Interruptible','off','Pointer','Left');
DragMarginPos = get(this.Margin(pos),'Position');
DragMarginPos(3) = DragMarginPos(3)/2;

% The drag margin must be a java component in order be of sufficiently
% heavy weight to appear in front of the other javacomponents. It must be
% recreated each click so that is never goes behind the help panel
thisButton = JButton;
thisButton.setBackground(java.awt.Color.gray);
thisButton.setBorder(BorderFactory.createEmptyBorder);
[junk,this.DragMargin{pos}] = javacomponent(thisButton,[0 0 1 1],this.Figure);    
set(this.DragMargin{pos},'Parent',this.Figure,'Units',get(this.Margin(pos),'Units'),...
    'Position',DragMarginPos);


function localMarginUp(es,ed,this,pos)

set(this.Figure,'WindowButtonMotionFcn',{@tshoverfig this},'WindowButtonUpFcn','',...
    'Pointer','Arrow','Interruptible','on');
set(this.DragMargin{pos},'Visible','off')
marginPos = get(this.DragMargin{pos},'Position');
figpos = get(this.Figure,'Position');
if pos==1
    dropMiddleWindowSize = figpos(3)-marginPos(1)-strcmp(this.HelpShowing,'on')*...
            this.HelpDialogPosition;
    if dropMiddleWindowSize<=81
        this.DialogPosition = min(marginPos(1),78-strcmp(this.HelpShowing,'on')*this.HelpDialogPosition);
    else
        this.DialogPosition = marginPos(1);
    end
else
    dropMiddleWindowSize = marginPos(1)-this.DialogPosition;
    if dropMiddleWindowSize<=81
        this.HelpDialogPosition = min(max(1,figpos(3)-marginPos(1)),...
            figpos(3)-this.DialogPosition-82);
    else
        this.HelpDialogPosition = max(1,figpos(3)-marginPos(1));
    end
end
localResize(this.Figure,ed,this)

function localSlideMargin(es,ed,this,pos)

thispt = get(this.Figure,'CurrentPoint');
thispos = get(this.DragMargin{pos},'Position');
set(this.DragMargin{pos},'Position',[thispt(1) thispos(2:end)]);

function posout = localResetFigPos(figpos,refpos)

% Moves the figure position to ensure that it remains within the screen
shiftH = 0;
shiftV = 0;
if figpos(1)<=0
    shiftH = -figpos(1)+5;
elseif figpos(1)+figpos(3)+2>refpos(3)
    shiftH = -figpos(1)-figpos(3)+refpos(3)-5;
end
if figpos(2)<=0
    shiftV = -figpos(2)+5;
elseif figpos(2)+figpos(4)+2>refpos(4)
    shiftV = refpos(4)-figpos(2)-figpos(4)-5;
end
posout = [figpos(1)+shiftH figpos(2)+shiftV figpos(3:4)];   

% Callback for Help panel visibility
function localHelpVisCallback(es,ed,h)

localResize(h.Figure,[],h);
set(h.HelpPanel,'visible',h.HelpShowing)
set(h.Margin(2),'Visible',h.HelpShowing)

