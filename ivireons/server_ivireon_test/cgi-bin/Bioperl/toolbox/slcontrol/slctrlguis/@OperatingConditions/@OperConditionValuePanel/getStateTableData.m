function [state_table,state_ind] = getStateTableData(this)
%getStateTableData  Method to get the current Simulink linearization State 
%                settings for the State table in the GUI.

%  Author(s): John Glass
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $ $Date: 2008/10/31 07:36:28 $

states = this.OpPoint.States;

if ~isempty(states)
    % Get all the number of states
    all_nstates = get(states,{'Nx'});
    total_states = sum([all_nstates{:}]);
    
    % Create the cell array to store the state table data
    state_table = cell(length(states)+total_states,2);
    % Create the array to store the indices for where each state
    % begins in the table
    state_ind = zeros(length(states),1);
    
    % Initialize the counter
    counter = 1;
    
    for ct1 = 1:length(states)
        if isempty(states(ct1).StateName)
            state_table{counter,1} = regexprep(states(ct1).Block,'\n',' ');
        else
            state_table{counter,1} = regexprep(states(ct1).StateName,'\n',' ');
        end

        % Enter the index in Java array units
        state_ind(ct1,1) = counter - 1;
        % Put in dummy data
        state_table{counter,2} = '0';
        % Increment the counter
        counter = counter + 1;
        for ct2 = 1:states(ct1).Nx
            state_table(counter,:) = {sprintf('State - %d',ct2), num2str(states(ct1).x(ct2))};
            counter = counter + 1;
        end
    end    
else
    % Return the index which is zero
    state_ind = 0;
    state_table = {ctrlMsgUtils.message('Slcontrol:operpointtask:ModelHasNoStates',this.Model),0};
end