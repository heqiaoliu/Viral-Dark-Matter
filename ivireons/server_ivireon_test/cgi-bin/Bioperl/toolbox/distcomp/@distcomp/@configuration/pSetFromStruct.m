function pSetFromStruct(obj, allValues)
; %#ok Undocumented
%Sets the values of this object to be those found in the input struct.
%

%  Copyright 2007 The MathWorks, Inc.

try
    obj.Description = allValues.Description;
catch
    % The description wasn't provided to us.
end

% The values for the findResource section are stored in allValues.findResource.
% Same for job, task, etc.
for f = {'findResource', 'scheduler', 'job', 'paralleljob', 'task'}
    try
        sectionValues = allValues.(f{1});
        obj.(f{1}).setFromEnabledStruct(sectionValues);
    catch
        % Most likely, no values was provided in the struct.
    end
end
    
