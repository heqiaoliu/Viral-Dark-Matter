function schema
% SCHEMA  Defines properties for nlbbgui class

% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2010/03/31 18:22:39 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('nlbbpack');

% Construct class
c = schema.class(hCreateInPackage, 'nlbbgui');

% listener (for estimate button etc)
schema.prop(c,'Listeners','MATLAB array');

% listener for figure closing event (ObjectBeingDestroyed)
schema.prop(c,'FigureListener','MATLAB array');

% handle to java gui frame
p = schema.prop(c,'jGuiFrame','com.mathworks.toolbox.ident.nnbbgui.NNBBGuiFrame');
p.AccessFlags.PublicSet = 'off';

schema.prop(c,'jEstimateButton','com.mathworks.mwswing.MJButton');

% handle to the model type and the estimation results panels
schema.prop(c,'ModelTypePanel','handle'); %udd class handle
schema.prop(c,'EstimationPanel','handle'); %udd class handle

p = schema.prop(c,'isIdle','bool'); 
p.FactoryValue = true;

% define events
schema.event(c,'VisibleModelChanged'); 
