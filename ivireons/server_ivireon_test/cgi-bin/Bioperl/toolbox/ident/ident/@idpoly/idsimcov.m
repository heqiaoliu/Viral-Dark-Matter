function ysd = idsimcov(th,ue,y)
%IDSIMCOV Help function to IDMODEL/SIM.   

%   L. Ljung 10-1-86, 9-9-94
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.9.4.4 $ $Date: 2009/12/05 02:03:31 $

Ncap = size(ue,1);
% *** Prepare for gradients calculations ***
%% y
%% ue
th = pvset(th,'BFFormat',1); % force double format
[a,b,c,d,f] = polydata(th);
na = th.na; nb = th.nb; nc = th.nc; nd = th.nd;
nf = th.nf; nk = th.nk;
nu = size(nb,2);
n = na+sum(nb)+sum(nf);
%nmax=max([na nb+nk-ones(1,nu)  nf]);
if th.na>0, yf = filter(-1,a,y); end
for k = 1:nu
   gg = conv(a,f(k,:));
   uf(:,k) = filter(1,gg,ue(:,k));
   if nf(k)>0, wf(:,k) = filter(-b(k,:),f(k,:),uf(:,k));end
end

% *** Compute the gradient PSI. ***
psi = zeros(Ncap,n);%jj=nmax+1:Ncap;
for kl = 1:na, psi(kl+1:Ncap,kl) = yf(1:Ncap-kl); end
ss = na; ss1 = na+sum(nb);
for ku = 1:nu
   for kl = 1:nb(ku)
       psi(kl+nk(ku):Ncap,ss+kl) = uf(1:Ncap-kl-nk(ku)+1,ku);
   end
   for kl = 1:nf(ku), psi(kl+1:Ncap,ss1+kl) = wf(1:Ncap-kl,ku);end
   ss = ss+nb(ku); ss1 = ss1+nf(ku);
end

%*** The covariance of y:
par = pvget(th,'ParameterVector');
P = pvget(th,'CovarianceMatrix');
if ischar(P)
    P = [];
end
me = min(eig(P));
if me<0
    P = P + abs(me)*eye(size(P));
end
actpar = [1:na+sum(nb),na+sum(nb)+nc+nd+1:length(par)];
[nrp,ncp] = size(P);
if nrp>=length(actpar);
   P = P(actpar,actpar);
   ysd = sqrt(sum(((psi*P).*psi),2));
else
   ysd = [];
end
