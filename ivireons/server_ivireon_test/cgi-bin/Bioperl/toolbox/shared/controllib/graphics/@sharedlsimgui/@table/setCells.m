function setCells(h, cellData)

% Author(s): James G. Owen
% Revised:
% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:26:32 $

if strcmp(class(cellData),'cell') % && (length(h.colnames)==0 || size(cellData,2) == length(h.colnames))
    h.celldata = cellData;
else 
    ctrlMsgUtils.error('Controllib:gui:SharedLsimGUI2')
end
