function schema
% Literal specification of simulation options for SRO Project.

% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/07/09 20:55:03 $

% Construct class
c = schema.class(findpackage('slcontrol'), 'SimOptionForm');

% Add new enumeration type
if (isempty(findtype('slcontrol_ODESolver')))
   schema.EnumType('slcontrol_ODESolver', ...
      {'auto',...
      'VariableStepDiscrete', 'ode45', 'ode23', 'ode113', ...
      'ode15s', 'ode23s', 'ode23t', 'ode23tb', ...
      'FixedStepDiscrete', 'ode5', 'ode4', 'ode3', ...
      'ode2', 'ode1', 'ode14x'});
end

p = schema.prop(c,'AbsTol', 'string');
p.FactoryValue = 'auto';

p = schema.prop(c,'FixedStep', 'string');
p.FactoryValue = 'auto';

p = schema.prop(c,'InitialStep', 'string');
p.FactoryValue = 'auto';

p = schema.prop(c,'MaxStep', 'string');
p.FactoryValue = 'auto';

p = schema.prop(c,'MinStep', 'string');
p.FactoryValue = 'auto';

p = schema.prop(c,'RelTol', 'string');
p.FactoryValue = '1e-3';

p = schema.prop(c,'Solver', 'slcontrol_ODESolver');
p.FactoryValue = 'ode45';

p = schema.prop(c,'ZeroCross', 'on/off');
p.FactoryValue = 'on';

% Start time for simulation
p = schema.prop(c,'StartTime','string');
p.FactoryValue = 'auto';  % inherited from model

% Stop time for simulation
p = schema.prop(c,'StopTime','string');
p.FactoryValue = 'auto';  % inherited from model

% Version
p = schema.prop(c, 'Version', 'double');
p.FactoryValue = 1.0;
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
