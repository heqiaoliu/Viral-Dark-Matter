function updateLinearizationPorts(this)
% UPDATELINEARIZATIONPORTS Update model linearization ports information.
%
% Updates the linearization port information in the model object, while
% keeping the identifier objects that have not changed.  The resulting object
% array is not sorted in any way.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2007 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/11/09 21:01:16 $

new_ports = fevalCompiled(this, @LocalGetAllPorts, this);
old_ports = this.LinearizationPorts;

this.LinearizationPorts = LocalMergePorts(new_ports, old_ports);

% ----------------------------------------------------------------------------
% ATTN: This function is evaluated after compiling the model.
function new_ports = LocalGetAllPorts(this)
% Correspondence table between I/O type and LinearAnalysisInput,
% LinearAnalysisOutput, LinearAnalysisLinearizeOrder,  LinearAnalysisOpenLoop.
ioperm = { 'on' , 'off', 'off', 'off', 'Input' ; ...
           'on' , 'off', 'off', 'on' , 'Input' ; ...
           'on' , 'off', 'on' , 'off', 'Input' ; ...
           'on' , 'off', 'on' , 'on' , 'Input' ; ...
           'off', 'on' , 'off', 'off', 'Output'; ...
           'off', 'on' , 'off', 'on' , 'Output'; ...
           'off', 'on' , 'on' , 'off', 'Output'; ...
           'off', 'on' , 'on' , 'on' , 'Output'; ...
           'on' , 'on' , 'off', 'off', 'InOut' ; ...
           'on' , 'on' , 'off', 'on' , 'InOut' ; ...
           'on' , 'on' , 'on' , 'off', 'OutIn' ; ...
           'on' , 'on' , 'on' , 'on' , 'OutIn' ; ...
           'off', 'off', 'off', 'on' , 'None'  ; ...
           'off', 'off', 'on' , 'on' , 'None' };

% Return array
new_ports = [];

% Iterate over each linearization I/O type.
for ct = 1:size(ioperm,1)
  % Get the names of the current linearization I/O ports.
  ports = find_system( this.getName, 'FindAll', 'on', ...
                       'LookUnderMasks', 'all', 'Type', 'port', ...
                       'LinearAnalysisInput',          ioperm{ct,1}, ...
                       'LinearAnalysisOutput',         ioperm{ct,2}, ...
                       'LinearAnalysisLinearizeOrder', ioperm{ct,3}, ...
                       'LinearAnalysisOpenLoop',       ioperm{ct,4} );

  % Create storage for identifier objects.
  S = handle( NaN(length(ports),1) );

  % Create identifier objects.
  for k = 1:length(S)
    hPort  = get_param(ports(k),     'Object');
    hBlock = get_param(hPort.Parent, 'Object');

    % Identifier properties
    name     = regexprep(hBlock.Name,'/','//');
    dims     = LocalMapDimensions(hPort);
    path     = modelpack.relpath( this.Name, hBlock.Path );
    portno   = hPort.PortNumber;
    type     = ioperm{ct,5};
    openloop = strcmp(ioperm{ct,4}, 'on');
    aliases  = LocalGetAliases(hPort, dims);

    % Create new identifier.
    S(k) = modelpack.SLLinearizationPortID( name, dims, path, ...
                                            type, portno, openloop );
    setAliases(S(k), aliases);
  end

  % Add new objects
  new_ports = [new_ports; S]; %#ok<AGROW>
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
  % Bus signal (flattenned the signal dimension)
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
  offset = 1;
  loc    = 3;

  for ct = 1:dimsSL(2)
    if dimsSL(loc) == 1
      % Scalar or vector signal in bus
      len = dimsSL(loc+1);
      aliases(offset:offset+len-1) = {sprintf('bus %d', ct)};
      loc = loc + 2;
    elseif dimsSL(loc) == 2
      % Matrix signal in bus
      len = prod(dimsSL(loc+(1:2)));
      aliases(offset:offset+len-1) = {sprintf('bus %d', ct)};
      loc = loc + 3;
    else
      ctrlMsgUtils.error( 'SLControllib:general:UnexpectedError' );
    end

    offset = offset + len;
  end
end
