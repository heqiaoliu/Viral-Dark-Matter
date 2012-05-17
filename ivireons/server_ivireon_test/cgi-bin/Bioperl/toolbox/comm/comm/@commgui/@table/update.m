function update(this, varargin)
%UPDATE   Update the table contents based on the start index

%	@commgui\@table
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/07 18:17:33 $

% Get handels
rowHandles = this.RowHandles;

% Get table data
tableData = this.TableData ;

% Get the start indext
startIdx = this.StartIndex;

% Updated the table contents
numCols = this.NumberOfColumns;
for p=1:this.MaxNumberOfDisplayedRows
    for q=1:numCols
        set(rowHandles(p,q), 'String', tableData{p+startIdx-1,q});
    end
end

%-------------------------------------------------------------------------------
% [EOF]
