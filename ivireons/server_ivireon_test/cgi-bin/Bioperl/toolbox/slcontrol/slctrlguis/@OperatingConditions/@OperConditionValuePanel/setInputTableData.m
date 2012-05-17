function setInputTableData(this,Data,row,col)
%setInputTableData  Method to update the Simulink model with changes to the
%                   input operating condition properties in the GUI.

%  Author(s): John Glass
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2008/10/31 07:36:31 $

% Set the properties 
switch col
    case 1
        this.InputTableData{row+1,col+1} = Data(row+1,col+1);
end

% Set the dirty flag
this.setDirty