function setIOTableData(this,Data)
%setIOTableData  Method to update the Simulink model with changes to the
%                linearization I/O properties in the GUI.

%  Author(s): John Glass
%  Revised:
% Copyright 2003-2005 The MathWorks, Inc.
% $Revision: 1.1.6.9 $ $Date: 2009/11/09 16:35:54 $

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
    [~,newioset] = setlinio(this.Model,ios,'silent');
    
    if numel(newioset) ~= numel(this.IOData)
        % Throw a warning that other IO points were removed from the table
        % since they are no longer valid.
        str = sprintf('When modifying the linearization I/O using the Analysis I/O table there were linearization I/O points found that are no longer valid in the model %s or any of its child model references. These invalid closed loop signals have been removed from the Analysis I/O table.',this.model);
        warndlg(str,'Simulink Control Design')
        % Update the tables
        this.IOData = newioset;
        this.updateIOTables;
    end
end
