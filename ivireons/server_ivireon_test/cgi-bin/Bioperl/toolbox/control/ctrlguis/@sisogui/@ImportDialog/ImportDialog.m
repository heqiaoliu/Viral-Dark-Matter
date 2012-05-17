function h = ImportDialog(sisodb,Parent)
%ImportDialog  Constructor for ImportDialog.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/12/04 22:22:08 $


% Create class instance
h = sisogui.ImportDialog;

if nargin == 1
    h.Parent = [];
else
    h.Parent = Parent;
end
    
h.sisodb = sisodb;
h.Design = sisodb.Loopdata.exportdesign;
h.setImportList;

if isempty(h.ImportList)
    % Compensators with constraints or fixed dynamics do not show up in
    % import dialog
    warndlg(sprintf('All compensators have constraints which prevent the use of the import dialog. Use the compensator editor to modify compensator parameters'),xlate('Import Warning'),'modal');
else
    h.buildDialog;
    h.refreshtable;
    if isequal(h.Design.Configuration ,0)
        %Use left truncate renderer for scd case
        import com.mathworks.toolbox.control.tableclasses.*;
        h.Handles.Table.setDefaultRenderer(h.Handles.Table.getColumnClass(0),MyTruncateRenderer);
    end
    h.Handles.Frame.setLocationRelativeTo(h.Parent);
end

