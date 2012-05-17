function [parmat,ms] = sscan(parm,StructureIndices,InputDelay,noise,init)
%SSCAN  private function

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.10.4.8 $ $Date: 2008/10/02 18:49:41 $

a = parm.a; b = parm.b; c = parm.c; d = parm.d; k = parm.k; x0 = parm.x0;
n = size(a,1); nu = size(b,2); ny = size(c,1);
if nu>0
    if any(InputDelay~=fix(InputDelay)) || any(InputDelay<0)
        ctrlMsgUtils.error('Ident:idmodel:sscan1')
    end
    if any(InputDelay==0),dkx(1)=1;else dkx(1)=0;end
end
if strcmp(noise,'Estimate'),dkx(2)=1;else dkx(2)=0;end
if strcmp(init,'Estimate'),dkx(3)=1;else dkx(3)=0;end
dkx=[dkx,InputDelay];
if isempty(StructureIndices) || ischar(StructureIndices)
    StructureIndices = [];
    if ny>n
        [u1,d1,v1] = svd(c);
        bestcon = inf;
        %rmbest = 1:n;
        s = RandStream('swb2712','seed',0);
        for k1=1:100
            if k1 == 1
                rm1 = 1:n;
            else
                rm = rand(s,ny,1);
                rmm = sort(rm);
                rm1 = rm<rmm(n+1);
            end
            con = cond(u1(rm1,1:n));
            if con < bestcon
                %rmbest = rm1;
                bestcon = con;
            end
            if con < 100
                break
            end
        end
        StructureIndices=zeros(1,ny);
        StructureIndices(rm1)=ones(1,n);
    else
        ind1=floor(n/ny);
        for kc=1:ny-1
            StructureIndices(kc)=ind1;
        end
        if ny>1
            StructureIndices(ny)=n-sum(StructureIndices);
        else
            StructureIndices=n;
        end
    end
end
np=sum(StructureIndices);
if any(StructureIndices<0)
    ctrlMsgUtils.error('Ident:idmodel:sscan2')
end

if length(StructureIndices)~=ny || np~=n
    ctrlMsgUtils.error('Ident:idmodel:idssSetCheck2',n)
end

%psz=find(StructureIndices==0);
r = cumsum(StructureIndices);
o1 = zeros(n,n);
rown = []; kc = 1;
for ky = 1:ny
    for koi = 0:StructureIndices(ky)-1
        rown = [rown,koi*ny+ky];
        if ky==1
            rr=0;
        else
            rr = r(ky-1);
        end
        o1(kc,rr+1+koi)=1;
        kc = kc+1;
    end
end
o2 = zeros(n*ny,n);
for jk = 1:ny
    xx = ltitr(a.',zeros(n,1),zeros(n,1),c(jk,:).');
    o2(jk:ny:ny*(n-1)+jk,:) = xx;
end
o2 = o2(rown,:);
if cond(o2)>1/eps
    ctrlMsgUtils.warning('Ident:idmodel:sscanCheck3')
end
%{
 if min(svd(o1))<100*eps|min(svd(o2))<100*eps
    error(sprintf([' The transformation to canonical form failed.',...
          '\n The reason is probably that outputs are colinear.']))
    end
%}

T = pinv(o2)*o1;
Ti = pinv(o1)*o2;
ac = Ti*a*T;
bc = Ti*b;
kc = Ti*k;
cc = c*T;
x0 = Ti*x0;
ms = canform(StructureIndices,nu,dkx);
if strcmpi(init,'Fixed')
    ms.x0s = x0;
end
parmat.a = ac;
parmat.b = bc;
parmat.c = cc;
parmat.d = d;
parmat.k = kc;
parmat.x0 = x0;
