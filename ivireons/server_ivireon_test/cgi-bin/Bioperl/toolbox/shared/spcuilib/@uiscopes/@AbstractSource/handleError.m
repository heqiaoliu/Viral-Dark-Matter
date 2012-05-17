function handleError(this)
%HANDLEERROR Handle and error condition.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/27 19:55:38 $

uiscopes.errorHandler(this.ErrorMsg, [this.Application.getAppName(true) ' Error']);

% [EOF]
