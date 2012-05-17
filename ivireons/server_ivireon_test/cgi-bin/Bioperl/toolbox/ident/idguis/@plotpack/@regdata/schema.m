function schema
% SCHEMA  Defines properties for regdata class

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/02/06 19:52:33 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('plotpack');

% Construct class
c = schema.class(hCreateInPackage, 'regdata');

schema.prop(c,'OutputName','string');
p = schema.prop(c,'ModelNames','string vector');
p.FactoryValue = {};
p.AccessFlags.AbortSet = 'off';

p = schema.prop(c,'ComboValue','MATLAB array');
p.FactoryValue = struct('Reg1',[],'Reg2',[]);

% not all regressors are active if not all models are active
p = schema.prop(c,'ActiveRegressors','string vector');
p.FactoryValue = {};

p = schema.prop(c,'is2D','bool');
p.FactoryValue = false;

% a struct array (length = no. reg) hold per-regressor info
p = schema.prop(c,'RegInfo','MATLAB array');
% each regressor has name, range, centerpoint and associated model names
p.FactoryValue = struct('Name','','Range',[-1 1],...
    'CenterPoint',0,'ModelNames',{{''}});
p.AccessFlags.AbortSet = 'off';
