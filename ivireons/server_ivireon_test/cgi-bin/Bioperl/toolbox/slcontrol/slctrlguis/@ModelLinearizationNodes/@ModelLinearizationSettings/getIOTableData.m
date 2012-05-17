function f = getIOTableData(this)
%getIOTableData  Method to get the current Simulink linearization I/O 
%                settings for the I/O table in the GUI.

%  Author(s): John Glass
%   Copyright 1986-2005 The MathWorks, Inc.
%   % Revision % % Date %

iodata = this.IOData;

if ~isempty(iodata)
    f = javaArray('java.lang.Object',length(iodata),6);
    
    for ct = 1:length(iodata)
        f(ct,1) = java.lang.Boolean(strcmp(iodata(ct).Active,'on'));
        f(ct,2) = java.lang.String(iodata(ct).Block);
        f(ct,3) = java.lang.Integer(iodata(ct).PortNumber);
        % Get the signal name
        ph = get_param(iodata(ct).Block,'PortHandles');
        f(ct,4) = java.lang.String(get_param(ph.Outport(iodata(ct).PortNumber),'Name'));
        if strcmpi(iodata(ct).Type,'in')
            f(ct,5) = java.lang.String( xlate('Input') );
        elseif strcmpi(iodata(ct).Type,'out')
            f(ct,5) = java.lang.String( xlate('Output') );
        elseif strcmpi(iodata(ct).Type,'inout')
            f(ct,5) = java.lang.String( xlate('Input - Output') );
        elseif strcmpi(iodata(ct).Type,'outin')
            f(ct,5) = java.lang.String( xlate('Output - Input') );
        else
            f(ct,5) = java.lang.String( xlate('None') );
        end
        f(ct,6) = java.lang.Boolean(strcmp(iodata(ct).OpenLoop,'on'));
    end
else
    f = [];
end
