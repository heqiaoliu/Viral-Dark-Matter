function varargout = removeOutput(this, varargin)
% REMOVEOUTPUT Removes the specified output ports from the model.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2010/03/22 04:19:53 $

% Find specified outputs
ni = nargin;
if (ni == 1) || ((ni == 2) && isnumeric(varargin{1}))
  % All or by indices
  portIDs = this.getOutputs( varargin{:} );
elseif ischar(varargin{1})
  % By name
  name = modelpack.relpath( this.getName, varargin{1} );
  portIDs = this.findOutput( name );
elseif isa( varargin{1}, 'modelpack.SLPortID' )
  % ID object
  portIDs = varargin{1};
else
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
end

if isempty(portIDs)
  warning('modelpack:warning', 'Specified output(s) cannot be found.');
end

% Get all outputs
oldIOPorts = this.getOutputs;

% Hide ports and update the model.
LocalHidePorts(this, portIDs)
updateIOPorts(this);

% Get all outputs
newIOPorts = this.getOutputs;

% Return removed outputs if requested.
if nargout > 0
  oldmember = ismember( oldIOPorts, newIOPorts );
  varargout{1} = oldIOPorts(~oldmember);
end

% ----------------------------------------------------------------------------
function LocalHidePorts(this, portIDs)
ports = findSimulinkPorts(this, portIDs);

% Turn off data logging settings.
for ct = 1:length(ports)
  % We can only remove signal logging markers.
  if ~isnan( portIDs(ct).getPortNumber )
    set( ports(ct), 'DataLogging', 'off' );
  else
    % Block will not be removed from the diagram.
    warning( 'modelpack:warning', ...
             'Outport block %s will not be removed from the block diagram.', ...
             portIDs(ct).getFullName );
  end
end
