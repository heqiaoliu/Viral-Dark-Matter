function c = eval(this,Sys)
% EVAL method to evaluate settling time requirement for a given system. 
%
% Inputs:
%          this - a srorequirement.settlingtime object.
%          Sys  - An LTI object
% Outputs: 
%          c - an n-by-1 matrix of doubles giving the maximum signed distance 
%          to the pole location for the settling time. A negative value 
%          indicates a feasible point.

% Author: A. Stothert
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:49 $
% Copyright 1986-2009 The MathWorks, Inc.

if isempty(Sys)
   c = [];
   return
end

%Extract linear system model
if isa(Sys,'lti')
   Model = Sys;
else
   Model = Sys.Model;
end

%Check we have a model that we can compute poles for.
if isa(Model,'frd')
   ctrlMsgUtils.error('Controllib:graphicalrequirements:errFRD',this.UserDescription{1})
end

%Check if need to compute closed loop pole location
if this.FeedbackSign ~= 0
   try
      Model = feedback(Model,1,1,1,this.FeedbackSign);
   catch E %#ok<NASGU>
      %Feedback failed, loop maybe algebraic and/or singular
      c = [];
      return
   end
end

%Check if we have a preprocess function to run
if ~isempty(this.PreProcessFcn)
   %Run preprocess function. For example since we need to compute poles/zeros
   %use pade approximations for IO delays
   Model = this.PreProcessFcn(Model);
end

%Compute the system poles
pSys = eig(Model);
%Make sure the system poles are in an order consistent with the last time
%they were computed
pSys = srorequirement.ut_matchLSQ(this,pSys);
if Model.Ts == 0
   %Continuous system
   c = real(pSys);
else
   %Discrete system
   c = log(abs(pSys))/Model.Ts;
end
end