function [ht,ns]=sieve(x,pmatrix,fcell,nunits,lstab,extlin)
%SIEVE

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2009/11/09 16:24:15 $

% Author(s): Anatoli Iouditski

% "local" global
[edlnth,diminp]=size(x);
diminp=diminp-1;
if isempty(pmatrix);
    pmatrix=eye(diminp);
end;
% added to manage LinearCoef term
if isempty(extlin),nolinmod=1; else nolinmod=0; end
cvready=0;
% initialize the model
sysdat=x;
rl=floor(log(edlnth/fcell/(diminp+1))/log(2));
gsiz=2^(rl+1)-1;

%if ~ischar(nunits) && nunits>3 && floor(nunits)==nunits,
if ~ischar(nunits) && floor(nunits)==nunits,
    if gsiz>nunits,
        gsiz=2^floor(log(nunits+1)/log(2))-1;
    end
end
% Initialize the HT structure
ht.TreeLevelPntr=zeros(gsiz,1);
ht.TreeLevelPntr(1)=1;
ht.AncestorDescendantPntr=zeros(gsiz,3);
ht.AncestorDescendantPntr(1,:)=[1,2,3];
DTPNTR=zeros(gsiz,2);
DTPNTR(1,:)=[1,size(sysdat,1)];
ht.LocalizingVectors=zeros(gsiz,diminp+1);
ht.LocalCovMatrix=zeros(gsiz,(diminp+1)*(diminp+2)/2);
ht.LocalParVector=zeros(gsiz,diminp+1);
s2=zeros(gsiz,1);

% identify ridge-type models
% when using the ridge model set cv vector and cvready flag
ss=rank(pmatrix);
if ss==1,
    [ucv, sss, vvv]=svd(pmatrix');
    cv=ucv(:,1)';
    cvready=1;
end

% Start computing the treepartition
maxknt=1;
for tnot=1:gsiz, % walking around the treepartition
    lwin=DTPNTR(tnot,1);
    rwin=DTPNTR(tnot,2);
    x=sysdat(lwin:rwin,:);
    fn=rwin-lwin+1;
    %	start compute the partition
    
    if fn>fcell*(diminp+1) && maxknt<gsiz,
        xx=x(:,2:diminp+1)*pmatrix';
        %	compute the "classification" row-vector cv
        if ~cvready,
            mtnot=ones(fn,1)*sum(xx)/fn;
            [ucv, sss, vvv]=svd((xx-mtnot)'*(xx-mtnot)/fn);
            cv=ucv(:,1)';
        end
        cvf=cv;
        
        [tmp, tspntr]=sort(cv*xx');
        cspntr=floor(fn/2);
        clvl=tmp(cspntr);
        
        sysdat(lwin:rwin,:)=x(tspntr,:);
        ht.LocalizingVectors(tnot,:)=[clvl, cvf];
        DTPNTR(maxknt+1,:)=[lwin,cspntr+lwin-1];
        DTPNTR(maxknt+2,:)=[cspntr+lwin,rwin];
        ht.AncestorDescendantPntr(tnot,2:3)=[maxknt+1,maxknt+2];
        ht.AncestorDescendantPntr(maxknt+1,:)=[tnot,0,0];ht.AncestorDescendantPntr(maxknt+2,:)=[tnot,0,0];
        maxknt=maxknt+2;
    end
    if tnot>1
        ht.TreeLevelPntr(tnot)=ht.TreeLevelPntr(ht.AncestorDescendantPntr(tnot,1))+1;
    end
    %	compute coefficient estimates
    
    xlong=[ones(size(x,1),1),x(:,2:diminp+1)];
    sxy=x(:,1)'*xlong;
    nx=size(xlong,2);
    mnkm=xlong'*xlong;
    ttol=max(size(mnkm))*norm(mnkm)*lstab;
    %mnkm=pinv(mnkm,ttol);
    mnkm=pinv(mnkm+ttol*eye(nx));
    
    ht.LocalCovMatrix(tnot,:)=m2vec(mnkm)';
    if tnot==1  % added to manage LinearCoef term
        if nolinmod
    ht.LocalParVector(tnot,:)= sxy*mnkm;
        else
            yoffset=mean(x(:,1)-x(:,2:diminp+1)*extlin);
            ht.LocalParVector(tnot,:)= [yoffset,extlin'];            
        end
    else
        ht.LocalParVector(tnot,:)= sxy*mnkm;
    end
    if (fn>fcell*(diminp+1) && fn<=2*fcell*(diminp+1))||tnot>gsiz/2,
        s2(tnot)=norm(x(:,1)-xlong*ht.LocalParVector(tnot,:)')/sqrt(fn-diminp-1);
    end
end
ns=median(abs(s2(s2>0))); % median estimate

% Oct2009
% FILE END

