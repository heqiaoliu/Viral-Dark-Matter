function val = pGetPathDependencies(job, val)
; %#ok Undocumented
%pGetPathDependencies 
%
%  VAL = pGetPathDependencies(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:34:04 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        val = serializer.getField(job, 'pathdependencies');
    end
end