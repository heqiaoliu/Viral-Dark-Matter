function schema
%  SCHEMA  Defines properties for @eventCharData class

%  Author(s):  
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/27 22:57:42 $

% Register class
superclass = findclass(findpackage('wrfc'), 'data');
c = schema.class(findpackage('tsguis'), 'histMedianData', superclass);

% Public attributes
schema.prop(c, 'MeanValue', 'MATLAB array'); % Mean Value
