function schema
% Defines properties for @requirementdata superclass

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:33 $

pk = findpackage('srorequirement');

% Register class 
c = schema.class(pk,'requirementdata');

%Data
p = schema.prop(c,'Type','string');           % Upper/lower flag
p.FactoryValue = 'lower';
p = schema.prop(c,'Weight','MATLAB array');   % Constraint weight
p.FactoryValue = 1;
schema.prop(c,'xCoords','MATLAB array');      % x-Axis Start and end coordinates
p = schema.prop(c,'xUnits','string');         % x-Axis units
p.FactoryValue = 'none';
schema.prop(c,'yCoords','MATLAB array');      % y-Axis Start and end coordinates
p = schema.prop(c,'yUnits','string');         % y-Axis units
p.FactoryValue = 'none';

%Event
schema.event(c, 'DataChanged');


