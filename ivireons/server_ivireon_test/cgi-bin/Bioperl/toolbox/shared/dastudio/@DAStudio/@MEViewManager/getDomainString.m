function domainName = getDomainString(this, obj)
% Return domain string for the passed object. It is roughly a package
% name except for some special cases.

%   Copyright 2009 The MathWorks, Inc.

% By default it is 'Other'
domainName = 'Other';
% Check for Shortcuts
if isa(obj, 'DAStudio.Shortcut')
    obj = obj.getForwardedObject;
end
% Get Package information.
classH = classhandle(obj);
if ~isempty(classH)
    packageName = classH.Package.Name;
    if ~isempty(packageName)
        domainName = packageName;
        % Special case for Workspace
        if isa(obj, 'DAStudio.WorkspaceNode')
            domainName = 'Workspace';
        elseif isa(obj, 'Simulink.code') || isa(obj, 'Simulink.ModelAdvisor') ...
            || isa(obj, 'Simulink.Root') || isa(obj, 'Simulink.ConfigSet') ...
            || isa(obj, 'Simulink.Directory')
            domainName = 'Other';
        end
        % TODO: Add more special cases if needed.
    end
end
% Get actual domain by this name.
domainInfo = find(this.Domains, 'Name', domainName);
% Check if this domain really exists. If not, create it at run time.
if isempty(domainInfo)
	this.createDomain(domainName);
end