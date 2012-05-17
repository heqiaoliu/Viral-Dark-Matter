function varargout = addOutput(this, varargin)
% ADDOUTPUT Adds new output ports to the model.
%
% Overloaded method:
% hOut = this.addOutput(name, [portno]);
% hOut = this.addOutput(portIDs);

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.8.9 $ $Date: 2010/03/22 04:19:52 $

if (nargin == 2) && isa( varargin{1}, 'modelpack.SLPortID' )
  % ID object
  portIDs = varargin{1};
elseif (nargin >= 2) && ischar(varargin{1})
  % By name
  % Construct full path.
  name = modelpack.relpath( this.getName, varargin{1} );
  name = sprintf( '%s/%s', this.getName, name );

  % Default port number
  if (nargin < 3 || isempty(varargin{2}))
    portno = [];
  else
    portno = varargin{2};
  end

  % Create new ports
  portIDs = LocalNewPort(this, name, portno);
else
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
end

%Check ports are valid
isValid = this.isValidPort(portIDs);
if ~all(isValid)
   ctrlMsgUtils.error('SLControllib:modelpack:slInvalidPort','portIDs')
end
%Check ports are outputs
isValid = strcmp(portIDs.getType,'Output');
if ~all(isValid)
   strPorts = utGetPortNameList(this,portIDs(~isValid));
   ctrlMsgUtils.error('SLControllib:modelpack:slAddOutputInvalidType',strPorts)
end

% Show ports and update the model.
LocalShowPorts(this, portIDs);
updateIOPorts(this);

% Get all outputs
newIOPorts = this.getOutputs;

% Return new outputs if requested.
if nargout > 0
  if (length(newIOPorts) > 1) || (length(portIDs) > 1)
    idxs = ismember( newIOPorts.getFullName, portIDs.getFullName );
  else
    idxs = strcmp( newIOPorts.getFullName, portIDs.getFullName );
  end
  varargout{1} = newIOPorts(idxs);
end

% ----------------------------------------------------------------------------
function LocalShowPorts(this, portIDs)
ports = findSimulinkPorts(this, portIDs);

% Turn on data logging settings.
for ct = 1:length(ports)
  % We can only add signal logging markers.
  if ~isnan( portIDs(ct).getPortNumber )
    % Will log signal using custom data logging name.
    set( ports(ct), 'DataLogging', 'on' );
  else
    % Block will not be added to the diagram.
    warning( 'modelpack:warning', ...
             'Outport block %s will not be added to the block diagram.', ...
             portIDs(ct).getFullName );
  end
end

% ----------------------------------------------------------------------------
function portID = LocalNewPort(this, name, portno)
% Check if the block exists.
try
   block = find_system( name, 'FindAll','on', 'SearchDepth',0, 'Type','block' );
catch %#ok<CTCH>
   ctrlMsgUtils.error( 'SLControllib:modelpack:slInvalidPort', 'name' );
end

hBlock = get_param(block, 'Object');

% Assign default port number
if isempty(portno)
  if strcmp(hBlock.BlockType, 'Outport')
    portno = NaN;
  else
    portno = 1;
  end
end

name = regexprep(hBlock.Name, '/', '//');
dims = 1; % Place holder dimension.
path = modelpack.relpath( this.Name, hBlock.Path );

portID = modelpack.SLPortID( name, dims, path, 'Output', portno );
