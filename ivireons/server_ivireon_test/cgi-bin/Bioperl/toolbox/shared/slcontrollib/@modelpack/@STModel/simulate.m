function [out,info] = simulate(this,T,InputSignals,SimOpt)
% SIMULATE  method to perform time domain simulation of the SISTOOL object
% model.
%
% [out,info] = this.simulate(T,InputSignals,SimOpt)
%
% Input:
%    T            - a double vector of simulation time points
%    InputSignals - a vector of modelpack.STPortID input objects
%    SimOpt       - a modelpack simoptions object
 
% Author(s): A. Stothert 25-Jul-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2009/09/21 00:07:02 $

%Check number of arguments
if nargin ~=4
   ctrlMsgUtils.error('SLControllib:modelpack:errNumArguments','4')
end

%Check input argument types
if ~isa(SimOpt,'modelpack.simoptions')
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','SimOpt','modelpack.simoptions')
elseif ~isa(SimOpt.Configuration,'modelpack.STConfig') 
   ctrlMsgUtils.error('SLControllib:modelpack:stErrorSimConfiguration')
end
if ~isempty(InputSignals) && ~isa(InputSignals,'timeseries');
   ctrlMsgUtils.error('SLControllib:modelpack:errArgumentType','InputSignals','timeseries');
end

%Find inputs and outputs defining system
Outputs = SimOpt.Outputs;
Inputs  = SimOpt.Configuration.ActiveInputs;
%Get the linear system!
sys     = this.linearize([],[Inputs;Outputs],[]);

%Perform appropriate simulation on system
[y,t] = utSimulate_LTI(this,sys,T,SimOpt.Configuration.InputType,InputSignals);

%Format output into timeseries objects
if ~isempty(y) && ~isempty(t)
   %Simulation succeeded
   nOut = numel(Outputs);
   out = cell(nOut,1);
   for ct = 1:nOut
      %Note indexing y by column works since all SISOTOOL outputs have
      %dimension 1
      out{ct} = timeseries(y(:,ct),t,'name',Outputs(ct).getFullName);
   end
else
   %Simulation failed
   ctrlMsguUtils.error('SLControllib:modelpack:stErrorSimulatePortDetails')
end

if nargout > 1
   %Requested simulation info output argument
   info = [];
end
