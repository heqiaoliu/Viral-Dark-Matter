function update(this)
%UPDATE Update compare results scope face

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/06/13 15:11:35 $

% Get handles
handles = this.WidgetHandles;

%-------------------------------------------------------
% Update plot
updateCompareTablePlot(this);

%-------------------------------------------------------
% Update table
[tableData columnLabels] = ...
    formatCompareTableData(this.MeasurementsPanel, this.ShowQuadrature);
set(handles.Table, 'Data', tableData, ...
    'ColumnName', columnLabels, 'UserData', []);

% If there is data in the table, make sure that the column labels fit to the
% columns 
numCol = length(columnLabels);
if numCol
    columnWidths = cell(1, numCol);
    margin = largestuiwidth({'s'});
    for p=1:numCol
        columnWidths{p} = largestuiwidth(columnLabels(p)) + margin;
    end
    set(handles.Table, 'ColumnWidth', columnWidths);
end

%-------------------------------------------------------
% Update eye diagram object settings view panel
exception = ...
    updateInfoTable(this, handles.SettingsPanelContents, this.SettingsPanel);
if ~isempty(exception)
    commscope.notifyWarning(this.Parent, exception);
end

%-------------------------------------------------------
% Update measurements view panel
updateSelector(this);

% Update IQ selector
set(handles.IQSelector, 'Value', this.ShowQuadrature)

% Update the table buttons
updateTableButtons(this)

%-------------------------------------------------------------------------------
% [EOF]
