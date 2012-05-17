function schema
% Defines properties for derived specplot class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/06/27 23:00:31 $

% Register class 
p = findpackage('tsguis');
% Register class 
c = schema.class(p,'specplot',findclass(p,'tsplot'));

% Plulic properties
% Accumulate or not
schema.prop(c, 'Cumulative', 'on/off');

%% AxesTable handle for Proeprty Editor Panels
schema.prop(c, 'PropEditor', 'MATLAB array');