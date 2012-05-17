function setStateTableData(this,Data,row,col)
% setStateTableData  Method to update the Simulink model with changes to the
%                   state operating condition properties in the GUI.

%  Author(s): John Glass
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $ $Date: 2008/10/31 07:36:32 $

% Check to see if the value is numeric.  Then set the properties. 
switch col
    case 1
        this.StateTableData{row+1,col+1} = Data(row+1,col+1);
end

% Set the dirty flag
this.setDirty