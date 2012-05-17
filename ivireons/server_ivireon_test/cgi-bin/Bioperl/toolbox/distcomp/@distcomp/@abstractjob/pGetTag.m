function val = pGetTag(job, val)
; %#ok Undocumented
%pGetTag 
%
%  VAL = pGetTag(JOB, VAL)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:34:10 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        val = serializer.getField(job, 'tag');
    end
end