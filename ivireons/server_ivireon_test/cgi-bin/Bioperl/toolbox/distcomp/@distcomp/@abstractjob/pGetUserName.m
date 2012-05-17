function val = pGetUserName(job, val)
; %#ok Undocumented
%pGetUserName 
%
%  VAL = pGetUserName(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:34:12 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        val = serializer.getField(job, 'username');
    end
end