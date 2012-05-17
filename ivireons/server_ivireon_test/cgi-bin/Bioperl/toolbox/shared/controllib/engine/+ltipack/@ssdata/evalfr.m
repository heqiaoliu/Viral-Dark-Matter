function fresp = evalfr(D,s)
%EVALFR  Evaluates frequency response at a single (complex) frequency.
%                                   -1
%       FRESP =  D + C * (X * E - A)  * B   .

%   Author(s):  P. Gahinet  5-13-96
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/02/08 22:47:38 $

% Compute H(s)
if isnan(s)
   % |s| = NaN
   fresp = nan(iosize(D));
elseif isinf(s)
   % |s| = Inf. First eliminate pole/zero cancellations at Inf
   [isProper,D] = isproper(D);
   if isProper
      fresp = D.d;
   else
      fresp = inf(size(D.d));
   end
   % Add delay contribution
   fresp = getDelayResp(D,fresp,s);
else
   % Jointly close the integrator and delay loops (the A-sI or D22-exp(-tau*s)
   % blocks could be singular, see g337144)
   Ts = D.Ts;
   d = D.d;
   e = D.e;
   if isempty(e)
      e = eye(size(D.a));
   end
   
   % Sizes
   [rs,cs] = size(d);
   tau = D.Delay.Internal;
   nfd = length(tau);
   ny = rs-nfd;
   nu = cs-nfd;
   
   if nfd>0
      % Note: K may be invertible when its (1,1) or (2,2) blocks are not
      if Ts==0
         etau = exp(tau*s);
      else
         etau = s.^tau;
      end
      K = [D.a-s*e , D.b(:,nu+1:nu+nfd) ; ...
            D.c(ny+1:ny+nfd,:) , d(ny+1:ny+nfd,nu+1:nu+nfd)-diag(etau)];
      b = [D.b(:,1:nu) ; d(ny+1:ny+nfd,1:nu)];
      c = [D.c(1:ny,:) , d(1:ny,nu+1:nu+nfd)];
      d = d(1:ny,1:nu);
   else
      K = D.a-s*e;      
      b = D.b;
      c = D.c;
   end
   
   % Evaluate response
   sw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
   if rs>=cs
      fresp = d - c * (K\b);
   else
      fresp = d - (c/K) * b;
   end
   clear sw
   
   if hasInfNaN(fresp)
      fresp = inf(ny,nu);
   else
      % Add delay contribution
      id = D.Delay.Input;
      od = D.Delay.Output;
      if norm(id,1)>0 || norm(od,1)>0
         if Ts==0
            fresp = lrscale(fresp,exp(-s*od),exp(-s*id));
         else
            fresp = lrscale(fresp,s.^(-od),s.^(-id));
         end
      end
   end
end

