function schema
% Copyright 2004 The MathWorks, Inc.

hPackage      = findpackage('DAStudio'); 
hThisClass    = schema.class(hPackage, 'PositionSchema');

schema.EnumType('PortSide', ...
                {'Left', 'Right'});
            
schema.EnumType('Units', ...
                {'km', 'm', 'cm', 'mm', 'mi', 'ft', 'in'}, ...
                [1 2 3 4 5 6 7]);
            
schema.EnumType('Space', ...
                {'WORLD', 'ADJOINING'}, ...
                [1 2]);
  
p = schema.prop(hThisClass, 'showPort', 'bool');
p = schema.prop(hThisClass, 'portSide', 'PortSide');
p = schema.prop(hThisClass, 'name', 'string');
p = schema.prop(hThisClass, 'originPosVector', 'string');
p = schema.prop(hThisClass, 'units', 'Units');
p = schema.prop(hThisClass, 'origin', 'Space');
p = schema.prop(hThisClass, 'axes', 'Space');

