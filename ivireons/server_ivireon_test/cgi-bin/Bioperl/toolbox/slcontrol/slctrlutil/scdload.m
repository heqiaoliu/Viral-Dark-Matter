function scdload(projfile, projname, selectedname)
% SCD_LOAD_PROJECT Load project from a file
% PROJFILE Project file name
% PROJNAME Project node name (label)
% SELECTEDNAME Default selected node name (label)
%
% ATTN: Will call pre/postload

% Author(s): John Glass
% Revised: 
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2008/12/04 23:28:04 $

% Load the project
explorer.loadProject(projfile);

% Get the loaded projects
[F,W] = slctrlexplorer('initialize');
projects = W.getChildren;

% Find given project
if isempty(projects)
  return
end
p = find(projects, 'Label', projname);

% Return if project already exists and don't want to replace it.
if isempty(p)
  return
end

% Find and set selected node
h = find(p, 'Label', selectedname);

if ~isempty(h)
  F.setSelected( h.getTreeNodeInterface );
  drawnow;
  F.setVisible(1);
end