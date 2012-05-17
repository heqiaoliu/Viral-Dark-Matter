function schema
% Defines properties for @tsxcorrnode class 
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/06/27 23:03:04 $

% Register class 
p = findpackage('tsguis');
c = schema.class(p, 'tscorrnode',findclass(p,'viewnode'));

% Public properties
p = schema.prop(c,'Viewstate','string');
p.FactoryValue = 'Plot';
schema.prop(c,'Timeseries1','MATLAB array');
schema.prop(c,'Timeseries2','MATLAB array');




