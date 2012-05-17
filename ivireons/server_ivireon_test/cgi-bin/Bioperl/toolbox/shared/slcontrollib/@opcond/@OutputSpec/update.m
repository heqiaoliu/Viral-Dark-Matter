function update(outputs)
%

% UPDATE 
%
 
% Author(s): John W. Glass 10-Dec-2007
%   Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/31 06:58:23 $

% Create the output constraint objects and populate their values
for ct = 1:length(outputs)
    %% Get the port handles
    Ports = get_param(outputs(ct).Block,'PortHandles');
    %% Get the port width
    if isnan(outputs(ct).PortNumber);
        PortWidth = get_param(Ports.Inport,'CompiledPortWidth');
    else
        PortWidth = get_param(Ports.Outport(outputs(ct).PortNumber),'CompiledPortWidth');
    end
    if isempty(outputs(ct).PortWidth) || ...
            (PortWidth ~= outputs(ct).PortWidth)
        %% Need to re-initialize the properties
        outputs(ct).PortWidth  = PortWidth;
        outputs(ct).Min        = -inf*ones(PortWidth,1);
        outputs(ct).Max        =  inf*ones(PortWidth,1);
        outputs(ct).y          =  zeros(PortWidth,1);
        outputs(ct).Known      =  false(PortWidth,1);
    end
end
