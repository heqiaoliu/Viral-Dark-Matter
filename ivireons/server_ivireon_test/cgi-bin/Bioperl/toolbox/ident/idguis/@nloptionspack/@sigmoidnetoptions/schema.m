function schema
% SCHEMA  Defines properties for sigmoidnetoptions class

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:32:03 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('nloptionspack');

% Construct class
c = schema.class(hCreateInPackage, 'sigmoidnetoptions');

schema.prop(c,'jMainPanel','com.mathworks.toolbox.ident.nnbbgui.SigmoidNetworkPropertiesPanel');
schema.prop(c,'jAdvancedButton','com.mathworks.mwswing.MJButton');
schema.prop(c,'jNumUnitsEdit','com.mathworks.mwswing.MJTextField');

% UDD objects for parent and advanced props
schema.prop(c,'NlarxPanel','handle'); % handle to owning panel

% array of listeners 
schema.prop(c,'Listeners','MATLAB array');

% handle to a sigmoidnet object
p = schema.prop(c,'Object','MATLAB array');
p.FactoryValue = sigmoidnet;
