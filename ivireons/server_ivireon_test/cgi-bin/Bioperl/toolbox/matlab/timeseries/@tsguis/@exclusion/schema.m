function schema
%SCHEMA  Defines properties for @exclusion class
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2005/06/27 22:57:33 $

%% Class overloaded to add logical combination operators

% Register class (subclass)
c = schema.class(findpackage('tsguis'),'exclusion');

%% Define logicSelectionMode type
if isempty(findtype('logicSelectionMode'))
    schema.EnumType('logicSelectionMode', {'and', 'or'});
end

%% Public attributes
%% Logical selection mode
p = schema.prop(c, 'LogicalOp', 'logicSelectionMode');
p.FactoryValue = 'and';

%% Rule characteristics
p = schema.prop(c, 'Xlow', 'MATLAB array');
p.Description = 'time lower bound';
p = schema.prop(c, 'Xlowstrict', 'on/off');
p.FactoryValue = 'off';
p = schema.prop(c,'Xhigh', 'MATLAB array');
p.Description = 'time upper bound';
p = schema.prop(c, 'Xhighstrict', 'on/off');
p.FactoryValue = 'off';
if isempty(findtype('TimeUnits'))
    schema.EnumType('TimeUnits', {'weeks', 'days', 'hours', 'minutes', ...
        'seconds', 'milliseconds', 'microseconds', 'nanoseconds'});
end
p = schema.prop(c,'XUnits','TimeUnits');
p.FactoryValue = 'seconds';
p = schema.prop(c, 'Ylow', 'MATLAB array');
p.Description = 'data lower bound';
p = schema.prop(c, 'Ylowstrict', 'on/off');
p.FactoryValue = 'off';
p = schema.prop(c, 'Yhigh', 'MATLAB array');
p.Description = 'data upper bound';
p = schema.prop(c, 'Yhighstrict', 'on/off');
p.FactoryValue = 'off';
p = schema.prop(c, 'Outlierwindow', 'MATLAB array');
p.Description = 'outlier window length';
p = schema.prop(c, 'Outlierconf', 'MATLAB array');
p.Description = 'outlier detection confidence limit';
p = schema.prop(c, 'Mexpression', 'string');
p.Description = 'MATLAB expression';
p = schema.prop(c, 'Flatlinelength', 'MATLAB array');
p.Description = 'mimimum flatline length';

p = schema.prop(c, 'AbsoluteTime', 'on/off');
p.FactoryValue = 'off';

p = schema.prop(c, 'Listeners', 'MATLAB array');
% p.AccessFlags.PublicGet = 'off';
% p.AccessFlags.PublicSet = 'off';

%% Rulechanged event
schema.event(c,'rulechange');