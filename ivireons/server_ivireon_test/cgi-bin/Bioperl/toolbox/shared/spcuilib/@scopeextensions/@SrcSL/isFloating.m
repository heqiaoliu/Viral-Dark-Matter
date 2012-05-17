function y = isFloating(this)
%isFloating Determine if connect-mode is 'floating'

% Copyright 2005 The MathWorks, Inc.

y = strcmpi(this.ConnectionMode,'floating');

% [EOF]
