function [success,errMsg] = preApply(this)
%PREAPPLY PreApply actions.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/06/11 16:05:31 $

[success, exception] = validate(this);

this.LastErrorCondition = exception;
if success
    errMsg = '';
    set(this.Driver.ConfigDb, 'AllowConfigEnableChangedEvent', false);
else
    errMsg = exception.message;
end

% [EOF]
