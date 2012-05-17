function schema
% Copyright 2009 The MathWorks, Inc.

hCreateInPackage = findpackage('DAStudio');
hThisClass       = schema.class(hCreateInPackage, 'MEViewProperty');


%% Public properties
p = schema.prop(hThisClass, 'Name', 'string');

p = schema.prop(hThisClass, 'isVisible', 'bool');
p.FactoryValue = true;

p = schema.prop(hThisClass, 'isMatching', 'bool');
p.FactoryValue = false;

% This is a transient property which will appear temporarily for a view.
p = schema.prop(hThisClass, 'isTransient', 'bool');
p.FactoryValue = false;
