function pMCRShutdownHandler( input )
% PMCRSHUTDOWNHANDLER
%
% PMCRSHUTDOWNHANDLER( 'initialize' ) creates a persistent mlock'd 
% onCleanup object with a cleanup function that calls 
% MCRShutdownHandler.runShutdownHooks().
%
% PMCRSHUTDOWNHANDLER( 'run' ) forces the cleanup function to run.
%

% Copyright 2008 The MathWorks, Inc.


% Do nothing if we are not deployed.
if ~isdeployed
    return;
end

persistent cleanup;

error( nargchk(1,1,nargin) );

switch input
    case 'initialize'    
        % Make sure all clients try and init the MatlabRefStore - this will fail if
        % we try and init from a different MCR than previously called this.
        com.mathworks.toolbox.distcomp.util.MatlabRefStore.initMatlabRef();          
    
        com.mathworks.toolbox.distcomp.util.MCRShutdownHandler.registerForCurrentMCR();       
    
        if isempty( cleanup )
            % Initialize the MCRShutdownHandler
            com.mathworks.toolbox.distcomp.util.MCRShutdownHandler.initializeForCurrentMCR();
            % onCleanup objects causing problems - see G475153
            % cleanup = onCleanup( @iRunShutdownHooks );
            cleanup = true;
        end
        mlock;
  case 'run'
      cleanup = [];
      iRunShutdownHooks();
  otherwise
      error( 'distcomp:pMCRShutdown:InvalidArgument', 'Input must be ''initialize'' or ''run''' );
end

function iRunShutdownHooks
com.mathworks.toolbox.distcomp.util.MCRShutdownHandler.runShutdownHooksForCurrentMCR();
