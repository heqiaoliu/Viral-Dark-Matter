function J = utSetJacobianIO(this,J,io)
% UTSETJACOBIANIO  Reconstruct the a Jacobian given a different set of
% linearization IO.
%
 
% Author(s): John W. Glass 20-Jul-2005
%   Copyright 2005-2010 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2010/04/11 20:41:07 $

% The F, G, and H matrices are now not valid.  We need to replace them with
% new connectivity
E = J.Mi.E;
F = J.Mi.F;
G = J.Mi.G;
H = J.Mi.H;

% Get the port handles.  Assume output and input ports match since the
% looping algorithm simultaneously get these ports.
InputPorts = J.Mi.InputPorts;
OutputPorts = J.Mi.OutputPorts;
InputName = J.Mi.InputName;
modelInputName = InputName;
for ct = 1:numel(modelInputName)
    modelInputName{ct} = regexprep(getBlockPath(slcontrol.Utilities,InputName{ct}),'\n',' ');
end
OutputName = J.Mi.OutputName;
modelOutputName = OutputName;
for ct = 1:numel(modelOutputName)
    modelOutputName{ct} = regexprep(getBlockPath(slcontrol.Utilities,OutputName{ct}),'\n',' ');
end

% Loop over the io objects zero out the I/O that does not apply
input_deleted = [];input_keep = [];
output_deleted = [];output_keep = [];
inports_used = [];outports_used = [];

for ct = 1:length(io)
    % Get the current port handle
    ph = get_param(io(ct).Block,'PortHandles');
    outport = ph.Outport(io(ct).PortNumber);
    % Find the indices to the port
    ind_in = find(strcmp(io(ct).Block,modelInputName));
    % Remove elements that are not part of the port specified in the IO.
    % This is to handle the case where a linearization point is on the
    % output of a block with multiple output ports.
    for ct2 = numel(ind_in):-1:1
        if io(ct).PortNumber ~= get_param(InputPorts(ind_in(ct2)),'PortNumber')
            ind_in(ct2) = [];
        end
    end
    ind_out = find(strcmp(io(ct).Block,modelOutputName));
    % Remove elements that are not part of the port specified in the IO.
    % This is to handle the case where a linearization point is on the
    % output of a block with multiple output ports.
    for ct2 = numel(ind_out):-1:1
        if io(ct).PortNumber ~= get_param(OutputPorts(ind_out(ct2)),'PortNumber')
            ind_out(ct2) = [];
        end
    end
    
    % Handle the E matrix for loop openings
    if strcmp(io(ct).OpenLoop,'on')
        [ind_e,~] = find(F(:,ind_in));
        E(ind_e,:) = 0;
    end
    
    % Now reconfigure the model according the IO condition
    switch io(ct).Type
        case 'in'
            inports_used = [inports_used;ind_in];
            output_deleted = [output_deleted;find(outport==OutputPorts)];
            [~,m,~] = unique(InputPorts(ind_in(:)),'first');
            input_keep = [input_keep;InputPorts(ind_in(sort(m)))];
        case 'out'
            outports_used = [outports_used;ind_out];
            input_deleted = [input_deleted;find(outport==InputPorts)];
            [~,m,~] = unique(OutputPorts(ind_out(:)),'first');
            output_keep = [output_keep;OutputPorts(ind_out(sort(m)))];
        case {'outin';'inout'}
            inports_used = [inports_used;ind_in];
            outports_used = [outports_used;ind_out];
            [~,m,~] = unique(InputPorts(ind_in(:)),'first');
            input_keep = [input_keep;InputPorts(ind_in(sort(m)))];
            [~,m,~] = unique(OutputPorts(ind_out(:)),'first');
            output_keep = [output_keep;OutputPorts(ind_out(sort(m)))];
        case 'none'
            output_deleted = [output_deleted;find(outport==OutputPorts)];
            input_deleted = [input_deleted;find(outport==InputPorts)];
    end
end

% The remaining ports in Ports_UnUsed now need to be eliminated
ind_remaining = setxor((1:length(InputPorts))',inports_used);
input_deleted = [input_deleted;ind_remaining];
ind_remaining = setxor((1:length(OutputPorts))',outports_used);
output_deleted = [output_deleted;ind_remaining];

% Remove the extraneous io
F(:,input_deleted) = [];
G(output_deleted,:) = [];
H(:,input_deleted) = [];
H(output_deleted,:) = [];
InputPorts(input_deleted) = [];
OutputPorts(output_deleted) = [];
InputName(input_deleted) = [];
OutputName(output_deleted) = [];

% Sort the ports to be in the order specified
order = [];
for ct = 1:numel(input_keep)
    order = [order;find(input_keep(ct) == InputPorts);];
end
F = F(:,order); H = H(:,order);
InputPorts = InputPorts(order);
InputName = InputName(order);

order = [];
for ct = 1:numel(output_keep)
    order = [order;find(output_keep(ct) == OutputPorts);];
end
G = G(order,:); H = H(order,:);
OutputPorts = OutputPorts(order);
OutputName = OutputName(order);

% Return the new Jacobian structure
J.Mi.E = E;
J.Mi.F = F;
J.Mi.G = G;
J.Mi.H = H;
J.Mi.InputPorts = InputPorts;
J.Mi.OutputPorts = OutputPorts;
J.Mi.InputName = InputName;
J.Mi.OutputName = OutputName;


