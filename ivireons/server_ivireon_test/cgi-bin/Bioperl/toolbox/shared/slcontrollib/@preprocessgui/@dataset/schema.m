function schema
%SCHEMA  Defines properties for @preprocess class
%
% Author(s): James G. Owen
% Revised:
%   Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/20 20:28:39 $


% Register class (subclass)
c = schema.class(findpackage('preprocessgui'), 'dataset');

% Time units
% R.C. used by simulink, revisit if it breaks due to the changes in ts
if isempty(findtype('TimeUnits'))
    schema.EnumType('TimeUnits', {'weeks', 'days', 'hours', 'minutes', ...
        'seconds', 'milliseconds', 'microseconds', 'nanoseconds'});
end

% Public attributes
schema.prop(c, 'Data', 'MATLAB array');
schema.prop(c, 'Datavariable', 'string');
schema.prop(c, 'Name', 'MATLAB array');
schema.prop(c, 'Headings', 'MATLAB array');
p = schema.prop(c, 'Timeunits', 'TimeUnits');
p.FactoryValue = 'seconds';
schema.prop(c, 'Time', 'MATLAB array');
schema.prop(c, 'Timevariable', 'string');
schema.prop(c, 'Userdata', 'MATLAB array');
