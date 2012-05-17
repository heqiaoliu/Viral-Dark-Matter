function handleButtons(this,buttonStr)
%HANDLEBUTTONS Handle buttons in Import dialog.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/09/09 21:29:42 $

d = this.dialog;

switch buttonStr
    case 'Import'
        if ~isempty(this.ImportErrorDialog) && ...
                ishghandle(this.ImportErrorDialog)
            delete(this.ImportErrorDialog);
        end
        % Evaluate and validate dialog entries
        % Validate stores evaluated result in .mlvarEval
        [success,exception] = this.validate;
        
        if success
            %use the .mlvarEval set above and ask the workspace handler if it
            %can accept this data
            hApp = this.hAppInst;
            hSrc = hApp.getExtInst('Sources','Workspace');
            dataHandler = hSrc.getDataHandlerClass(this.hAppInst.Visual);
            [isValid, errorMsg] = feval([dataHandler '.isDataValid'], this.mlVarEval);
            %if it can accept the data delete the workspace import dialog and
            %set its handle to [] to avoid errors in renaming the title of
            %existing dialogs
            if isValid
                delete(d);
                this.dialog=[];
                % Expression/variable validated
                % Evaluated data was cached during validate
                this.importBtnClicked;
            else % if it cannot accept the data send up an error
                dialogProvider = DAStudio.DialogProvider;
                dialogProvider.errordlg(errorMsg, 'Error: Import from Workspace', true);
            end
        else
            this.LastErrorCondition = exception;
            dialogProvider = DAStudio.DialogProvider;
            dialogProvider.errordlg(exception.message, 'Error: Import from Workspace', true);
        end
        
        
    case 'ListBox'
        % User clicked in variable listbox
        % convert 0-based row number to 1-based
        row = 1 + getWidgetValue(d,'WorkspaceVars');
        % Get variable name for this row
        ws_names = getUserData(d,'WorkspaceVars');
        this_name = ws_names{row};
        % Replace edit box with selected variable name
        d.setWidgetValue('mlvar',this_name);
                
    case 'Refresh'
        this.show;
        
    case 'Help'
        doc('mplay');
        
    case 'Cancel'
        if ~isempty(this.ImportErrorDialog) && ...
                ishghandle(this.ImportErrorDialog)
            delete(this.ImportErrorDialog);
        end
        
        delete(d);  % close dialog
        this.dialog = [];
end

% [EOF]
