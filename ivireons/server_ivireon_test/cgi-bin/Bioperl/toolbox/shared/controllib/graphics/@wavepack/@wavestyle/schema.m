function schema
%SCHEMA  Defines properties for @wavestyle class

%   Author(s): John Glass
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:28:38 $

% Register class
c = schema.class(findpackage('wavepack'), 'wavestyle');

% Public attributes
schema.prop(c, 'Colors', 'MATLAB array'); 
schema.prop(c, 'LineStyles', 'MATLAB array');    
p = schema.prop(c, 'LineWidth', 'double');    
p.FactoryValue = 0.5;
schema.prop(c, 'Markers', 'MATLAB array');    
schema.prop(c, 'Legend', 'string'); 
schema.prop(c, 'GroupLegendInfo', 'MATLAB array');

% Event
schema.event(c,'StyleChanged');   % Notifies of change in style attributes