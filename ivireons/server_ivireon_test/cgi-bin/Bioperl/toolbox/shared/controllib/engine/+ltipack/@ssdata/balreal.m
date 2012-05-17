function [Db,g,T,Ti] = balreal(D,Options)
% Computes balanced realization of state-space model.

%	Author(s): J.N. Little, Alan J. Laub, P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:41 $
if hasInternalDelay(D)
   throw(ltipack.utNoDelaySupport('balreal',D.Ts,'internal'))
end

% Check properness and make explicit
nx0 = size(D.a,1);
[isProper,D] = isproper(D,'explicit');
if ~isProper
   ctrlMsgUtils.error('Control:general:NotSupportedImproperSys','balreal')
elseif nargout>2 && order(D)<nx0
   ctrlMsgUtils.error('Control:transformation:balreal1')
end

% Stable/unstable partition
% RE: 1) The Hankel SVs are invariant under state transformation
%     2) Use stability threshold to avoid grabbing poles near instability 
%        boundary (such poles typically induce large HSV and make the 
%        Lyapunov equations badly conditioned)
[Ds,Dns,~,T,Ti] = stabsep(D,Options);

% Compute Cholesky factors of reachability and observability Gramians
% RE: 1) Uses Hammarling's algorithm that solves directly for the
%        Cholesky factor of the Lyapunov equation solution (see LYAPCHOL)
%     2) Skip scaling (rigorous scaling palready performed in STABSEP)
if D.Ts==0
   Rr = lyapchol(Ds.a,Ds.b,[],'noscale');
   Ro = lyapchol(Ds.a',Ds.c',[],'noscale');
else
   Rr = dlyapchol(Ds.a,Ds.b,[],'noscale');
   Ro = dlyapchol(Ds.a',Ds.c',[],'noscale');
end   
   
% Compute SVD of the ``product of the Cholesky factors''
% NOTE: Numerically, the product SVD algorithm of Heath et al. (reference [12]
% of [1]) is superior to forming the product ro*rr' directly and then
% computing the SVD.  In other words, the following code should be used:
%      [u,g,v] = prodsvd(ro,rr')
[u,s,v] = svd(Ro*Rr');
g = diag(s);
ns = length(g);

% Form transformation Ts for the stable part
ZeroTol = 10*eps;
ZeroHSV = (g<=ZeroTol*max(g));  % zero or nearly zero HSV
if all(ZeroHSV)
   % g = 0
   Ts = eye(ns);
   Tsi = Ts;
elseif ~any(ZeroHSV)
   % all nonzero
   sgi = 1./sqrt(g);
   Ts = repmat(sgi,[1 ns]) .* (u'*Ro);     % efficient diag(sgi)*u'*Ro
   Tsi = (Rr'*v) .* repmat(sgi.',[ns 1]);  % efficient Rr'*v*diag(sgi)
else
   % Some HSV are nearly zero (non minimal realization)
   nz = sum(ZeroHSV);
   nnz = ns-nz;
   % Build balancing transform Ts=[Ts1;Ts2] and Tsi=[Tsi1,Tsi2]
   sgi = 1./sqrt(g(1:nnz));
   Ts1 = lrscale(u(:,1:nnz)'*Ro,sgi,[]);
   Tsi1 = lrscale(Rr'*v(:,1:nnz),[],sgi);
   % Compute Ts2 and Tsi2 s.t. Ts2*Tsi1=0, Ts1*Tsi2=0
   [q,junk] = qr(Tsi1);   Ts2 = q(:,nnz+1:ns)'; %#ok<NASGU>
   [q,junk] = qr(Ts1');   Tsi2 = q(:,nnz+1:ns); %#ok<NASGU>
   % Enforce Ts2*Tsi2 = I
   [u,s,v] = svd(Ts2*Tsi2);
   sgi = 1./sqrt(diag(s(1:nz,1:nz)));
   Ts2 = lrscale(u(:,1:nz)'*Ts2,sgi,[]);
   Tsi2 = lrscale(Tsi2*v(:,1:nz),[],sgi);
   % Build Ts and Tsi
   % RE: Ts * (Rr'*Rr) * Ts' = blkdiag(g(1:nnz),S) where S
   %     is full and associated with nonminimal modes. The 
   %     fact that S is full is not a problem for MODRED 
   %     since approximation errors in the non-minimal
   %     subspace are immaterial
   Ts =  [Ts1;Ts2];
   Tsi = [Tsi1,Tsi2];
end

% Form balanced realization
% REVISIT: should support descriptor case
[aNs,bNs,cNs] = getABCD(Dns);
[as,bs,cs] = getABCD(Ds);
Db = ltipack.ssdata(...
   blkdiag(aNs,Ts*as*Tsi),...
   [bNs ; Ts*bs],...
   [cNs , cs*Tsi],...
   D.d,[],D.Ts);
Db.Delay = D.Delay;

% Combine state transformations
nns = size(aNs,1);
g = [Inf(nns,1) ; g];
T = blkdiag(eye(nns),Ts) * T;
Ti = Ti * blkdiag(eye(nns),Tsi);
