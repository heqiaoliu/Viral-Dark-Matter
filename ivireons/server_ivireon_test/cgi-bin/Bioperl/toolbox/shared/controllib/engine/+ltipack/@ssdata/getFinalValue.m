function yf = getFinalValue(D,RespType,x0)
% Computes steady-state value for a given response type, assuming the 
% model is stable

%   Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:06 $
switch RespType
   case 'step'
      % YF is the DC gain
      yf = dcgain(D);
      
   case {'impulse','initial'}
      % Note: D is proper but not necessarily reduced (E may be singular, see g263960)
      [a,b,c,d] = getABCD(D);
      if strcmp(RespType,'initial')
         % For initial, set H(s) = (c/(sI-A)*x0)
         b = x0(:);
      end
      % YF is DC gain of s * H(s) or (z-1) * H(z)
      if isempty(a)
         yf = zeros(size(d,1),size(b,2));
      else
         if D.Ts~=0
            a = a-eye(size(a));
         end
         % Scale A prior to SVD
         [s,junk,a] = mscale(a,'noperm');
         b = lrscale(b,1./s,[]);
         c = lrscale(c,[],s);
         % Compute projector
         [u,sv,v] = svd(a);
         sv = diag(sv);
         rk = length(find(sv>1e2*eps*sv(1)));
         u1 = u(:,1:rk);
         v1 = v(:,1:rk);
         % Watch for divide by zero, etc (g354285)
         hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
         yf = c*b-(c*u1)*((v1'*u1)\(v1'*b));
         yf(~isfinite(yf)) = Inf;
      end
end
