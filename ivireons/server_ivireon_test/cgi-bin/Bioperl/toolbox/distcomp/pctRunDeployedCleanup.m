function pctRunDeployedCleanup
% PCTRUNDEPLOYEDCLEANUP
%
% Force the cleanup function in pMCRShutdownHandler to run.
%
% After this has been called PCT functionality should not
% be used in the current MATLAB session.
%

% Copyright 2008 The MathWorks, Inc.

pMCRShutdownHandler( 'run' );
    
    
    
