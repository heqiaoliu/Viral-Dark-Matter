function [success, msg] = preApply(this)
%PREAPPLY Pre-apply callback for the dialog.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/06/11 16:06:27 $

[success, exception] = validate(this);

this.LastErrorCondition = exception;
if success
    msg = '';
else
    msg = exception.message;
end

% [EOF]
