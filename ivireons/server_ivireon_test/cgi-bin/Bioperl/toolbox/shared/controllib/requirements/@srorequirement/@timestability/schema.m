function schema
%SCHEMA for timestability class

% Author(s): A. Stothert 06-July-2006
% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:37:31 $

%Package
pk = findpackage('srorequirement');

%Class
c = schema.class(pk,'timestability',findclass(pk,'scalar'));

%Native Properties
p = schema.prop(c,'steadystatevalue','double');     %Defines expected SS value
p.FactoryValue = 1;
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p = schema.prop(c,'t0','double');                   %Defines start time for stability check
p.FactoryValue = 1;
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p = schema.prop(c,'absTol','double');               %Used to define maximum error
p.FactoryValue = 1;
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

