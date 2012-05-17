function schema
%  SCHEMA  Defines properties for @TimeFinalValueData class

%  Author(s):  
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/27 23:02:05 $

% Register class
superclass = findclass(findpackage('wrfc'), 'data');
c = schema.class(findpackage('tsguis'), 'tsMeanData', superclass);

% Public attributes
schema.prop(c, 'MeanValue', 'MATLAB array'); % Mean Value
schema.prop(c, 'StdValue', 'MATLAB array');% Std Value
schema.prop(c, 'MedianValue', 'MATLAB array');% Std Value
p = schema.prop(c, 'Starttime', 'MATLAB array'); % Start time for mean interval
%p.FactoryValue = -inf;
p = schema.prop(c, 'Endtime', 'MATLAB array'); % End time for mean interval
%p.FactoryValue = inf;