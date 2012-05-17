function schema
%SCHEMA  Defines properties for @interp class

% Author(s): James G. Owen
% Revised:
% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2008/01/29 15:37:09 $

% Register class (subclass)
c = schema.class(findpackage('preprocessgui'), 'interp');

% Enumerations
if isempty(findtype('interpmethod'))
    schema.EnumType('interpmethod', {'zoh','linear'});
end

% Public attributes
p = schema.prop(c, 'Rowremove', 'on/off');
p.FactoryValue = 'off';
p = schema.prop(c, 'Rowor', 'on/off');
p.FactoryValue = 'off';
p = schema.prop(c, 'Interpolate', 'on/off');
p.FactoryValue = 'off';
p = schema.prop(c, 'method', 'interpmethod');
p.FactoryValue = 'zoh';

p = schema.prop(c, 'Listeners', 'MATLAB array');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
