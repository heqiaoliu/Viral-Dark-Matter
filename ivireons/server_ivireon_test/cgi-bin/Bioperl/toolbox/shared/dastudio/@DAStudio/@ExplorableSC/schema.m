function schema
% Copyright 2004-2005 The MathWorks, Inc.

%% Class Definition
hSuperPackage = findpackage('DAStudio');
hSuperClass   = findclass(hSuperPackage, 'Shortcut');
hPackage      = findpackage('DAStudio'); 
hThisClass    = schema.class(hPackage, 'ExplorableSC', hSuperClass);
  
%% Class Methods
m = schema.method(hThisClass, 'getChildren');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {'handle vector'};

m = schema.method(hThisClass, 'isMasked');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {'bool'};

%% Class Properties
p = schema.prop(hThisClass, 'Recursive', 'bool');
p.Visible      = 'off';
p.FactoryValue = 1;

p = schema.prop(hThisClass, 'Children', 'handle vector');
p.Visible     = 'off';

p = schema.prop(hThisClass, 'Listeners', 'handle vector');
p.Visible     = 'off';
