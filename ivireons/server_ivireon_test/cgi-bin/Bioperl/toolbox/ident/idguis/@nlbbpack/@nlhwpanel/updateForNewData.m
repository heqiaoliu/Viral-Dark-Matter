function updateForNewData(this,data)
% udpate nlhw panels for I/O names from the new data.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/31 06:13:10 $

% update model I/O names
nlhwmodel = this.NlhwModel;
nlhwmodel.InputName = data.InputName;
if isequal(nlhwmodel.OutputName,data.OutputName)
    outputchanged = false;
else
    outputchanged = true;
    nlhwmodel.OutputName = data.OutputName;
end

this.updateModel(nlhwmodel);

%selind = 1;
if outputchanged
    selind = this.ActiveOutputIndex;
    this.ActiveOutputIndex = 1; %reset active output to 1 so that combo selection change callback does not fire
    this.setOutputCombo; %sets selected index to 1 (i.e. 0 in java).

    % restore active output index:
    this.ActiveOutputIndex = selind;
    javaMethodEDT('setSelectedIndex',this.jModelOutputCombo,selind-1);
end

% update tables on both tabbed panels
this.updateNonlinPanelContents;
this.updateLinearPanelforNewOutput;
%this.updateRegressorsPanel(nlarxmodel,selind);

