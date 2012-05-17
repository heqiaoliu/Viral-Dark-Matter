function [na,nb,nc,nd,nf,nk,par,nu] = polychk(a,b,c,d,f,lam,T,inhib)
%POLYCHK  Private function for converting polynomials into their orders
%         and the corresponding parameter vector.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.12.4.6 $ $Date: 2009/10/16 04:55:52 $

if nargin<8
    inhib = 0;
end

if norm(lam)==0
    inhib = 1;
end

if isempty(T), T = 1; end
T = idutils.utValidateTs(T,false);
doubleB = ~iscell(b); doubleF = ~iscell(f);

if ~doubleB
    if ~all(cellfun('isclass',b,'double')) || ~all(cellfun(@(x)isempty(x) || isvector(x),b))
        ctrlMsgUtils.error('Ident:idmodel:polyCheckBFCell','b')
    end
    doubleB = false;
    b = idcell2mat(b,T);
end

if ~doubleF
    if ~all(cellfun('isclass',f,'double')) || ~all(cellfun(@(x)isempty(x) || isvector(x),f))
        ctrlMsgUtils.error('Ident:idmodel:polyCheckBFCell','f')
    end
    doubleF = false;
    f = idcell2mat(f,T);
end

[nu,nb1] = size(b); % nu = nu(1);

if isempty(a), a = 1; end
if isempty(c), c = 1; end
if isempty(d), d = 1; end

if ~isempty(b)
    if isempty(f)
        f = ones(nu,1);
    end
else
    b = []; % remove partially empty specification
    nu = 0; nb1 = 0;
end

[nuf, nf1] = size(f);

if nu~=nuf
    if doubleB && doubleF
        ctrlMsgUtils.error('Ident:idmodel:polyCheckBFRows1')
    elseif ~doubleB && ~doubleF
        ctrlMsgUtils.error('Ident:idmodel:polyCheckBFRows2')
    else
        ctrlMsgUtils.error('Ident:idmodel:polyCheckBFRows3')
    end
end

if size(a,1)>1
    ctrlMsgUtils.error('Ident:idmodel:rowVecPolyVal','A')
end

if size(c,1)>1
    ctrlMsgUtils.error('Ident:idmodel:rowVecPolyVal','C')
end

if size(d,1)>1
    ctrlMsgUtils.error('Ident:idmodel:rowVecPolyVal','D')
end

if a(1)~=1
    ctrlMsgUtils.error('Ident:idmodel:monicPoly','A')
end

if c(1)~=1
    ctrlMsgUtils.error('Ident:idmodel:monicPoly','C')
end

if d(1)~=1
    ctrlMsgUtils.error('Ident:idmodel:monicPoly','D')
end

if T>0 && nu>0 && any(f(:,1)~=1)
    ctrlMsgUtils.error('Ident:idmodel:monicFPoly')
end

na = length(a)-1; nc = length(c)-1; nd = length(d)-1;
if nu>0
    ib = b~=0;
    if nb1>1
        nk = sum(cumsum(ib')==0);
    else
        nk = double((cumsum(ib')==0));
    end
    if T>0
        ib = (b(:,nb1:-1:1)~=0);
        if nb1>1
            nb = -sum(cumsum(ib')==0)-nk+nb1;
        else
            nb = -(cumsum(ib')==0)-nk+nb1;
        end
        nb = max(nb,zeros(1,nu));
        nk(nb==0) = zeros(1,sum(nb==0));
    else
        nb = nb1-nk;
        nk = 0*nk; %reset nk to zero for CT models
    end
else
    nb = zeros(1,0); nk = nb;
end

if nf1==1 || nf1==0
    nf = zeros(1,nu);
else
    if T>0
        ih = (f(:,nf1:-1:1)~=0);
        nf = -sum(cumsum(ih')==0)+nf1-1;
    else
        ih = f~=0;
        for ku = 1:nu
            nf(ku) = nf1-find(ih(ku,:)~=0, 1);
            if f(ku,nf1-nf(ku))~=1
                ctrlMsgUtils.error('Ident:idmodel:polyCheckF1')
            end
        end
    end
end

n = na+sum(nb)+nc+nd+sum(nf);
par = zeros(1,n);

if na>0, par(1:na)=a(2:na+1);end
if nc>0, par(na+sum(nb)+1:na+nc+sum(nb))=c(2:nc+1);end
if nd>0, par(na+nc+1+sum(nb):na+nc+nd+sum(nb))=d(2:nd+1);end

sb = na; sf = na+sum(nb)+nc+nd;
for k = 1:nu
    if ~isempty(nb)
        if nb(k)>0
            if T>0
                par(sb+1:sb+nb(k)) = b(k,nk(k)+1:nk(k)+nb(k));
            else
                par(sb+1:sb+nb(k)) = b(k,end-nb(k)+1:end);
            end
        end
    end
    
    if nf(k)>0
        if T>0
            par(sf+1:sf+nf(k)) = f(k,2:nf(k)+1);
        else
            par(sf+1:sf+nf(k)) = f(k,nf1-nf(k)+1:nf1);
        end
    end
    if ~isempty(nb)
        sb = sb+nb(k);
    end
    sf = sf+nf(k);
end

if T==0 && ~inhib
    % C and D*A should have the same order
    if length(c)>length(conv(d,a))
        ctrlMsgUtils.warning('Ident:idmodel:improperNoiseModel')
    elseif length(c)<length(conv(d,a))
        ctrlMsgUtils.warning('Ident:idmodel:properNoiseModel')
    end
end

par = par(:);
