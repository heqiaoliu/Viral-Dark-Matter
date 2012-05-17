function schema
%SCHEMA for requirement class.

% Author(s): A. Stothert 04-Apr-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:27 $


%Package
pk = findpackage('srorequirement');

%Class
c = schema.class(pk,'requirement');

%Private properties
p = schema.prop(c,'Data','handle');     %@srorequirement.requirementdata handle
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PrivateGet = 'on';
p.AccessFlags.PrivateSet = 'on';
p = schema.prop(c,'Source','handle vector');   %@modelpack.PortID handles
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PrivateGet = 'on';
p.AccessFlags.PrivateSet = 'on';
p.FactoryValue = [];

%Native Properties
p = schema.prop(c,'Name','string');
p.FactoryValue = 'Name';
p = schema.prop(c,'UserDescription','string vector');
p.FactoryValue = {'User description'};
p = schema.prop(c,'Description','string vector');
p.FactoryValue = {'Description'};
p.AccessFlags.PublicSet = 'off';
p = schema.prop(c,'NormalizeValue','double');
p.FactoryValue = NaN;
p = schema.prop(c,'PreProcessFcn','mxArray');
p.FactoryValue = '';
p = schema.prop(c,'isEnabled','bool');
p.FactoryValue = true;
p = schema.prop(c,'isProgressPlotted','bool');
p.FactoryValue = false;
p = schema.prop(c,'isFrequencyDomain','bool');
p.FactoryValue = false;
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'off';
p = schema.prop(c,'ConstraintSize','mxArray');
p.FactoryValue = 1;
p = schema.prop(c,'UID','string');
p.FactoryValue = '';
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(c,'Listeners','handle vector');
p.FactoryValue = '';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

%Events
schema.event(c, 'sourceChanged');