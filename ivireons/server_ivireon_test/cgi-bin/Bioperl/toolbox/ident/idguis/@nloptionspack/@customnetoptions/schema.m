function schema
% SCHEMA  Defines properties for customnetoptions class

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/05/19 23:04:28 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('nloptionspack');

% Construct class
c = schema.class(hCreateInPackage, 'customnetoptions');

schema.prop(c,'jMainPanel','com.mathworks.toolbox.ident.nnbbgui.CustomnetPropertiesPanel');
schema.prop(c,'jImportButton','com.mathworks.mwswing.MJButton');
schema.prop(c,'jUnitFcnName','com.mathworks.mwswing.MJLabel');
schema.prop(c,'jNumUnitsEdit','com.mathworks.mwswing.MJTextField');

schema.prop(c,'NlarxPanel','handle'); % handle to owning panel

% array of listeners 
schema.prop(c,'Listeners','MATLAB array');

% handle to a customnet object
p = schema.prop(c,'Object','MATLAB array');
p.FactoryValue = customnet; 

% handle to unit function specification dialog
schema.prop(c,'UnitFcnDlg','handle');