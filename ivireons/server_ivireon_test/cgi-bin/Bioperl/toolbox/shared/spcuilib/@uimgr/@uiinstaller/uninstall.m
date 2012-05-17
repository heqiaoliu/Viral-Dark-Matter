function uninstall(hInstall,hTarget)
%UNINSTALL Uninstall plug-in tree from target application tree.
%   Automatically unrenders widgets during the uninstall process.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2006/05/09 23:41:04 $

if ~isempty(hInstall)
    % Check that the install data (plug-in) is self-consistent,
    % and that it is compatible with the target application GUI
    validate(hInstall,hTarget);
    deleteFromTarget(hInstall,hTarget);
end

% -----------------------------------------------------
function deleteFromTarget(hInstall,hTarget)
%deleteFromTarget Disconnect specified target application nodes.

numNodes = size(hInstall.Plan,1); % # rows = # nodes to install
for i = 1:numNodes
    srcNode = hInstall.Plan{i,1};
    tgtAddr = hInstall.Plan{i,2};

    % tgtAddr describes where the source (plug-in) nodes were installed.
    % But, not every child in .DestAddrs is from this source.
    % (There can be additional children!)
    % We must identify the specific children installed.
    %
    % Find path of the source node, and extract the top-level name
    % Ex: if getPath(srcChild) is 'top/mid/bot',
    %     then getFirstName() is 'top'
    %     and if tgtAddr is 'baseApp/Tools'
    %     then targetPath is 'baseApp/Tools/top'
    %
    targetPath = [tgtAddr '/' getFirstPathName(srcNode)];
    targetNode = findchild(hTarget,targetPath);
    if isempty(targetNode)
        error('uimgr:uiinstaller:SourceNotFound',...
            ['Failed to find installer path "%s"\n' ...
             'in target application.'],targetPath);
    end
    remove(targetNode);  % unrender/disconnect/fall out of scope
end

%%
function first = getFirstPathName(node)
% Return first level in path name
% Ex: if node path is 'one/two/three', we return 'one'.

p = getPath(node);
idx = find(p=='/');  % path delimiter
if isempty(idx)
    first = p;
else
    % return path chars up to but not including first slash found
    first = p(1:idx(1)-1);
end

% [EOF]
