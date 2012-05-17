function val = pSetTag(job, val)
; %#ok Undocumented
%pSetTag 
%
%  VAL = pSetTag(JOB, VAL)

%  Copyright 2004-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:34:30 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        serializer.putField(job, 'tag', val);
    end
end
% Store nothing
val = '';