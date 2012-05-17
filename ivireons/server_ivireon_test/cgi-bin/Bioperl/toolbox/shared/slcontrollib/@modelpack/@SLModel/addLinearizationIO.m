function ports = addLinearizationIO(this, varargin)
% ADDLINEARIZATIONIO Adds new linearization I/O ports to the model.
%
% Overloaded method:
% hLin = this.addLinearizationIO(name, [type], [openloop], [portno]);
% hLin = this.addLinearizationIO(portIDs);

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2007 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/01/15 18:56:54 $

if (nargin == 2) && isa(varargin{1}, 'modelpack.SLLinearizationPortID')
  ports = varargin{1};
elseif (nargin >= 2) && ischar(varargin{1})
  % Construct full path.
  name = modelpack.relpath( this.getName, varargin{1} );
  name = sprintf( '%s/%s', this.getName, name );

  if (nargin < 3 || isempty(varargin{2}))
    type = 'Output';
  else
    type = varargin{2};
  end

  if (nargin < 4 || isempty(varargin{3}))
    openloop = false;
  else
    openloop = varargin{3};
  end

  if (nargin < 5 || isempty(varargin{4}))
    portno = 1;
  else
    portno = varargin{4};
  end

  % Create new ports
  ports = LocalNewPort(this, name, type, openloop, portno);
else
  ctrlMsgUtils.error( 'SLControllib:modelpack:InvalidInputArguments' );
end

%Check ports are valid
isValid = this.isValidPort(ports);
if ~all(isValid)
   badNames = ports(~isValid).getFullName;
   if iscell(badNames)
      %More than one invalid port
      commas = cell(size(badNames));
      [commas{:}] = deal(', ');
      commas{end} = '';
      badNames = vertcat(badNames,commas);
      badNames = strcat(badNames{:});
   end
   ctrlMsgUtils.error('SLControllib:modelpack:slInvalidPort',badNames)
end

% Add them to the current list.
this.LinearizationPorts = [this.LinearizationPorts; ports(:)];

% Add ports to the model.
LocalShowPorts(this, ports);

% ----------------------------------------------------------------------------
function portID = LocalNewPort(this, name, type, openloop, portno)
% Check if block exists.
try
  block = find_system( name, 'FindAll','on', 'SearchDepth',0, 'Type','block' );
catch
  ctrlMsgUtils.error( 'SLControllib:general:InvalidBlockName', name );
end

hBlock = get_param(block, 'Object');
% hPort  = handle( hBlock.PortHandles.Outport(portno) );

name   = regexprep(hBlock.Name,'/','//');
% dims   = hPort.CompiledPortDimensions(2:end);
dims   = 1;
path   = modelpack.relpath( this.Name, hBlock.Path );

portID = modelpack.SLLinearizationPortID( name, dims, path, ...
                                          type, portno, openloop );

% ----------------------------------------------------------------------------
function LocalShowPorts(this, portIDs)
% Correspondence table between I/O type and LinearAnalysisInput,
% LinearAnalysisOutput, LinearAnalysisLinearizeOrder settings.
typestrs = {'Input', 'Output', 'InOut', 'OutIn', 'None'};
typeperm = { 'on' , 'off', 'off'; ...
             'off', 'on' , 'off'; ...
             'on' , 'on' , 'off'; ...
             'on' , 'on' , 'on' ; ...
             'off', 'off', 'off' };

ports = findSimulinkPorts(this, portIDs);

for ct = 1:length(ports)
  idx = find( strcmp(portIDs(ct).getType, typestrs) );

  % [true, false] <-> {'on', 'off'}
  onoff    = {'on', 'off'};
  flag     = portIDs(ct).isOpenLoop;
  openloop = onoff{ [flag, ~flag] };

  % Set linearization settings.
  set( ports(ct), ...
       'LinearAnalysisInput',          typeperm{idx,1}, ...
       'LinearAnalysisOutput',         typeperm{idx,2}, ...
       'LinearAnalysisLinearizeOrder', typeperm{idx,3}, ...
       'LinearAnalysisOpenLoop',       openloop );
end
