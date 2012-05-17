function schema
% Defines properties for @timedata class.
%
%   Author(s): James G. Owen
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2005/07/14 15:28:26 $


% Register class (subclass)
p = findpackage('tsguis');
pparent = findpackage('wrfc');
c = schema.class(p, 'xydata',findclass(pparent,'data'));

% Public properties
schema.prop(c, 'XData', 'MATLAB array');
schema.prop(c, 'YData', 'MATLAB array');






