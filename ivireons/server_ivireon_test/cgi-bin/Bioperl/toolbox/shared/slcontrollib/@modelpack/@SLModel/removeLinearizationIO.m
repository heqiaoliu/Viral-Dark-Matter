function removeLinearizationIO(this, varargin)
% REMOVELINEARIZATIONIO Removes the specified linearization I/O ports from
% the model.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/11/09 21:01:01 $

% Find specified outputs
ni = nargin;
if (ni == 1) || ((ni == 2) && isnumeric(varargin{1}))
  % All or by indices
  hId = this.getLinearizationIOs( varargin{:} );
elseif ischar(varargin{1})
  % By name
  hId = this.findLinearizationIO( varargin{1} );
elseif isa( varargin{1}, 'modelpack.SLLinearizationPortID' )
  % ID object
  hId = varargin{1};
else
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
end

% Locate ports and remove them from the list.
if ~isempty(hId)
  % Remove ports from the list
  [selected, indices] = ismember( hId, this.LinearizationPorts );
  this.LinearizationPorts(indices(selected)) = [];

  % Remove ports from the model if they are already in there.
  LocalHidePorts( this, hId(selected) )

  if ~all(selected)
    warning('modelpack:warning', 'Some outputs were not in the model.');
  end
else
  warning('modelpack:warning', 'Specified I/O(s) cannot be found.');
end

% ----------------------------------------------------------------------------
function LocalHidePorts(this, portIDs)
ports = findSimulinkPorts(this, portIDs);

% Turn off linearization settings.
for ct = 1:length(ports)
  set( ports(ct), ...
       'LinearAnalysisInput',          'off', ...
       'LinearAnalysisOutput',         'off', ...
       'LinearAnalysisLinearizeOrder', 'off', ...
       'LinearAnalysisOpenLoop',       'off' );
end
