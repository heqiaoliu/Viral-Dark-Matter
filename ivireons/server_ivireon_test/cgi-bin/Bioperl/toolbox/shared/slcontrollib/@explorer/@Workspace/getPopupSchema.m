function menu = getPopupSchema(this, manager)
% GETPOPUPSCHEMA Constructs node's popup menu

% Author(s): John Glass, B. Eryilmaz
% Revised:
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.6.10 $ $Date: 2008/01/15 18:56:51 $

menu  = awtcreate( 'com.mathworks.mwswing.MJPopupMenu', ...
                   'Ljava.lang.String;', 'Default Menu' );
item1 = awtcreate( 'com.mathworks.mwswing.MJMenu', ...
                   'Ljava.lang.String;', xlate('New', '-s') );
item2 = awtcreate( 'com.mathworks.mwswing.MJMenuItem', ...
                   'Ljava.lang.String;', xlate('Project...') );
item3 = awtcreate( 'com.mathworks.mwswing.MJMenuItem', ...
                   'Ljava.lang.String;', xlate('Task...') );
item4 = awtcreate( 'com.mathworks.mwswing.MJMenuItem', ...
                   'Ljava.lang.String;', xlate('Load...') );
item5 = awtcreate( 'com.mathworks.mwswing.MJMenuItem', ...
                   'Ljava.lang.String;', xlate('Save...') );

menu.add( item1 ); item1.add( item2 ); item1.add( item3 );
menu.addSeparator;
menu.add( item4 );
menu.add( item5 );

h = handle( item2, 'callbackproperties' );
fun = { @LocalNewProject, this, manager };
h.ActionPerformedCallback = fun;
h.MouseClickedCallback    = fun;

h = handle( item3, 'callbackproperties' );
fun = { @LocalNewTask this, manager };
h.ActionPerformedCallback = fun;
h.MouseClickedCallback    = fun;

h = handle( item4, 'callbackproperties' );
fun = { @LocalLoad, this, manager };
h.ActionPerformedCallback = fun;
h.MouseClickedCallback    = fun;

h = handle( item5, 'callbackproperties' );
fun = { @LocalSave, this, manager };
h.ActionPerformedCallback = fun;
h.MouseClickedCallback    = fun;

% --------------------------------------------------------------------------- %
function LocalNewProject(hSrc, hData, this, manager)
% Create the new project dialog and let it handle the rest
newdlg = explorer.NewProjectDialog(this);
awtinvoke( newdlg.Dialog, 'setVisible', true )

% --------------------------------------------------------------------------- %
function LocalNewTask(hSrc, hData, this, manager)
% Create the new task dialog and let it handle the rest
% Find non-MPC projects
theseChildren = setdiff(this.getChildren, ...
        [this.find('-class','mpcnodes.MPCGUI','-depth',1);...
         this.find('-class','controlnodes.SISODesignTask','-depth',1);]);
if isempty(theseChildren)
  newdlg = explorer.NewProjectDialog(this);
else
  newdlg = explorer.NewTaskDialog(this);
end
awtinvoke( newdlg.Dialog, 'setVisible', true )

% --------------------------------------------------------------------------- %
function LocalLoad(hSrc, hData, this, manager)
manager.loadfrom(this.getChildren);

% --------------------------------------------------------------------------- %
function LocalSave(hSrc, hData, this, manager)
manager.saveas(this.getChildren)
