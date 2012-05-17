function out1 = getCell(h, row, col)

% GETCELL Used by java to view the contents of a cell

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:26:16 $


row = double(row);
col = double(col);

X = h.celldata{(row-1)*length(h.colnames)+col};
if isempty(X)
   out1 = java.lang.String('');
else
   if isnumeric(X)
        out1 = java.lang.String(num2str(X));
   elseif ischar(X)
        out1 = java.lang.String(X);
   end     
end