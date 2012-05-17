function [input_table,input_ind] = getInputTableData(this)
%getInputTableData  Method to get the current Simulink linearization Input 
%                   settings for the Input table in the GUI.

%  Author(s): John Glass
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $ $Date: 2008/10/31 07:36:26 $

inputs = this.OpPoint.Inputs;

if ~isempty(inputs)
    % Get all the number of inputs
    all_ninputs = get(inputs,{'PortWidth'});
    total_inputs = sum([all_ninputs{:}]);
    
    % Create the cell object to store the inputs table data
    input_table = cell(length(inputs)+total_inputs,2);
    % Create the array to store the Indices for where each input
    % begins in the table
    input_ind = zeros(length(inputs),1);
    
    % Initialize the counter
    counter = 1;
    
    for ct1 = 1:length(inputs)
        % Enter the state name
        input_table(counter,:) = {regexprep(inputs(ct1).Block,'\n',' '),'0'};
        % Enter the index in Java array units
        input_ind(ct1,1) = counter - 1;
        % Increment the counter
        counter = counter + 1;
        for ct2 = 1:inputs(ct1).PortWidth
            input_table(counter,:) = {sprintf('Channel - %d',ct2),...
                                        num2str(inputs(ct1).u(ct2))};
            counter = counter + 1;
        end
    end    
else
    % Return the index which is zero
    input_ind = 0;
    input_table = {ctrlMsgUtils.message('Slcontrol:operpointtask:ModelHasNoInputs',this.Model),'0'};
end