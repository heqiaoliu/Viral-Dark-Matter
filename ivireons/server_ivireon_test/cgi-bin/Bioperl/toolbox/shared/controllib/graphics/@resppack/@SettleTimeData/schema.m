function schema
%  SCHEMA  Defines properties for @SettleTimeData class

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:18:57 $

% Register class
superclass = findclass(findpackage('wrfc'), 'data');
c = schema.class(findpackage('resppack'), 'SettleTimeData', superclass);

% Public attributes
schema.prop(c, 'Time',    'MATLAB array'); % XData
schema.prop(c, 'YSettle', 'MATLAB array'); % YData
schema.prop(c, 'FinalValue',  'MATLAB array'); % Final value

% Preferences
p = schema.prop(c, 'SettlingTimeThreshold', 'MATLAB array');
p.FactoryValue = 0.02;
