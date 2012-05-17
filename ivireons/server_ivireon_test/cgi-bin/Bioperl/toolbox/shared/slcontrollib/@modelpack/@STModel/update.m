function update(this,UpdateWhat) 
% UPDATE  method to update SISOTOOL model object, this synchronizes the 
% model object parameters, ports, and states with the SISOTOOL object.
%
% this.update(UpdateWhat)
% 
% Inputs: 
%     UpdateWhat - an optional string indication what to update, accepted
%     values are {'Parameters'|'Ports'|'LinearizationPorts'|'States'|'All'}, 
%     if omitted the default 'All' is used.
%
 
% Author(s): A. Stothert 22-Jul-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.10 $ $Date: 2009/05/23 08:11:45 $

%Check for optional arguments
if nargin < 2, UpdateWhat = 'All'; end

switch UpdateWhat
   case 'Parameters' 
      localUpdateParams(this)
   case 'Ports' 
      this.IOs = localUpdatePorts(this,this.IOs,'modelpack.STPortID');
   case 'LinearizationPorts'
      this.LinearizationIOs = localUpdatePorts(this,...
         this.LinearizationIOs,'modelpack.STLinearizationID');
   case 'States'
      localUpdateStates(this);
   case 'All'
      localUpdateParams(this)
      this.IOs              = localUpdatePorts(this,this.IOs,'modelpack.STPortID');
      this.LinearizationIOs = localUpdatePorts(this,...
         this.LinearizationIOs,'modelpack.STLinearizationID');
      localUpdateStates(this);      
   otherwise
      ctrlMsgUtils.error('SLControllib:modelpack:errValueEnumerated','UpdateWhat', ...
         '{''Parameters''|''Ports''|''LinearizationPorts''|''States''|''All''}');
end

%--------------------------------------------------------------------------
function localUpdateParams(this)
%Function to make sure all SISOTOOL parameters have equivalent parameter ID
%objects as properties of the SISOTOOL model object.

Compensators = this.Model.C;
Params       = this.Parameters;
FoundParams  = false(1,numel(Params));   %Keep track of parameters found
NewParams    = [];                       %Vector of newly found parameters

for ct=1:numel(Compensators)
   if isa(Compensators(ct),'sisodata.TunedZPK')
      %Always has PZGroup specs
      if Compensators(ct).isTunable
         ZPKSpecs = Compensators(ct).getZPKParameterSpec;
      else
         ZPKSpecs = struct('GainSpec',[],'PZGroupSpec',[]);
      end
      MaskParamSpec = Compensators(ct).getMaskParameterSpec; %Only returns tunable mask parameters
      SISOParams = [...
         MaskParamSpec; ...
         ZPKSpecs.GainSpec; ...
         ZPKSpecs.PZGroupSpec];
   else
      %No PZGroup spec
      SISOParams = Compensators(ct).getMaskParameterSpec;
   end
   for ct_P = 1:numel(SISOParams)
      NewP  = SISOParams(ct_P).getID;
      found = false; idx = 1;
      while ~found && idx <= numel(this.Parameters)
         found = NewP.isSame(this.Parameters(idx));
         if ~found, idx = idx + 1; end
      end
      if ~found
         %New parameter, first make sure we have correct dimension and locations 
         %then add to list of new parameters
         [Value,Dim,Locations] = getParameterData(this,Compensators(ct),NewP);
         NewP.update(this,'Dimension',Dim,'Locations',Locations);
         NewParams = [NewParams; NewP]; %#ok<AGROW>
      else
         %Existing parameter
         if ~FoundParams(idx)
            %Haven't already found this parameter, update dimension, value and
            %location
            FoundParams(idx) = true;
            [Value,Dim,Locations] = getParameterData(this,Compensators(ct),NewP);
            Params(idx).update(this,'Dimension',Dim,'Locations',Locations);
         end
      end
   end
end

%Remove any missing params and add new parameters
if any(~FoundParams), 
   Params(~FoundParams).delete; 
   Params = Params(ishandle(Params));
end
this.Parameters      = [Params; NewParams];

%--------------------------------------------------------------------------
function IOs = localUpdatePorts(this,IOs,objType)
%Function to make sure all SISOTOOL ports have equivalent port ID
%objects as properties of the SISOTOOL model object.
%
% Inputs:
%    IOs     - vector of currently known ports
%    objType - string with type of port object to create if new ports are
%              identified can be one of
%              {'modelpack.STPortID'|'modelpack.STLinearizationID'}

nIOs = numel(IOs);

%Collect list of all actual SISOTOOL inputs & outputs
Inputs       = this.Model.Input;  
nInputs      = numel(Inputs); 
Outputs      = this.Model.Output; 
nOutputs     = numel(Outputs);
Compensators = get(this.Model.C,{'Identifier'});
nComps       = numel(Compensators);
Loops        = get(this.Model.L,{'Identifier'});
nLoops       = numel(Loops);
%Construct full names for comparison with known ports
InputsPaths  = repmat({''},nInputs,1);
InPortNames  = vertcat(Inputs,repmat({'In'},nComps+nLoops,1));
InPortPaths  = vertcat(Compensators,Loops);
InFullNames  = vertcat(InputsPaths,strcat(InPortPaths,'/'));
InPortPaths  = vertcat(InputsPaths,InPortPaths);
InFullNames  = strcat(InFullNames,strcat(InPortNames,':1'));
OutputsPaths = repmat({''},nOutputs,1);
OutPortNames = vertcat(Outputs,repmat({'Out'},nComps+nLoops,1));
OutPortPaths = vertcat(Compensators,Loops);
OutFullNames = vertcat(OutputsPaths,strcat(OutPortPaths,'/'));
OutPortPaths = vertcat(OutputsPaths,OutPortPaths);
OutFullNames = strcat(OutFullNames,strcat(OutPortNames,':1'));

%Check the difference between known and actual ports
FoundInPorts  = false(1,nInputs+nComps+nLoops);  %Keep track of ports found
FoundOutPorts = false(1,nOutputs+nComps+nLoops); 
FoundIO       = false(1,nIOs);
for ct = 1:nIOs   %Loop over known ports
   FullName = IOs(ct).getFullName;
   idxIn  = strcmp(InFullNames,FullName);
   idxOut = strcmp(OutFullNames,FullName);
   if any(idxIn)
      FoundInPorts(idxIn) = true;
      FoundIO(ct) = true;
   end
   if any(idxOut)
      FoundOutPorts(idxOut) = true;
      FoundIO(ct) = true;
   end
end

%Create any new ports.
newIO = localNewPorts(...
   {InPortNames{~FoundInPorts}}, ...
   {InPortPaths{~FoundInPorts}}, ...
   objType, 'Input');
newIO = [newIO; localNewPorts(...
   {OutPortNames{~FoundOutPorts}}, ...
   {OutPortPaths{~FoundOutPorts}}, ...
   objType, 'Output')];

%Remove IOs not found and add new IOs
if any(~FoundIO), IOs(~FoundIO).delete, end
IOs = [IOs(FoundIO); newIO];

%--------------------------------------------------------------------------
function localUpdateStates(this)
%Function to make sure all SISOTOOL states have equivalent STStateID
%objects as properties of the SISOTOOL model object.
%

States  = this.States;  %List of known states
nStates = numel(States);

%Collect list of all actual SISOTOOL states
StateNames   = this.Model.Name;
Compensators = get(this.Model.C,{'Identifier'});
if ~isempty(Compensators)
   StateNames = vertcat(StateNames,Compensators);
end
Loops  = get(this.Model.L,{'Identifier'});
if ~isempty(Loops)
   StateNames   = vertcat(StateNames,Loops);
end

%Check the difference between known and actual states
FoundState = false(1,numel(StateNames));  %Keep track of states found
Found      = false(1,nStates);
for ct = 1:nStates
   Name = States(ct).getName;
   idx  = strcmp(StateNames,Name);
   if any(idx)
      %Existing state, 
      FoundState(idx) = true;
      if ~Found(ct)
         %Haven't yet found this state,update dimension and sampling time
         Found(ct) = true;
         [Ts,Dim]  = getStateData(this,StateNames{idx},'');
         States(ct).update(this,'Ts',Ts,'Dimension',Dim);
      end
   end
end

%Create any new states.
newState = [];
for idx = find(~FoundState)
   %Add new state
   [Ts,Dim] = getStateData(this,StateNames{idx},'');
   newState = [newState; modelpack.STStateID(...
      StateNames{idx},...
      Dim,...
      '',...
      Ts)]; %#ok<AGROW>
end

%Remove states not found and add new states
if any(~Found), States(~Found).delete, end
this.States = [States(Found); newState];

%--------------------------------------------------------------------------
function NewPorts = localNewPorts(PortNames,PortPaths,objType,Type)
%Helper function to create a vector of STPortID or STLinearizationID objects

NewPorts = [];
for ct=1:numel(PortNames)
   NewPorts = [NewPorts; feval(objType,...
      PortNames{ct}, [1 1], ...
      PortPaths{ct}, Type);]; %#ok<AGROW>
end
   