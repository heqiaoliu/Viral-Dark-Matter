function storedEnv = pClearEnvironmentBeforeSubmission
; %#ok Undocumented
%pClearEnvironmentForExecution - clear various environment variables
%   Various schedulers (such as LSF) default to forwarding all environment
%   variables to the workers. This function clears environment variables
%   that could interfere with correct operation on the worker.

% Copyright 2006 The MathWorks, Inc.

% Might want to add HOME to the list below?
fields = { 'ARCH', 'MATLAB', 'MATLABPATH', 'MATLAB_ARCH', 'BASEMATLABPATH', 'OS' };

% Pre-allocate the storedEnv return
fieldsAndValues = repmat( fields, 2, 1 );
storedEnv = struct( fieldsAndValues{:} );

for ii=1:length( fields )
    storedEnv.(fields{ii}) = getenv( fields{ii} );
    setenv( fields{ii}, '' );
end