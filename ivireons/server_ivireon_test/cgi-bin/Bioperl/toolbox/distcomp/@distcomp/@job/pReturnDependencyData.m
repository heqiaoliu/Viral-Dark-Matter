function [fileList, zipData] = pReturnDependencyData(job)
; %#ok Undocumented
%pReturnDependencyData 
%
%  [FILELIST, ZIPDATA] = pReturnDependencyData(JOB)

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.6 $    $Date: 2008/09/13 06:51:32 $ 

proxyJob = job.ProxyObject;
if ~isempty(proxyJob)
    try
        fileList = cell(proxyJob.getFileDepPathList(job.UUID));
        itemList = proxyJob.getFileDepData(job.UUID);
        data = itemList(1).getData;
        if ~isempty(data) && data.limit > 0
            % Define the type of the output as int8 to conform with the
            % input type required by zip.
            zipData = distcompByteBuffer2MxArray(data, int8([]));
        else
            zipData = int8([]);
        end
        itemList(1).delete();
    catch err
        throw(distcomp.handleJavaException(job, err));
    end
end
