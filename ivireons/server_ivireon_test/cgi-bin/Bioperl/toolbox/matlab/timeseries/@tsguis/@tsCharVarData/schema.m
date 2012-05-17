function schema
%  SCHEMA  Defines properties for @TimeFinalValueData class

%  Author(s):  
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/27 23:01:53 $

% Register class
superclass = findclass(findpackage('wrfc'), 'data');
c = schema.class(findpackage('tsguis'), 'tsCharVarData', superclass);

% Public attributes
% Mean periodogram/cumulative periogram value in the selected freq interval
schema.prop(c, 'Value', 'MATLAB array');
% Total variance
schema.prop(c, 'Variance', 'MATLAB array');
% Variance below left frequency interval
schema.prop(c, 'LVariance', 'MATLAB array');
% Variance below right freq interval
schema.prop(c, 'RVariance', 'MATLAB array');
% Start freq for interval
p = schema.prop(c, 'Startfreq', 'MATLAB array'); 
%p.FactoryValue = -inf;
% End freq for interval
p = schema.prop(c, 'Endfreq', 'MATLAB array'); 
%p.FactoryValue = inf;
