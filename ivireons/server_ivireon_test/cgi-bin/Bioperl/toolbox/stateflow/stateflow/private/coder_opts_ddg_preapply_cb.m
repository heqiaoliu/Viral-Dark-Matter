function [res, err] = coder_opts_ddg_preapply_cb(dlgH, numWidgets)

% Copyright 2002-2005 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2005/12/19 07:59:09 $

if ~ishandle(dlgH)
    return;
end

targetId = dlgH.getDialogSource.Id;

% Get the flag info from the target, and the uicontrols from the gui
flags   = target_methods('codeflags',targetId);

for i = 1:length(flags)
    newVal = dlgH.getWidgetValue(int2str(i));
    
    if strcmp(flags(i).type, 'word')
        % Try validate word string
        newVal = regexp(newVal, '^\s*([a-zA-Z]\w*)\s*$', 'tokens');
        if isempty(newVal)
            % If not valid word string, use the previous value
            % WISH: Give warning
            newVal = flags(i).value;
            dlgH.setWidgetValue(int2str(i), newVal);
        else
            newVal = newVal{1}{1};
        end
    end
    
    flags(i).value = newVal;
end

% Update the data dictionary if any flags have changed
target_methods('setcodeflags',targetId,flags);

err = [];
res = 1;