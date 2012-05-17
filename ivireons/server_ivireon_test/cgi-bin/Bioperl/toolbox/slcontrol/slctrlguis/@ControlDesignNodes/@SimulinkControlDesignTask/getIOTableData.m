function [input_table_data,output_table_data] = getIOTableData(this)
%getIOTableData  Method to get the current Simulink linearization I/O 
%                settings for the I/O table in the GUI.

%  Author(s): John Glass
%  Copyright 2005 The MathWorks, Inc.

iodata = this.IOData;

% Get the types of IO
iotype = get(iodata,{'Type'});

% Find the objects with input data
mixedio = iodata([find(strcmp(iotype,'inout'));...
                    find(strcmp(iotype,'outin'))]);
inio = [iodata(strcmp(iotype,'in'));...
            mixedio];
        
if numel(inio) > 0
    input_table_data = javaArray('java.lang.Object',length(inio),4);
    
    for ct = 1:numel(inio)
        input_table_data(ct,1) = java.lang.Boolean(strcmp(inio(ct).Active,'on'));
        input_table_data(ct,2) = java.lang.String(inio(ct).Block);
        input_table_data(ct,3) = java.lang.Integer(inio(ct).PortNumber);
        % Get the signal name
        ph = get_param(inio(ct).Block,'PortHandles');
        input_table_data(ct,4) = java.lang.String(get_param(ph.Outport(inio(ct).PortNumber),'Name'));
    end
else
    input_table_data = [];
end

% Find the objects with output data
outio = [iodata(strcmp(iotype,'out'));...
            mixedio];
        
if numel(outio) > 0
    output_table_data = javaArray('java.lang.Object',length(outio),4);
    
    for ct = 1:numel(outio)
        output_table_data(ct,1) = java.lang.Boolean(strcmp(outio(ct).Active,'on'));
        output_table_data(ct,2) = java.lang.String(outio(ct).Block);
        output_table_data(ct,3) = java.lang.Integer(outio(ct).PortNumber);
        % Get the signal name
        ph = get_param(outio(ct).Block,'PortHandles');
        output_table_data(ct,4) = java.lang.String(get_param(ph.Outport(outio(ct).PortNumber),'Name'));
    end
else
    output_table_data = [];
end        