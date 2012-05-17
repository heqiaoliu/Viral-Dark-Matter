function updateIOPorts(this)
% UPDATEIOPORTS Updates model input/output information.
%
% Updates the I/O port information in the model object, while keeping the
% identifier objects that have not changed.  The resulting object array is
% not sorted in any way.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2010 The MathWorks, Inc.
% $Revision: 1.1.8.9 $ $Date: 2010/03/22 04:19:56 $

new_ports = fevalCompiled(this, @LocalGetAllPorts, this);
old_ports = this.IOPorts;

this.IOPorts = LocalMergePorts(new_ports, old_ports);

% ----------------------------------------------------------------------------
% ATTN: This function is evaluated after compiling the model.
function new_ports = LocalGetAllPorts(this)
% Update all inputs, outputs, and signals.
Inputs  = LocalUpdateIOs( this, 'Inport' );
Outputs = LocalUpdateIOs( this, 'Outport' );
Signals = LocalUpdateSignals( this );

% Combine outputs
new_ports = [ Inputs; Outputs; Signals ];

% ----------------------------------------------------------------------------
function S = LocalUpdateIOs(this, blocktype)
% Used to create identifier objects for top level Inport and Outport blocks.
% Get the names of the current I/O blocks.
blocks = find_system( this.Name, 'FindAll', 'on', ...
                      'SearchDepth', 1, 'BlockType', blocktype );

% Create storage for identifier objects.
S = handle( NaN(length(blocks),1) );

% Create identifier objects.
for ct = 1:length(S)
  hBlock = get_param(blocks(ct), 'Object');

  % Get port handle
  switch blocktype
    case 'Outport'
      type  = 'Output';
      hPort = handle( hBlock.PortHandles.Inport(1) );
    case 'Inport'
      type  = 'Input';
      hPort = handle( hBlock.PortHandles.Outport(1) );
  end

  % Identifier properties
  name = regexprep(hBlock.Name, '/', '//');
  dims = LocalMapDimensions(hPort);
  path = modelpack.relpath( this.Name, hBlock.Path );

  % Create new identifier.
  S(ct) = modelpack.SLPortID( name, dims, path, type, [] );
end

% ----------------------------------------------------------------------------
function S = LocalUpdateSignals(this)
% Used to create identifier objects for logged model signals.
% Get the names of the current outport ports
ports = find_system( this.Name, 'FindAll', 'on', 'LookUnderMasks', 'all', ...
                     'Type', 'port', 'PortType', 'outport', ...
                     'DataLogging', 'on' );

% Create storage for identifier objects.
S = handle( NaN(length(ports),1) );

% Create identifier objects.
for ct = 1:length(S)
  hPort  = get_param(ports(ct),    'Object');
  hBlock = get_param(hPort.Parent, 'Object');

  % Identifier properties
  name    = regexprep(hBlock.Name, '/', '//');
  dims    = LocalMapDimensions(hPort);
  path    = modelpack.relpath( this.Name, hBlock.Path );

  portno  = hPort.PortNumber;
  aliases = LocalGetAliases(hPort, dims);

  % Create new identifier.
  S(ct) = modelpack.SLPortID( name, dims, path, [], portno );
  setAliases(S(ct), aliases);
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

% ----------------------------------------------------------------------------
function dims = LocalMapDimensions(hPort)
% Maps the dimensions of the port HPORT from Simulink convention to Model API
% convention.
%
% DIMS is a scalar or a 1x2 integer array.
dimsSL = hPort.CompiledPortDimensions;

if (dimsSL(1) == 1) || (dimsSL(1) == 2)
  % Scalar, vector, or matrix signal
  dims = dimsSL(2:end);
elseif ( dimsSL(1) == -2 )
  % Bus signal (flatten the signal dimensions)
  dims = hPort.CompiledPortWidth;
else
  ctrlMsgUtils.error( 'SLControllib:general:UnexpectedError' );
end

% ----------------------------------------------------------------------------
function aliases = LocalGetAliases(hPort, dims)
% Gets the signal names from the port HPORT.

% Get default aliases from named signals.
aliases(1:prod(dims)) = { hPort.UserSpecifiedLogName };

% Parse names for bus signals
dimsSL = hPort.CompiledPortDimensions;
if (dimsSL(1) == -2)
  ports  = get_param( hPort.Line, 'NonVirtualSrcPorts' );
  offset = 1;

  % Get source signal names
  for ct = 1:length(ports)
    len = get(ports(ct), 'CompiledPortWidth');
    aliases(offset:offset+len-1) = {get(ports(ct), 'UserSpecifiedLogName')};
    offset = offset + len;
  end
end

% ----------------------------------------------------------------------------
%if ~isempty( hPort.busStruct)
%  aliases = getSignalNames( hPort.busStruct );
%end

% getTreeItems: return a formatted representation of input signals for a
% tree widget and the handles of all blocks associated with this block
% function [items, handles] = getTreeItems(s)
% items   = {};
% handles = [];
% for i = 1:length(s)
%     if isempty(s(i).signals)
%         items   = [items {s(i).name}];
%         handles = unique([handles s(i).src]);
%     else
%         [itms hdls] = getTreeItems(s(i).signals);
%         items   = [items {s(i).name, itms}];
%         handles = unique([handles s(i).src hdls]);
%     end
% end
