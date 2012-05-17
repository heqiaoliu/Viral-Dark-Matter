function val = pGetName(job, val)
; %#ok Undocumented
%pGetName 
%
%  val = pGetName(JOB, val)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:34:03 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        val = char(serializer.getField(job, 'name'));
    end
end