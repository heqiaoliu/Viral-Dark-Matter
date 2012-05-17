function schema
%SCHEMA  Defines properties for @BlockInspectorLinearization class

%  Author(s): John Glass
%  Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.13 $ $Date: 2009/03/31 00:22:50 $

% Register class (subclass) in package
inpkg = findpackage('GenericLinearizationNodes');
c = schema.class(inpkg, 'BlockInspectorLinearization');

% Property for the simulink block 
schema.prop(c, 'A', 'MATLAB array');
schema.prop(c, 'B', 'MATLAB array');
schema.prop(c, 'C', 'MATLAB array');
schema.prop(c, 'D', 'MATLAB array');

schema.prop(c, 'InLinearizationPath','string');
schema.prop(c, 'FullBlockName', 'string');
schema.prop(c, 'SampleTimes', 'MATLAB array');

% Storage for all the Block's linearization
schema.prop(c, 'allA', 'MATLAB array');    
schema.prop(c, 'allB', 'MATLAB array');
schema.prop(c, 'allC', 'MATLAB array');
schema.prop(c, 'allD', 'MATLAB array');
schema.prop(c, 'indx', 'MATLAB array');    
schema.prop(c, 'indu', 'MATLAB array');
schema.prop(c, 'indy', 'MATLAB array');

p = schema.prop(c, 'Jacobian', 'string'); % Jacobian type (exact, perturbation, etc.)
p.FactoryValue = 'not available';
