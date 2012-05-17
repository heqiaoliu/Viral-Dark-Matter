function schema
% SCHEMA  Defines properties for nlhwplot class

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:50 $

% Get handles of associated packages and classes
hCreateInPackage   = findpackage('plotpack');

% Construct class
c = schema.class(hCreateInPackage, 'nlhwdata');

schema.prop(c,'Model','MATLAB array');
schema.prop(c,'ModelName','string');

p = schema.prop(c,'Data','MATLAB array');
%Data.InputNLData = struct('x',[],'y',[]);
%Data.OutputNLData = struct('x',[],'y',[]);
% store linear model simulation results only?
Data.StepResponse = struct('t',[],'y',[]);
Data.ImpulseResponse = struct('t',[],'y',[]);
Data.BodeResponse = struct('w',[],'mag',[],'phase',[]);
Data.PZMap = struct('z',[],'p',[]);
p.FactoryValue = Data;

% model "color" (this notion is used by GUI)
p = schema.prop(c,'Color','MATLAB array');
p.FactoryValue = [0 0 1]; %blue

% linestyle char
schema.prop(c,'StyleArg','string vector');

% model can have active or inactive state (useful for GUI)????
p = schema.prop(c,'isActive','bool'); 
p.FactoryValue = true;

