function [p,q] = covar(D,w,rw)
% Computes output and state covariances given noise
% intensity W = Rw' * Rw

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:48 $

% Delay handling: 
%  1) Internal delays not supported
%  2) State covariance: delays can be ignored if Wij=0 or 
%     InputDelay(i)=InputDelay(j) for all (i,j)
%  3) Output covariance: output delay can be ignored if uniform
%     and input delays affect only W matrix
StateCovar = (nargout>1);
id = D.Delay.Input;
od = D.Delay.Output;
Diffid = bsxfun(@minus,id,id'); % id(i)-id(j)
if any(D.Delay.Internal) || any(diff(od)) || any(w(:) & Diffid(:))
   if D.Ts==0
      ctrlMsgUtils.error('Control:analysis:covar2');
   elseif StateCovar
      ctrlMsgUtils.error('Control:analysis:covar4');
   else
      D = elimDelay(D);
   end
end

% Check properness
Nx = size(D.a,1);
[isProper,D] = isproper(D);
if ~isProper
   ctrlMsgUtils.error('Control:general:NotSupportedImproperSys','covar');
elseif StateCovar && size(D.a,1)~=Nx
   ctrlMsgUtils.error('Control:analysis:covar5');
end

% Get data (beware of zero internal delays)
[a,b,c,d,~,e] = getABCDE(D);

% Compute state and output covariances
try
   % Stable model
   if D.Ts==0
      rq = lyapchol(a,b*rw',e);
   else
      rq = dlyapchol(a,b*rw',e);
   end
   % State covariance
   q = rq' * rq;
   % Output covariance
   % RE: Delay test above ensures Wij=0 when id(i)~=id(j),
   %     so delays have no effect
   rp = [rq*c'; rw*d'];
   p = rp' * rp;
catch %#ok<CTCH>
   % Unstable
   p = inf(size(c,1));
   q = inf(size(a,1));
end
