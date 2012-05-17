function c = eval(this,Sys)
% Evaluates gain phase margin requirement for given system. Note this
% requirement is a constraint.
%
% Inputs:
%          this - a srorequirement.gainphasemarginlocation object.
%          sys  - An LTI object.
% Outputs: 
%          c - a vector of doubles giving the signed distance of each.
%              gainphase point to each edge of gainphase constraint. A 
%              negative value indicates a feasible point.

% Author: A. Stothert
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:55 $
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

%Compute margins
marg =  srorequirement.ut_ComputeGPmargins(Model,this.FeedbackSign);

%Group outputs
[ny,nu] = size(Model);
GM = nan(nu,1);
PM = nan(nu,1);
for ct = 1:nu
   %Convert Gain margins to correct units
   GMTmp = marg(ct).dgm;
   GMTmp = unitconv(GMTmp,'abs',this.getData('yUnits'));
   GM(ct) = min(GMTmp);

   %Convert phase margins to correct units
   PMTmp = marg(ct).dpm;
   PMTmp = unitconv(PMTmp,'deg',this.getData('xUnits'));
   PM(ct) = min(PMTmp);
end

%Compute distance of each gainphase point to each edge of the constraint
c = this.minDistance([PM, GM]);

%Fix any infinite bounds
if any(~isfinite(GM))
   c(~isfinite(GM)) = 1e5;
end
if any(~isfinite(PM))
   c(~isfinite(PM)) = 1e5;
end

