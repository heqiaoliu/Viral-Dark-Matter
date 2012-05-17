function allValues = pGetStruct(obj)
; %#ok Undocumented
%Returns all the values stored in this configuration.
%

%  Copyright 2007 The MathWorks, Inc.
    
allValues = struct('Description', obj.Description);
% Store the values for the findResource section in allValues.findResource.
% Same for job, task, etc.
for f = {'findResource', 'scheduler', 'job', 'paralleljob', 'task'}
    allValues.(f{1}) = obj.(f{1}).getEnabledStruct();
end

