function show(this)
%Show the dialog after populating the list of model names

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 06:13:38 $


%prepare input contents for the dialog's popup menu
Type = this.Owner.getCurrentModelTypeID;
[x,xchar] = this.Owner.getListOfInitialModels;
if isempty(xchar)
    if strcmp(Type,'idnlarx')
        Name = 'Nonlinear ARX';
    else
        Name = 'Hammerstein-Wiener';
    end
    errordlg(sprintf('No %s models of matching dimensions found. Estimate or import a model first.',Name),...
        'Model Initialization','modal')
    return
end

h = this.jDialog;
L = this.jOwnerFrame.getLocation;
L.translate(340,187);

h.setLocation(L);
h.setComboList(x); %event thread method

% always bring up the dialog in default state
this.Data.(Type).SelectedIndex = 1;
this.Data.(Type).ExistingModels = xchar;
%this.Data.idnlhw.SelectedIndex = 1;

javaMethodEDT('setSelectedIndex',this.jCombo,0); 
javaMethodEDT('setSelected',this.jCheck,false); 

this.refreshInfoOnModel(Type,1);

javaMethodEDT('show',this.jDialog);
