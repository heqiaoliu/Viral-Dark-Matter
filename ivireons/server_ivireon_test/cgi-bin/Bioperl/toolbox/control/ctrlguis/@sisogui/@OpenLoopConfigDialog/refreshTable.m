function refreshTable(this)
%refreshTable Refreshes table with config data

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2005/12/22 17:41:49 $

LoopConfig = this.LoopConfig(this.Target);

% Determine number of rows, columns

LoopOpenings = LoopConfig.LoopOpenings;
numLoopOpenings = length(LoopOpenings);

if isequal(numLoopOpenings, 0)
    this.Handles.TableModel.clearRows;
else
    if isequal(this.LoopData.getconfig,0)
        % SCD case
        for ct = 1:numLoopOpenings
            TableData(ct,:) = {...
                LoopOpenings(ct).Status, ...
                LoopOpenings(ct).BlockName, ...
                num2str(LoopOpenings(ct).PortNumber)};
        end
    else
        % Fixed configuration 
        for ct = 1:numLoopOpenings
            TableData(ct,:) = {...
                LoopOpenings(ct).Status, ...
                LoopOpenings(ct).BlockName};%, ...
               % ' '};
        end
    end
    this.Handles.TableModel.setData(TableData);
end


% %% Create a table model event to update the table
% evt = javax.swing.event.TableModelEvent(this.Handles.TableModel);
% awtinvoke(this.Handles.TableModel,'fireTableChanged',evt);

