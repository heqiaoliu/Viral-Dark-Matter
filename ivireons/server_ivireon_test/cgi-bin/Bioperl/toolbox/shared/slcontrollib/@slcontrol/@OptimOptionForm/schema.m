function schema
% Literal specification of optimization options for SRO Project.

% Author(s): P. Gahinet, Bora Eryilmaz
% Revised: A. Stothert
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2008/12/29 02:16:01 $

% Construct class
c = schema.class(findpackage('slcontrol'), 'OptimOptionForm');

% Make sure have enumeration types
if isempty( findtype('slcontrol_Display') )
  schema.EnumType('slcontrol_Display', {'off','iter','notify','final'});
end
if isempty( findtype('slcontrol_Gradient') )
  schema.EnumType('slcontrol_Gradient', {'basic','refined'});
end
if isempty( findtype('slcontrol_Search') )
  schema.EnumType('slcontrol_Search', ...
		  {'None','Positive Basis Np1','Positive Basis 2N',...
		   'Genetic Algorithm','Latin Hypercube','Nelder-Mead'});
end
if isempty( findtype('slcontrol_Parallel'))
   schema.EnumType('slcontrol_Parallel', {'always','never'});
end

% Display
p = schema.prop(c, 'Display', 'slcontrol_Display');
p.FactoryValue = 'iter';

% Gradient algorithm
p = schema.prop(c, 'GradientType', 'slcontrol_Gradient');
p.FactoryValue = 'basic';

% Max iterations
p = schema.prop(c, 'MaxIter', 'string');
p.FactoryValue = '100';

% Objective tolerance
p = schema.prop(c, 'TolFun', 'string');
p.FactoryValue = '0.001';

% Tolerance on search direction magnitude
p = schema.prop(c, 'TolX', 'string');
p.FactoryValue = '0.001';

% Enable parallel
p = schema.prop(c, 'UseParallel', 'slcontrol_Parallel');
p.FactoryValue = 'never';

% Parallel path dependencies
p = schema.prop(c, 'ParallelPathDependencies', 'string vector');
p.FactoryValue = {};

% Search method (GADS only)
p = schema.prop(c, 'SearchMethod', 'slcontrol_Search');
p.FactoryValue = 'Latin Hypercube';

% Search limit (GADS only)
p = schema.prop(c, 'SearchLimit', 'string');
p.FactoryValue = '3';

% Version
p = schema.prop(c, 'Version', 'double');
p.FactoryValue = 1;
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
