function obj = remoteparfor(maxLabsToAcquire, varargin)
; %#ok Undocumented

%   Copyright 2007-2008 The MathWorks, Inc.

%   $Revision: 1.1.6.8 $  $Date: 2009/02/06 14:16:55 $

obj = distcomp.remoteparfor;

session = com.mathworks.toolbox.distcomp.pmode.SessionFactory.getCurrentSession;
if isempty(session) || ~session.isPoolManagerSession
    error('distcomp:remoteparfor:UnableToConstruct', 'No current session exists to connect a parfor controller to');
end
try
    % Make a new parfor controller - this might throw a
    % SessionDestroyedException
    p = session.createParforController;
catch err
    [isJavaError, exceptionType] = isJavaException(err);
    if ~isempty(regexp(exceptionType, 'SessionDestroyedException', 'once'))
        error('distcomp:remoteparfor:UnableToConstruct', 'No running session exists to connect a parfor controller to');
    elseif isequal( exceptionType, 'com.mathworks.toolbox.distcomp.pmode.CannotAcquireLabsException' )
        error( 'distcomp:remoteparfor:NoLabsAvailable', ...
               ['No labs from the matlabpool were available for remote execution.', ...
                'This could be because a previous SPMD block or PARFOR loop failed to complete correctly ', ...
                'and was interrupted. If this problem persists, you may need to restart the ', ...
                'matlabpool.'] );
    else
        rethrow(err);
    end
end
try
    obj.Session = session;
    obj.ParforController = p;
    % Get the IntervalReturnQueue
    obj.IntervalCompleteQueue = p.getIntervalCompleteQueue;
    % Try to acquire some labs
    obj.NumWorkers = p.acquireLabs(int32(maxLabsToAcquire));
    % Serialize the initialization data and store it locally
    spmdlang.BaseRemote.saveLoadCount( 'clear' );
    obj.SerializedInitData = distcompMakeByteBufferHandle(distcompserialize(varargin));
    p.beginLoop(obj.SerializedInitData);
    % Listen for object destruction to interrupt if we exit the parfor loop prematurely
    obj.ObjectBeingDestroyedListener = handle.listener(obj, 'ObjectBeingDestroyed', {@pObjectBeingDestroyed});
    
    % Error if we're about to broadcast Composites to the labs
    if spmdlang.BaseRemote.saveLoadCount( 'get' ) ~= 0
        error( 'distcomp:remoteparfor:IllegalComposite', ...
            'Composite objects may not used within a parfor loop' );
    end
catch err
    % If anything goes wrong during construction of this interface then we
    % need to clean up the parfor controller, otherwise all subsequent
    % parfor statements will revert to running locally.
    p.interrupt;
    rethrow(err);
end
