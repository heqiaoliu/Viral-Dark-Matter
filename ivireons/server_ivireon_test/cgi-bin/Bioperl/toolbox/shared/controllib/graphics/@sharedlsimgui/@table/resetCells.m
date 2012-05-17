function resetCells(h, cellData)

% RESETCELLS Used by java to write back edited table values to the @table

% Author(s): James G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:26:30 $

% deactivate listeners to avoid loop
for L = h.listeners'
    set(L,'Enabled','off');
end

nrows = length(cellData);
ncols = length(cellData{1});
cellArray = cell(nrows,ncols);
for row=1:nrows
    for col=1:ncols
       cellArray{row,col} = char(cellData{row}{col});
    end
end
h.celldata = cellArray;

% turn listeners back on
for L = h.listeners'
    L.Enabled = 'on';
end
