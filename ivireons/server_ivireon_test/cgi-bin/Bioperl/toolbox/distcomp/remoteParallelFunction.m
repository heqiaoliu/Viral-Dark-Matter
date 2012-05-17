function [ERROR, out] = remoteParallelFunction(init, data, isFinalInterval)
; %#ok Undocumented

% Copyright 2007-2010 The MathWorks, Inc.
% $Revision: 1.1.6.8 $   $Date: 2010/03/22 03:41:46 $

persistent channel;
mlock;

try
    notFound = false;
    % Channel construction data supplied
    if ~isempty( init ) && init.get.capacity() > 0
        
        % Make sure that numlabs and labindex are 1 during a parfor, and that
        % Matlab files are re-interpreted as necessary.
        pctPreRemoteEvaluation( 'mpi_mi' );
        
        % If there are 2 inputs then the first represents a serialized
        % cell array that gives the relevant information to reconstruct
        % the channel - the form is @FH = {@FH, args}
        [C, notFound] = iDeserializeByteBuffer(init);
        init.free;
        channel = feval(C{1}, C{2:end});
    end

    % Iterate data supplied
    if ~isempty(data) && data.get.capacity() > 0
        channelArgs = distcompdeserialize(distcompByteBuffer2MxArray(data.get));
        data.free;
        out = distcompMakeByteBufferHandle(distcompserialize(feval(channel, channelArgs{:})));
    end
    
    % Indicate that no error occurred
    ERROR = false;
catch err
    ERROR = true;
    if notFound
        theErr = MException('distcomp:parfor:SourceCodeNotAvailable', ...
            'Lab unable to find file.');
         theErr = addCause(theErr, err);
         out = distcompMakeByteBufferHandle(distcompserialize(theErr));
    else
        out = distcompMakeByteBufferHandle(distcompserialize(err));
    end
end

if isFinalInterval || ERROR
    channel = [];
    % Reset the MPI layer after a parfor
    dctRegisterMpiFunctions('mwmpi');
end

% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
function [data, functionNotFound] = iDeserializeByteBuffer(buffer)
% Make sure that we turn off the UnresolvedFunctionHandle warning whilst
% loading data that is likely to throw this warning. Also reset the
% lastwarn to nothing so that we know the deserialization actually threw
% this issue
state = warning('off', 'MATLAB:dispatcher:UnresolvedFunctionHandle');
try
    [lastMsg, lastID] = lastwarn('');
    % Deserialize the byte buffer
    data = distcompdeserialize(distcompByteBuffer2MxArray(buffer.get));
    % Check lastwarn to see if the function was not found?
    [aMsg, anID] = lastwarn;
    functionNotFound = strcmp(anID, 'MATLAB:dispatcher:UnresolvedFunctionHandle');
    % Reset the lastwarn and warning state 
    lastwarn(lastMsg, lastID);
catch E
    warning(state);
    rethrow(E);
end
warning(state);
