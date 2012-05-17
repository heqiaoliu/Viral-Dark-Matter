function setStateConstrTableData(this,Data,mStateIndices,row,col)
% setStateTableData  Method to update the Simulink model with changes to the
%                   state operating condition properties in the GUI.

%  Author(s): John Glass
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2008/10/31 07:36:59 $


states = this.OpSpecData.States;

% Find the index corresponding to the state block being used.
diff_indices = mStateIndices-row;
diff_ind = find(diff_indices <= 0);
stateind = diff_ind(end);
ind = row-mStateIndices(stateind);

% Check to see if the value is numeric.  Then set the properties. 
switch col
    case 1
        d_numeric = str2double(Data(row+1,col+1));
        if ~isnan(d_numeric)
            states(stateind).x(ind) = d_numeric; %#ok<NASGU>
        end
        this.StateSpecTableData{row+1,col+1} = Data(row+1,col+1);
    case 2
        states(stateind).Known(ind) = double(Data(row+1,col+1)); %#ok<NASGU>
        % Set the data in the task node object
        this.StateSpecTableData{row+1,col+1} = Data(row+1,col+1);
    case 3
        states(stateind).SteadyState(ind) = double(Data(row+1,col+1)); %#ok<NASGU>
        % Set the data in the task node object
        this.StateSpecTableData{row+1,col+1} = Data(row+1,col+1);
    otherwise
        % Set the data in the task node object
        this.StateSpecTableData{row+1,col+1} = Data(row+1,col+1);
end

% Set the dirty flag
this.setDirty