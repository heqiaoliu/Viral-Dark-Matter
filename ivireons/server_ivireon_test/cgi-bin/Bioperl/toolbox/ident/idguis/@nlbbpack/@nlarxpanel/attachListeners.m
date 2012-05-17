function attachListeners(this,varargin)
% Attach listeners to nlarx panel options

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.11 $ $Date: 2009/07/09 20:52:15 $

h = handle(this.jModelOutputCombo,'CallbackProperties');
L1 = handle.listener(h,'ActionPerformed', {@LocalOutputSelectionChanged this});

h = handle(this.jEditRegButton,'CallbackProperties');
L2 = handle.listener(h,'ActionPerformed',{@LocalShowRegressorDialog this});

h = handle(this.jInferDelayButton,'CallbackProperties');
L3 = handle.listener(h,'ActionPerformed',{@LocalShowDelayInspector this});

h = handle(this.jNonlinCombo,'CallbackProperties');
L4 = handle.listener(h,'ActionPerformed', {@LocalNonlinSelectionChanged this});

h = handle(this.jIncludeLinearModelCheckBox,'CallbackProperties');
L5 = handle.listener(h,'ItemStateChanged', {@LocalIncludeLinearModel this});

h = handle(this.jApplySettingsCheckBox,'CallbackProperties');
L6 = handle.listener(h,'ItemStateChanged', {@LocalApplyToAllOutputs this});

h = handle(this.jRegTableModel,'CallbackProperties');
L7 = handle.listener(h,'TableChanged', {@LocalRegTableChanged this});

L8 = handle.listener(this,this.findprop('NlarxModel'),'PropertyPostSet',...
    {@LocalModelChangedCallback this});

this.Listeners = [L1,L2,L3,L4,L5,L6,L7,L8];

%--------------------------------------------------------------------------
function LocalOutputSelectionChanged(es,ed,this)

%Rules:
%When model output changes, the nonlin type and corresponding options in
%the GUI are unilaterally updated by reading the corresponding values from
%the NlarxModel object.
%
% What happens to the GUI states of the other nonlinearities? I guess they
% could be left "as is" (as set, if at all, for a previous output
% selection). This is under the assumption that users are "likely" to
% configure a particular choice of nonlinearity in a certain way that does
% not depend upon the choice of output channel. This also means less work.
%   (The other choice is to reset all other options to their default
%   states. Not doing that here).

Ind = ed.JavaEvent.getSource.getSelectedIndex+1;

if (Ind==this.ActiveOutputIndex) || (Ind<1)
    return;
end

%1a. first update the model for ActiveOutputIndex output
%1b. update ActiveOutputIndex
this.updateModelforActiveOutput;

%2. refresh the contents of the dialog for current output
this.updatePanelsforNewOutput;

%-------------------------------------------------------------------------
function LocalRegTableChanged(es,ed,this)
% regressor table updated

col = ed.JavaEvent.getColumn   + 1;
row = ed.JavaEvent.getFirstRow + 1;
m = this.NlarxModel;
[ny,nu] = size(m);

% React only to table cell changes by the user.
if ((col==0) || (col==1) || (col==4) || (row==1) || (row==(nu+2)))
    return;
end

tablemodel = ed.Source;
charvalue = tablemodel.getValueAt(row-1,col-1);
Ind = this.getCurrentOutputIndex;

alldata = cell(tablemodel.getData);
try
    if isempty(charvalue)
        ctrlMsgUtils.error('Ident:idguis:nlarxInvalidOrder')
    end
    
    val = evalin('base',charvalue); %evaluated the entered expression
    if ~isnonnegintscalar(val)
        ctrlMsgUtils.error('Ident:idguis:nlarxInvalidOrder')
    end
    % we have a valid scalar; update model
    m = nlbbpack.updateModelOrder(m,row,col,val,Ind*(~this.applyToAllOutputs));
    this.updateModel(m);
    
    %update strings in table (immediate apply)
    str = nlbbpack.getRegExpr(m,row,Ind);
    alldata{row,col} = int2str(val);
    alldata{row,4} = str;
catch E
    errordlg(idlasterr(E),'Invalid IDNLARX Model Order','modal')
    oldval = nlbbpack.getModelOrderInt(m,row,col,Ind);
    alldata{row,col} = int2str(oldval);
end

tablemodel.setData(nlutilspack.matlab2java(alldata),[0,nu+1],row-1,row-1);

if this.RegEditDialog.jMainPanel.isVisible
    this.RegEditDialog.updateDialogContents;
end

%-------------------------------------------------------------------------
function LocalShowRegressorDialog(es,ed,this)
% show regressor dialog

this.RegEditDialog.show;

%--------------------------------------------------------------------------
function LocalNonlinSelectionChanged(es,ed,this)

% If nonlin type is switched, the nonlin properties are read-off from the
% corresponding options object. No change in these options happens. The
% NlarxModel is unilaterally updated based on the selected nonlin type and
% the corresponding options.
%this.updateModelforActiveOutput;
%this.updateCurrentNonlinOptionsPanel;
try
    this.updateModelforActiveOutput;
catch E
    errordlg(idlasterr(E),'Nonlinearity Update Failed','modal')
end
%--------------------------------------------------------------------------
function LocalIncludeLinearModel(es,ed,this)

%disp ('include linear model changed')

%OutputNum = this.getCurrentOutputIndex;
thisNL = char(this.jMainPanel.getCurrentNonlinID);
nl = this.NonlinOptionsPanels.(thisNL).Object;

%m = this.NlarxModel;
if ismember(class(nl),{'neuralnet','linear','treepartition'})
    return
end

if (ed.JavaEvent.getStateChange==java.awt.event.ItemEvent.DESELECTED)
    nl.LinearTerm = 'off';
else
    nl.LinearTerm = 'on';
end
%this.NlarxModel = []; %todo: UDD bug?
%this.NlarxModel = m;
this.NonlinOptionsPanels.(thisNL).Object = nl;
nlbbpack.sendModelChangedEvent('idnlarx');

%--------------------------------------------------------------------------
function LocalApplyToAllOutputs(es,ed,this)
% Callback to checkbox for apply settings to all outputs.
% disable output combo box
% disable edit regressor button (need not close regressor dialog)
% update orders and NL info right away

if (ed.JavaEvent.getStateChange==java.awt.event.ItemEvent.DESELECTED)
    javaMethodEDT('setEnabled',this.jEditRegButton,true);
    javaMethodEDT('setEnabled',this.jModelOutputCombo,true);
    this.applyToAllOutputs = false;
else
    status = LocalCheckIfConformityAcceptable(this);
    
    if status
        javaMethodEDT('setEnabled',this.jEditRegButton,false);
        javaMethodEDT('setEnabled',this.jModelOutputCombo,false);
        if this.RegEditDialog.jMainPanel.isVisible
            javaMethodEDT('setVisible',this.RegEditDialog.jMainPanel,false);
        end
        this.applyToAllOutputs = true;
        this.conformOutputs;
        nlbbpack.sendModelChangedEvent('idnlarx');
    else
        javaMethodEDT('doClick',this.jApplySettingsCheckBox);
    end
end

%--------------------------------------------------------------------------
function LocalShowDelayInspector(es,ed,this)

messenger = nlutilspack.messenger;
ze = messenger.getCurrentEstimationData; %estimation data

close(findall(0,'type','figure','tag','ident:data:delayinspectiontool'))

Orders = {this.NlarxModel.na,this.NlarxModel.nb};

nlutilspack.delayestim(this,ze,Orders);

%--------------------------------------------------------------------------
function status = LocalCheckIfConformityAcceptable(this)

status = true;
m = this.NlarxModel;

if any(~cellfun('isempty',m.CustomRegressors))
    % there are custom regressors in at least one output
    msg  = sprintf('%s %s\n\n%s',...
        'At least one model output contains custom regressors.',...
        'This action will cause the custom regressors for all outputs to be replaced by those of the current output.',...
        'Do you want to accept this setting?');
    btnname = questdlg(msg,'Apply Setting to All Outputs Question','Yes','No','Yes');
    status = strcmpi(btnname,'Yes');
end

%--------------------------------------------------------------------------
function LocalModelChangedCallback(es,ed,this)
% IDNLARX model's properties were changed

m = this.NlarxModel;

if ~isa(m,'double') 
    I = isestimated(m);
    if I==0 || (I==-1 && ~isinitialized(m.nl))
        % m contained structural changes
        nlbbpack.sendModelChangedEvent('idnlarx');
    end
end
