function table_data = getOutputResultsTableData(this)
%getoutputTableData  Method to get the current Simulink linearization output 
%                settings for the output table in the GUI.

%  Author(s): John Glass
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $ $Date: 2008/12/04 23:27:28 $

table_data = javaArray('java.lang.Object',2,1);

% Get the index of the selected model
outputs = this.OpReport.Outputs;

if ~isempty(outputs)
    % Get all the number of outputs
    all_noutputs = get(outputs,{'PortWidth'});
    total_outputs = sum([all_noutputs{:}]);
    
    % Create the java object to store the output table data
    output_table = javaArray('java.lang.Object',length(outputs)+total_outputs,3);
    % Create the java object to store the indices for where each output
    % begins in the table
    output_ind = javaArray('java.lang.Integer',length(outputs),1);
    
    % Initialize the counter
    counter = 1;
    
    for ct1 = 1:length(outputs)
        % Enter the output name
        output_table(counter,1) = java.lang.String(regexprep(outputs(ct1).Block,'\n',' '));
        % Enter the index in Java array units
        output_ind(ct1,1) = java.lang.Integer(counter - 1);
        % Put in dummy data
        output_table(counter,2) = java.lang.String('0');
        output_table(counter,3) = java.lang.String('0');
        % Increment the counter
        counter = counter + 1;
        for ct2 = 1:outputs(ct1).PortWidth
            output_table(counter,1) = java.lang.String(sprintf('output - %d',ct2));
            if (isempty(outputs))
                output_table(counter,2) = java.lang.String('N/A');
            elseif (outputs(ct1).Known(ct2))
                output_table(counter,2) = java.lang.String(num2str(outputs(ct1).yspec(ct2)));
            else
                output_table(counter,2) = java.lang.String(['[ ',...
                        num2str(outputs(ct1).Min(ct2)),...
                        ' , ',...
                        num2str(outputs(ct1).Max(ct2)),...
                        ' ]']);
            end
            if ~isempty(outputs(ct1).y)
                output_table(counter,3) = java.lang.String(num2str(outputs(ct1).y(ct2)));
            else
                output_table(counter,3) = java.lang.String('N/A');
            end
            counter = counter + 1;
        end
    end    
else
    % Return that there are no outputs in the Simulink model
    output_table = javaArray('java.lang.Object',1,3);
    % Return the index which is zero
    output_ind = javaArray('java.lang.Integer',1,1);
    output_ind(1,1) = java.lang.Integer(0);
    output_table(1,1) = java.lang.String(ctrlMsgUtils.message('Slcontrol:operpointtask:ModelHasNoOutputs',this.OpReport.Model));
    output_table(1,2) = java.lang.String('');
    output_table(1,3) = java.lang.String('');
end

table_data(1) = output_table;
table_data(2) = output_ind;
