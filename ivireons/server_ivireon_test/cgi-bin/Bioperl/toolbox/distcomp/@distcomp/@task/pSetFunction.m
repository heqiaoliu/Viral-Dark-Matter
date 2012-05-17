function val = pSetFunction(task, val)
; %#ok Undocumented
%PSETFUNCTION A short description of the function
%
%  VAL = PSETFUNCTION(TASK, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.8 $    $Date: 2008/02/02 13:01:12 $ 

import com.mathworks.toolbox.distcomp.util.ByteBufferItem

HAS_PROXY = task.HasProxyObject;
HAS_TASKINFO = ~isempty(task.TaskInfo);
% Need to test for both as the initializeation of the object wil not work correctly
if HAS_PROXY || HAS_TASKINFO
    % argument check here, so we don't get strange errors when the workers
    % attempt to evaluate the task
    if ~(isa(val, 'function_handle') || ischar(val))
        error('distcomp:task:InvalidProperty','Function must be a function_handle or string');
    end
    try
        % Serialize the function and wrap in the required java object
        s = distcompserialize(val);
        item = ByteBufferItem(distcompMxArray2ByteBuffer(s));
    catch err
        throw(distcomp.handleJavaException(task, err));
    end
    try
        if ~isempty(task.TaskInfo)
            task.TaskInfo.setMLFunction(item);
            % Cache the data that backs the ByteBuffer
            task.TaskInfoCache{end + 1} = s;
        elseif task.HasProxyObject
            % Put the data into a ByteBufferItem[] to pass to the proxy
            itemArray = dctJavaArray(item,...
                'com.mathworks.toolbox.distcomp.util.LargeDataItem');
            task.ProxyObject.setMLFunction(task.UUID, itemArray);
        end
    catch err
        throw(distcomp.handleJavaException(task, err));
    end
end
% Do not hold anything locally
val = [];
