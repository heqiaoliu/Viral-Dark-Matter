function c = eval(this,Sys)
% EVAL method to evaluate pole-zero location requirement for a given system
%
% Inputs:
%          this - a srorequirement.pzlocation object.
%          Sys  - An n-by-1  vector of Sys structures
% Outputs: 
%          c - an n-by-1 matrix of doubles giving the maximum signed distance 
%          of each pole/zero to each edge of the requirement. A negative value 
%          indicates a feasible point.
 
% Author(s): A. Stothert 11-Apr-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:02 $

c = [];
if isempty(Sys)
   return
end

if isfield(Sys,'Model')
   Model = Sys.Model; 
else
   Model = Sys;
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

%Group pole/zeros into test points
if any(strcmp({'pole','both'},this.polezero))
   %Compute the system poles
   pSys = eig(Model);
   %Make sure the system poles are in an order consistent with the last time
   %they were computed
   %pSys = srorequirement.ut_matchLSQ(this,pSys);
   TestPoint = pSys;
else 
   TestPoint = [];
end
if any(strcmp({'zero','both'},this.polezero))
   %Compute the system zeros
   zSys = zero(Model);
   %Make sure the system poles are in an order consistent with the last time
   %they were computed
   %zSys = srorequirement.ut_matchLSQ(this,zSys);
   TestPoint = [TestPoint; zSys];
end

if isempty(TestPoint)
   %No poles or zeros to test, assume satisfy all constraints
   c = -inf(this.ConstraintSize);
else
   %Compute signed distance of each testpoint to each edge
   c = this.minDistance([real(TestPoint),imag(TestPoint)]);
   %Only keep track of closest infeasible or feasible point
   c = sign(c(1,:)).*min(abs(c),[],1);
end

