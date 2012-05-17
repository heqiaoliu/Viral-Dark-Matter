function tmpCell = GetRow(h)
% GETROW returns a cell array with row numbers 

%  Copyright 2004-2009 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $ $Date: 2009/04/24 18:30:51 $
 

rowLength = size(h.IOData.rawdata,1);

% reset the h.IOData.checkLimitColumn
h.IOData.checkLimitRow=20;
% if too many rows available, return row numbers plus 'More'
if (rowLength>h.IOData.checkLimitRow)
    % too many rows, put 'More ...' option at the end of the list
    tmpCell=num2cell(1:h.IOData.checkLimitRow);
    tmpCell(h.IOData.checkLimitRow+1)={xlate('More ...')};
else
    tmpCell=num2cell(1:rowLength);
end


