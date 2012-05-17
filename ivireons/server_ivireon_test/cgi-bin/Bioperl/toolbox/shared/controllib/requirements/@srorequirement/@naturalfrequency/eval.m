function c = eval(this,Sys)
% EVAL  Method to evaluate natural frequency of a linear system
%
% Inputs:
%          this - a srorequirement.naturalfrequency object.
%          Sys  - An LTI object.
% Outputs: 
%          c - a nx1 double giving the natural frequencies of the system, 
%          interpreted as the radius of each pole pair from the origin on
%          a continuous pole-zero plot.

% Author(s): A. Stothert 31-May-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:07 $

c = [];
if isempty(Sys) 
   return 
end

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
   catch
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
   %Continuous time
   c = abs(pSys);
else
   %Discrete time
   r = abs(pSys); t = angle(pSys);
   c = sqrt(log(r).^2+t.^2)/Model.Ts;
end
