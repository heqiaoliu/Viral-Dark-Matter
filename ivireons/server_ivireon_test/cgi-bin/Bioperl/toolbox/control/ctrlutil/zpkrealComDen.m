function [a,b,c,d,e] = zpkrealComDen(Zero,Pole,Gain)
%ZPKREALCOMDEN  Realization of M-by-1 ZPK model with common denominator.
%
%   [A,B,C,D,E] = ZPKREAL(ZERO,POLE,GAIN)  returns a state-space
%   realization for the ZPK model with data ZERO, POLE, GAIN.  
%   ZERO should be an M-by-1 cell array with M>1 and GAIN 
%   should be an M-by-1 double array.

%   Author: P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2007/02/06 19:51:06 $
ny = length(Gain);

if all(Gain==0)
   % Zero gain -> no dynamics
   a = [];
   b = zeros(0,1);
   c = zeros(ny,0);
   d = zeros(ny,0);
   e = [];
else
   % Determine if system is real
   isReal = isreal(Gain) && isconjugate(Pole);
   if isReal
      for ct=1:ny
         isReal = isReal && isconjugate(Zero{ct});
      end
   end
   
   % Determine if system is proper
   np = length(Pole);
   reldeg = max(cellfun('length',Zero)) - np;
   if reldeg>0
      D = poly(Pole);  % denominator
   end
   
   % Contruct vector P of poles sorted by magnitude and regroup complex conjugate pairs 
   Pole = LocalSortPole(Pole,isReal);
   
   % 1) Realize proper part
   if isReal
      ld = max(0,imag(Pole(1:np-1)));
      a = diag(real(Pole)) + diag(ones(np-1,1),1) + diag(-ld.^2,-1);
   else
      a = diag(Pole) + diag(ones(np-1,1),1);
   end
   if np>0
      b = [zeros(np-1,1) ; 1];
   else
      b = zeros(0,1);
   end

   % Compute C,D for each output channel
   % RE: Decompose improper model as Q(s) + N(s)/d(s) where reldeg(N/d)<=0
   c = zeros(ny,np);
   cmag = zeros(ny,np);
   d = zeros(ny,1);
   Q = zeros(ny,reldeg+1);  % stores polynomial part in improper case
   for ct=1:ny
      z = Zero{ct};
      N = Gain(ct) * poly(z);   % numerator
      if length(z)<=np
         % Proper transfer
         Nmag = abs(Gain(ct)) * poly(-abs(z));
      else
         % Improper transfer: split into proper + polynomial
         [q,N] = deconv(N,D);  
         N(1:end-np) = 0;  % enforce deg(N)<deg(D) (see g353895)
         Q(ct,reldeg-length(q)+2:reldeg+1) = q;
         Nmag = abs(N);
      end
      [c(ct,:),d(ct),cmag(ct,:)] = LocalRealize(N,Pole,Nmag,isReal);
   end
   
   % Balancing (using structure-exploiting algorithm)
   if any(cmag(:))
      [a,b,c] = LocalBalance(a,b,c,cmag);
   end
   e = [];
   
   % 2) Add improper part
   if reldeg>0
      [apol,bpol,cpol,dpol,epol] = compreal(Q,[zeros(1,reldeg) 1]);
      [a,b,c,d,e] = ssops('add',a,b,c,d,e,apol,bpol,cpol,dpol,epol);
   end
end


%----------------- Local Functions --------------------------------

function [a,b,c] = LocalBalance(a,b,c,cmag)
% Custom algorithm for balancing A,B,C
% RE: Balancing based on max(CMAG,1) was found to 
%     yield best compression of numerical range
np = size(a,1);

% Construct scaling that normalizes columns of CMAG
% RE: Set s(end)=1 so b(end) is unchanged
cmag = max(cmag,[],1);
cmag(cmag==0) = 1;
s = pow2(round(log2(cmag/cmag(np))));

% Apply scaling
si = 1./s;
c = lrscale(c,[],si);
b = lrscale(b,s,[]);
a = lrscale(a,s,si);

% Equalize norms of b,c
cmax = max(abs(c(:)));
sf = pow2(round(log2(cmax)/2));
c = c/sf;
b(np) = sf;

%-----------------------------------------------------------------------

function [c,d,cmag] = LocalRealize(N,p,Nmag,isReal)
% Computes C,D for single channel
%   N = numerator polynomial
%   p = vector of poles
np = length(p);
cd = zeros(1,np+1); % [c,d]
cmag = zeros(1,np+1);

idx = find(N~=0,1);
if ~isempty(idx)
   % Drop leading zeros in N and compute number NZ of zeros
   N = N(idx:end);
   Nmag = Nmag(idx:end);
   nz = length(N)-1;
   
   % Form linear system for x=cd(1:nz+1)
   N = flipud(N(:));
   T = zeros(nz+1);
   T(1,1) = 1;
   Tmag = T;

   if isReal
      % Real case
      ct = 1;
      while ct<=nz
         pr = real(p(ct));
         pi = imag(p(ct));
         T(1:ct+1,ct+1) = filter([-pr 1],1,T(1:ct+1,ct));
         ct = ct+1;
         if pi~=0 && ct<=nz
            % Complex pair
            T(1:ct+1,ct+1) = filter([pr^2+pi^2 -2*pr 1],1,T(1:ct+1,ct-1));
            ct = ct+1;
         end
      end
   else
      % Complex case
      for ct=1:nz
         T(1:ct+1,ct+1) = filter([-p(ct) 1],1,T(1:ct+1,ct));
      end
   end
   
   % Solve for x
   cd(1:nz+1) = T\N;
   
   % Estimate generic scale of C's entries
   Nmag = flipud(Nmag(:));
   for ct=1:nz
      Tmag(1:ct+1,ct+1) = filter([abs(p(ct)) 1],1,Tmag(1:ct+1,ct));
   end
   Tmag(1:nz+2:end) = -1;
   cmag(1:nz+1) = -(Tmag\Nmag);
end

c = cd(1:np);
d = cd(np+1);
cmag = cmag(1:np);

%-----------------------------------------------------------------------

function p = LocalSortPole(p,isReal)
% Sort and groups poles
if isReal
   pp = p(imag(p)>=0);
   [junk,is] = sort(abs(pp));
   pp = pp(is);
   ctp = 1;
   for ct=1:length(pp)
      x = pp(ct);
      if imag(x)==0
         p(ctp) = x;  ctp = ctp + 1;
      else
         p([ctp,ctp+1]) = [x ; conj(x)];  ctp = ctp + 2;
      end
   end
else
   [junk,is] = sort(abs(p));
   p = p(is);
end
