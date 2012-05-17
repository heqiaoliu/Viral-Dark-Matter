function state = pGetStateFromStorage(job)
; %#ok Undocumented
%pGetStateFromStorage 
%
%  VAL = pGetStateFromStorage(JOB)

%  Copyright 2008 The MathWorks, Inc.

%  $Revision: 1.1.6.1 $    $Date: 2008/05/19 22:44:49 $ 

serializer = job.Serializer;

if ~isempty(serializer)
    try
        state = char(serializer.getField(job, 'state'));
    catch err %#ok<NASGU>
        state = 'unavailable';        
    end
else
    state = 'unavailable';    
end