function schema
% SCHEMA  Defines properties for regeditdialog class

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:54:09 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('nlbbpack');

% Construct class
c = schema.class(hCreateInPackage, 'regeditdialog');

% listeners
schema.prop(c,'Listeners','MATLAB array');

% handle to main java panel for this class
schema.prop(c,'jMainPanel','com.mathworks.toolbox.ident.nnbbgui.RegressorEditorDialog'); 

% handle to parent nlarx panel
schema.prop(c,'NlarxPanel','handle');

% copy of model for local manipulation (so users can "cancel")
p = schema.prop(c,'ModelCopy','MATLAB array');
p.AccessFlags.AbortSet = 'off';

% handles to java controls
schema.prop(c,'jModelOutputCombo','com.mathworks.mwswing.MJComboBox');
schema.prop(c,'jRegTypesCombo','com.mathworks.mwswing.MJComboBox');

%schema.prop(c,'jCloseButton','com.mathworks.mwswing.MJButton');
%schema.prop(c,'jHelpButton','com.mathworks.mwswing.MJButton');
%schema.prop(c,'jAutoSelectCheckBox','com.mathworks.mwswing.MJCheckBox');
schema.prop(c,'jStdRegTable','com.mathworks.mwswing.MJTable');
schema.prop(c,'jCustomRegTable','com.mathworks.mwswing.MJTable');

tabmod = 'com.mathworks.toolbox.ident.nnbbgui.RegressorEditorDialog$RegressorTableModel';
schema.prop(c,'jStdTableModel',tabmod);
schema.prop(c,'jCustomTableModel',tabmod);

%schema.prop(c,'jAddCustomRegButton','com.mathworks.mwswing.MJButton');
%schema.prop(c,'jImportCustomRegButton','com.mathworks.mwswing.MJButton');
%schema.prop(c,'jDeleteCustomRegButton','com.mathworks.mwswing.MJButton');

% handle to custom regressor editor dialog (udd obj)
schema.prop(c,'CustomRegEditDialog','handle');

%Note: this is not same as getCurrentOutputIndex, which returns the current
%combobox value. This property is updated to agree with combobox value only
%after data for output before combox change has been stored.
schema.prop(c,'ActiveOutputIndex','double');

% current selection index in the regressor subset selection combo (1..7)
schema.prop(c,'ActiveRegIndex','double');

% customreg import dlg
schema.prop(c,'CustomImportdlg','handle');
