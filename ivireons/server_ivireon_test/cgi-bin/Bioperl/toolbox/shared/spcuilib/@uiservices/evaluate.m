function [value, errId, errStr] = evaluate(str, name)
%EVALUATE   Evaluate variables in the MATLAB workspace.
%
%   EVALUATE will take a string (or cell array of strings)
%   representing filter coefficients or the Sampling frequency and evaluate
%   it in the base MATLAB workspace. If the variables exist and are numeric, the
%   workspace variables values are returned in VALS, if they do not exist, an
%   error dialog is launched and the error message is returned in ERRSTR.
%
%   Input:
%     strs   - String or cell array of strings from edit boxes
%     names  - String or cell array of names for the edit boxes.  This
%              allows EVALUATEVARS to give customized error messages if the
%              editboxes are empty.  If this input is not given a generic
%              message 'Editboxes cannot be empty.' will be given.  If this
%              input is empty it will be ignored.
%
%   Outputs:
%     vals   - Values returned after evaluating the input strs in the
%              MATLAB workspace.
%     errId  - Error identifier returned if evaluation failed.
%     errStr - Error string returned if evaluation failed.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/12/07 20:45:13 $

if nargin < 2
    name = '';
end

errStr = '';
errId  = '';

value = [];
if isempty(str),
    if isempty(name)
        [errStr, errId] = uiservices.message('EvaluateEmptyEditBox');
    else
        [errStr, errId] = uiservices.message('EvaluateEmptyNamedEditBox', name);
    end
else
    try
        value = evalin('base',['[' str ']']);
        if ~isnumeric(value)
            [errStr, errId] = uiservices.message('EvaluateNonNumeric', str);
        end
    catch e %#ok
        [errStr, errId] = uiservices.message('EvaluateUndefinedVariable', str);
    end
end

if nargout < 2 && ~isempty(errStr);
    error(errId, errStr); % Top level try catch will display the error dialog.
end

% [EOF]
