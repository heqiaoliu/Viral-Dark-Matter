function schema
% SCHEMA  Defines properties for customregeditdialog class

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:30:28 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('nlbbpack');

% Construct class
c = schema.class(hCreateInPackage, 'customregeditdialog');

% listeners
schema.prop(c,'Listeners','MATLAB array');

% handle to main java panel for this class
schema.prop(c,'jMainPanel','com.mathworks.toolbox.ident.nnbbgui.CustomRegEditorDialog'); 

% handle to regressor editor dialog
schema.prop(c,'RegDialog','handle');


% handle to parent nlarx panel
schema.prop(c,'NlarxPanel','handle');

% handles to java controls
schema.prop(c,'jModelOutputCombo','com.mathworks.mwswing.MJComboBox');
%schema.prop(c,'jCloseButton','com.mathworks.mwswing.MJButton');
schema.prop(c,'jHelpButton','com.mathworks.mwswing.MJButton');
schema.prop(c,'jCreateButton','com.mathworks.mwswing.MJButton');
schema.prop(c,'jRefreshButton','com.mathworks.mwswing.MJButton');
schema.prop(c,'jButtonGroup','javax.swing.ButtonGroup');
schema.prop(c,'jExpressionEdit','com.mathworks.mwswing.MJTextField');
schema.prop(c,'jOneAtATimeTable','com.mathworks.mwswing.MJTable');
schema.prop(c,'jBatchTable','com.mathworks.mwswing.MJTable');
schema.prop(c,'jCrossTermsCheckBox','com.mathworks.mwswing.MJCheckBox');

p = schema.prop(c,'IsExprEditEmpty','bool');
p.FactoryValue = true;
