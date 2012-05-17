function schema

% Copyright 2004-2006 The MathWorks, Inc.

pk = findpackage('graphics');
cls = schema.class(pk,'panbehavior');

p = schema.prop(cls,'Enable','bool');
p.FactoryValue = true;

p = schema.prop(cls,'Serialize','MATLAB array');
p.FactoryValue = true;
p.AccessFlags.Serialize = 'off';

p = schema.prop(cls,'Name','string');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'on';
p.FactoryValue = 'Pan';
p.AccessFlags.Serialize = 'off';

% Enumeration Style Type
if (isempty(findtype('StyleChoice')))
    schema.EnumType('StyleChoice',{'horizontal','vertical','both'});
end

p = schema.prop(cls,'Style','StyleChoice');
p.FactoryValue = 'both';

% EVENTS
schema.event(cls,'BeginDrag');
schema.event(cls,'EndDrag');