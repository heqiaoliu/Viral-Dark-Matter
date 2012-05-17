function sz = guiSizes(this)
%GUISIZES Returns a structure of spacings and sizes.

%	@commgui\@table
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/09/13 06:46:08 $

% Get the base GUI sizes
sz = baseGuiSizes(this);

% Set the font parameters
sz = setFontParams(this, sz);

% Get available size
tableWidth = this.TableWidth;
tableHeight = this.TableHeight;

% Determine cloumn widths
colLabels = this.ColumnLabels;
len = length(colLabels);
columnData = cell(1, 2);
for p=1:len
    if size(colLabels{p}, 2) == 2
        columnData{p} = colLabels{p}{1};
    else
        columnData{p} = colLabels{p};
    end
end

columnData = [columnData; this.TableData];
numCols = this.NumberOfColumns;
totalColWidth = 0;
for p=1:numCols
    sz.tableColumnWidth(p) = largestuiwidth(columnData(:, p)) + 3;
    totalColWidth = totalColWidth + sz.tableColumnWidth(p);
end

% Determine spacing
sz.tableTop = tableHeight - sz.vcc - sz.lh - sz.ptTweak;
sz.tableRowSpacing = sz.lh;
this.MaxNumberOfDisplayedRows = floor((sz.tableTop -sz.vcc)/sz.tableRowSpacing);

% Determine control sizes
sz.tableCtrlWidth = 10 + sz.bwTweak;
sz.tableCtrlX = tableWidth - sz.tableCtrlWidth - sz.hcc;
sz.tableCtrlUpY = sz.tableTop - sz.tableRowSpacing + sz.lblTweak;
sz.tableCtrlDownY = sz.tableTop ...
    - sz.tableRowSpacing*this.MaxNumberOfDisplayedRows + sz.lblTweak;

% Determine extra width for columns, if any.  Note that, if the totalColWidth is
% less than sz.tableCtrlX - 2*sz.hcc (for space between first column and the 
% panel and the space between controls and the last column), then we can add
% more space to each column
extraSpace = (sz.tableCtrlX - totalColWidth - 2*sz.hcc - sz.tcs*(numCols-1)) ...
    / numCols;
if extraSpace < 0
    extraSpace = 0;
end
for p=1:numCols
    sz.tableColumnWidth(p) = sz.tableColumnWidth(p) + extraSpace;
    totalColWidth = totalColWidth + sz.tableColumnWidth(p);
end


% Determine column locations
sz.tableX(1) = sz.hcc;
for p=2:numCols
    sz.tableX(p) = sz.tableX(p-1) + sz.tableColumnWidth(p-1) + sz.tcs;
end

%-------------------------------------------------------------------------------
% [EOF]