function [outDoubleArray,numcols] = getImportCellArrayCache(h,...
    topRow,topColumn,MINROWCOUNT,MINCOLUMNCOUNT)

%  Copyright 2008 The MathWorks, Inc.

% Manages cached data cell array for Import Dialog cell array table.

topRow = topRow+1;
topColumn = topColumn+1;    

% Get the data
s = size(h.IOData.rawdata);

% Build the data cache
nrows = min(s(1)-topRow+1,2*MINROWCOUNT);
ncols = min(s(2)-topColumn+1,2*MINCOLUMNCOUNT);
if ncols>0 && nrows>0
    outDoubleArray = h.IOData.rawdata(topRow:topRow+nrows-1,topColumn:topColumn+ncols-1);
    numcols = size(outDoubleArray,2);
    outDoubleArray = outDoubleArray(:);
else
    outDoubleArray = [];
    numcols = 0;
end
