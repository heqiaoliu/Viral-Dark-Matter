function updatetable(this, VarNames, VarData)
% UPDATETABLE Update the table based on the variable name cell array
% VarNames and the cell array of data VarData.

%   Author(s): Craig Buhr, John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2006/11/17 14:04:47 $

%% Store the data in the object
this.VarNames = VarNames;
this.VarData = VarData;

if length(VarNames) > 0
    %% Get the data for the table
    data = this.createtablecell(VarNames, VarData);

    %% Update the table
    this.Frame.updateTable(data);
else
    %% Clear the table
    this.Frame.clearTable;
end