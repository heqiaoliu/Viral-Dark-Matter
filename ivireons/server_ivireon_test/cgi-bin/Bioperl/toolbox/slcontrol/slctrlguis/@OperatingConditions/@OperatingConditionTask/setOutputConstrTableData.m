function setOutputConstrTableData(this,Data,mOutputIndices,row,col)
%setOutputConstrTableData  Method to update the Simulink model with changes to the
%                   input operating condition properties in the GUI.

%  Author(s): John Glass
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2008/10/31 07:36:58 $

outputs = this.OpSpecData.Outputs;

% Find the index corresponding to the output block being used.
diff_indices = mOutputIndices-row;
diff_ind = find(diff_indices <= 0);
outputind = diff_ind(end);
ind = row-mOutputIndices(outputind);

% Set the properties 
switch col
    case 1
        d_numeric = str2double(Data(row+1,col+1));
        if ~isnan(d_numeric)
            outputs(outputind).y(ind) = d_numeric; %#ok<NASGU>
        end
        this.OutputSpecTableData{row+1,col+1} = Data(row+1,col+1);
    case 2
        outputs(outputind).Known(ind) = double(Data(row+1,col+1)); %#ok<NASGU>
        this.OutputSpecTableData{row+1,col+1} = Data(row+1,col+1);
    otherwise
        % Set the data in the task node object
        this.OutputSpecTableData{row+1,col+1} = Data(row+1,col+1);
end

% Set the dirty flag
this.setDirty