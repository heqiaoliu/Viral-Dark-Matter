function chkSimPrintDlgs()

% Copyright 2006 The MathWorks, Inc.

% Remember previous hidden handles state
prev = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');

try
    % Loop over every open print dialog
    dlgs = findobj(0,'Tag','TMWsimprintdlg');
    for i = 1:length(dlgs)
        % Try reading a property from the associated model. If it fails
        % then assume the model is not open and close the dialog.
        data = get(dlgs(i),'UserData');
        try
            get_param(data.RootSys,'Name');
        catch
            delete(dlgs(i));
        end
    end
catch
end

% Restore state
set(0,'ShowHiddenHandles',prev);
