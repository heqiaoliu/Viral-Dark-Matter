function [success,exception] = validate(this)
%VALIDATE Validate settings of Dialog object
%   success: boolean status, 0=fail, 1=accept
%       err: error message, string

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/07/23 18:44:14 $

exception = MException.empty;
success = true;

% Could throw an error, so protect against this
try
    % Evaluate to see if an error will occur
    % If no error, cache result so we only need to do this once
    exprStr = this.dialog.getWidgetValue('mlvar');
    
    % Check for an empty string, and provide a useful error msg
    % ("expr=evalin(...)" yields a non-helpful error msg)
    if isempty(exprStr)
        success = false;
        [msg, id] = uiscopes.message('EmptyExpression');
        exception = MException(id, msg);
        return
    end
    this.mlvarEval = evalin('base', exprStr);
    
    % Expression could be further validated here
    
    % Copy eval'd result into object repository when valid:
    this.mlvar = exprStr;
    
catch e
    % Get the message from the MException object which does not have any
    % "Error in ==>" messages
    success = false;
    
    [msg, id] = uiscopes.message('EvaluationErrorOccurred', uiservices.cleanErrorMessage(e));
    exception = MException(id, msg);
end

% [EOF]
