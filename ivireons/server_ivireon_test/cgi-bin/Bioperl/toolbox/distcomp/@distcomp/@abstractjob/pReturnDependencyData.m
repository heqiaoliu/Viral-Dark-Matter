function [fileList, zipData] = pReturnDependencyData(job)
; %#ok Undocumented
%pReturnDependencyData 
%
%  [FILELIST, ZIPDATA] = pReturnDependencyData(JOB)

%  Copyright 2005-2008 The MathWorks, Inc.

%  $Revision: 1.1.10.5 $    $Date: 2008/05/05 21:35:36 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        values = serializer.getFields(job, {'filedependencies' 'filedata'});
        [fileList, zipData] = deal(values{:});
    catch err
        error('distcomp:job:CorruptData', ...
            'Unable to read the file dependency data from storage.\nNested error :%s', err.message);
    end
end