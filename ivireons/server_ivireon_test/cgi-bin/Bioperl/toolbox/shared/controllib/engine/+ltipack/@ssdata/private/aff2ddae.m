function [bd,cd,dd,Delay] = aff2ddae(ny,nu,ad,bTerms,cTerms,dTerms,Delay)
%AFF2DDAE  Computes DDAE representation of affine discrete model
%
%     x[k+1] =   Ad x[k]      + sum Bp u[k-Np]
%      y[k]  = sum Cq x[k-Nq] + sum Dr u[k-Nr]
%
%   This DDAE "realization" does not increase the number of states and 
%   minimizes the number of internal delays.
%
%   The struct arrays BTERMS, CTERMS, DTERMS contain the delay values
%   and matrix coefficients for each term in the affine model. Each set
%   of terms is sorted by increasing delay values. On output, all discrete
%   internal delays are nonzero.

%	 Author: P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:10 $
nx = size(ad,1);

% Eliminate all zero terms in BTERMS, CTERMS, DTERMS
bTerms = localDiscardZeroTerms(bTerms);  nbt = length(bTerms);
cTerms = localDiscardZeroTerms(cTerms);  nct = length(cTerms);
dTerms = localDiscardZeroTerms(dTerms);  ndt = length(dTerms);

% Pull out shared input delays 
if nbt>0 || ndt>0
   delta = min([Inf,bTerms(1:min(1,nbt)).delay,dTerms(1:min(1,ndt)).delay]);
   if delta>0
      Delay.Input = Delay.Input + delta;
      for ct=1:nbt
         bTerms(ct).delay = bTerms(ct).delay - delta;
      end
      for ct=1:ndt
         dTerms(ct).delay = dTerms(ct).delay - delta;
      end
   end
end

% Pull out shared output delays 
if nct>0 || ndt>0
   delta = min([Inf,cTerms(1:min(1,nct)).delay,dTerms(1:min(1,ndt)).delay]);
   if delta>0
      Delay.Output = Delay.Output + delta;
      for ct=1:nct
         cTerms(ct).delay = cTerms(ct).delay - delta;
      end
      for ct=1:ndt
         dTerms(ct).delay = dTerms(ct).delay - delta;
      end
   end
end

% Rewrite the output equation as
%    y[k] = sum_q (Cq x[k-Nq] + sum_s Dqs u[k-Nq-Mqs])
% where M0s<N1, M1s<N2-N1,... 
% Make sure cTerms has a term for Nq=0
if nct==0 || cTerms(1).delay>0
   cTerms = [struct('delay',0,'coeff',zeros(ny,nx)) ; cTerms];   nct = nct+1;
end
dDelays = [dTerms.delay];
cDelays = [cTerms.delay , Inf];
% Keep track of rank of [[Cq,Dqs]:q>=j]
cumrk = zeros(nct,1);  
nzrows = false(ny,1);
% Rewrite equation: 
cdTerms = struct('xdelay',cell(nct,1),'c',[],'ds',[],'udelays',[],'nzrows',[]);
for ct=nct:-1:1,
   idx = find(cDelays(ct)<=dDelays & dDelays<cDelays(ct+1));
   cdTerms(ct).xdelay = cDelays(ct);
   cdTerms(ct).c = cTerms(ct).coeff;
   cdTerms(ct).ds = {dTerms(idx).coeff};
   cdTerms(ct).udelays = [dTerms(idx).delay] - cDelays(ct);
   nzrows = nzrows | any([cdTerms(ct).c,cdTerms(ct).ds{:}],2);   
   cdTerms(ct).nzrows = nzrows;
   cumrk(ct) = sum(nzrows);
end
   
% Determine set of u[k-Ns] terms needed to realize the affine model
udelays = unique([bTerms.delay , cdTerms.udelays]);  
udelays = udelays(udelays>0);
nud = length(udelays);
uoffsets = nu * (nud-1:-1:0);

% DDAE sizes
nzu = nu*nud;
nzx = sum(cumrk(2:nct));
nfd = nzx + nzu;
Nint = zeros(nfd,1);

% Construct DDAE model
% x equation
b1 = zeros(nx,nu);
b2 = zeros(nx,nfd);
for ct=1:nbt,
   delta = bTerms(ct).delay;
   if delta==0
      b1 = bTerms(1).coeff;
   else
      b2(:,nzx+uoffsets(delta==udelays)+(1:nu)) = bTerms(ct).coeff;
   end
end
% y equation
cdT = cdTerms(1);
c1 = cdT.c;
d11 = zeros(ny,nu);
d12 = zeros(ny,nfd);
if nct>1
   d12(cdTerms(2).nzrows,1:cumrk(2)) = eye(cumrk(2));
end
for ct=1:length(cdT.udelays)
   delta = cdT.udelays(ct);
   if delta==0
      d11 = cdT.ds{ct};
   else
      d12(:,nzx+uoffsets(delta==udelays)+(1:nu)) = cdT.ds{ct};
   end
end

% z equation
c2 = zeros(nfd,nx);
d21 = zeros(nfd,nu);
d22 = zeros(nfd);
% zx terms
iz = 0;
for j=2:nct
   cdT = cdTerms(j);
   lzj = cumrk(j);   nzrows = cdT.nzrows;
   c2(iz+1:iz+lzj,:) = cdT.c(nzrows,:);
   if j<nct
      lzjp1 = cumrk(j+1);
      Pi = zeros(ny,lzjp1);  Pi(cdTerms(j+1).nzrows,:) = eye(lzjp1);
      d22(iz+1:iz+lzj,iz+lzj+(1:lzjp1)) = Pi(nzrows,:);
   end
   for ct=1:length(cdT.udelays)
      delta = cdT.udelays(ct);
      if delta==0
         d21(iz+1:iz+lzj,:) = cdT.ds{ct}(nzrows,:);
      else
         d22(iz+1:iz+lzj,nzx+uoffsets(delta==udelays)+(1:nu)) = ...
            cdT.ds{ct}(nzrows,:);
      end
   end
   Nint(iz+1:iz+lzj,:) = cdT.xdelay-cdTerms(j-1).xdelay;
   iz = iz + lzj;
end
% zu terms
if nud>0
   d21(nfd-nu+1:nfd,:) = eye(nu);
end
d22(nzx+1:nfd-nu,nzx+nu+1:nfd) = eye(nzu-nu);
aux = repmat(fliplr(diff([0 udelays])),nu,1);
Nint(nzx+1:nfd) = aux(:);

% Eliminate superfluous delays and construct output matrices
[d22,cd2,bd2,junk,dkeep] = smreal(d22,[c2 d21],[b2;d12],[]);
bd = [b1 , bd2(1:nx,:)];
cd = [c1 ; cd2(:,1:nx)];
dd = [d11 bd2(nx+1:nx+ny,:);cd2(:,nx+1:nx+nu) d22];
Delay.Internal = Nint(dkeep);
      

%---------------------------
function s = localDiscardZeroTerms(s)
% Discards terms with zero coefficient
nt = length(s);
nzT = false(nt,1);
for ct=1:nt
   nzT(ct) = (norm(s(ct).coeff,1)>0);
end
s = s(nzT,:);
