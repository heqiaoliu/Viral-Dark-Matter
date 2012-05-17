function Sys = linearize(this,oppts, portIDs, linOptions)
% LINEARIZE Linearizes the model at the specified operating point.
%
% SYS = this.linearize(oppts, linearizationios, [linoptions])
% SYS = this.linearize(times, linearizationios, [linoptions])
%
% SYS is linear time-invariant state-space model.
% LINEARIZATIONIOS is an array of LINEARIZATIONIO objects.
% LINOPTIONS is a linearization options object.
 
% Author(s): A. Stothert 29-Nov-2007
% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2009/12/05 02:22:35 $

%Check for installed SCD license
if isempty(ver('slcontrol')) || ~license('test','simulink_control_design')
   ctrlMsgUtils.error('SLControllib:modelpack:slSCDLicense')
end

%Process input arguments
modelName = this.getName;
if isempty(oppts)
   %No operating point specified, create a default
   oppts = operpoint(modelName);
elseif ~isa(oppts,'opcond.OperatingPoint') && ~isnumeric(oppts)
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','oppts','opcond.OperatingPoint or double')
end
if isnumeric(oppts) && ( any(oppts(:) < 0) || ~isreal(oppts) )
   %Snapshot times must be positive real
   ctrlMsgUtils.error('SLControllib:modelpack:slLinearizePositiveTimes')
end
if ~isa(portIDs,'modelpack.SLLinearizationPortID')
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','linearizationios','modelpack.SLLinearizationID')
end
if nargin < 4  
   %No options specified, use defaults
   linOptions = linoptions;
elseif ~isa(linOptions,'LinearizationObjects.linoptions')
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','linoptions','LinearizationObjects.linoptions')
end

%Check passed ports are valid
isValid = this.isValidPort(portIDs);
if ~all(isValid)
   ctrlMsgUtils.error('SLControllib:modelpack:slInvalidPort','linearizationios')
end

%Convert model API port ID's to IO's that are used by linearize 
IOs = localConvertIOs(modelName,portIDs);
%Call linearize
nSys = numel(oppts);
if nSys > 1
   Sys = cell(size(oppts));
   for ct=1:nSys
      Sys{ct} = linearize(this.getName,oppts(ct),IOs,linOptions);
   end
else
   Sys = linearize(this.getName,oppts,IOs,linOptions);
end

function  ios = localConvertIOs(modelName,portIDs)
%% Convert model API ports to linio ports

for ct=numel(portIDs):-1:1
   port = portIDs(ct);
   %Map port type
   switch port.getType
      case 'Input', pType = 'in';
      case 'Output', pType = 'out';
      case 'InputOutput', pType = 'inout';
      case 'OutputInput', pType = 'outin';
      case 'None', pType = 'none';
   end
   %Map open loop setting
   if port.isOpenLoop, isOpenLoop = 'on'; 
   else isOpenLoop = 'off'; end    
   %Find block name
   name = port.getName;
   path = port.getPath;
   if isempty(path)
      name = sprintf('%s/%s',modelName,name);
   else
      name = sprintf('%s/%s/%s',modelName,path,name);
   end
   %Create linio object
   ios(ct) = linio(...
      name,...
      port.getPortNumber,...
      pType,...
      isOpenLoop);
end
