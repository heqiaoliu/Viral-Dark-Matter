function schema
% SCHEMA  Defines properties for nlhwpanel class

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/05/19 23:04:15 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('nlbbpack');

% Construct class
c = schema.class(hCreateInPackage, 'nlhwpanel');

% listener (for estimate button etc)
schema.prop(c,'Listeners','MATLAB array');

% handle to main java panel for this class
schema.prop(c,'jMainPanel','com.mathworks.toolbox.ident.nnbbgui.ModelTypeMiddlePanelOfTypeNLHW'); 

% handles to java controls
% nonlinear props
schema.prop(c,'jNonlinTable','com.mathworks.toolbox.ident.nnbbgui.ModelTypeMiddlePanelOfTypeNLHW$NLHWTable');
schema.prop(c,'jNonlinTableModel','com.mathworks.toolbox.ident.nnbbgui.ModelTypeMiddlePanelOfTypeNLHW$NLHWTableModel');

% linear props
schema.prop(c,'jModelOutputCombo','com.mathworks.mwswing.MJComboBox');
schema.prop(c,'jApplySettingsCheckBox','com.mathworks.mwswing.MJCheckBox');
schema.prop(c,'jInferDelayButton','com.mathworks.mwswing.MJButton');
schema.prop(c,'jLinearTable','com.mathworks.mwswing.MJTable');
schema.prop(c,'jLinearTableModel','com.mathworks.toolbox.ident.nnbbgui.ModelTypeMiddlePanelOfTypeNLHW$LinearTableModel');

% handles to udd classes for special options
schema.prop(c,'WavenetAdvancedOptions','handle');

% wavenet bject currently under edit (if any)
p = schema.prop(c,'WaveNLData','MATLAB array');
p.FactoryValue = struct('Type','input','Index',1); %index should be populated when used
p.AccessFlags.AbortSet = 'off';

% is data single output? 
p = schema.prop(c,'isSingleOutput','bool'); 
p.FactoryValue = true;

% is data single input? 
p = schema.prop(c,'isSingleInput','bool'); 
p.FactoryValue = true;

% store nlarx model data
p = schema.prop(c,'NlhwModel','MATLAB array');
p.AccessFlags.AbortSet = 'off';

p = schema.prop(c,'LatestEstimModelName','string');
p.FactoryValue = '';

% there is a separate linear orders table for each output
schema.prop(c,'ActiveOutputIndex','double');

p = schema.prop(c,'applyToAllOutputs','bool');
p.FactoryValue = false;

% saturation, deadzone and pwlinear editors
schema.prop(c,'SaturationEditor','handle');
schema.prop(c,'DeadzoneEditor','handle');
schema.prop(c,'PwlinearEditor','handle');
schema.prop(c,'Poly1dEditor','handle');
schema.prop(c,'UnitFcnDlg','handle');

% array of listeners 
schema.prop(c,'Listeners','MATLAB array');

