function updatetable(this, VarNames, VarData)
% UPDATETABLE Update the table based on the variable name cell array
% VarNames and the cell array of data VarData.

%   Author(s): Craig Buhr, John Glass
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/03/26 17:49:29 $

%% Store the data in the object
this.VarNames = VarNames;
this.VarData = VarData;

if isempty(VarNames)
    %% Clear the table
    this.Handles.TableModel.clearRows;
else    
    %% Get the data for the table
    data = this.createtablecell(VarNames, VarData);
    cm = this.TableColumnNames;
    %% Update the table
    this.Handles.TableModel.setDataVector(data,cm);
end
