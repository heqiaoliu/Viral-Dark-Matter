function [success,msg] = pDialogCallback(obj,action,dlg)
%PDIALOGCALLBACK - Dispatcher method for dialog callbacks

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:56:03 $

try
    [success,msg] = i_callback(obj,action,dlg);
catch E
    success = false;
    msg = E.message;
end

function [success,msg] = i_callback(obj,action,dlg)

success = true;
msg = '';
switch action
    case 'inputdlg'
        val = dlg.getWidgetValue('input');
        obj.pDialogData.InputDlgAnswer = val;
        cb = obj.pDialogData.Callback;
        if ~isempty(cb)
            if iscell(cb)
                feval(cb{:},val);
            else
                feval(cb,val);
            end
        end
    case 'listdlg'
        ind = dlg.getWidgetValue('list');
        if numel(ind)~=1
            DAStudio.error('Shared:message:SelectionRequired');
        end
        val = obj.pDialogData.ListString{ind+1};
        obj.pDialogData.ListDlgAnswer = val;
        cb = obj.pDialogData.Callback;
        if ~isempty(cb)
            if iscell(cb)
                feval(cb{:},val);
            else
                feval(cb,val);
            end
        end
    otherwise
        dependencies.assert(false,sprintf('Unexpected action: %s',action));
end


