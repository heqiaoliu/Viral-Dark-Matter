function schema()
%SCHEMA Baseline schema

%   Copyright 1984-2007 The MathWorks, Inc. 

classPkg = findpackage('specgraph');
basePkg = findpackage('hg');
lineCls = basePkg.findclass('line');

%define class
hClass = schema.class(classPkg , 'baseline', lineCls);
hClass.description = 'A reference base line for a chart';

hProp = schema.prop(hClass, 'BaseValue', 'double');
hProp.Description = 'Base line value';
hProp.FactoryValue = 0.0;
hProp.SetFunction = @LdoBaseValueSet;

hProp = schema.prop(hClass,'BaseValueMode','axesXLimModeType');
hProp.SetFunction = @LdoBaseValueModeSet;
hProp.Visible = 'off';

hProp = schema.prop(hClass,'InternalSet','bool');
hProp.FactoryValue = false;
hProp.Visible = 'off';

hProp = schema.prop(hClass, 'Orientation', 'string');
hProp.Description = 'Base line orientation';
hProp.Visible = 'off';
hProp.FactoryValue = 'X';

hProp = schema.prop(hClass, 'Listener', 'handle');
hProp.Visible = 'off';

hProp = schema.prop(hClass, 'AxesListener', 'handle');
hProp.Visible = 'off';

function value = LdoBaseValueSet(h, value)
if h.orientation == 'X'
  set(h,'YData',[value value]);
else
  set(h,'XData',[value value]);
end
if ~h.InternalSet
    h.BaseValueMode = 'manual';
end

function value = LdoBaseValueModeSet(h, value)
hAx = ancestor(h,'axes');
if strcmpi(value,'manual')
    return;
end
if strcmp(h.Orientation,'X')
    if strcmpi(get(hAx,'YScale'),'linear')
        h.InternalSet = true;
        h.BaseValue = 0;
        h.InternalSet = false;
    else
        h.InternalSet = true;
        h.BaseValue = 1;
        h.InternalSet = false;
    end
else
    if strcmpi(get(hAx,'XScale'),'linear')
        h.InternalSet = true;
        h.BaseValue = 0;
        h.InternalSet = false;
    else
        h.InternalSet = true;
        h.BaseValue = 1;
        h.InternalSet = false;
    end
end
    