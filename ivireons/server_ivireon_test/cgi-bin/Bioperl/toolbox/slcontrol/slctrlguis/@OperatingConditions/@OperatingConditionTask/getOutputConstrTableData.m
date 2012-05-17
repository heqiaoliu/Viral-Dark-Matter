function [output_table, output_ind] = getOutputConstrTableData(this)
%getOutputTableData  Method to get the current Simulink linearization Output 
%                   settings for the Output table in the GUI.

%  Author(s): John Glass
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2008/10/31 07:36:50 $

outputs = this.OpSpecData.Outputs;

if ~isempty(outputs)
    % Get all the number of outputs
    all_noutputs = get(outputs,{'PortWidth'});
    total_outputs = sum([all_noutputs{:}]);
    
    % Create the cell array to store the outputs table data
    output_table = cell(length(outputs)+total_outputs,5);
    % Create the vector to store the indices for where each output
    % begins in the table
    output_ind = zeros(numel(outputs),1);
    
    % Initialize the counter
    counter = 1;
    
    for ct1 = 1:length(outputs)        
        % Enter the index in Java array units
        output_ind(ct1,1) = counter - 1;
        % Enter the state name
        output_table(counter,:) = {regexprep(outputs(ct1).Block,'\n',' '),...
                        '0',false,'0','0'};
        % Increment the counter
        counter = counter + 1;
        for ct2 = 1:outputs(ct1).PortWidth
            output_table(counter,:) = {sprintf('Channel - %d',ct2),...
                num2str(outputs(ct1).y(ct2)), outputs(ct1).Known(ct2) == 1,...
            	num2str(outputs(ct1).Min(ct2)), num2str(outputs(ct1).Max(ct2))};
            counter = counter + 1;
        end
    end    
else
    % Return the index which is zero
    output_ind = 0;
    output_table = {ctrlMsgUtils.message('Slcontrol:operpointtask:ModelHasNoOutputs',this.Model),...
                        '',false,'',''};
end