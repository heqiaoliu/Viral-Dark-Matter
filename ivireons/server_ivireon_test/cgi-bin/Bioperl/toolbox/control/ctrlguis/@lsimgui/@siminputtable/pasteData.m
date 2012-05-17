function numpastedrows = pasteData(h, copyStruc, varargin)

% PASTEDATA Pastes data from clipboard structure copyStruc onto the selected rows
% Note that the copyStruc array is normally stored in the copieddatabuffer of h, but
% copyStruc is passed as an argument so that the import button
% (which does not use the copieddatabuffer internal clipboard can reuse
% this code)

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2005/12/22 17:39:01 $

import java.lang.*;

numpastedrows = 0;
inputdata = h.inputsignals;

if ~isempty(varargin)
    selectedRows = varargin{1};
else
    selectedRows = double(h.STable.getSelectedRows)+1;
end
lenimport = length(copyStruc.columns);
lenselection = length(selectedRows);

if lenselection ~= lenimport
    if lenselection == 1
        
        % Is there sufficient room in the table?
        if lenimport>length(h.inputsignals)-selectedRows+1
            errordlg(sprintf('There is insufficient room in the table to insert the signals'),...
                     'Linear Simulation Tool', 'modal');
            return
        end
        
        if lenimport>1 
              if ~all(cellfun('isempty',{h.inputsignals(selectedRows+1:(selectedRows+lenimport-1)).name}))
                  overwrite = questdlg(sprintf('Inserting these signals will overwrite unselected inputs. Do you wish to continue?'),...
                      'Linear Simulation Tool','OK','Cancel','OK');
                  if strcmp(overwrite, 'Cancel')
                      return
                  end
              end
              selectedRows = selectedRows:(selectedRows+lenimport-1);
        end
    elseif lenselection ==0 
        errordlg('No inputs are selected', 'Linear simulation tool', 'modal');
        return
    else
        errstr = sprintf('Size mismatch: %s columns cannot be mapped to %s inputs',num2str(lenimport),num2str(lenselection));
        errordlg(errstr, 'Linear simulation tool', 'modal');
        return
    end
end
switch copyStruc.source(1:3)
case {'wor','mat'}  
    varName = copyStruc.subsource;   
    for k = 1:lenimport
        inputdata(selectedRows(k)).transposed = copyStruc.transposed;
        inputdata(selectedRows(k)).source = copyStruc.source(1:3);
        inputdata(selectedRows(k)).subsource = varName;
        inputdata(selectedRows(k)).values = copyStruc.data(:,copyStruc.columns(k));
        inputdata(selectedRows(k)).construction = copyStruc.construction;
        inputdata(selectedRows(k)).interval = [1 length(inputdata(selectedRows(k)).values)];
        inputdata(selectedRows(k)).column = copyStruc.columns(k);
        inputdata(selectedRows(k)).name = varName;
        inputdata(selectedRows(k)).size = size(copyStruc.data);
    end
    numpastedrows = lenimport;
case 'inp'
    for k = 1:lenimport
        inputdata(selectedRows(k)).source = copyStruc.tablesources{k};
        inputdata(selectedRows(k)).values = copyStruc.data{k};
        inputdata(selectedRows(k)).subsource = copyStruc.subsource{k};
        inputdata(selectedRows(k)).construction = copyStruc.construction{k};
        inputdata(selectedRows(k)).interval = copyStruc.intervals(2*k-1:2*k);
        inputdata(selectedRows(k)).column = copyStruc.columns{k};
        inputdata(selectedRows(k)).name = copyStruc.names{k};
        inputdata(selectedRows(k)).transposed = copyStruc.transposed(k);
        inputdata(selectedRows(k)).size = copyStruc.size(2*k-1:2*k);
    end
    numpastedrows = lenimport;
case {'xls','csv','asc'}   
    thisCols = copyStruc.columns;           
    for k=1:length(thisCols)    
        inputdata(selectedRows(k)).source = copyStruc.source(1:3);
        inputdata(selectedRows(k)).subsource = copyStruc.subsource;
        inputdata(selectedRows(k)).values = copyStruc.data(:,k);
        inputdata(selectedRows(k)).construction = copyStruc.construction;
        inputdata(selectedRows(k)).interval = [1 length(inputdata(selectedRows(k)).values)];
        inputdata(selectedRows(k)).column = copyStruc.columns(k);
        inputdata(selectedRows(k)).name = ...
            ['Column' char('A'+copyStruc.columns(k)-1)];
        inputdata(selectedRows(k)).size = [length(inputdata(selectedRows(k)).values) 1];    
    end
    numpastedrows = length(thisCols);
case 'sig'
    for k=1:lenselection
        inputdata(selectedRows(k)).source = copyStruc.source(1:3);
        inputdata(selectedRows(k)).subsource = copyStruc.subsource;
        inputdata(selectedRows(k)).values = copyStruc.data;
        inputdata(selectedRows(k)).construction = copyStruc.construction;
        inputdata(selectedRows(k)).interval = [1 copyStruc.length];
        inputdata(selectedRows(k)).column = 1;
        inputdata(selectedRows(k)).name =  copyStruc.subsource; 
        inputdata(selectedRows(k)).size = [length(inputdata(selectedRows(k)).values) 1];
    end
    numpastedrows = lenselection;
end

% Now handle the situation where this is a cut
if ~isempty(h.cutrows)
    if isequal(h.cutrows,h.copieddatabuffer) %the clipboard must match the last cut or its just a regular paste
        inputdata(setdiff(h.cutrows.columns,selectedRows)) = [];    
        sizeTable = double(h.sizeof);
        inputdata(length(inputdata)+1:sizeTable(1)) = ...
            struct('values',[],'source','','subsource','','construction','','interval',[],...
            'size',[],'column',[],'name','');
    end
    h.cutrows = [];
end

oldinputsignals = h.inputsignals;
h.inputsignals = inputdata;
if h.syncinterval; % update the simulation length if necessary
	h.update
	
	% force update of the table text history since this is not a user edit
	h.lastcelldata = h.celldata;
else
    h.inputsignals = oldinputsignals; %abort - revert
end




       
           

