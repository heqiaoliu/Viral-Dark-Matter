function [isStable,isMStable] = isstable(this,idx)
%ISSTABLE   Returns 1 for a stable model.
%
%  STABLESTATUS = ISSTABLE(SRC,N) returns 1 if the N-th model is stable, 
%  0 if it is unstable, and NaN for undetermined.

%  Author(s): Bora Eryilmaz
%   Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:21:25 $
s = this.Cache(idx);
if isempty(s.Stable)
   % Assess stability
   D = getModelData(this,idx);
   if hasDelayDynamics(D,'pole')
      s.Stable = NaN;
      s.MStable = NaN;
   else
      % Compute poles
      p = pole(D,'fast');
      if D.Ts==0
         s.Stable = all(real(p)<0);
         s.MStable = all(real(p)<0 | p==0);
      else
         s.Stable = all(abs(p)<1);
         s.MStable = all(abs(p)<1 | p==1);
      end
   end
   % Update DC gain
   s.DCGain = dcgain(D);
   this.Cache(idx) = s;
end
isStable = double(s.Stable);
isMStable = double(s.MStable);

