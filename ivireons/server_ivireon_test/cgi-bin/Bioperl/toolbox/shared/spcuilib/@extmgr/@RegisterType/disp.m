function disp(this)
%DISP Display extension type (RegisterType) object.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/08/03 21:37:45 $

% Display to the command window:
% '    Type (Constraint:Order)'
% Ex:
% '    General (SelectAll:0)'
%
% Note: uses 4 leading spaces, so that display works
%       well with RegisterTypeDb display method.

fprintf('    %s (%s:%d)\n', ...
    this.Type, ...
    class(this.Constraint), ...
    this.Order);

% [EOF]
