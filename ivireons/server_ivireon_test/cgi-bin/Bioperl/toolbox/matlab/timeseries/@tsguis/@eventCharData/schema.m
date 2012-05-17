function schema
%  SCHEMA  Defines properties for @eventCharData class

%  Author(s):  
%  Revised:
%  Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/06/27 22:57:01 $

% Register class
superclass = findclass(findpackage('wrfc'), 'data');
c = schema.class(findpackage('tsguis'), 'eventCharData', superclass);

% Public attributes
%schema.prop(c, 'Event', 'MATLAB array'); % Event
schema.prop(c, 'Time', 'MATLAB array'); 
schema.prop(c, 'Amplitude', 'MATLAB array'); 
schema.prop(c, 'EventName', 'MATLAB array'); % Event
