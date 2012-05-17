function setDatapanel(this, newPanel, selectedNode)
%SETDATAPANEL Hide the old panel and show the new one.
%   This method will delegate to the SETPANELVISIBILITY methods
%   of the old (becoming invisible) and new (becoming visible) panels.
%
%   Function arguments
%   ------------------
%   THIS: the object instance.
%   NEWPANEL: the panel (handle) to display, or a string representing text.
%       The text may be 'default', in which case a default string is
%       displayed.
%   SELECTEDNODE: The node which was selected, and which is responsible
%       for displaying the particular panel.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/02/06 14:22:42 $

    if ischar(newPanel)
        % Display the string in a panel.
        hText = findobj(this.noDataPanel.mainPanel,'type', 'uicontrol');
        if strcmpi('default', newPanel)
            if numOpenFiles(this)
                newPanel = 'Select objects from tree to begin.';
            else
                newPanel = 'Open a file to begin.';
            end
        end
        set(hText, 'String', sprintf('\n%s', xlate(newPanel)));
        newPanel = this.noDataPanel;
    end

    % Hide the old panel
    this.currentPanel.setPanelVisibility(false);
    this.currentPanel = newPanel;
    % Show the new panel
    if nargin==2
        newPanel.setPanelVisibility(true);
    else
        newPanel.setPanelVisibility(true, selectedNode);
    end

end

function num = numOpenFiles(this)
    % A method to determine the number of open files.
    hdfRootNode = get(this.treeHandle,'Root');
    num = get(hdfRootNode, 'ChildCount');
end

