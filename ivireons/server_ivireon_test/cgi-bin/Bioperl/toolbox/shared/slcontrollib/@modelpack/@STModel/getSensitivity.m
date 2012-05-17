function [derivs, varargout] = getSensitivity(this, T, InputSignals, variables, Opt)
% GETSENSITIVITY Computes sensitivity derivatives of model trajectories with
% respect to parameter changes
%
% [derivs,info] = this.getSensitivity(time, inputs, variables, options)
% [lResp, rResp, info] = this.getSensitivity(...)
%
% TIMESPAN is one of: TFinal, [TStart TFinal], or [TStart OutputTimes TFinal].
% INPUTS is a cell array of TIMESERIES objects, one per model input.
% VARIABLES one of STParameterID, ParameterSpec for a STParameterID, or a 
%           string with the variable full name
% OPTIONS is a GRADOPTIONS object.
%
% DERIVS is a cell array of TIMESERIES objects, one per parameter per model
% output.
%
 
% Author(s): A. Stothert 02-Aug-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2009/09/21 00:07:01 $

dOut = nargout==2;            %Flag to compute and return finite difference

%Check argument dimensions
if ~ischar(variables)&&numel(variables)~=1
  ctrlMsgUtils.error('SLControllib:general:InvalidArgument', ...
                     'VARIABLES', 'getSensitivity', ...
                     'modelpack.STModel.getSensitivity')
end

%Check variables argument type
haveSpec = false;
switch class(variables)
   case {'modelpack.ParameterSpec', 'modelpack.STParameterSpec'}
      haveSpec = true;
      pSpec = variables;
      nP    = numel(pSpec);
      pID   = pSpec.getID;
      if nP > 1, pID   = [pID{:}]; end   %Convert to vector from cell array
      if ~isa(pID,'modelpack.STParameterID')
         ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','variables','modelpack.STParameterID')
      end
   case 'modelpack.STParameterID'
      pID   = variables;
      nP    = numel(pID);
      pSpec = struct('Maximum',cell(nP,1),'Minimum',cell(nP,1));
   case 'char'
      pID = this.findParameter(variables,true);  %Look for exact match
      if isempty(pID)
         ctrlMsgUtils.error('SLControllib:modelpack:errParameterNotFound',variables)
      end
      nP    = numel(pID);
      pSpec = struct('Maximum',cell(nP,1),'Minimum',cell(nP,1));
   otherwise
      ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','variables', ...
         'modelpack.ParameterSpec, modelpack.STParameterID, or string');
end

%Check the Opt argument
if ~isa(Opt,'modelpack.gradoptions')
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','options','modelpack.gradoptions');
end
delta    = Opt.Perturbation;
if isempty(delta), delta = 1e-3; end
OutPorts = Opt.Outputs;
InPorts  = Opt.Configuration.ActiveInputs;

%Create storage space for outputs
nOut = numel(OutPorts);               %Number of output ports
nPScalar = prod(pID.getDimensions);   %Number of scalar parameters
if dOut, 
   %Compute and return finite differences
   derivs = cell(nPScalar,nOut); 
else
   %Return perturbed signals
   yR = cell(nPScalar,nOut);
   yL = cell(nPScalar,nOut);
end

%Compute all perturbations
if haveSpec
   nom = this.getValue(pSpec).Value;  %Nominal parameter value
else
   nom = this.getValue(pID).Value;  %Nominal parameter value
end
if ~isempty(pSpec.Maximum)
   dR = min( nom.*(1+sign(nom)*delta), pSpec.Maximum);
else
   dR = nom.*(1+sign(nom)*delta);
end
if ~isempty(pSpec.Minimum)
   dL = max( nom.*(1-sign(nom)*delta), pSpec.Minimum);
else
   dL = nom.*(1-sign(nom)*delta);
end
%Set any perturbations with zero nominal
idxZero     = nom==0;
if all(idxZero)
   nNorm = 1;
else
   nNorm = norm(nom);
end
dR(idxZero) = delta*nNorm;
dL(idxZero) = -delta*nNorm;

%Loop over each scalar perturbation
pvR = nom; 
pvL = nom; 
for ct_pScalar=1:nPScalar
   %Set perturbation for a specific parameter
   pvR(ct_pScalar) = dR(ct_pScalar);
   pvL(ct_pScalar) = dL(ct_pScalar);

   %Get left and right perturbed systems

   %Right perturbation
   if haveSpec
      this.setValue(pSpec,pvR);
   else
      this.setValue(pID,pvR);
   end
   sysR = this.linearize([],[InPorts;OutPorts],[]);
   %Left perturbation
   if haveSpec
      this.setValue(pSpec,pvL)   
   else
      this.setValue(pID,pvL)  
   end
   sysL = this.linearize([],[InPorts;OutPorts],[]);

   if dOut
      %Compute finite difference
      [y,t] = utSimulate_LTI(this,sysR-sysL,T,Opt.Configuration.InputType,InputSignals);
      yD = localConvert2TS(y,t,OutPorts);
      yD = cellfun(@(x) x./(pvR(ct_pScalar)-pvL(ct_pScalar)),yD,'UniformOutput',false);
      [derivs{ct_pScalar,:}] = yD{:};
   else
      %Return perturbed signals directly
      [y,t] = utSimulate_LTI(this,vertcat(sysR,sysL),T,Opt.Configuration.InputType,InputSignals);
      yRL = localConvert2TS(y,t,OutPorts);
      [yR{ct_pScalar,:}] = yRL{1:nOut};
      [yL{ct_pScalar,:}] = yRL{nOut+1:2*nOut};
   end
   
   %Restore parameter perturbation
   pvR(ct_pScalar) = nom(ct_pScalar); 
   pvL(ct_pScalar) = nom(ct_pScalar);
end

%Construct info argument to return
rTypes = {'Perturbed signals','Finite differences'};
info = struct('Perturbations',[dL(:), dR(:)],'ReturnType',rTypes{dOut+1});

if dOut
   %Return computed Jacobian
   varargout{1} = info;
else
   %Return perturbed trajectories
   derivs = yL;
   varargout{1} = yR;
   varargout{2} = info;
end

%--------------------------------------------------------------------------
function out = localConvert2TS(y,t,Outputs)
%Helper function to convert numerical data to time series. 
%
%Note that this function relies on the fact that all SISOTOOL output ports 
%have a dimension equal to [1 1].

nSig = size(y,2);        %Number of signals from simulation
nOut = numel(Outputs);   %Number of system outputs

switch nSig
   case nOut
      %Results from computed finite difference
      out = cell(nSig,1);
      for ct = 1:nSig
         out{ct} = timeseries(y(:,ct),t,'name',Outputs(ct).getFullName);
      end
   case 2*nOut
      %Results from Left-Right simulation
      out = cell(nSig,1);
      for ct = 0:nSig-1
         out{ct+1} = timeseries(y(:,ct+1),t,'name',...
            Outputs(rem(ct,nOut)+1).getFullName);
      end
   otherwise
      ctrlMsgUtils.error('SLControllib:modelpack:stErrorPortDimensionMismatch')
end

