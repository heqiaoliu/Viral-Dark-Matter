function schema
% Defines properties for @selectrules class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/06/27 22:59:23 $

%% Register class 
p = findpackage('tsguis');
c = schema.class(p,'selectrules',findclass(p,'viewdlg'));

%% Public properties

%% Rule objects
schema.prop(c,'Rules','MATLAB array');
schema.prop(c,'Calendar','MATLAB array');








