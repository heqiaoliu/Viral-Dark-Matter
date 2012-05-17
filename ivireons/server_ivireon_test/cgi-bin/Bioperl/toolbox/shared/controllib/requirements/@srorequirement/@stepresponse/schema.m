function schema 
% SCHEMA  Step response bound object schema
%
 
% Author(s): A. Stothert 
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:37:15 $

%Package
pk = findpackage('srorequirement');

%Class
c = schema.class(pk,'stepresponse',findclass(pk,'piecewiselinear'));

%Native Properties

%Properties for step response characteristics. Note these are derived
%properties, the description (or truth) of the constraint is stored in the
%this.Data property inherited from srorequirement.piecewiselinear
p = schema.prop(c,'InitialValue','double');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p = schema.prop(c,'FinalValue','double');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p = schema.prop(c,'StepTime','double');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p = schema.prop(c,'RiseTime','double');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p = schema.prop(c,'SettlingTime','double');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p = schema.prop(c,'PercentRise','double');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p = schema.prop(c,'PercentSettling','double');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p = schema.prop(c,'PercentOvershoot','double');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p = schema.prop(c,'PercentUndershoot','double');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';