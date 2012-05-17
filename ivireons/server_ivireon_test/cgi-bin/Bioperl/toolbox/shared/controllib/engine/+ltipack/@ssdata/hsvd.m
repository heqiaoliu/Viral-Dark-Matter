function [g,baldata] = hsvd(D,Options)
%HSVD  Computes the Hankel singular values.
%
%   Note: Second input OPTIONS must be of class ltioptions.hsvd.

%	Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:13 $
if hasInternalDelay(D)
   throw(ltipack.utNoDelaySupport('hsvd',D.Ts,'internal'))
end

% Check properness and derive explicit realization
% Note: Eliminate structurally nonminimal states (needed for MINREAL_INF,
% see also attas)
nx0 = size(D.a,1);
[isProper,D] = isproper(sminreal(D),'explicit');
if ~isProper
    ctrlMsgUtils.error('Control:general:NotSupportedImproperSys','hsvd')
end
nsnm = nx0-size(D.a,1);  % number of cancelled states
   
% Stable/unstable partition (see BALREAL for details)
[Ds,Dns,baldata] = stabsep(D,Options);

% Compute Cholesky factors of reachability and observability Gramians
% RE: 1) Uses Hammarling's algorithm that solves directly for the
%        Cholesky factor of the Lyapunov equation solution (see LYAPCHOL)
%     2) Skip scaling (rigorous scaling already performed in STABSEP)
if D.Ts==0
   Rr = lyapchol(Ds.a,Ds.b,[],'noscale');
   Ro = lyapchol(Ds.a',Ds.c',[],'noscale');
else
   Rr = dlyapchol(Ds.a,Ds.b,[],'noscale');
   Ro = dlyapchol(Ds.a',Ds.c',[],'noscale');
end   

% Compute SVD of the "product of the Cholesky factors"
% NOTE: Numerically, the product SVD algorithm of Heath et al. (reference [12]
% of [1]) is superior to forming the product ro*rr' directly and then
% computing the SVD.  In other words, the following code should be used:
%      [u,g,v] = prodsvd(ro,rr')
[u,s,v] = svd(Ro*Rr');
gs = diag(s);

% Add unstable HSV
nns = order(Dns);
g = [inf(nns,1) ; gs ; zeros(nsnm,1)];

if nargout>1
   % Save Gramian and SVD info
   baldata.Rr = Rr;
   baldata.Ro = Ro;
   baldata.u = u;
   baldata.v = v;
   baldata.g = g;
   baldata.d = D.d;  % may differ from original D because of ISPROPER call
   % Estimate threshold ZEROTOL below which the computed HSV should be
   % considered zero
   baldata.ZeroTol = eps * (norm(D.d,1) + norm(abs(Ro)*abs(Rr)',1));
end
