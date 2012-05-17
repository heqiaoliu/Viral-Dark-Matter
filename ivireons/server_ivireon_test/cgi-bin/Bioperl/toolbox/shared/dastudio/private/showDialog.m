%
% open a dialog for a given object or bring the dialog forward if it is
% already open
%
function dlg = showDialog(obj, option, tag)

%   Copyright 2009 The MathWorks, Inc.

dlg = DAStudio.ToolRoot.getOpenDialogs(obj);
found = false;

for i = 1:length(dlg)
    if strcmp(dlg(i).dialogTag, tag)
        found = true;
        dlg(i).show;
        break;
    end
end
if ~found
    dlg = DAStudio.Dialog(obj, option, 'DLG_STANDALONE');
end