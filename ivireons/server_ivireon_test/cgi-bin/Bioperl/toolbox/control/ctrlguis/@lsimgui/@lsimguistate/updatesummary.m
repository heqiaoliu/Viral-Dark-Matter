function updatesummary(state)

% UPDATESUMMARY Updates the summary group box with the currently selected
% information

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.6.9 $ $Date: 2007/08/20 16:25:20 $

import com.mathworks.toolbox.control.spreadsheet.*;
import javax.swing.*;

% If there is no inputtable then the status cannot be updated
% e.g. because this is an initial plot GUI
if isempty(state.inputtable) || ~ishandle(state.inputtable)
    return
end

selectedinputs = double(state.inputtable.STable.getSelectedRows)+1;
numselectedinputs = length(selectedinputs);

if numselectedinputs==1
    %summaryTitle = sprintf('Data for input: %s',state.inputtable.celldata{selectedinputs,1});
    
    switch state.inputtable.inputsignals(selectedinputs).source
    case 'xls'
        summaryString = sprintf('Originally loaded from:  Excel spreadsheet, Sheetname:  %s\nFile:  %s, Column number:  %s',...
            state.inputtable.inputsignals(selectedinputs).subsource, ...
            state.inputtable.inputsignals(selectedinputs).construction,...
            num2str(state.inputtable.inputsignals(selectedinputs).column));                       
    case 'asc'
        summaryString = sprintf('Originally loaded from:  Ascii file, Delimiter: %s\nFile:  %s, Column number:  %s',...
            state.inputtable.inputsignals(selectedinputs).subsource,...
            state.inputtable.inputsignals(selectedinputs).construction,...
            num2str(state.inputtable.inputsignals(selectedinputs).column));       
    case 'csv'
        summaryString = sprintf('Originally loaded from:  CSV file, File:  %s\nColumn number:  %s',...
            state.inputtable.inputsignals(selectedinputs).construction,...
            num2str(state.inputtable.inputsignals(selectedinputs).column));
    case 'wor'            
        if state.inputtable.inputsignals(selectedinputs).transposed
            summaryString = sprintf('Originally loaded from:  Workspace, Variable name: %s\nRow number:  %s',...
                state.inputtable.inputsignals(selectedinputs).subsource,...
                num2str(state.inputtable.inputsignals(selectedinputs).column)); 
        else
            summaryString = sprintf('Originally loaded from:  Workspace, Variable name: %s\nColumn number:  %s',...
                state.inputtable.inputsignals(selectedinputs).subsource,...
                num2str(state.inputtable.inputsignals(selectedinputs).column)); 
        end
    case 'mat'
        if state.inputtable.inputsignals(selectedinputs).transposed
            summaryString = sprintf('Originally loaded from:  MAT file, Variable name: %s\nFile:  %s, Row number:  %s', ...
                state.inputtable.inputsignals(selectedinputs).subsource,...
                state.inputtable.inputsignals(selectedinputs).construction,...
                num2str(state.inputtable.inputsignals(selectedinputs).column));          
        else
            summaryString = sprintf('Originally loaded from:  MAT file, Variable name: %s\nFile:  %s, Column number:  %s', ...
                state.inputtable.inputsignals(selectedinputs).subsource,...
                state.inputtable.inputsignals(selectedinputs).construction,...
                num2str(state.inputtable.inputsignals(selectedinputs).column));       
        end
    case 'sig'
        summaryString = sprintf('Originally loaded from:  Signal designer, Name: %s\nDetails:  %s', ...
            state.inputtable.inputsignals(selectedinputs).subsource,...
            state.inputtable.inputsignals(selectedinputs).construction);  
    case 'ini'
        summaryString = sprintf('Originally loaded from:  Initial data, Original input #%d', ...
            state.inputtable.inputsignals(selectedinputs).column);  
    otherwise
        summaryString = sprintf('Use "Import signal..." or "Design signal..." buttons to assign data to inputs');
    end   
    
elseif state.inputtable.STable.getSelectedRowCount > 1
    %summaryTitle = sprintf('Data for input: multi-select');
    summaryString = sprintf('Multi-select');
else
    %summaryTitle = sprintf('Data for input: no inputs selected');
    summaryString = sprintf('No selection');
end
state.handles.TXTsummary.setText(summaryString);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% to be added when java figures can be used to represent signal summary
% rw = MLthread(state.handles.PNLsummaryOuter.getBorder,'setTitle',{java.lang.String(summaryTitle)});
% SwingUtilities.invokeLater(rw);
% rw = MLthread(state.handles.PNLsummaryOuter,'.Component.repaint',{});
% SwingUtilities.invokeLater(rw);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%