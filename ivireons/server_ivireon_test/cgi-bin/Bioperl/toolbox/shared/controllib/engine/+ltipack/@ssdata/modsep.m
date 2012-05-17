function [H,H0,T,Ti] = modsep(G,N,RegionFcn,varargin)
% Region-based modal decomposition.

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/02/08 22:47:43 $
[ny,nu] = iosize(G);
if hasInternalDelay(G)
   throw(ltipack.utNoDelaySupport('modsep',G.Ts,'internal'))
end

% Extract data
try
   % REVISIT: descriptor case will require generalized Sylvester solver (LAPACK)
   %          properness check currently done by getABCD
   [a,b,c,d] = getABCD(G);
catch %#ok<CTCH>
   ctrlMsgUtils.error('Control:general:NotSupportedImproperSys','modsep')
end
Ts = G.Ts;

% Scale A,B,C to minimize loss of accuracy in Schur decomposition
% and reordering
nx = size(a,1);
if G.Scaled && isempty(G.e)
   % No scaling necessary
   s = ones(nx,1);   p = (1:nx)';
else
   [a,b,c,~,s,p] = xscale(a,b,c,d,[],Ts);
end

% Schur decomposition
[u,a] = schur(a);
e = ordeig(a);

% Assign region index to each eigenvalue
try
   clusters = zeros(nx,1);
   for ct=1:nx
      clusters(ct) = round(feval(RegionFcn,e(ct),varargin{:}));
   end
catch  %#ok<CTCH>
   ctrlMsgUtils.error('Control:transformation:modsep1')
end
if any(clusters<1 | clusters>N)
   ctrlMsgUtils.error('Control:transformation:modsep2')
end

% Go complex if A real but different regions are assigned to conjugate pairs
if isreal(a)
   idxp = find(imag(e)>0);
   [~,ia,ib] = intersect(e,conj(e(idxp)));
   if any(clusters(ia)~=clusters(idxp(ib)))
      [u,a] = rsf2csf(u,a);
   end
end

% Sort eigenvalues by increasing region index
try
   [u,a] = ordschur(u,a,-clusters);
   b = u'*b;
   c = c*u;
catch %#ok<CTCH>
   ctrlMsgUtils.error('Control:transformation:modsep4')
end
clusters = sort(clusters);
if isempty(clusters)
   blksize = [];
else
   blksize = diff([0;find(diff(clusters));length(clusters)]);
end

% Block diagonalize
try
   [t,a] = bdschur(a,[],blksize);
catch ME
   % Should not happen
   throw(ME)
end
b = t\b;
c = c*t;

% Initialize outputs
H0 = ltipack.ssdata([],zeros(0,nu),zeros(ny,0),d,[],G.Ts);
H0.Delay = G.Delay;
% N-by-1 array H
h = ltipack.ssdata([],zeros(0,nu),zeros(ny,0),zeros(ny,nu),[],G.Ts);
h.Delay = G.Delay;
H = repmat(h,[N 1]);

% Store factors
is = 0;
for j=1:length(blksize)
   % Store j-th component
   bs = blksize(j);
   jsys = clusters(is+1);
   H(jsys).a = a(is+1:is+bs,is+1:is+bs);
   H(jsys).b = b(is+1:is+bs,:);
   H(jsys).c = c(:,is+1:is+bs);
   is = is+bs;
end

% Construct block diagonalization state transformation T and its inverse Ti
% RE: The system with decoupled dynamics is ss2ss(G,T)
if nargout>2
   Ti(:,p) = diag(s);
   Ti = Ti * u * t;
   T(p,:) = diag(1./s);
   T = t \ (u' * T);
end
