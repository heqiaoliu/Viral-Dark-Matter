function update(inputs)
%

% UPDATE  Update the input point specification object
%
 
% Author(s): John W. Glass 10-Dec-2007
%   Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2009/04/21 04:28:43 $

% Check that the port dimensions are correct
for ct = 1:length(inputs)
    input = inputs(ct);
    % Get the port handles
    Ports = get_param(inputs(ct).Block,'PortHandles');
    % Get the port width
    PortWidth = get_param(Ports.Outport,'CompiledPortWidth');
    if isempty(inputs(ct).PortWidth) || (PortWidth ~= inputs(ct).PortWidth)
        % Need to re-initialize the properties
        input.PortWidth = PortWidth;
        input.u         = zeros(PortWidth,1);
        input.Known     = false(PortWidth,1);
        input.Min       = -inf*ones(PortWidth,1);
        input.Max       =  inf*ones(PortWidth,1);
    end
    if isempty(input.PortDimensions)
        PortDimensions = get_param(input.Block,'CompiledPortDimensions');
        input.PortDimensions = PortDimensions.Outport;
    end
end
