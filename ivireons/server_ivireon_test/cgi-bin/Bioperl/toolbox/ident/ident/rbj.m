function [thm,yhat,p,phi,psi] = rbj(z,nn,adm,adg,th0,p0,phi,psi)
%RBJ    Computes estimates recursively for a BOX-JENKINS model.
%   [THM,YHAT] = RBJ(Z,NN,adm,adg)
%
%   z : An IDDATA object or the output-input data matrix z = [y u].
%       The routine is for single input, single output data only.
%   NN : NN=[nb nc nd nf nk], The orders and delay of a general
%        input-output model (see also BJ).
%
%   adm: Adaptation mechanism. adg: Adaptation gain
%    adm='ff', adg=lam: Forgetting factor algorithm, with forg factor lam
%    adm='kf', adg=R1:  The Kalman filter algorithm with R1 as covariance
%                       matrix of the parameter changes per time step
%    adm='ng', adg=gam: A normalized gradient algorithm, with gain gam
%    adm='ug', adg=gam: An Unnormalized gradient algorithm with gain gam
%
%   THM: The resulting estimates. Row k contains the estimates "in alpha-
%        betic order" corresponding to data up to time k (row k in Z)
%
%   YHAT: The predicted values of the outputs. Row k corresponds to time k

%   Initial value of parameters(TH0) and of "P-matrix" (P0) can be given by
%   [THM,YHAT,P] = RBJ(Z,NN,adm,adg,TH0,P0)
%
%   Initial and last values of auxiliary data vectors phi and psi are
%   obtained by [THM,YHAT,P,phi,psi] = RBJ(Z,NN,adm,adg,TH0,P0,phi0,psi0).
%
%   See also BJ, RARX, RARMAX, ROE, RPEM and RPLR.

%   L. Ljung 10-1-89
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.7.4.4 $  $Date: 2008/10/02 18:46:15 $

if nargin < 4
    disp('Usage: MODEL_PARS = RBJ(DATA,ORDERS,ADM,ADG)')
    disp('       [MODEL_PARS,YHAT,COV,PHI,PSI] = RBJ(DATA,ORDERS,ADM,ADG,TH0,COV0,PHI,PSI)')
    disp('       ADM is one of ''ff'', ''kf'', ''ng'', ''ug''.')
    return
end

if ~any(strncmpi(adm,{'ff','kf','ng','ug'},2))
    ctrlMsgUtils.error('Ident:estimation:recurCheck1','rbj')
end
adm = lower(adm(1:2));

if isa(z,'iddata')
    y = pvget(z,'OutputData');
    u = pvget(z,'InputData');
    z = [y{1},u{1}];
end

[nz,ns]=size(z);
if ns<=1
    ctrlMsgUtils.error('Ident:estimation:recurOneInputRequired','rbj')
end

if ns>2
    ctrlMsgUtils.error('Ident:estimation:recurMultiInput','rbj')
end

if length(nn)~=5
    ctrlMsgUtils.error('Ident:estimation:rbjOrders')
end

nb=nn(1);nc=nn(2);nd=nn(3);nf=nn(4);nk=nn(5); %nu=1;
if nk<1
    ctrlMsgUtils.error('Ident:estimation:recurCheck2','rbj')
end
d = sum(nn(1:4));

ng=nf+nc;
nbm=max([nb+nk-1,ng,nd]);ndm=max(nd,nc);nfm=max([nf,ng,nd]);
tic=nb+1:nb+nc;tif=nb+nc+nd+1:d;
tib=1:nb;tid=nb+nc+1:nb+nc+nd;
ib=nk:nb+nk-1;ibg=1:ng;ibd=nk:nk+nd-1;
ic=nbm+1:nbm+nc;
id=nbm+nc+1:nbm+nc+nd;idc=nbm+nc+1:nbm+nc+nc;
iff=nbm+nc+ndm+1:nbm+nc+ndm+nf;ifg=nbm+nc+ndm+1:nbm+nc+ndm+ng;
ifd=nbm+nc+ndm+1:nbm+nc+ndm+nd;
dm=nfm+nbm+nc+ndm;
i=[ib ic id iff];
if nargin<8, psi=zeros(dm,1);end
if nargin<7, phi=zeros(dm,1);end
if nargin<6, p0=10000*eye(d);end
if nargin<5, th0=eps*ones(d,1);end
if isempty(psi),psi=zeros(dm,1);end
if isempty(phi),phi=zeros(dm,1);end
if isempty(p0),p0=10000*eye(d);end
if isempty(th0),th0=eps*ones(d,1);end
if length(th0)~=d
    ctrlMsgUtils.error('Ident:estimation:recurCheck3','rbj(Z,NN,adm,adg,th0,...)')
end
[th0nr,th0nc]=size(th0);if th0nr<th0nc, th0=th0';end

p=p0;th=th0;
if adm(1)=='f', R1=zeros(d,d);lam=adg;end
if adm(1)=='k', [sR1,SR1]=size(adg);
    if sR1~=d || SR1~=d
        ctrlMsgUtils.error('Ident:estimation:recurCheck4','rbj(Z,NN,''kf'',R1,...)')
    end
    R1=adg;lam=1;
end
if adm(2)=='g', grad=1;else grad=0;end
thm = zeros(nz,length(th));
yhat = zeros(nz,1);
for kcou=1:nz
    yh=phi(i)'*th;
    epsi=z(kcou,1)-yh;
    if ~grad,K=p*psi(i)/(lam + psi(i)'*p*psi(i));
        p=(p-K*psi(i)'*p)/lam+R1;
    else
        K=adg*psi(i);
    end
    if adm(1)=='n', K=K/(eps+psi(i)'*psi(i));end
    th=th+K*epsi;
    c=fstab([1;th(tic)])';f=fstab([1;th(tif)])';d=[1;th(tid)];
    th(tic)=c(2:nc+1);th(tif)=f(2:nf+1);g=conv(f,c);%HIT*********
    w=th([tib tif])'*phi([ib iff]);
    util=d'*[z(kcou,2);phi(ibd)]-g'*[0;psi(ibg)];
    if nf>0
        wtil=d'*[w;-phi(ifd)]+g'*[0;psi(ifg)];
    end
    v=z(kcou,1)-w;
    epsilon=v-th([tic tid])'*phi([ic id]);

    if nc>0
        epstil=c'*[epsilon;-psi(ic)];end
    if nd>0
        vtil=c'*[v;psi(idc)];
    end
    phi(2:dm)=phi(1:dm-1);psi(2:dm)=psi(1:dm-1);

    if nb>0,phi(1)=z(kcou,2);psi(1)=util;end
    if nc>0,phi(ic(1))=epsilon;psi(ic(1))=epstil;end
    if nd>0,phi(id(1))=-v;psi(id(1))=-vtil;end
    if nf>0,phi(iff(1))=-w;psi(iff(1))=-wtil;end
    thm(kcou,:)=th';yhat(kcou)=yh;
end

