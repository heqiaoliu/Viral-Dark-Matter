function update(this)
%

% UPDATE  Update the input point objects.  Assumes that the model is
% compiled.
%
 
% Author(s): John W. Glass 10-Dec-2007
%   Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2009/04/21 04:28:41 $

% Check that the port dimensions are correct
for ct = 1:length(this)
    input = this(ct);
    % Get the port handles
    Ports = get_param(this(ct).Block,'PortHandles');
    % Get the port width
    PortWidth = get_param(Ports.Outport,'CompiledPortWidth');
    if isempty(this(ct).PortWidth) || (PortWidth ~= this(ct).PortWidth)
        % Need to re-initialize the properties        
        input.PortWidth = PortWidth;
        input.u = zeros(PortWidth,1);
    end
    if isempty(input.PortDimensions)
        PortDimensions = get_param(input.Block,'CompiledPortDimensions');
        input.PortDimensions = PortDimensions.Outport;
    end
end
