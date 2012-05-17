function [tansw,l2norm,nlrgs,nosgm,dcoef] = nltest(nlobj,y,x,searchflag)
% NLTEST: Tests if TREEPARTITION function NLOBJ is linear.
% Usage:
%	[tansw,l2norm,nlregs,nosgm,detectratio]=NLTEST(NLOBJ);
%	[tansw,l2norm,nlregs,nosgm,detectratio]=NLTEST(NLOBJ, Y,X,SEARCHFLAG);
% Inputs:
%   NLOBJ: TREEPARTITION object
%   Y, X: outputs and regressors, supposed to satisfy a linear
%   relationship. These arguments are necessary if the TREEPARTITION
%   object NLOBJ is not estimated yet or if SEARCHFLAG is true
%   SEARCHFLAG: if true the search over possible nonlinear regressors
%    entries will be done
% Outputs:
%   TANSW:  is 1 if linear hypothesis is rejected, 0 if not.
%   L2NORM: is -1 if the linear hypothesis is NOT rejected. If a nonlinearity
%       is detected, this value provides an estimation of the expected MSE (Mean-Square Error)
%       for the best ARX approximation (the part of the error "explained" with
%       nonlinear model). This value can be compared to the (estimated)
%       noise standard deviation ("unexplained error") to get an idea of the significance
%       of the detected nonlinearity.
%   NLREGS:  is empty if linear hypothesis is NOT rejected for the model.
%       If a nonlinearity is found contains the NonlinearRegressors property of the IDNLARX model.
%       When calling with SEARCHFLAG==1  this output contains the value of NonlinearRegressors
%       property of the model which corresponds to the most  significant  nonlinearity dtected.
%   NOSGM: is zero if the linear hypothesis is NOT rejected.
%       If a nonlinearity is detected, this value is an estimation of the noise standard
%       deviation (unexplained error), which can be compared to L2NORM value.
%   DetectRatio: is the ratio of the test statistics and the detection threshold for
%       the i-th data channel. Small  (<0.5) or large (>2)  DetectRatio signifies
%       that the test is robust. A value of DetectRatio close to one means that the test is
%       on the edge of detecting the nonlineairty. In this case searching for nonlinear regressors
%       can provide more reliable results.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/31 06:14:52 $

% Author(s): Anatoli Iouditski
eflag=0;
ni=nargin;
nlrgs=[];
l2norm=0;
nosgm=0;
tansw=0;
error(nargchk(1,4,ni,'struct'))
if ni<3 && ~isinitialized(nlobj)
    ctrlMsgUtils.error('Ident:analysis:nltestMissingRegressors')
end
nregs=size(x,2);
if rank(x)<nregs,
    ctrlMsgUtils.warning('Ident:analysis:nltestNonPersistentInput')
    eflag=2;
end

if ni<4, searchflag=0; end
if searchflag
    nregs = size(x,2);
    %nallcomb = 2^nregs;
    pt = 0;
    dcoef=0;
    e1flag=0;
    for knl=1:nregs
        nlrcomb = nchoosek(1:nregs, knl);
        ncomb = size(nlrcomb,1);
        for kc=1:ncomb
            pt = pt + 1;
            nlr = nlrcomb(kc,:);
            nlobj.NonlinearRegressors=nlr;
            nlobj=soinitialize(nlobj,y,x);
            [tan,l2,ddcoef,eeflag]=nldetect(nlobj);
            if eeflag==1,
                ctrlMsgUtils.warning('Ident:analysis:emptyTree')
            end
            e1flag=max(e1flag,eeflag);
            dcoef=max(dcoef,ddcoef);
            if tan>0, tansw=1;end
            if l2>l2norm,
                l2norm=l2;
                nosgm=sqrt(nlobj.Parameters.NoiseVariance);
                nlrgs=nlr;
            end
        end
    end
else
    if ~isinitialized(nlobj),
        nlobj=soinitialize(nlobj,y,x);
        [tansw,l2norm,dcoef,e1flag]=nldetect(nlobj);
        if e1flag==1
            ctrlMsgUtils.warning('Ident:analysis:emptyTree')
        end
        
        if tansw,
            nlrgs=nlobj.NonlinearRegressors;
            nosgm=sqrt(nlobj.Parameters.NoiseVariance);
        end
    end
end
eflag=max(eflag,e1flag);
if ~l2norm, l2norm=-1;end

% verify if the test results are reliable
if eflag&&(l2norm==-1),
    dcoef=1;
end
%end of nltest
%==========================================================
function [tansw,l2norm,dcoef,eflag]=nldetect(nlobj)
ht=nlobj.Parameters.Tree;
eflag=0;
if isempty(ht.TreeLevelPntr),
    tansw=0;l2norm=-1;dcoef=0;eflag=1;
    return
end
nosgm=sqrt(nlobj.Parameters.NoiseVariance);
dlnth=nlobj.Parameters.SampleLength;
thrshp=nlobj.Options.Threshold;
if ischar(thrshp), %case of "auto"
    thrshp=1.0;
end

if (isempty(nosgm) || nosgm<1e-8), nosgm=1e-8; end

tansw=0;l2=0;
diminp=size(ht.LocalParVector,2)-1;
lmax=ht.TreeLevelPntr(length(ht.TreeLevelPntr));

iset=find(ht.TreeLevelPntr<=lmax-1);
lambda=(diminp+1)*ones(size(iset));
wvltc=zeros(size(iset));

for i=(iset)'
    wvltc(i)=(ht.LocalParVector(ht.AncestorDescendantPntr(i,2),:)-ht.LocalParVector(i,:))...
        *pinv(v2mat(ht.LocalCovMatrix(ht.AncestorDescendantPntr(i,2),:)))*(ht.LocalParVector(ht.AncestorDescendantPntr(i,2),:)-ht.LocalParVector(i,:))'...
        +(ht.LocalParVector(ht.AncestorDescendantPntr(i,3),:)-ht.LocalParVector(i,:))...
        *pinv(v2mat(ht.LocalCovMatrix(ht.AncestorDescendantPntr(i,3),:)))*(ht.LocalParVector(ht.AncestorDescendantPntr(i,3),:)-ht.LocalParVector(i,:))';
end
tm=find(ht.TreeLevelPntr==lmax-1);
ssl=norm(wvltc(tm))/sqrt((diminp+1)*length(tm));
nsg=nosgm;
if ssl<nsg^2,nsg=sqrt(ssl);end

wvltbc=(wvltc> 2*log(dlnth)/thrshp^2*nsg^2*lambda);

% compute the detection coef
dcoef=max(wvltc./(2*log(dlnth)/thrshp^2*nsg^2*lambda));
% individual test
if sum(wvltbc)>0
    tansw=1;
    l2=sum(wvltbc.*(wvltc-nsg^2*lambda));
    wvltc=wvltc.*(wvltbc==0);
end

% level-aggregated test

%tm=zeros(size(iset));
for lvl=1:lmax-1
    tm=(ht.TreeLevelPntr(1:length(iset))==lvl).*wvltc;
    nlvl=(diminp+1)*length(find(tm>0));
    slvl=(diminp+1).^2*length(tm~=0);
    dl2n=sum(tm)-nlvl*nsg^2;
    
    if dl2n<0, dl2n=0; end
    dcoef=max(dcoef,abs(dl2n)/(sqrt(3*slvl)*sqrt(2*log(length(tm)))/thrshp*nsg^2));
    if abs(dl2n)>sqrt(3*slvl)*sqrt(2*log(length(tm)))/thrshp*nsg^2;
        tansw=1;
        l2=l2+ dl2n;
    end
end

l2norm=sqrt(l2/dlnth);
%end of @treepartition/nltest.m
