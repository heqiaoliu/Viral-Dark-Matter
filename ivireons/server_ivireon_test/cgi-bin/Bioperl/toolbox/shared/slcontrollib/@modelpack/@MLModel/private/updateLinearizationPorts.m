function updateLinearizationPorts(this)
% UPDATELINEARIZATIONPORTS Update model linearization ports information.
%
% Updates the linearization port information in the model object, while
% keeping the identifier objects that have not changed.  The resulting object
% array is not sorted in any way.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2005/12/22 18:53:10 $

new_ports = LocalGetAllPorts(this);
old_ports = this.LinearizationPorts;

this.LinearizationPorts = LocalMergePorts(new_ports, old_ports);

% ----------------------------------------------------------------------------
function new_ports = LocalGetAllPorts(this)
% Update all inputs, outputs
Inputs  = LocalUpdateIOs( this, 'Inport' );
Outputs = LocalUpdateIOs( this, 'Outport' );

% Combine outputs
new_ports = [ Inputs; Outputs ];

% ----------------------------------------------------------------------------
function S = LocalUpdateIOs(this, porttype)
ports = this.ModelData.(porttype);

% Create storage for identifier objects.
S = handle( NaN(length(ports),1) );

% Create identifier objects.
for ct = 1:length(S)
  % Get port type
  switch porttype
  case 'Outport'
    type  = 'Output';
    str   = 'y';
  case 'Inport'
    type  = 'Input';
    str   = 'u';
  end

  % Identifier properties
  name  = sprintf('%s%d', str, ct);
  dims  = ports(ct);

  % Create new identifier.
  S(ct) = modelpack.MLLinearizationPortID(this, name, dims, type);
  setAliases(S(ct), '');
end

% ----------------------------------------------------------------------------
function new_ports = LocalMergePorts(new_ports, old_ports)
% Modifies new_ports by replacing already existing elements from old_ports.
for i = 1:length(new_ports)
  for j = 1:length(old_ports)
    % Replace with existing equivalent identifier if they are equivalent.
    if isSame( new_ports(i), old_ports(j) )
      new_ports(i) = old_ports(j);
      % ATTN: No port should have more than one identifier.
      break;
    end
  end
end
