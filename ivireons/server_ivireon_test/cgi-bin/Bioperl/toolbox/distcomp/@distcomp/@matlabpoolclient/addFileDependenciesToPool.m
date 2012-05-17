function addFileDependenciesToPool(obj, dependencyDir, dependencyMap)
; %#ok Undocumented

%   Copyright 2009 The MathWorks, Inc.

% If we are running just on the client none of the following is needed.
if obj.IsClientOnlySession
    return
end
% Get the current Session's FileDependencyAssistant
fda = com.mathworks.toolbox.distcomp.pmode.SessionFactory.getCurrentSession.getFileDependenciesAssistant;
% Set the dependency directory
fda.setDependencyDir(dependencyDir);
% Add the elements from the map to the assistant - since we are a client we
% are the source of the dependencies and need to add them in a similar way
% to the client.
for i = 1:size(dependencyMap, 1)
    fda.addDependency(dependencyMap{i, 1}, dependencyMap{i, 2});
end
