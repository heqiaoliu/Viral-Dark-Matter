function out1 = getdata(h)

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:26:20 $

nrows = size(h.celldata,1);
ncols = size(h.celldata,2);

out1 = javaArray('java.lang.String',nrows,ncols);
for row=1:nrows
    for col=1:ncols
        cellval = h.celldata{row,col};
        if isempty(cellval)
            cellval = ' ';
        end
        out1(row,col) = java.lang.String(cellval);
    end
end

