function this = TreeManager(varargin)
% TREEMANAGER Constructor for @TreeManager object

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/02/06 20:00:18 $

% Create class instance
this = explorer.TreeManager;

% Create the root node (Workspace) object.
this.Root = explorer.Workspace;

% Create explorer
this.ExplorerPanel = awtcreate( 'com.mathworks.toolbox.control.explorer.ExplorerPanel', ...
                                'Lcom/mathworks/toolbox/control/explorer/ExplorerTreeNode;', ...
                                this.Root.getTreeNodeInterface );
this.Explorer      = awtcreate( 'com.mathworks.toolbox.control.explorer.Explorer', ...
                                'Lcom/mathworks/toolbox/control/explorer/ExplorerPanel;', ...
                                this.ExplorerPanel );

% Add Java related callbacks
this.addCallbacks;

% Add UDD related listeners
this.addListeners

% Initially select the top node
this.ExplorerPanel.setSelected( this.Root.getTreeNodeInterface );
