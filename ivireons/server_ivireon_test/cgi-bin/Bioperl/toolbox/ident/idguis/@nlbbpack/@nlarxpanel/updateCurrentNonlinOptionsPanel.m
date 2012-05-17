function updateCurrentNonlinOptionsPanel(this)
% Update the NonlinOptionsPanels property.
% Update the widget states/values on the current nonlin options panel by
% reading values from the data (options) object.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:50:27 $

Ind = this.getCurrentOutputIndex;
nl = this.NlarxModel.Nonlinearity(Ind);
Name = localGetNonlinOptionsName(nl);
IDs = cell(this.jMainPanel.getKnownNonlinTypeIDs);
[tF,Loc] = ismember(Name,IDs);

if Loc==0
    ctrlMsgUtils.error('Ident:idguis:invalidNonlinType',Name)
else
    javaMethodEDT('setSelectedIndex',this.jNonlinCombo,Loc-1);
end

% The panel to be updated has its options object. Ask
% this object to refresh the panel
this.NonlinOptionsPanels.(Name).refreshPanelWidgets;

%-------------------------------------------------------------------------
function Name = localGetNonlinOptionsName(nl)

%todo: remove multiple names

Name = lower(class(nl));

if strcmp(Name,'treepartition')
    Name = 'tree';
elseif strcmp(Name,'sigmoidnet')
    Name = 'sigmoid';
elseif strcmp(Name,'customnet')
    Name = 'custom';
end
