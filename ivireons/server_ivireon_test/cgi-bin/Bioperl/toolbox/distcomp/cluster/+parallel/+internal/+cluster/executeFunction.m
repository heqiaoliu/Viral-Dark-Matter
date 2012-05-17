function varargout = executeFunction(fcn, fcnNumArgsOut, fcnArgsIn, workerCwd)

%  Copyright 2010 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $  $Date: 2010/03/22 03:42:10 $

% NB It is very important that the number of output arguments requested from
% executeFunction is EQUAL to the number of output arguments that the user originally
% requested for fcn.  Note that only PCT code calls executeFunction, so this is just 
% a sanity check.
if nargout ~= fcnNumArgsOut
    fcnName = fcn;
    if isa(fcn, 'function_handle')
        fcnName = func2str(fcn);
    end
    error('distcomp:batch:InconsistentNumberOfOutputArguments', ...
        '%d output arguments were requested from %s, but %d were requested from %s', ...
        nargout, mfilename, fcnNumArgsOut, fcnName);
end

% Let's try and deal with the CWD to make this work in a shared file=system
% - NOTE any errors we will stick with the current CWD and try and continue
try
    cd(workerCwd);
catch err
    warning('distcomp:batch:ErrorSettingCurrentDirectory', ...
        ['Unable to change to requested folder: %s.\n', ...
        'Current folder is: %s.\nReason: %s'], ...
        workerCwd, pwd, err.message);
end

% MATLAB is not good at asking for zero output arguments, try for example 
% clear
% [x{1:0}] = feval(@matlabroot)
% So we will distinguish between fcnNumArgsOut == 0 and anything else
if fcnNumArgsOut > 0
    varargout = cell(fcnNumArgsOut, 1);
    [varargout{1:fcnNumArgsOut}] = feval(fcn, fcnArgsIn{:});
else
    feval(fcn, fcnArgsIn{:});
end
