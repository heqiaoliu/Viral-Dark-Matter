function render(this)
%RENDER   Render the table

%	@commgui\@table
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2008/09/13 06:46:09 $

% If not already rendered
if ~this.Rendered
    
    % Get size and spacing information
    sz = guiSizes(this);

    % Render column labels
    numColumns = this.NumberOfColumns;
    colLabels = this.ColumnLabels;
    hColumnLabel = zeros(1, numColumns);
    for p=1:numColumns
        if p==1
            alignment = 'left';
        else
            alignment = 'right';
        end
        x = sz.tableX(p);
        y = sz.tableTop;
        width = sz.tableColumnWidth(p);
        height = sz.lh;
        tempLabel = colLabels{p};
        if size(tempLabel, 2) == 2
            tempLabelTooltip = tempLabel{2};
            tempLabel = tempLabel{1};
        else
            tempLabelTooltip = '';
        end
        hColumnLabel(p) = uicontrol(...
            'Parent', this.Parent,...
            'FontSize', get(0,'defaultuicontrolFontSize'),...
            'HorizontalAlignment', alignment,...
            'Position', [x y width height],...
            'String', tempLabel,...
            'Tooltip', tempLabelTooltip,...
            'Style', 'text',...
            'FontWeight', 'bold', ...
            'Tag', ['ColumnLabel_' tempLabel]);
    end
    this.ColumnLabelHandles = hColumnLabel;

    % Reset the start index
    this.StartIndex = 1;
    
    % Populate the panel with table data
    tableData = this.TableData;
    numRows = min(this.MaxNumberOfDisplayedRows, this.NumberOfRows);
    rowHandles = zeros(numRows, this.NumberOfColumns);
    if this.NumberOfRows > this.MaxNumberOfDisplayedRows
        this.NumberOfDisplayedRows = this.MaxNumberOfDisplayedRows;
    else
        this.NumberOfDisplayedRows = this.NumberOfRows;
    end
    for p=1:this.NumberOfDisplayedRows
        rowHandles(p, :) = ...
            renderNextRow(this, tableData(p+this.StartIndex-1, :), p, sz);
    end
    this.RowHandles = rowHandles;

    load comm_scroll_arrowheads
    
    % Render up control
    x = sz.tableCtrlX;
    y = sz.tableCtrlUpY;
    width = sz.tableCtrlWidth;
    height = sz.lh;
    this.UpControl = uicontrol(...
        'Parent', this.Parent,...
        'FontSize', get(0,'defaultuicontrolFontSize'),...
        'HorizontalAlignment', 'left',...
        'Position', [x y width height],...
        'CData', scroll_arrowheads{1}, ...
        'Style', 'pushbutton',...
        'Callback', {@(src,evnt)upButtonPressed(src,this)},...
        'Enable', 'off', ...
        'ToolTip', 'Scroll up', ...
        'Tag', 'UpControl'); %#ok<USENS> loaded from mat file
    if ( this.StartIndex > 1 )
        set(this.UpControl, 'Enable', 'on');
    end

    % Render down control
    x = sz.tableCtrlX;
    y = sz.tableCtrlDownY;
    width = sz.tableCtrlWidth;
    height = sz.lh;
    this.DownControl = uicontrol(...
        'Parent', this.Parent,...
        'FontSize', get(0,'defaultuicontrolFontSize'),...
        'HorizontalAlignment', 'left',...
        'Position', [x y width height],...
        'CData', scroll_arrowheads{2}, ...
        'Style', 'pushbutton',...
        'Callback', {@(src,evnt)downButtonPressed(src,this)},...
        'ToolTip', 'Scroll down', ...
        'Tag', 'DownControl');
    if ((this.MaxNumberOfDisplayedRows+this.StartIndex-1) >= this.NumberOfRows)
        set(this.DownControl, 'Enable', 'off');
    end

    % Mark as rendered
    this.Rendered = 1;

    % Restore the font parameters to the system defaults
    restoreFontParams(this, sz);

end

%-------------------------------------------------------------------------------
function upButtonPressed(hSrc, this)
% Callback function for up button

% update start index
startIndex = this.StartIndex;
startIndex = startIndex - 1;
this.StartIndex = startIndex;

% If at the beginning of the table, enable up button
if (startIndex == 1)
    uicontrol(double(this.DownControl));
    set(hSrc, 'Enable', 'off');
end

% If down button is disabled, enable it
hDown = this.DownControl;
if strcmp(get(hDown, 'Enable'), 'off')
    set(hDown, 'Enable', 'on');
end

% Update table
update(this);

%-------------------------------------------------------------------------------
function downButtonPressed(hSrc, this)
% Callback function for down button

% update start index
startIndex = this.StartIndex;
startIndex = startIndex + 1;
this.StartIndex = startIndex;

% If at the end of the table, disable down button
if (startIndex+this.MaxNumberOfDisplayedRows-1 == this.NumberOfRows)
    uicontrol(double(this.UpControl));
    set(hSrc, 'Enable', 'off');
end

% If up button is disabled, enable it
hUp = this.UpControl;
if strcmp(get(hUp, 'Enable'), 'off')
    set(hUp, 'Enable', 'on');
end

% Update table
update(this);

%-------------------------------------------------------------------------------
function handles = renderNextRow(this, rowData, pos, sz)
% Render a single row of the table at position pos

y = sz.tableTop - sz.tableRowSpacing*pos;

handles = zeros(size(rowData));
for p=1:length(rowData)
    if p==1
        alignment = 'left';
    else
        alignment = 'right';
    end
    handles(p) = uicontrol(...
        'Parent', this.Parent,...
        'FontSize', get(0,'defaultuicontrolFontSize'),...
        'HorizontalAlignment', alignment,...
        'Position', [sz.tableX(p) y sz.tableColumnWidth(p) sz.lh],...
        'String', rowData{p},...
        'Style', 'text',...
        'Tag', sprintf('Column_%d_Row_%d', p, pos));
end

%-------------------------------------------------------------------------------
% [EOF]