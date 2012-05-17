function menu = getPopupSchema(this, manager)
% GETPOPUPSCHEMA Constructs the default popup menu

% Author(s): John Glass, Bora Eryilmaz
% Revised:
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2009/11/09 16:34:37 $

menu  = awtcreate( 'com.mathworks.mwswing.MJPopupMenu', ...
                   'Ljava.lang.String;', 'Default Menu' );
item1 = awtcreate( 'com.mathworks.mwswing.MJMenu', ...
                   'Ljava.lang.String;', xlate('New','-s') );
item2 = awtcreate( 'com.mathworks.mwswing.MJMenuItem', ...
                   'Ljava.lang.String;', xlate('Task...') );
item3 = awtcreate( 'com.mathworks.mwswing.MJMenuItem', ...
                   'Ljava.lang.String;', xlate('Save...') );
item4 = awtcreate( 'com.mathworks.mwswing.MJMenuItem', ...
                   'Ljava.lang.String;', xlate('Delete') );
item5 = awtcreate( 'com.mathworks.mwswing.MJMenuItem', ...
                   'Ljava.lang.String;', xlate('Rename') );

menu.add( item1 ); item1.add( item2 );
menu.addSeparator;
menu.add( item3 );
menu.addSeparator;
menu.add( item4 );
menu.add( item5 );

h = handle( item2, 'callbackproperties' );
fun = { @LocalNewTask, this, manager };
h.ActionPerformedCallback = fun;
h.MouseClickedCallback    = fun;

h = handle( item3, 'callbackproperties' );
fun = { @LocalSave, this, manager };
h.ActionPerformedCallback = fun;
h.MouseClickedCallback    = fun;

h = handle( item4, 'callbackproperties' );
fun = { @LocalDelete, this, manager };
h.ActionPerformedCallback = fun;
h.MouseClickedCallback    = fun;

h = handle( item5, 'callbackproperties' );
fun = { @LocalRename, this, manager };
h.ActionPerformedCallback = fun;
h.MouseClickedCallback    = fun;

% --------------------------------------------------------------------------- %
function LocalNewTask(hSrc, hData, this, manager)
% Create the new task dialog and let it handle the rest
newdlg = explorer.NewTaskDialog(this);
awtinvoke( newdlg.Dialog, 'setVisible', true )

% --------------------------------------------------------------------------- %
function LocalSave(hSrc, hData, this, manager)
manager.saveas(this)

% --------------------------------------------------------------------------- %
function LocalDelete(hSrc, hData, this, manager)
parent = this.up;
parent.removeNode(this);
manager.Explorer.setSelected(parent.getTreeNodeInterface);

% --------------------------------------------------------------------------- %
function LocalRename(hSrc, hData, this, manager)
Tree = manager.ExplorerPanel.getSelector.getTree;
Tree.startEditingAtPath(Tree.getSelectionPath);
