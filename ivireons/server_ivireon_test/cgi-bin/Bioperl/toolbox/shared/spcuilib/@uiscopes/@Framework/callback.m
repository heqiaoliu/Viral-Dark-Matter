function callback(this, callbackFcn, warningFcn)
%CALLBACK Generic callback function for use by extensions.
%   CALLBACK(H, FCN, WARNFCN) Execute FCN, handle warnings and error
%   conditions.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/09 19:34:55 $

% Turn off warnings.
w = warning('off'); %#ok<WNOFF>

% Cache the old warning state and set lastwarn to empty.
[oldWarningString, oldWarningID] = lastwarn('');

try
    
    % Fire the callback that we've been given.
    callbackFcn();
    
    % Check for warnings.
    [warningString, warningID] = lastwarn;
    
    if ~isempty(warningString)
        
        % The caller to define the category, summary and details.
        [category, summary, details] = warningFcn(warningString, warningID);
        
        this.MessageLog.add('warn', category, summary, details);
    end
    
    % Reset the last warning state.
    lastwarn(oldWarningString, oldWarningID);
    
    % Reset the warning state.
    warning(w);
    
catch me
    
    % Reset the last warning state.
    lastwarn(oldWarningString, oldWarningID);
    
    % Reset the warning state.
    warning(w);
    
    % All errors are thrown to an error dialog, not the message log.  We
    % want a "hard" interrupt here and the message log is more passive.
    uiscopes.errorHandler(me.message);
end

% [EOF]
