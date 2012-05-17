function rowsadded = addrows(h,thisSelectedRows)

% ADDROWS  Adds row to the table.inputsignals if there is room at 
%          the bottom of the table. Returns the number of rows added

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2005/12/22 17:38:53 $

thisSignals = h.inputsignals;

% Only shift if the last row is empty and the selected row is not the last
% row
emptyRow = struct('values',{[]},'source',{''},'subsource',{''},'construction',{''},...
'interval',{[]},'column',{[]},'name',{''},'transposed',{false},'size',[0 0]);

% Map only if the last length(thisSelectedRows) are open
if all(strcmp({h.inputsignals(end-length(thisSelectedRows)+1:end).name},'')) 
    destinationRows = 1:length(h.inputsignals);
    destinationRows(thisSelectedRows) = [];
    thisSignals(destinationRows) = thisSignals(1:(end-length(thisSelectedRows)));
    thisSignals(thisSelectedRows) = deal(emptyRow);
    h.inputsignals = thisSignals;
    rowsadded = length(thisSelectedRows);
else
    errordlg('Insufficient room to add additional rows','Linear simulation tool','modal')
    rowsadded = 0;
end


   