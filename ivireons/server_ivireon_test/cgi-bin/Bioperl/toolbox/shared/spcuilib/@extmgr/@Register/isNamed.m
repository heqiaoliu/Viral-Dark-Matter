function y = isNamed(this,theType,theName)
%ISNAMED True if Register object has matching type and name.
%   ISNAMED(H,TYPE,NAME) returns true if extension registration
%   has matching TYPE and NAME strings.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/04/09 19:04:33 $

y = strcmpi(this.Type, theType);
if nargin > 2
    y = y && strcmpi(this.Name, theName);
end

% [EOF]
