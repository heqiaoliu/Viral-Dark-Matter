function attachListeners(this,varargin)
% Attach listeners to widgets owned by initmodeldialog

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 06:13:34 $

h0 = this.jDialog;

h = handle(h0.getOKButton,'CallbackProperties');
L1 = handle.listener(h,'ActionPerformed', {@LocalOKButtonPressed this});

h = handle(h0.getCancelButton,'CallbackProperties');
L2 = handle.listener(h,'ActionPerformed', {@LocalCancelButtonPressed this});

h = handle(h0.getHelpButton,'CallbackProperties');
L3 = handle.listener(h,'ActionPerformed', {@LocalHelpButtonPressed });

h = handle(this.jCombo,'CallbackProperties');
L4 = handle.listener(h,'ItemStateChanged', {@LocalComboChanged this});

this.Listeners = [L1,L2,L3,L4];

%--------------------------------------------------------------------------
function LocalOKButtonPressed(es,ed,this)
% apply selected initial model

Type = this.Owner.getCurrentModelTypeID;
selInd = this.jCombo.getSelectedIndex+1;
newModelName = this.Data.(Type).ExistingModels{selInd};

algoUpdate = this.jCheck.isSelected;

this.Owner.updateForNewInitialModel(Type,newModelName,algoUpdate);

javaMethodEDT('hide',this.jDialog);

%--------------------------------------------------------------------------
function LocalCancelButtonPressed(es,ed,this)
% hide dialog

javaMethodEDT('hide',this.jDialog);


%--------------------------------------------------------------------------
function LocalHelpButtonPressed(varargin)
% show dialog help

iduihelp('nlinitialmodeldlg.htm',...
    'Help: Initial Model Specification');

%--------------------------------------------------------------------------
function LocalComboChanged(combo,ed,this)
% show dialog with list of idnlarx or idnlhw model names in popup

if (ed.JavaEvent.getStateChange==ed.JavaEvent.SELECTED)
    Mpanel = this.Owner;
    Type = Mpanel.getCurrentModelTypeID; %char(this.jMainPanel.getCurrentModelTypeID);
    Ind = this.Data.(Type).SelectionIndex;
    selInd = combo.getSelectedIndex+1;
    if (selInd==Ind) || (selInd<1)
        return;
    end
    
    % refresh info area
    this.refreshInfoOnModel(Type,selInd);
end

