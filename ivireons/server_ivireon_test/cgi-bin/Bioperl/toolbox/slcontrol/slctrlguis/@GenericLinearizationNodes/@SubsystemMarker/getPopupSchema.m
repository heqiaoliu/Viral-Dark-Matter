function Menu = getPopupSchema(this,manager) %#ok<INUSD>
% BUILDPOPUPMENU

% Author(s): John Glass
% Revised: 
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2008/12/04 23:27:04 $

Menu = javaObjectEDT('com.mathworks.mwswing.MJPopupMenu',...
                    ctrlMsgUtils.message('Slcontrol:linearizationtask:LinearizationInspector'));

str = ctrlMsgUtils.message('Slcontrol:linearizationtask:ShowBlocksInLinearizationPath');
item1 = javaObjectEDT('com.mathworks.mwswing.MJCheckBoxMenuItem',str);
item1.setName('ShowBlocksMenuItem')
hout = slctrlguis.linearizationpanels.getBlockExplorePanel(this.ListData,this.Blocks);
item1.setState(hout.ShowBlocksInLinearization);
Menu.add(item1);

h = handle(item1, 'callbackproperties' );
h.ActionPerformedCallback = {@LocalToggleHighlight,this};
h.MouseClickedCallback = {@LocalToggleHighlight,this};

% Configure a listener to the show blocks in linearization changed event
ShowBlocksFlagListener = addlistener(hout,'ShowBlocksInLinearization',...
                        'PostSet', @(es,ed)handleShowBlocksChange(es,ed,this));
                    
h = this.Handles;
h.PopupMenuItems = item1;
h.ShowBlocksFlagListener = ShowBlocksFlagListener;
this.Handles = h;
                    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handleShowBlocksChange(es,ed,this)

val = ed.AffectedObject.ShowBlocksInLinearization;
javaMethodEDT('setState',this.Handles.PopupMenuItems(1),val)
                    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalToggleHighlight(es,ed,this)

ShowBlocksFlagListener = this.Handles.ShowBlocksFlagListener;
ShowBlocksFlagListener.Enabled = false;
hout = slctrlguis.linearizationpanels.getBlockExplorePanel();
setShowBlocksInLinearization(hout,es.getState);
ShowBlocksFlagListener.Enabled = true;