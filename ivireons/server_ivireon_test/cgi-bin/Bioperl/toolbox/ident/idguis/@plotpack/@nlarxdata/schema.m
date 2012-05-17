function schema
% SCHEMA  Defines properties for nlarxdata class

% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/06/07 14:42:34 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('plotpack');

% Construct class
c = schema.class(hCreateInPackage, 'nlarxdata');

% singletons for a model
schema.prop(c,'Model','MATLAB array');
schema.prop(c,'ModelName','string');

% regressors
%schema.prop(c,'Regressors','MATLAB array');

% center point
%schema.prop(c,'CenterPoint','MATLAB array');

% model "color" (this notion is used by GUI)
p = schema.prop(c,'Color','MATLAB array');
%p.FactoryValue = [0 0 1]; %blue

% linestyle char
% schema.prop(c,'StyleArg','string vector');

p = schema.prop(c,'isActive','bool'); 
p.FactoryValue = true;
