function c = eval(this,Sys)
% Evaluates gain phase margin requirement for given system. Note this
% requirement can be either an objective or constraint.
%
% Inputs:
%          this - a srorequirement.gainphasemargin object.
%          sys  - An LTI object.
% Outputs: 
%          c - a vector of doubles giving the loop-at-a-time gain or phase

% Author: A. Stothert
% $Revision: 1.1.8.2 $ $Date: 2010/03/31 18:37:59 $
% Copyright 1986-2010 The MathWorks, Inc.

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
marg = srorequirement.ut_ComputeGPmargins(Model,this.FeedbackSign);

%Group outputs
[~,nu] = size(Model);
c  = nan(1,nu);
switch this.Data.Type
   case 'gain'
      for ct = 1:nu
         cTmp = marg(ct).dgm;
         cTmp = unitconv(cTmp,'abs',this.getData('yUnits'));
         if isnan(marg(ct).Stable) || marg(ct).Stable, cTmp = abs(cTmp); end
         c(ct) = min(cTmp);
      end
   case 'phase'
      for ct = 1:nu
         cTmp = marg(ct).dpm;
         cTmp = unitconv(cTmp,'deg',this.getData('xUnits'));
         c(ct) = min(cTmp);
      end
   case 'both'
      c = nan(2,nu);
      for ct = 1:nu
         tmpGM = marg(ct).dgm;
         tmpGM = unitconv(tmpGM,'abs',this.getData('yUnits'));
         if isnan(marg(ct).Stable) || marg(ct).Stable, tmpGM = abs(tmpGM); end
         c(1,ct) = min(tmpGM);
         tmpPM = marg(ct).dpm;
         tmpPM = unitconv(tmpPM,'deg',this.getData('xUnits'));
         c(2,ct) = min(tmpPM);
      end
end
if any(~isfinite(c))
   c(~isfinite(c)) = 1e5;
end
