function newEx = pctTransformRemoteException( cause )
%pctTransformRemoteException - transform a remote exception for local display

% Used by pctAddRemoteCause

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2009/07/18 15:50:30 $

oldMsg   = cause.message;
oldId    = cause.identifier;
oldStack = cause.stack;

stackToPrint = '';

for ii=1:length( oldStack )
    frame = oldStack(ii);
    [~, displayFile] = fileparts( frame.file );
    
    % Only include stack frames up to the remote transition point
    if iFrameIsTransitionToRemote( displayFile, frame.name )
        break;
    end
    
    % Choose how to display the function
    if ~strcmp( displayFile, frame.name )
        displayItem = sprintf( '%s>%s', displayFile, frame.name );
    else
        displayItem = sprintf( '%s.m', displayFile );
    end
    
    stackToPrint = sprintf( '%s\n%s at %s', ...
                            stackToPrint, displayItem, num2str( frame.line ) );
end

if isempty( stackToPrint )
    stackToPrint = sprintf( '\n(No remote error stack)' );
end

newMsg = sprintf( '\n%s\n\nError stack:%s', oldMsg, stackToPrint );
newEx  = MException( oldId, '%s', newMsg );

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iFrameIsTransitionToRemote - check a given stack frame to see if this is
% the point at which "remote" execution starts
function tf = iFrameIsTransitionToRemote( file, fcn )

% Incorporate the known elements on the stack which are the transition to
% remote execution
tf = ( strcmp( file, 'parallel_function' ) ) || ...
     ( strcmp( file, 'LocalSpmdExecutor' ) && ...
       strcmp( fcn, 'LocalSpmdExecutor.initiateComputation' ) ) || ...
     ( strcmp( file, 'remoteBlockExecution' ) );
end
