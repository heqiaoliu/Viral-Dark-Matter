function sys = numden2idss(num,den,Ts)
%NUMDEN2IDSS convert transfer function num/den to IDSS object.
% 
%  sys = numden2idss(num,den,Ts)

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 21:00:48 $

[ny,nu] = size(num);
iod = 0;
D.num = num;
D.den = den;

D = utZeroPad(D,false); % process 'z^-1' form

if ny==1 && nu==1
   % SISO case
   [a,b,c,d,e] = compreal(num{1},den{1});
else
   % MIMO case
   % Compute orders for row- and column-oriented realizations
   [ro,co,D] = utGetOrder(D);
   if any(iod(:))
      % Map residual I/O delays into internal delays, channel by channel
      Dsub = ltipack.ssdata;
      if co<=ro
         % Realize each column and concatenate realizations
         for j=1:nu,
            [Dsub.a,Dsub.b,Dsub.c,Dsub.d,Dsub.e] = ...
               LocalRealizeSingleChannel(D.num(:,j),D.den(:,j));
            DelaySub = Delay;
            DelaySub.Input = Delay.Input(j);
            DelaySub.Output = Delay.Output + iod(:,j);
            Dsub.Delay = DelaySub;
            Dsub = utFoldDelay(Dsub,[],iod(:,j));
            if j==1
               Dss = Dsub; 
            else
               Dss = iocat(Dss,Dsub,2);
            end
         end
      else
         % Realize each row and concatenate realizations
         for i=1:ny,
            [Dsub.a,Dsub.b,Dsub.c,Dsub.d,Dsub.e] = ...
               LocalRealizeSingleChannel(D.num(i,:),D.den(i,:));
            DelaySub = Delay;
            DelaySub.Input = Delay.Input + iod(i,:).';
            DelaySub.Output = Delay.Output(i);
            Dsub.Delay = DelaySub;
            Dsub = utFoldDelay(Dsub,iod(i,:).',[]);
            if i==1
               Dss = Dsub;
            else
               Dss = iocat(Dss,Dsub,1);
            end
         end
      end
      
   else
      % No I/O delays
      if co<=ro
         % Realize each column and concatenate realizations
         % RE: Structure-aware balancing performing by COMPREAL
         a = [];  b = [];  c = zeros(ny,0);  d = zeros(ny,0);  e = [];
         for j=1:nu,
            [aj,bj,cj,dj,ej] = LocalRealizeSingleChannel(D.num(:,j),D.den(:,j));
            [a,b,c,d,e] = ssops('hcat',a,b,c,d,e,aj,bj,cj,dj,ej);
         end
      else
         % Realize each row and concatenate realizations
         a = [];  b = zeros(0,nu);  c = [];  d = zeros(0,nu);  e = [];
         for i=1:ny,
            [ai,bi,ci,di,ei] = LocalRealizeSingleChannel(D.num(i,:),D.den(i,:));
            [a,b,c,d,e] = ssops('vcat',a,b,c,d,e,ai,bi,ci,di,ei);
         end
      end

   end
   
end

sys = idss(a,b,c,d); 
sys.Ts = Ts;


%------------------------- Local Functions ---------------------------

function [a,b,c,d,e] = LocalRealizeSingleChannel(num,den)
% State-space realization of SIMO or MISO TF model.
[ny,nu] = size(num);

% Determine which entries are dynamic
dyn = (cellfun('length',num)>1);
d = zeros(ny,nu);
for ct=1:max(ny,nu),
   dyn(ct) = dyn(ct) && any(num{ct});
   if ~dyn(ct)
      d(ct) = num{ct}(1)/den{ct}(1);
   end
end
idyn = find(dyn);
ndyn = length(idyn);

% Compute realization for subset of non-static entries
if ndyn==0
   % Static gain
   a = [];
   b = zeros(0,nu);
   c = zeros(ny,0);
   e = [];
   return

elseif ndyn<2 || isEqualDen(den{idyn}),
   % Common denominator for entries with dynamics
   [a,bdyn,cdyn,ddyn,e] = LocalComDen(num(idyn),den{idyn(1)});
   
else
   % Entry-by-entry realization
   a = [];   bdyn = [];   cdyn = [];   ddyn = [];   e = [];
   if nu==1,
      catop = 'vcat';
   else
      catop = 'hcat';
   end
   
   for k=1:ndyn,
      [ak,bk,ck,dk,ek] = compreal(num{idyn(k)},den{idyn(k)});
      [a,bdyn,cdyn,ddyn,e] = ...
         ssops(catop,a,bdyn,cdyn,ddyn,e,ak,bk,ck,dk,ek);
   end
end

% Expand realization to include entries w/o dynamics
na = size(a,1);
if nu==1,
   c = zeros(ny,na);
   c(idyn,:) = cdyn;
   b = bdyn;
else
   b = zeros(na,nu);
   b(:,idyn) = bdyn;
   c = cdyn;
end
d(idyn) = ddyn;



function [a,b,c,d,e] = LocalComDen(num,den)
% Realization of SIMO or MISO TF model with common denominator. 
%
%   [A,B,C,D] = COMDEN(NUM,DEN)  returns a state-space
%   realization for the SIMO or MISO model with data NUM,DEN.

% Get number of outputs/inputs 
[p,m] = size(num);

% Turn NUM into an array and equalize the number of columns
% RE: lengths of numerators may vary for improper models
lnum = cellfun('length',num);
lmax = max(lnum);
if any(lnum<lmax)
   % Equalize lengths using zero padding
   for ct=1:max(p,m)
      num{ct} = [zeros(1,lmax-lnum(ct)) , num{ct}];
   end
   den = [zeros(1,lmax-length(den)) , den];
end
num = cat(1,num{:});

% Handle various cases
if ~any(num(:)),
   % All zero
   a = [];   
   b = zeros(0,m);  
   c = zeros(p,0);  
   d = zeros(p,m);
   e = [];
   
else
   % Realize with COMPREAL
   [a,b,c,d,e] = compreal(num,den);
   
   % Transpose/permute A,B,C,D in MISO case to make A upper Hessenberg
   if p<m,
      b0 = b;
      a = a.';  b = c.';  c = b0.';  d = d.';  e = e.';
      perm = size(a,1):-1:1;
      a = a(perm,perm);
      b = b(perm,:);
      c = c(:,perm);
      if ~isempty(e)
         e = e(perm,perm);
      end
   end
end

%=========================================================================
function [a,b,c,d,e] = compreal(num,den)
%COMPREAL  Companion realization of SIMO transfer functions
%
%   [A,B,C,D,E] = COMPREAL(NUM,DEN) computes a state-space realization
%   (A,B,C,D,E) of the SIMO transfer function NUM/DEN with common 
%   denominator DEN (a row vector).  If L is the maximum length of
%   the numerator and denominator polynomials, NUM should be a
%   PxL matrix if there are P outputs, and DEN should be a vector of
%   length L.  The E matrix is empty (identity) if there are at least 
%   as many poles than zeros and is singular otherwise.
%
%   See also TF/SS.

%   Author: P. Gahinet, 5-1-96
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2006/12/27 21:00:48 $
e = [];
[p,r] = size(num);
if r==1 || norm(num,1)==0
   % Pure gain or zero numerator
   a = [];
   b = zeros(0,1);
   c = zeros(p,0);
   d = num(:,1)/den(:,1);
   
else
   % Locate and normalize leading denominator coefficient
   idx = find(den~=0,1);
   den1 = den(idx);
   den = den(idx+1:r)/den1;
   num = num/den1;
   % Build companion realization (in controller form)
   ld = length(den);
   if idx==1
      % Proper case
      a = [-den ; eye(ld-1,ld)];
      b = eye(ld,1);
      d = num(:,1);
      c = num(:,2:r) - d * den;
      kE = 0;
   else
      % Improper case
      ld1 = min(1,ld);
      a = blkdiag(eye(idx),diag(ones(ld1,ld-1),-1));
      a(idx+ld1,idx+1:idx+ld) = -den;
      b = zeros(idx+ld,1);
      if ld>0
         b(idx+1) = 1;
      else
         b(idx) = -1;
      end
      c = num;
      d = zeros(p,1);
      e = diag([zeros(idx,1);ones(ld,1)]);
      stride = idx+ld+1;
      e(stride:stride:(idx-1+ld1)*stride) = 1;
      kE = idx;
   end
   
   % Balancing
   [a,b,c,e] = LocalBalance(a,b,c,e,kE);
end

%----------------------- Local Functions --------------------

function [a,b,c,e] = LocalBalance(a,b,c,e,kE)
% Specialized balancing for companion form
% kE = number of zeros on the diagonal of E
nx = size(a,1);

% Balance portion of A matrix associated with denominator
if nx<kE+2
   rs = zeros(0,1);
else
   [junk,junk,x] = balance(a(kE+1:nx,kE+1:nx),'noperm');
   % Incremental scaling factors (decreasing)
   rs = diag(x,-1);
end

% Protect against scaling anomalies when last 
% denominator entries are small or zero
% [num,den] = pade(1,20);  x = num-den;  x(1) = 1;
% [a,b,c,d] = compreal(den,x);
igap = find(rs(2:end)<min(1,1e-3*rs(1:end-1)));
if ~isempty(igap)
   rsmin = min(1,rs(igap(1)));
   rs = max(rs,rsmin);
end
   
% In improper case, balance portion of C associated 
% with first kE+1 states
if kE>0
   if kE<nx
      kE = kE+1;
   end
   vc = max(abs(c(:,1:kE)),[],1);
   vc = vc/vc(1);
   [junk,junk,x] = balance([vc; eye(kE-1,kE)],'noperm');
   rs = [diag(x,-1) ; rs];
end
      
% Form the scaling vector and balance
s = cumprod([1;rs]);
a = lrscale(a,s,1./s);
b = lrscale(b,s,[]);
c = lrscale(c,[],1./s);
if ~isempty(e)
   e = lrscale(e,s,1./s);
end

% Equalize the norms of b and c
cnorm = norm(c,1);
bnorm = norm(b,1);
if cnorm>0
   sbc = pow2(round(log2(cnorm/bnorm)/2));  % sqrt(cnorm/bnorm)
   c = c / sbc;
   b = b * sbc;
end

%===== Adapted===========================================
function [ro,co,D] = utGetOrder(D)
% Computes order of TF models
%
%   [RO,CO] = UTGETORDER(D) computes the orders RO and CO of
%   row-wise and column-wise state-space realizations of D  
%
%   [RO,CO,D] = UTGETORDER(D) also returns the normalized
%   transfer function with all leading denominator coefficients
%   equal to 1

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2006/12/27 21:00:48 $

% Add static method to be included for compiler
%#function ltipack.isEqualDen

num = D.num;
den = D.den;
[ny,nu] = size(num);

% Normalize denominators and compute order of hij(s)
% RE: Normalization needed to identify common den in
% sys = [tf([1 2 5],-2*[1 2 2]) ; tf(-6*[1 0],4*[1 2 2])];
Normalized = true;
ioOrders = zeros(ny,nu);
for ct=1:ny*nu
   nct = num{ct};
   dct = den{ct};
   den1 = dct(find(dct~=0,1));
   if den1~=1
      num{ct} = nct/den1;
      den{ct} = dct/den1;
      Normalized = false;
   end
   % Order of hij(s)
   if all(nct==0)
      % zero entries contribute no dynamics
      ioOrders(ct) = 0;
   elseif dct(1)~=0
      % proper
      ioOrders(ct) = length(dct)-1;
   else
      ioOrders(ct) = length(nct);
   end
end
   
% Determine row-wise order
ro = 0;
for i=1:ny,
   jdyn = find(ioOrders(i,:));  % non-static entries
   if length(jdyn)>1 && isEqualDen(den{i,jdyn}),
      % Common denominator
      ro = ro + ioOrders(i,jdyn(1));
   else
      % Sum orders for hij(s), j = 1:nu
      ro = ro + sum(ioOrders(i,jdyn));
   end
end
   
% Determine column-wise order
co = 0;
for j=1:nu,
   idyn = find(ioOrders(:,j));   % non-static entries
   if length(idyn)>1 && isEqualDen(den{idyn,j})
      % Common denominator
      co = co + ioOrders(idyn(1),j);
   else
      co = co + sum(ioOrders(idyn,j));
   end
end

if nargout==3 && ~Normalized
   D.num = num;
   D.den = den;
end
%===========================================================
function [a,b,c,d,e]=ssops(op,a1,b1,c1,d1,e1,a2,b2,c2,d2,e2)
%SSOPS  Basic interconnection operations on state-space models.

%	Pascal Gahinet  5-9-97
%	Copyright 1986-2005 The MathWorks, Inc. 
%	$Revision: 1.1.8.1 $  $Date: 2006/12/27 21:00:48 $

% RE: No dimension checking + assumes empty matrices
%     correctly dimensioned
[ny1,nu1] = size(d1);  nx1 = size(a1,1);
[ny2,nu2] = size(d2);  nx2 = size(a2,1);

switch op, 
   case 'add'
      % Addition (parallel)
      a = [a1 zeros(nx1,nx2) ; zeros(nx2,nx1) a2];
      b = [b1 ; b2];
      c = [c1 , c2];
      d = d1 + d2;
      
   case 'mult'
      % Multiplication (series sys1*sys2)
      %     [ a1  b1*c2 ]       [ b1*d2 ]
      % A = [  0    a2  ]   B = [   b2  ]
      %
      % C = [ c1  d1*c2 ]   D =  d1*d2
      a = [a1 , b1*c2 ; zeros(nx2,nx1) , a2];
      b = [b1*d2 ; b2];
      c = [c1 , d1*c2];
      d = d1 * d2;
      
   case 'vcat'
      % Vertical concatenation
      %     [ a1  0 ]       [ b1 ]
      % A = [  0 a2 ]   B = [ b2 ]
      %
      %     [ c1  0 ]       [ d1 ]
      % C = [  0 c2 ]   D = [ d2 ]
      a = [a1 zeros(nx1,nx2) ; zeros(nx2,nx1) a2];
      b = [b1 ; b2];
      c = [c1 zeros(ny1,nx2) ; zeros(ny2,nx1) c2];
      d = [d1 ; d2];
      
   case 'hcat'
      % Horizontal concatenation
      %     [ a1  0 ]       [ b1  0 ]
      % A = [  0 a2 ]   B = [  0 b2 ]
      %
      % C = [ c1 c2 ]   D = [ d1 d2]
      a = [a1 zeros(nx1,nx2) ; zeros(nx2,nx1) a2];
      b = [b1 zeros(nx1,nu2) ; zeros(nx2,nu1) b2];
      c = [c1 , c2];
      d = [d1 , d2];
      
   case 'append'
      %     [ a1  0 ]       [ b1  0 ]
      % A = [  0 a2 ]   B = [  0 b2 ]
      %
      %     [ c1  0 ]       [ d1   0]
      % C = [  0 c2 ]   D = [  0  d2]
      a = [a1 zeros(nx1,nx2) ; zeros(nx2,nx1) a2];
      b = [b1 zeros(nx1,nu2) ; zeros(nx2,nu1) b2];
      c = [c1 zeros(ny1,nx2) ; zeros(ny2,nx1) c2];
      d = [d1 zeros(ny1,nu2) ; zeros(ny2,nu1) d2];
      
end

% E matrix
if nargout>4
   if isempty(e1)
      if isempty(e2)
         e = [];
      else
         e = [eye(nx1) zeros(nx1,nx2) ; zeros(nx2,nx1) e2];
      end
   else
      if isempty(e2)
         e = [e1 zeros(nx1,nx2) ; zeros(nx2,nx1) eye(nx2)];
      else
         e = [e1 zeros(nx1,nx2) ; zeros(nx2,nx1) e2];
      end
   end
end
%===========================================================
function D = utZeroPad(D,LeftPadding)
% Pads the numerators or denominators of Transfer Functions
% with zeros to make NUM{i,j} and DEN{i,j} of equal length.  
% The zeros are added to the left if  VAR = 's' or 'z'  and 
% to the right otherwise.
%
% Also removes the extra leading zeros in NUM{i,j} and 
% DEN{i,j} (while keeping them of equal length)

%      Author: P. Gahinet, 5-1-96
%      Copyright 1986-2005 The MathWorks, Inc.
%      $Revision: 1.1.8.1 $  $Date: 2006/12/27 21:00:48 $
num = D.num;
den = D.den;
if LeftPadding
   for k = 1:numel(num)
      nk = num{k};
      dk = den{k};
      % Pad zeros to the left to make num/den of equal length
      lgap = length(dk) - length(nk);
      if lgap~=0
         nk = [zeros(1,lgap) , nk];
         dk = [zeros(1,-lgap) , dk];
      end
      % Remove leading zeros appearing in both num and den
      if nk(1)==0 && dk(1)==0
         ld = length(dk);
         ind = find(nk~=0 | dk~=0);
         nk = nk(ind(1):ld);
         dk = dk(ind(1):ld);
      end
      num{k} = nk;
      den{k} = dk;
   end
else
   for k = 1:numel(num)
      nk = num{k};
      dk = den{k};
      % Pad zeros to the right to make num/den of equal length
      lgap = length(dk) - length(nk);
      if lgap~=0
         nk = [nk , zeros(1,lgap)];
         dk = [dk , zeros(1,-lgap)];
      end
      % Remove leading and trailing zeros appearing in both num and den
      % (delete leading zeros to ensure that num(1) or den(1) is always nonzero)
      ind = find(nk~=0 | dk~=0);
      num{k} = nk(ind(1):ind(end));
      den{k} = dk(ind(1):ind(end));
   end
end
D.num = num;
D.den = den;
%============================================================
function tf = isEqualDen(varargin)
% Checks if a set of denominator vectors are all equal up to 
% leading zeros.

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/12/27 21:00:48 $

% Remove leading zeros
for ct=1:nargin
   den = varargin{ct};
   if den(1)==0
      varargin{ct} = den(find(den~=0,1):end);
   end
end

% Compare denominators
tf = isequal(varargin{:});
%===============================================================
function X = lrscale(X,L,R)
%LRSCALE  Applies left and right scaling matrices.
%
%   Y = LRSCALE(X,L,R) forms Y = diag(L) * X * diag(R) in 
%   2mn flops if X is m-by-n.  L=[] or R=[] is interpreted
%   as the identity matrix.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2006/12/27 21:00:48 $
[m,n] = size(X);
if ~isempty(L)
   L = reshape(L,m,1);
   X = L(:,ones(1,n)) .* X;
end
if ~isempty(R)
   R = reshape(R,1,n);
   X = X .* R(ones(1,m),:);
end
%==============================================================

% FILE END