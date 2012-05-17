function table_data = getStateResultsTableData(this)
%getStateTableData  Method to get the current Simulink linearization State 
%                settings for the State table in the GUI.

%  Author(s): John Glass
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $ $Date: 2008/12/04 23:27:30 $

table_data = javaArray('java.lang.Object',2,1);

% Get the index of the selected model
states = this.OpReport.states;

% Create the table
if ~isempty(states)
    % Get all the number of states
    all_nstates = get(states,{'Nx'});
    total_states = sum([all_nstates{:}]);
    
    % Create the java object to store the state table data
    state_table = javaArray('java.lang.Object',length(states)+total_states,5);
    % Create the java object to store the indices for where each state
    % begins in the table
    state_ind = javaArray('java.lang.Integer',length(states),1);
    
    % Initialize the counter
    counter = 1;
    
    for ct1 = 1:length(states)
        % Enter the state name
        if isa(states(ct1),'opcond.StateReport')
            if isempty(states(ct1).StateName)
                state_table(counter,1) = java.lang.String(regexprep(states(ct1).Block,'\n',' '));
            else
                state_table(counter,1) = java.lang.String(regexprep(states(ct1).StateName,'\n',' '));
            end
        else
            state_table(counter,1) = java.lang.String(regexprep(states(ct1).SimMechBlock,'\n',' '));
        end

        % Enter the index in Java array units
        state_ind(ct1,1) = java.lang.Integer(counter - 1);
        % Put in dummy data
        state_table(counter,2) = java.lang.String('0');
        state_table(counter,3) = java.lang.String('0');
        state_table(counter,4) = java.lang.String('0');
        state_table(counter,5) = java.lang.String('0');
        % Increment the counter
        counter = counter + 1;
        for ct2 = 1:states(ct1).Nx
            state_table(counter,1) = java.lang.String(sprintf('State - %d',ct2));
            if (isempty(states))
                state_table(counter,2) = java.lang.String('N/A');
            elseif (states(ct1).Known(ct2))
                state_table(counter,2) = java.lang.String(num2str(states(ct1).x(ct2)));
            else
                state_table(counter,2) = java.lang.String(['[ ',...
                                               num2str(states(ct1).Min(ct2)),...
                                               ' , ',...
                                               num2str(states(ct1).Max(ct2)),...
                                               ' ]']);
            end
            state_table(counter,3) = java.lang.String(num2str(states(ct1).x(ct2)));
            if ((isempty(states)) || ~states(ct1).SteadyState(ct2))
                state_table(counter,4) = java.lang.String('N/A');
            else
                state_table(counter,4) = java.lang.String('0');
            end
            if ~isempty(states(ct1).dx)
                state_table(counter,5) = java.lang.String(num2str(states(ct1).dx(ct2)));
            else
                state_table(counter,5) = java.lang.String('N/A');
            end
            counter = counter + 1;
        end
    end    
else
    % Return that there are no states in the Simulink model
    state_table = javaArray('java.lang.Object',1,5);
    % Return the index which is zero
    state_ind = javaArray('java.lang.Integer',1,1);
    state_ind(1,1) = java.lang.Integer(0);
    state_table(1,1) = java.lang.String(ctrlMsgUtils.message('Slcontrol:operpointtask:ModelHasNoStates',this.OpReport.Model));
    state_table(1,2) = java.lang.String('');
    state_table(1,3) = java.lang.String('');
    state_table(1,4) = java.lang.String('');
    state_table(1,5) = java.lang.String('');
end

table_data(1) = state_table;
table_data(2) = state_ind;
