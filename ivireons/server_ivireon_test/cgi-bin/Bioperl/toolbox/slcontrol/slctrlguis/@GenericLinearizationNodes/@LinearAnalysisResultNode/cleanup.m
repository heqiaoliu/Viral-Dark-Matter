function cleanup(this)
% CLEANUP  Clean up the node
%
 
% Author(s): John W. Glass 08-Dec-2006
% Copyright 2006 The MathWorks, Inc.
% $$ $$

if ~isempty(this.Dialog)
    if ~isempty(this.InspectorNode)
        % Set the workspace node as the root
        Root = this.Handles.ExplorerTreeManager.Root;
        Root.removeNode(Root.getChildren);
        javaMethodEDT('cleanup',this.Handles.ExplorerTreeManager.ExplorerPanel);
        delete(this.Handles.ExplorerTreeManager);
    end
    javaMethodEDT('clearTabPane',this.Dialog);
    this.Dialog = [];
end