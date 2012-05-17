function setIOTableData(this,InputData,OutputData)
%setIOTableData  Method to update the Simulink model with changes to the
%                linearization I/O properties in the GUI.  This is used for
%                both the input and output tables.

%  Author(s): John Glass
%  Copyright 2005 The MathWorks, Inc.

Data = InputData;
if ~strcmp(Data(1,2),'Add linearization IOs by right clicking on a signal') 
    % Construct the linearization object
    h = linearize.IOPoint;
    ios = [];   
    
    for ct = 1:length(Data)    
        ios =  [ios;h.copy];
        
        % Begin parsing through the IO table data
        if Data(ct,1)
            set(ios(end),'Active','on');
        else
            set(ios(end),'Active','off');
        end
        
        % Begin setting the IO object properties
        set(ios(end),...
            'Block',Data(ct,2),...
            'PortNumber',Data(ct,3));
        
        % Set the IO object property type
        if strcmpi( Data(ct,5), xlate('Input') )
            set(ios(end),'Type','in')
        elseif strcmpi( Data(ct,5), xlate('Output') )
            set(ios(end),'Type','out')
        elseif strcmpi( Data(ct,5), xlate('Input - Output') )
            set(ios(end),'Type',xlate('inout'))
        elseif strcmpi( Data(ct,5), xlate('Output - Input') )
            set(ios(end),'Type','outin')
        else
            set(ios(end),'Type','none')
        end        
        
        % Set the open loop property to its valid value
        if Data(ct,6)
            set(ios(end),'OpenLoop','on');
        else
            set(ios(end),'OpenLoop','off');
        end
    end
    
    % Store the IO object
    this.IOData = ios;
    % Write the new settings to the Simulink model
    setlinio(this.Model,ios);
end