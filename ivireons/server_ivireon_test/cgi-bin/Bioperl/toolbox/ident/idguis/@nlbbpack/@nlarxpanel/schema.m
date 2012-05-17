function schema
% SCHEMA  Defines properties for nlarxpanel class

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/02/06 19:52:02 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('nlbbpack');

% Construct class
c = schema.class(hCreateInPackage, 'nlarxpanel');

% listener (for estimate button etc)
schema.prop(c,'Listeners','MATLAB array');

% handle to main java panel for this class
schema.prop(c,'jMainPanel','com.mathworks.toolbox.ident.nnbbgui.ModelTypeMiddlePanelOfTypeNLARX'); 

% handles to java controls
schema.prop(c,'jModelOutputCombo','com.mathworks.mwswing.MJComboBox');
schema.prop(c,'jApplySettingsCheckBox','com.mathworks.mwswing.MJCheckBox');

%% regressor panel 
schema.prop(c,'jInferDelayButton','com.mathworks.mwswing.MJButton');
schema.prop(c,'jEditRegButton','com.mathworks.mwswing.MJButton');
schema.prop(c,'jRegTable','com.mathworks.toolbox.ident.nnbbgui.ModelTypeMiddlePanelOfTypeNLARX$NlArxTable');
schema.prop(c,'jRegTableModel','com.mathworks.toolbox.ident.nnbbgui.ModelTypeMiddlePanelOfTypeNLARX$NlArxTableModel');

%% model properties panel
schema.prop(c,'jNonlinCombo','com.mathworks.mwswing.MJComboBox'); %NL type
schema.prop(c,'jIncludeLinearModelCheckBox','com.mathworks.mwswing.MJCheckBox'); 

% handles to udd classes for dialog and subpanels
schema.prop(c,'RegEditDialog','handle');
p = schema.prop(c,'NonlinOptionsPanels','MATLAB array');
validTypes = nlbbpack.getNlarxNonlinTypes('id');
val = cell(1,length(validTypes));
p.FactoryValue = cell2struct(val,validTypes,2);

% is data single output? 
p = schema.prop(c,'isSingleOutput','bool'); 
p.FactoryValue = true;

% store nlarx model data
p = schema.prop(c,'NlarxModel','MATLAB array');
p.AccessFlags.AbortSet = 'off';

p = schema.prop(c,'LatestEstimModelName','string');
p.FactoryValue = '';

%Note: this is not same as getCurrentOutputIndex, which returns the current
%combobox value. This property is updated to agree with combobox value only
%after data for output before combox change has been stored.
schema.prop(c,'ActiveOutputIndex','double');

p = schema.prop(c,'applyToAllOutputs','bool');
p.FactoryValue = false;
