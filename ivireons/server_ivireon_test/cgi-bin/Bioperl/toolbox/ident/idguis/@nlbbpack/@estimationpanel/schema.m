function schema
% SCHEMA  Defines properties for estimationpanel class

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:53:40 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('nlbbpack');

% Construct class
c = schema.class(hCreateInPackage, 'estimationpanel');

% handle to owning java panel
schema.prop(c,'jMainPanel','com.mathworks.mwswing.MJPanel');

% Table handles
schema.prop(c,'jTable','com.mathworks.toolbox.slestim.util.MultiSpanCellTable');
schema.prop(c,'jTableModel','com.mathworks.toolbox.slestim.util.DataTableModel');

% info box
schema.prop(c,'jInfoArea','com.mathworks.toolbox.ident.nnbbgui.EstimationResultsPanel$InfoArea');

% other java widgets
schema.prop(c,'jEstimationOptionsButton','com.mathworks.mwswing.MJButton');
schema.prop(c,'jRandomizeCheckBox','com.mathworks.mwswing.MJCheckBox');
schema.prop(c,'jReiterateCheckBox','com.mathworks.mwswing.MJCheckBox');

% array of listeners 
schema.prop(c,'Listeners','MATLAB array');

% messenger between optimizer and iteration table
schema.prop(c,'OptimMessenger','handle');

% table header indices for iterative estimation
p = schema.prop(c,'IterTableIndices','MATLAB array');
p.FactoryValue = 1;

schema.prop(c,'AlgorithmOptions','handle vector');
