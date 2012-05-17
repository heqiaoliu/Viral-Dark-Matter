function b = isEmpty(this)
%ISEMPTY  True if the database contains no children.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/03/13 19:45:51 $

% Camelcasing this method is important so we do not overwrite the builtin
% ISEMPTY, which can cause object displays to look ugly.

b = isempty(this.down);

% [EOF]
