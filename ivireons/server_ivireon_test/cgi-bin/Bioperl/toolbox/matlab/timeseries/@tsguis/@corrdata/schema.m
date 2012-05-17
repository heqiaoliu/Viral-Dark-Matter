function schema
% Defines properties for @timedata class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2005/06/27 22:56:32 $


% Register class (subclass)
p = findpackage('tsguis');
pparent = findpackage('wrfc');
c = schema.class(p, 'corrdata',findclass(pparent,'data'));

% Public properties
schema.prop(c, 'CData', 'MATLAB array');
schema.prop(c, 'Lags', 'MATLAB array');






