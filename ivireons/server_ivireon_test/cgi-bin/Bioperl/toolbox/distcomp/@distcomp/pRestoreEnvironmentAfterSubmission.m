function pRestoreEnvironmentAfterSubmission( storedEnv )
; %#ok Undocumented
%pRestoreEnvironmentAfterSubmission - the counterpart to pClearEnvironmentBeforeSubmission.a
%   Call this to restore all the environment variables cleared by that
%   function.

% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2006/06/27 22:33:39 $

fields = fieldnames( storedEnv );
for ii=1:length( fields )
    setenv( fields{ii}, storedEnv.(fields{ii}) );
end