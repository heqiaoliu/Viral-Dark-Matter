function val = pGetCreateTime(job, val)
; %#ok Undocumented
%pGetCreateTime 
%
%  VAL = pGetCreateTime(JOB, VAL)

%  Copyright 2000-2006 The MathWorks, Inc.

%  $Revision $    $Date: 2006/06/27 22:33:56 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        val = char(serializer.getField(job, 'createtime'));
    end
end