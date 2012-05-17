function val = pGetFileDependencies(job, val)
; %#ok Undocumented
%pGetFileDependencies 
%
%  VAL = pGetFileDependencies(JOB, VAL)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:33:58 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        val = serializer.getField(job, 'filedependencies');
    end
end