function reset(h,nrows,colnames,name, extrablankrows)

% RESET Resets the siminputtable to blank entries

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2005/12/22 17:39:02 $

ncols = length(colnames);
thiscelldata = cell(nrows+extrablankrows,ncols);
thiscelldata(:)={' '};
for k=1:nrows
    thiscelldata{k,1} = num2str(k);
end

h.colnames = colnames;
h.setCells(thiscelldata);
h.name = name;
h.leadingcolumn = 'on';
inputSignalStruct = struct('values',[],'source','','subsource','','construction','','interval', ...
[],'column',[],'name','','transposed',false,'size',[0 0]);
inputSignalArray(1:nrows) = inputSignalStruct;
h.inputsignals = inputSignalArray;
for k=1:nrows
    inNames{k} = num2str(k);
end
h.inputnames = inNames;
h.lastcelldata = h.celldata;
h.readonlyrows = nrows+1:nrows+extrablankrows;