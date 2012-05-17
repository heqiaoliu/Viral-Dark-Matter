function schema
% Copyright 2004-2005 The MathWorks, Inc.

%% Class Definition
hSuperPackage = findpackage('DAStudio');
hSuperClass   = findclass(hSuperPackage, 'Object');
hPackage      = findpackage('DAStudio'); 
hThisClass    = schema.class(hPackage, 'Explorable', hSuperClass);
  
%% Class Methods
m = schema.method(hThisClass, 'isHierarchical');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {'bool'};

m = schema.method(hThisClass, 'getHierarchicalChildren');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {'handle vector'};

m = schema.method(hThisClass, 'getChildren');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle'};
s.OutputTypes = {'handle vector'};

m = schema.method(hThisClass, 'getDialogSchema');
s = m.Signature;
s.varargin    = 'off';
s.InputTypes  = {'handle', 'string'};
s.OutputTypes = {'mxArray'};

%% Class Properties
p = schema.prop(hThisClass, 'Children', 'handle vector');
p.SetFunction = @setChildren;

p = schema.prop(hThisClass, 'Listeners', 'handle vector');
p.Visible     = 'off';
