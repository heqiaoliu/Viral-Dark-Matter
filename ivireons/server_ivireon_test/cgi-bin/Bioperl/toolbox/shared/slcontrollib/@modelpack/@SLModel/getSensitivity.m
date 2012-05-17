function [derivs, varargout] = getSensitivity(this, T, InputSignals, variables, Opt)
% GETSENSITIVITY Computes sensitivity derivatives of model trajectories with
% respect to parameter changes
%
% [derivs,info] = this.getSensitivity(time, inputs, variables, options)
% [lResp, rResp, info] = this.getSensitivity(...)
%
% TIMESPAN is one of: TFinal, [TStart TFinal], or [TStart OutputTimes TFinal].
% INPUTS is a cell array of TIMESERIES objects, one per model input.
% VARIABLES one of ParameterID, ParameterSpec for a ParameterID, or a
%           string with the variable full name
% OPTIONS is a GRADOPTIONS object.
%
% DERIVS is a cell array of TIMESERIES objects, one per parameter per model
% output.
%

% Author(s): A. Stothert
% Copyright 2006-2007 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/01/15 18:56:56 $

dOut = nargout<=2;            %Flag to compute and return finite differences

%Check argument dimensions
if ~ischar(variables)&&numel(variables)~=1
  ctrlMsgUtils.error('SLControllib:general:InvalidArgument', ...
                     'VARIABLES', 'getSensitivity', ...
                     'modelpack.SLModel.getSensitivity' );
end

%Check variables argument type
haveSpec = false;
switch class(variables)
   case 'modelpack.ParameterSpec'
      haveSpec = true;
      pSpec = variables;
      nP    = numel(pSpec);
      pID   = pSpec.getID;
      if nP > 1, pID   = [pID{:}]; end   %Convert to vector from cell array
      if ~isa(pID,'modelpack.SLParameterID')
        ctrlMsgUtils.error( 'SLControllib:modelpack:errArgumentType', ...
                            'VARIABLES', 'modelpack.SLParameterID' );
      end
   case 'modelpack.SLParameterID'
      pID   = variables;
      nP    = numel(pID);
      pSpec = struct('Maximum',cell(nP,1),'Minimum',cell(nP,1));
   case 'char'
      pID = this.findParameter(variables);  %Look for exact match
      if isempty(pID)
        ctrlMsgUtils.error( 'SLControllib:modelpack:errParameterNotFound', ...
                            variables );
      end
      nP    = numel(pID);
      pSpec = struct('Maximum',cell(nP,1),'Minimum',cell(nP,1));
  otherwise
    ctrlMsgUtils.error( 'SLControllib:modelpack:errArgumentType', ...
                        'VARIABLES', ...
                        'modelpack.ParameterSpec, modelpack.SLParameterID, or string' );
end

%Check the Opt argument
if ~isa(Opt,'modelpack.gradoptions')
  ctrlMsgUtils.error( 'SLControllib:modelpack:errArgumentType', ...
                      'OPTIONS', 'modelpack.gradoptions' );
end
%Set the perturbation size
delta    = Opt.Perturbation;
if isempty(delta), delta = 1e-3; end
%Get the output ports
OutPorts   = Opt.Outputs;
allOutputs = this.getOutputs;  %All ports know to model
if isempty(OutPorts)
   %No ports specified in options, assume all Outports
   OutPorts = allOutputs;
end
if isempty(OutPorts)
  ctrlMsgUtils.error( 'SLControllib:modelpack:NoModelOutputSpecified' );
end

%Retrive current prameter value and treat as nominal
if haveSpec
   pObj = pSpec;
else
   pObj = pID;
end
nom = this.getValue(pObj).Value;

%Create storage space for outputs
nOut     = numel(OutPorts);                     % Number of output ports
nPScalar = numel(nom);                          % Number of scalar parameters
if dOut,
   %Compute and return finite differences
   derivs = cell(nPScalar,nOut);
else
   %Return perturbed signals
   yR = cell(nPScalar,nOut);
   yL = cell(nPScalar,nOut);
end

%Compute all perturbations based off nominal value
dR = nom.*(1+sign(nom)*delta);
dL = nom.*(1-sign(nom)*delta);
%Use typical value to set at least a minimum perturbation
if haveSpec
   typical = variables.TypicalValue;
   typical(typical==0) = 1;   %Protect against zero values
else
   typical = ones(size(nom));
end
dR = dR + 0.01*delta*abs(typical);
dL = dL - 0.01*delta*abs(typical);
%Limit perturbation size if parameters limits are specified
if haveSpec
   if ~isempty(pSpec.Maximum)
      dR = min(dR,pSpec.Maximum);
   end
   if ~isempty(pSpec.Minimum)
      dL = max(dL,pSpec.Minimum);
   end
end

%Loop over each scalar perturbation
pvR = nom;
pvL = nom;
for ct_pScalar=1:nPScalar
   %Set perturbation for a specific parameter
   pvR(ct_pScalar) = dR(ct_pScalar);
   pvL(ct_pScalar) = dL(ct_pScalar);

   %Get left and right perturbed responses
   if strcmpi(Opt.GradientType,'refined')
      [yRp, yLp, simInfo] = localRefinedGradient(this,pObj,pvR,pvL,T,InputSignals,Opt);
   else
      [yRp, yLp, simInfo] = localBasicGradient(this,pObj,pvR,pvL,T,InputSignals,Opt);
   end

   if ~simInfo.userStopped
      %Should have full sets of data
      if dOut
         %Compute finite difference
         for ct_Output = 1:nOut
            yRp{ct_Output} = (yRp{ct_Output}-yLp{ct_Output})...
               ./(pvR(ct_pScalar)-pvL(ct_pScalar));
         end
         derivs(ct_pScalar,:) = yRp(:);
      else
         %Return perturbed signals directly
         yR(ct_pScalar,:) = yRp(:);
         yL(ct_pScalar,:) = yLp(:);
      end
   end

   %Restore parameter perturbation
   pvR(ct_pScalar) = nom(ct_pScalar);
   pvL(ct_pScalar) = nom(ct_pScalar);
end

%Finished with perturbations, set parameter back to nominal value
this.setValue(pObj,nom);

%Construct info argument to return
rTypes = {'Perturbed signals','Finite differences'};
info = struct(...
   'Perturbations',[dL(:), dR(:)],...
   'ReturnType',rTypes{dOut+1},...
   'SimulationStatus',simInfo);

if dOut
   %Return computed Jacobian
   varargout{1} = info;
else
   %Return perturbed trajectories
   derivs = yL;
   varargout{1} = yR;
   varargout{2} = info;
end

% ----------------------------------------------------------------------------
% Function to compute left and right perturbation responses by separate
% simulation calls
function [yRp, yLp,info] = localBasicGradient(this,pObj,pvR,pvL,T,InputSignals,Opt)

%Right perturbation
this.setValue(pObj,pvR);
[yRp,info] = this.simulate(T,InputSignals,Opt);
if ~info.userStopped
   %Left perturbation
   this.setValue(pObj,pvL)
   [yLp,info] = this.simulate(T,InputSignals,Opt);
else
   yLp = [];
end

% ----------------------------------------------------------------------------
% Function to compute left and right perturbation responses using one
% simulation call
function [yRp, yLp,info] = localRefinedGradient(this,pObj,pvR,pvL,T,InputSignals,Opt)

%Get parameter name and subsref if any
[name,subs] = modelpack.varnames(pObj.getName);
%Check we have a valid gradient model
if isempty(this.GradModel) || ~ishandle(this.GradModel)
   %No gradient model
   createGradModel = true;
else
   %Have grad model, check that it contains the required parameter
   idxP = strcmp({this.GradModel.Variables.Name},name);
   createGradModel = ~any(idxP);
end
allP = getTunableParameters(this);         %All parameters
allV = evalParameters(this, {allP.Name});  %All parameter values
if createGradModel
   %Have to (re)create grad model, make sure to copy all parameters across
   this.GradModel = slcontrol.GradientModel(this.Name,allV);
   idxP = strcmp({this.GradModel.Variables.Name},name);
end

%Make sure Grad model parameters are synced with the original model
%parameters
for ctP = 1:numel(allP)
   idx = strcmp({this.GradModel.Variables.Name},allP(ctP).Name);
   if ~isempty(idx)
      this.GradModel.Variables(idx).LValue = allV(ctP).Value;
      this.GradModel.Variables(idx).RValue = allV(ctP).Value;
   end
end

%Get model API object for gradient model
hGradModel = this.GradModel.utCreateGradMAPI;

%Set left and right perturbations for parameter
if ~isempty(subs)
   %Need to set a subelement of the variable
   LValue = this.GradModel.Variables(idxP).LValue;
   RValue = this.GradModel.Variables(idxP).LValue;
   eval(['LValue',subs,'=','pvL;'])
   eval(['RValue',subs,'=','pvR;'])
   this.GradModel.Variables(idxP).LValue = LValue;
   this.GradModel.Variables(idxP).RValue = RValue;
else
   this.GradModel.Variables(idxP).LValue = pvL;
   this.GradModel.Variables(idxP).RValue = pvR;
end

%Set ports for gradient model based on original model
origOutputs    = Opt.Outputs;
if ~isempty(origOutputs)
   pNames = origOutputs.getBlock;
   pNums  = origOutputs.getPortNumber;
else
   %No specific outputs in options, assume all outputs are required
   pNames = this.getOutputs.getBlock;
   pNums  = this.getOutputs.getPortNumber;
end
if ~iscell(pNames), pNames = {pNames}; end
GradModelOpts = Opt.copy;
GradModelOpts.Outputs = [];
for ctO = 1:numel(pNames)
   GradModelOpts.Outputs = vertcat(GradModelOpts.Outputs,...
      hGradModel.addOutput(strcat('Left/',pNames{ctO}),pNums(ctO)));
   GradModelOpts.Outputs = vertcat(GradModelOpts.Outputs,...
      hGradModel.addOutput(strcat('Right/',pNames{ctO}),pNums(ctO)));
end

%Copy configuration from model to gradient model
GradModelOpts.Configuration = Opt.Configuration.copy;

%Simulate the gradient model
L = handle.listener(Opt,'StopSim',@(hSrc,hData) localStopSim(hGradModel.getName)); %#ok<NASGU>
[y,info] = hGradModel.simulate(T,InputSignals,GradModelOpts);
y   = reshape(y,2,numel(pNames));
yLp = y(1,:);
yRp = y(2,:);

function localStopSim(model)
%% Manage stop sim events
set_param(model,'SimulationCommand','Stop')

