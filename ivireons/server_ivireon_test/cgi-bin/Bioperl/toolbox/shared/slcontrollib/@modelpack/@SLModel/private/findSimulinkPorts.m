function ports = findSimulinkPorts(this, portIDs)
% FINDSIMULINKPORTS Returns the Simulink.Port objects corresponding to the
% ports/blocks identified by PORTIDS.
%
% For an internal block, returns the port object for the specified output.
% For an Outport block, returns the port object for the connecting source.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/06/07 14:51:40 $

model = this.getName;

% Pre-allocate the port object vector.
nport = length(portIDs);
ports = handle( NaN(nport,1) );

for ct = 1:nport
  h = portIDs(ct);

  % Construct the block path
  block = sprintf('%s/%s', model, h.getBlock);

  if isnan( h.getPortNumber )
    % Outport block: Port is the output of the source block.
    PortConnectivity = get_param( block, 'PortConnectivity' );
    SrcBlock         = PortConnectivity.SrcBlock;

    PortHandles      = get_param( SrcBlock, 'PortHandles' );
    PortNumber       = PortConnectivity.SrcPort + 1;
  else
    % Internal block: Port is the output of the specified block.
    PortHandles      = get_param( block, 'PortHandles' );
    PortNumber       = h.getPortNumber;
  end

  % Store port object handle.
  ports(ct) = handle( PortHandles.Outport( PortNumber ) );
end
