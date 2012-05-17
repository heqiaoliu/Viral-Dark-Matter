function [menubar, toolbar] = getMenuToolBarSchema(this, manager)
% GETMENUTOOLBARSCHEMA Create menubar and toolbar.  Also, set the callbacks
% for the menu items and toolbar buttons.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2008/08/22 20:25:41 $

% Create menubar
menubar = manager.getMenuBar( this.getGUIResources );
% Create toolbar
toolbar = manager.getToolBar( this.getGUIResources );
                                              
% Load Menu
h = handle( menubar.getMenuItem('open'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalLoad, this, manager };

% Save Menu
h = handle( menubar.getMenuItem('save'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalSave, this, manager };

% Close Menu
h = handle( menubar.getMenuItem('close'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalClose, this, manager };

% export Menu
h = handle( menubar.getMenuItem('export'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalExport, this.sisodb };

% undo Menu
h = handle( menubar.getMenuItem('undo'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalUndo, this.sisodb };
awtinvoke( menubar.getMenuItem('undo'),'setEnabled(Z)',false);

% redo Menu
h = handle( menubar.getMenuItem('redo'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalRedo, this.sisodb };
awtinvoke( menubar.getMenuItem('redo'),'setEnabled(Z)',false);

% Preference Menu
h = handle( menubar.getMenuItem('prefs'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalEditPrefs, this.sisodb };

% About
h = handle( menubar.getMenuItem('about'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalAbout, this, manager };


% TOOLBAR

% Load Button
h = handle( toolbar.getToolbarButton('open'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalLoad, this, manager };

% Save Button
h = handle( toolbar.getToolbarButton('save'), 'callbackproperties' );
h.ActionPerformedCallback = { @LocalSave, this, manager };

% Undo Button
h = handle( toolbar.getToolbarButton('undo'), 'callbackproperties' );
h.ActionPerformedCallback = {@LocalUndo, this.sisodb };
awtinvoke( toolbar.getToolbarButton('undo'),'setEnabled(Z)',false);

% Redo Button
h = handle( toolbar.getToolbarButton('redo'), 'callbackproperties' );
h.ActionPerformedCallback = {@LocalRedo, this.sisodb };
awtinvoke( toolbar.getToolbarButton('redo'),'setEnabled(Z)',false);

% Install listener for enable state
Recorder = this.sisodb.EventManager.EventRecorder;
this.Handles.UndoListener = handle.listener(Recorder,findprop(Recorder,'Undo'),...
   'PropertyPostSet',{@LocalDoMenu menubar.getMenuItem('undo') toolbar.getToolbarButton('undo') 1});

this.Handles.RedoListener = handle.listener(Recorder,findprop(Recorder,'Redo'),...
   'PropertyPostSet',{@LocalDoMenu menubar.getMenuItem('redo') toolbar.getToolbarButton('redo') 0});




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalLoad
function LocalLoad(es,ed,this, manager)
manager.loadfrom(this.up);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalSave
function LocalSave(es,ed,this, manager)
manager.saveas(this.up)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalClose
function LocalClose(es,ed,this,manager)
manager.Explorer.doClose;



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalUndo 
function LocalUndo(hMenu,event,sisodb)
% Undo callback
StackLength = length(sisodb.EventManager.EventRecorder.Undo);
% Prevent undo if stack is less then desired length g229541
if StackLength > 1
    sisodb.EventManager.undo;
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalRedo
function LocalRedo(hMenu,event,sisodb)
% Redo callback
StackLength = length(sisodb.EventManager.EventRecorder.Redo);
% Prevent redo if stack is less then desired length g229541
if StackLength > 0
   sisodb.EventManager.redo;
end


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalDoMenu
function LocalDoMenu(hProp,event,hMenu,hToolBar,MinStackLength)
% Update menu state and label
Stack = event.NewValue;
if length(Stack)<=MinStackLength
    % Empty stack
    hMenu.setText(sprintf('&%s',xlate(get(hProp,'Name'))));
    awtinvoke(hMenu,'setEnabled(Z)',false);
    awtinvoke(hToolBar,'setEnabled(Z)',false);
else
    % Get last transaction's name
    ActionName = Stack(end).Name;
    Label = sprintf('&%s %s',xlate(get(hProp,'Name')),ActionName);
    hMenu.setText(Label)
    awtinvoke(hMenu,'setEnabled(Z)',true);
    awtinvoke(hToolBar,'setEnabled(Z)',true);
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalEditPrefs
function LocalEditPrefs(es,ed,sisodb)
% Edit SISO Tool prefs 
edit(sisodb.Preferences); 


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalExport
function LocalExport(es,ed,sisodb)
% Opens export dialog
sisodb.DesignTask.showExportDialog;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LocalAbout
function LocalAbout(hSrc, hData, this, manager)
import javax.swing.JOptionPane;

% Get the version number from ver
verdata = ver('control');
% Create the version message
message = sprintf('%s %s\n%s', verdata.Name, verdata.Version, ...
                            sprintf('Copyright 1986 - %s, The MathWorks, Inc.',verdata.Date(end-3:end)));
awtinvoke('com.mathworks.mwswing.MJOptionPane', ...
        'showMessageDialog(Ljava/awt/Component;Ljava/lang/Object;Ljava/lang/String;I)', ...
        manager.Explorer, message, xlate('About Control System Toolbox'), com.mathworks.mwswing.MJOptionPane.PLAIN_MESSAGE);
