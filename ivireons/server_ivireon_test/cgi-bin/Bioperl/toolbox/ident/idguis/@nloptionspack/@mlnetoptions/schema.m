function schema
% SCHEMA  Defines properties for mlnetoptions class

% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/06/07 14:42:01 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('nloptionspack');

% Construct class
c = schema.class(hCreateInPackage, 'mlnetoptions');

schema.prop(c,'jMainPanel','com.mathworks.toolbox.ident.nnbbgui.MlnetPropertiesPanel');
schema.prop(c,'jImportButton','com.mathworks.mwswing.MJButton');
%schema.prop(c,'jAdvancedButton','com.mathworks.mwswing.MJButton');
schema.prop(c,'jNetworkObjectName','com.mathworks.mwswing.MJLabel');

% UDD objects for parent and advanced props
schema.prop(c,'NlarxPanel','handle'); % handle to owning panel

% imported network name
p = schema.prop(c,'NetworkName','string'); 
p.FactoryValue = '';

% array of listeners 
schema.prop(c,'Listeners','MATLAB array');

% handle to an neuralnet object
p = schema.prop(c,'Object','MATLAB array');
p.FactoryValue = neuralnet; 

% handle to import dialog
schema.prop(c,'NetworkImportdlg','handle');
 
