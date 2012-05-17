function schema
% Defines properties for @tsspecnode class which represents
% spectral views of time series
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/06/27 23:03:17 $

% Register class 
p = findpackage('tsguis');
c = schema.class(p, 'tshistnode',findclass(p,'viewnode'));

% Public properties
p = schema.prop(c,'Viewstate','string');
p.FactoryValue = 'Plot';




