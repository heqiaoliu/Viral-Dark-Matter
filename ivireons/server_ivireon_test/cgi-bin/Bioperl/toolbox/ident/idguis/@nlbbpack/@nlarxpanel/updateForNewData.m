function updateForNewData(this,data)
% udpate nlarx panels for I/O names from the new data.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/31 06:12:52 $

% update model I/O names
nlarxmodel = this.NlarxModel;
nlarxmodel.InputName = data.InputName;
if isequal(nlarxmodel.OutputName,data.OutputName)
    outputchanged = false;
else
    outputchanged = true;
    nlarxmodel.OutputName = data.OutputName;
end
%this.NlarxModel = nlarxmodel; % G337953
this.updateModel(nlarxmodel);

selind = 1;
if outputchanged
    selind = this.ActiveOutputIndex;
    this.ActiveOutputIndex = 1; %reset active output to 1 so that combo selection change callback does not fire
    this.setOutputCombo; %sets selected index to 1 (i.e. 0 in java).

    % restore active output index:
    this.ActiveOutputIndex = selind;
    javaMethodEDT('setSelectedIndex',this.jModelOutputCombo,selind-1);
end

% update reg table column 1 (I/O names):
this.updateRegressorsPanel(nlarxmodel,selind);

% update regressor dialogs
if this.RegEditDialog.jMainPanel.isVisible
    this.RegEditDialog.updateDialogContents;
end

hh = this.RegEditDialog.CustomRegEditDialog;
if ~isempty(hh) && ishandle(hh)
    hh.updateDialogContents;
end

% Note: The nonlin options "Object" does not need to be updated. 
