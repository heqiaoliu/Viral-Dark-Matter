function val = pSetJobData(job, val)
; %#ok Undocumented
%PSETJOBDATA A short description of the function
%
%  VAL = PSETJOBDATA(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.8.7 $    $Date: 2008/02/02 12:59:58 $ 

import com.mathworks.toolbox.distcomp.util.ByteBufferItem

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    try
        s = distcompserialize(val);
        % Put the data into a ByteBufferItem[] to pass to the proxy
        itemArray = dctJavaArray(ByteBufferItem(distcompMxArray2ByteBuffer(s)),...
            'com.mathworks.toolbox.distcomp.util.LargeDataItem');
        proxyJob.setJobScopeData(job.UUID, itemArray);
    catch err
        throw(distcomp.handleJavaException(job, err));
    end
end
% Do not hold anything locally
val = [];