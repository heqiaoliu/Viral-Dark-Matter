function Spec = getSpec(this,Variable)
% GETSPEC  Method to return a spec object for a modelpack ID object
%
% Spec = model.getSpec(ID)
%
 
% Author(s): A. Stothert 31-Oct-2005
% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/09/18 02:28:31 $

%Handle cases for explicit input types
processed = false;
if isa(Variable,'modelpack.STStateID') 
   %Want to get a state spec
   Spec = localGetSpec(this,Variable,'modelpack.StateSpec');
   processed = true;
end
if isa(Variable,'modelpack.STParameterID') 
   %Want to get a parameter spec
   Spec = localGetSpec(this,Variable,'modelpack.STParameterSpec');
   processed = true;
end
if isa(Variable,'modelpack.STPortID') 
   %Want to get a port spec
   Spec = localGetSpec(this,Variable,'PortSpec');
   processed = true;
end

%Handle case for more generic inputs
if ischar(Variable)
   %Want to get a parameter parameter spec using the fullname
   Spec = localGetStringSpec(this,Variable);
   processed = true;
end
if ~processed && isa(Variable,'modelpack.VariableID')
   %Want to get a generic variable spec
   Spec = localGetVariableSpec(this,Variable);
   processed = true;
end

if ~processed
   ctrlMSgUtils.error('SLControllib:modelpack:errArgumentType','ID', ...
      'string, modelpack.STParameterID, modelpack.STPortID, or modelpack.STStateID');
end

%--------------------------------------------------------------------------
function Val = localGetSpec(this,VarID,type)
%Local sub-function to return a spec ot the appropriate type

nVar = numel(VarID);
Val = handle(nan(nVar,1));
for ct = 1:nVar
   Val(ct,1) = feval(type,this,VarID(ct));
   if strcmp(type,'modelpack.STParameterSpec')
      Val(ct,1).InitialValue = this.getValue(VarID(ct)).Value;
      Val(ct,1).TypicalValue = Val(ct,1).InitialValue;
   end
end

%--------------------------------------------------------------------------
function Val = localGetStringSpec(this,Variable)
%Local sub-function to create a spec from a string

%Check parameters for match
ID = this.findParameter(Variable,true);
if ~isempty(ID)
   Val = localGetSpec(this,ID,'modelpack.STParameterSpec');
   %No need to search further, exit
   return
end

%Check states for match
ID = this.findState(Variable,true);
if ~isempty(ID)
   Val = localGetSpec(this,ID,'modelpack.StateSpec');
   %No need to search further, exit
   return
end

%Check input ports 
ID = this.findInput(Variable,true);
if ~isempty(ID)
   Val = localGetSpec(this,ID,'modelpack.PortSpec');
   %No need to search further, exit
   return
end

%Check output ports 
ID = this.findInput(Variable,true);
if ~isempty(ID)
   Val = localGetSpec(this,ID,'modelpack.PortSpec');
   %No need to search further, exit
   return
end

%No matching element found return empty handle
Val = handle(nan);

%--------------------------------------------------------------------------
function Val = localGetVariableSpec(this,Variable)

%Mix of different Variable ID objects
nVal = numel(Variable);
Val  = handle(nan(nVal,1));
for ct = 1:nVal
   
   %Determine the type of spec to create  
   switch class(Variable(ct))
      case 'modelpack.STPortID'
         type = 'modelpack.PortSpec';
      case 'modelpack.STStateID'
         type = 'modelpack.StateSpec';
      case 'modelpack.STParameterID'
         type = 'modelpack.STParameterSpec';
      otherwise
         %Unsupported type, skip spec creation
         type = [];
   end
   
   %Create the spec
   if ~isempty(type)
      Val(ct,1) = localGetSpec(this,Variable(ct),type);
   end
end

