function schema
%  SCHEMA  Defines properties for @regLineData class

%  Author(s):  
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/27 22:59:11 $

% Register class
superclass = findclass(findpackage('wrfc'), 'data');
c = schema.class(findpackage('tsguis'), 'regLineData', superclass);

% Public attributes
schema.prop(c, 'Slopes', 'MATLAB array'); % Line slopes
schema.prop(c, 'Biases', 'MATLAB array'); % Line biases