function addFileDependenciesToPool(~, dependencyDir, dependencyMap)
; %#ok Undocumented

%   Copyright 2009 The MathWorks, Inc.

% Get the current Session's FileDependencyAssistant
fda = com.mathworks.toolbox.distcomp.pmode.SessionFactory.getCurrentSession.getFileDependenciesAssistant;
% Set the dependency directory
fda.setDependencyDir(dependencyDir);
% Add the elements from the map to the assistant
for i = 1:size(dependencyMap, 1)
    fda.addDependency(dependencyMap{i, 1}, dependencyMap{i, 2});
end
