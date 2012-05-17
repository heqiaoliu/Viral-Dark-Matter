function schema
% Defines properties for derived specplot class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2005/12/15 20:56:16 $

% Register class 
p = findpackage('tsguis');
c = schema.class(p,'histplot',findclass(p,'tsplot'));

%% Public properties
p = schema.prop(c,'Bins','MATLAB array');
p.FactoryValue = 50;


