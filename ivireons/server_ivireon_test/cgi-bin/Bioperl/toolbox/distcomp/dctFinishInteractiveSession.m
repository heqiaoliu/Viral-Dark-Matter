function dctFinishInteractiveSession
; %#ok Undocumented

% Copyright 2006-2008 The MathWorks, Inc.

% This function should be called to finish any interactive session
% that has been started by a parallel job that has pIsInteractiveJob
% true. The behaviour is to pick up the saved post functions that 
% would have normally run in a non-interactive job and run them now.

root = distcomp.getdistcompobjectroot;

try
    % Make sure that the session has the correct MPI functions to terminate 
    dctRegisterMpiFunctions('mwmpi');
    dctStoreFunctionArray('run');
catch e
    if isa(e, 'distcomp.ExitException')
        root.CurrentErrorHandlers.errorFcn(e.CauseException, 'Unexpected error in %s - MATLAB will now exit and restart.', e.message);
    else
        root.CurrentErrorHandlers.errorFcn(e, 'Unexpected error whilst finishing an interactive task - MATLAB will now exit.');
    end
end