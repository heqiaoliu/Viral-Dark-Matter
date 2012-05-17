function schema

% Copyright 2003-2006 The MathWorks, Inc.

pk = findpackage('graphics');
cls = schema.class(pk,'zoombehavior');

p = schema.prop(cls,'Enable','bool');
p.FactoryValue = true;

p = schema.prop(cls,'Serialize','MATLAB array');
p.FactoryValue = true;
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'Name','string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';
p.FactoryValue = 'Zoom';
p.AccessFlags.Serialize = 'off';

% Enumeration Style Type
if (isempty(findtype('StyleChoice')))
    schema.EnumType('StyleChoice',{'horizontal','vertical','both'});
end

p = schema.prop(cls,'Style','StyleChoice');
p.FactoryValue = 'both';


