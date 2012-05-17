function handleButtons(this,arg)
%HANDLEBUTTONS Handle buttons in hierarchy viewer.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:30:30 $

hDlg = this.dialog;
switch lower(arg)
    case 'select'
        % User clicked on a selection in the tree
        % Get concatenated-string corresponding to this location
        %   'top/child/subchild/node'
        % Note: could be a numeric empty if no selection is made
        %   (i.e., used to have one entry selected, then a click
        %    is made that does not highlight any entry ... in this
        %    case, [] is the widget value)
        % We translate this to an empty STRING, which is the
        % type of .dialogSelection
        treeNodeStr = hDlg.getWidgetValue('tree');
        if isempty(treeNodeStr), treeNodeStr=''; end
        
        % Pass the path (or empty string) via an object property
        this.dialogSelection = treeNodeStr;
        hDlg.refresh;  % Update the dialog
        
    case 'refresh'
        this.show;
        
    otherwise % 'close'
        delete(hDlg);  % close dialog
end

% [EOF]
