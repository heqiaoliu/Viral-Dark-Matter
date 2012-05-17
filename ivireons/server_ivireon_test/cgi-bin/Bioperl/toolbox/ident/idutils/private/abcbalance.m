function [a,b,c,e,s,p,sfio] = abcbalance(a,b,c,e,condt,varargin)
%ABCBALANCE  Balancing of state-space models.
%
%   [A,B,C,E,S,P] = ABCBALANCE(A,B,C,E,CONDT) uses BALANCE to
%   compute a diagonal similarity transformation T such that 
%   [T\A*T,T\B;C*T,0] has approximately equal row and column 
%   norms.  CONDT specifies an upper bound on the condition 
%   number of T.  The output vectors S and P implicitly define
%   the transformation T as T(:,P) = diag(S) and its inverse
%   Ti as Ti(P,:) = diag(1./S).
%
%   [A,B,C,E,S,P,IOS] = ABCBALANCE(A,B,C,E,CONDT,Option1,Option2,...)
%   specifies additional options as strings:
%     'noperm'   Prevents state permutation during balancing
%     'perm'     Enables state permutation (default)
%     'scale'    Rescales B and C to make the balancing insensitive 
%                to I/O scale
%     'noscale'  No I/O rescaling (default)
%
%   With the 'scale' option, balancing is performed on the scaled
%   triplet (A,IOS*B,IOS*C).  This I/O rescaling is implicit and 
%   does not change the transfer function returned by ABCBALANCE.
%
%   LOW-LEVEL UTILITY, CALLED BY SSBAL.

% copied from control/control/@ss/private/abcbalance.m on Nov 08, 2006.

%   Authors: P. Gahinet and C. Moler
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/12/27 20:57:52 $

% RE: Expects A,B,C,E to be matrices 2D arrays
XPerm = ~any(strcmp('noperm',varargin)); % state permutation enabled?
ScaleIO = any(strcmp('scale',varargin)); % perform I/O scaling?

% Get dimensions
nx = size(a,1);
ne = size(e,1);

% Quick exit when no state
if nx==0,
   s = ones(0,1); 
   p = zeros(0,1);
   sfio = 1;
   return
end

% Form 2D matrix M = [|A|+|E| |B|;|C| 0] to be balanced
mae = abs(a);
if ne>0,
   mae = mae + abs(e);
end
mb = max([abs(b) , zeros(nx,1)],[],2);
mc = max([abs(c) ; zeros(1,nx)],[],1);

% Compute scalings SFX (states), SFBC (B vs. C), and SFIO (scaling H(s) -> sfio * H(s))
if ScaleIO && any(mb) && any(mc) && norm(mae,1)>0
    % Balancing with optimal I/O scaling
    [sfx,sfbc,sfio,p] = LocalScaleBalance(mae,mb,mc,varargin);
else
    % No I/O scaling
    [sfx,sfbc,sfio,p] = LocalBalance(mae,mb,mc,XPerm,condt);
end

% If cond(T) exceeds CONDT, rescale diag(T) to match the bound on CONDT 
if isfinite(condt) && max(sfx)>10*condt*min(sfx),
   sfx = log2(sfx);
   scalf = log2(condt)/(max(sfx)-min(sfx));
   sfx = pow2(round(scalf*sfx));
end

% Compute balanced/scaled realization
s = sfx / sfbc;
is = 1./s;
a(p,p) = lrscale(a,is,s);
b(p,:) = lrscale(b,is,[]);
c(:,p) = lrscale(c,[],s);
if ne,
   e(p,p) = lrscale(e,is,s);
end


%--------------- Local Functions --------------------------------------

%%%%%%%%%%%%%%%%
% LocalBalance %
%%%%%%%%%%%%%%%%
function [sfx,sfbc,sfio,perm] = LocalBalance(a,b,c,XPerm,condt)
% Regular balancing
nx = size(a,1);

% To activate balancing when M=[A B;C 0] is triangular, set
% zero entries of B and C to
%   * C(j)=TINY*|C| if C~=0, |B| otherwise 
%   * B(j)=TINY*|B| if B~=0, |C| otherwise
% RE: This perturbation will be visible only when C.ej=0 and 
%     A.ej=s.ej, i.e., x(j) is unobservable or uncontrollable
bmax = max(b); 
cmax = max(c);
tiny = max(1e-100,(1/condt)^2);
b(b==0) = tiny * bmax + (bmax==0) * cmax;
c(c==0) = tiny * cmax + (cmax==0) * bmax;

% Perform the balancing with BALANCE
[sf,junk,junk] = balance([a b;c 0],'noperm');
sfx = sf(1:nx);     % balances the states
sfbc = sf(nx+1);    % equalizes |B| and |C|
sfio = 1;

% BALANCE may permute the rows/cols of A to enforce triangularity (desirable 
% for balancing prior to Hessenberg reduction). Acquire this permutation PERM
if XPerm
   [junk,perm,junk] = balance(a);
else
   perm = 1:nx;  % No permutation
end


%%%%%%%%%%%%%%%%%%%%%
% LocalScaleBalance %
%%%%%%%%%%%%%%%%%%%%%
function [sfx,sfbc,sfio,perm] = LocalScaleBalance(a,b,c,Options)
% Balancing with optimal I/O scaling. Seeks scaling t=SFIO such that 
% after balancing of (A,tB,tC,0), the norms of A, B, C are roughly 
% equalized and nearly equal to the norm of BALANCE(A). This particular 
% scaling enhances computations that ought to be invariant under I/O scaling 
% (e.g., computing transfer function zeros)

% RE: Do not remove A's diagonal (geck 130048)
%     a = [-3e4 1;0 -6e9]; b = [1e9;0];  c = [0,1e9]; d = 1;
%     zero(ss(a,b,c,d))
nx = size(a,1);

% Balance A and acquire PERM if requested
% RE: Use two-step approach when PERM is required to prevent scaling 
%     from operating only on a submatrix (can lead to poor overall 
%     scaling in some cases)
[a0,b0,c0,junk,sa,perm] = aebalance(a,b,c,[],'safebal',Options{:});
anorm0 = norm(a0,1);

% Lower bound on optimal scaling t* using balancing at t=0
tlb = 0.5*anorm0/sqrt(max(b0)*max(c0));

% Estimate t* where ||A(t)|| starts increasing
% Algorithm first increases t until an upper bound TUB is found, and
% then refines the estimate [TLB,TUB] of t*
% RE: Since TLB is scale invariant, this ensures appx scale invariance
%     of the balancing algorithm
tub = Inf;
sflb = [];
iter = 0;
while iter<6 && tub>100*tlb
   % Next test point
   if isinf(tub)
      t = tlb * 10^(2+iter);
   else
      t = sqrt(tlb*tub);
   end
   % Balance
   [sfx,junk,m] = balance([a t*b;t*c 0],'noperm');
   if norm(m(1:nx,1:nx),1)>=2*anorm0
      tub = t;
   else
      tlb = t;  sflb = sfx;
   end
   iter = iter+1;
end

% Use scaling for t=tlb (makes difference for margex2 in ltigallery)
sfio = tlb;
if isempty(sflb)
   [sflb,junk,junk] = balance([a tlb*b;tlb*c 0],'noperm');
end
sfbc = sflb(nx+1);  % equalizes |B| and |C|
sfx = sflb(1:nx);   % balances the states


