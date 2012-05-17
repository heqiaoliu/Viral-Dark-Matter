function setInputConstrTableData(this,Data,mInputIndices,row,col)
% setInputConstrTableData  Method to update the Simulink model with changes to the
%                   input operating condition properties in the GUI.

%  Author(s): John Glass
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2008/10/31 07:36:57 $

inputs = this.OpSpecData.Inputs;

% Find the index corresponding to the input block being used.
diff_indices = mInputIndices-row;
diff_ind = find(diff_indices <= 0);
inputind = diff_ind(end);
ind = row-mInputIndices(inputind);

% Set the properties
switch col
    case 1
        d_numeric = str2double(Data(row+1,col+1));
        if ~isnan(d_numeric)
            inputs(inputind).u(ind) = d_numeric; %#ok<NASGU>
        end
        this.InputSpecTableData{row+1,col+1} = Data(row+1,col+1);
    case 2
        inputs(inputind).Known(ind) = double(Data(row+1,col+1)); %#ok<NASGU>
        this.InputSpecTableData{row+1,col+1} = Data(row+1,col+1);
    otherwise
        % Set the data in the task node object
        this.InputSpecTableData{row+1,col+1} = Data(row+1,col+1);
end

% Set the dirty flag
this.setDirty