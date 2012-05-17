function val = pSetInputArguments(task, val)
; %#ok Undocumented
%PSETINPUTARGUMENTS A short description of the function
%
%  VAL = PSETINPUTARGUMENTS(TASK, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.8 $    $Date: 2008/02/02 13:01:14 $ 

import com.mathworks.toolbox.distcomp.util.ByteBufferItem

HAS_PROXY = task.HasProxyObject;
HAS_TASKINFO = ~isempty(task.TaskInfo);
% Need to test for both as the initializeation of the object wil not work correctly
if HAS_PROXY || HAS_TASKINFO
    % Check we have been sent something sensible
    if ~(iscell(val) && (isvector(val) || isempty(val)))
        error('distcomp:task:InvalidProperty','InputArguments must be a vector cell array');
    end
    try
        s = distcompserialize(val);
        item = ByteBufferItem(distcompMxArray2ByteBuffer(s));
    catch err
        throw(distcomp.handleJavaException(task, err));
    end
    try
        if ~isempty(task.TaskInfo)
            task.TaskInfo.setInputData(item);
            % Cache the data that backs the ByteBuffer
            task.TaskInfoCache{end + 1} = s;
        elseif task.HasProxyObject
            % Put the data into a ByteBufferItem[] to pass to the proxy
            itemArray = dctJavaArray(item,...
                'com.mathworks.toolbox.distcomp.util.LargeDataItem');
            task.ProxyObject.setInputData(task.UUID, itemArray);
        end
    catch err
        throw(distcomp.handleJavaException(task, err));
    end
end
% Do not hold anything locally
val = [];
