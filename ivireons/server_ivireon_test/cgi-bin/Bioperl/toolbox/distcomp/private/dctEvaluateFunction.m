function [out, errOut, textOut] = dctEvaluateFunction(fcn, nOut, args, captureText) %#ok<INUSL> - Input args used in evalc 

% Copyright 2006-2008 The MathWorks, Inc.

% evalc a function which CANNOT error. Thus the textOut variable will
% contain all the textual output and will always exist.
[textOut, out, errOut] = evalc('iEvaluateWithNoErrors(fcn, nOut, args)');
% If that task has not requested output then set it to nothing.
if ~captureText
    textOut = '';
end

function [out, errOut] = iEvaluateWithNoErrors(fcn, nOut, args) %#ok<DEFNU> - used by wrapping function
out = {};
try
    % MATLAB is not good at asking for zero output arguments, try for example 
    % clear
    % [x{1:0}] = feval(@matlabroot)
    % So we will distinguish between nOut == 0 and anything else
    if nOut > 0
        [out{1:nOut}] = feval(fcn, args{:});
    else
        feval(fcn, args{:});
    end
    errOut = MException('', '');
catch errOut
end
