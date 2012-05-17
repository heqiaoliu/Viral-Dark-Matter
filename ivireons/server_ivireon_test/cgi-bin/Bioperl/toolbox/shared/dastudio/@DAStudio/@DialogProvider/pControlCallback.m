function pControlCallback(obj,action,dlg)
%PCONTROLCALLBACK - Dispatcher method for callbacks from dialog controls

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:56:02 $

if strcmp(action,'ErrorDlg')
    % Just delete the dialog.  This will cause the "waitfor" in "errordlg"
    % to return.
    delete(dlg);
elseif strcmp(action,'MsgBox')
    % Just delete the dialog.  This will cause the "waitfor" in "msgbox"
    % to return.
    delete(dlg);
elseif strncmp(action,'QuestDlg_',9)
    val = action(10:end);
    obj.pDialogData.QuestDlgValue = val;
    % This will cause the "waitfor" in "errordlg" to return.
    delete(dlg);
    % Execute the callback if there is one.
    cb = obj.pDialogData.Callback;
    if ~isempty(cb)
        if iscell(cb)
            feval(cb{:},val);
        else
            feval(cb,val);
        end
    end
elseif strcmp(action,'list')
    ind = dlg.getWidgetValue('list');
    iteminfo = obj.pDialogData.ItemInfo{ind+1};
    dlg.setWidgetValue('info',iteminfo);
else
    dependencies.assert(false,sprintf('Unexpected action: %s',action));
end
end

