function val = pSetName(job, val)
; %#ok Undocumented
%pSetName 
%
%  VAL = pSetName(JOB, VAL)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:34:24 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        serializer.putField(job, 'name', val);
    end
end
% Store nothing
val = '';