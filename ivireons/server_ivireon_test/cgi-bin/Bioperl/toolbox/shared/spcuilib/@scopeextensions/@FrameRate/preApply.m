function [success, err] = preApply(this)
%PREAPPLY Called before apply the dialog changes by DDG.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/06/11 16:05:48 $

% Call the validate method to do the checking.
[success, exception] = validate(this);

% Save the exception (could be []) in the object for later testing.
this.LastErrorCondition = exception;

% If the validation is successful, disable the Event from being sent until
% the postApply so that we can send the event there after everything has
% been set properly.
if success
    err = '';
    this.SendEvent = false;
else
    err = exception.message;
end

% [EOF]
