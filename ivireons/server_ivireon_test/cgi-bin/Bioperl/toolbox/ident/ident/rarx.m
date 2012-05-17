function [thm,yhat,p,phi] = rarx(z,nn,adm,adg,th0,p0,phi)
%RARX   Computes estimates recursively for an ARX model.
%   [THM,YHAT] = RARX(Z,NN,adm,adg)
%
%   z : An IDDATA object or the output-input data matrix z = [y u].
%       The routine is for single output data only. The number of inputs
%       can be zero (time series) or more.
%
%   NN : NN = [na nb nk], The orders and delay of an ARX model (see also ARX)
%
%   adm: Adaptation mechanism. adg: Adaptation gain
%    adm='ff', adg=lam: Forgetting factor algorithm, with forg factor lam.
%    adm='kf', adg=R1:  The Kalman filter algorithm with R1 as covariance
%                       matrix of the parameter changes per time step.
%    adm='ng', adg=gam: A normalized gradient algorithm, with gain gam.
%    adm='ug', adg=gam: An Unnormalized gradient algorithm with gain gam.
%
%   THM: The resulting estimates. Row k contains the estimates "in alpha-
%        betic order" corresponding to data up to time k (row k in Z).
%
%   YHAT: The predicted values of the outputs. Row k corresponds to time k.
%
%   Initial value of parameters(TH0) and of "P-matrix" (P0) can be given by
%   [THM,YHAT,P] = RARX(Z,NN,adm,adg,TH0,P0)
%
%   Initial and last values of auxiliary data vector phi are obtained by
%   [THM,YHAT,P,phi] = RARX(Z,NN,adm,adg,TH0,P0,phi0)
%
%   See also ARX, RARMAX, ROE, RBJ, RPEM and RPLR.

%   L. Ljung 10-1-89
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.7.4.4 $  $Date: 2008/10/02 18:46:14 $

if nargin < 4
    disp('Usage: MODEL_PARS = RARX(DATA,ORDERS,ADM,ADG)')
    disp('       [MODEL_PARS,YHAT,COV,PHI] = RARX(DATA,ORDERS,ADM,ADG,TH0,COV0,PHI)')
    disp('       ADM is one of ''ff'', ''kf'', ''ng'', ''ug''.')
    return
end

if ~any(strncmpi(adm,{'ff','kf','ng','ug'},2))
    ctrlMsgUtils.error('Ident:estimation:recurCheck1','rarx')
end
adm = lower(adm(1:2));

if isa(z,'iddata')
    y = pvget(z,'OutputData');
    u = pvget(z,'InputData');
    z = [y{1},u{1}];
end

[nz,ns] = size(z);
if ns==1
    if length(nn)~=1
        ctrlMsgUtils.error('Ident:estimation:rarxTimeSeries')
    end
end

if 2*ns-1~=length(nn)
    ctrlMsgUtils.error('Ident:estimation:rarxOrders')
end

na=nn(1);if ns>1,nb=nn(2:ns);nk=nn(ns+1:2*ns-1);else nk=1;nb=0;end
%nu=1;
if any(nk<1)
    ctrlMsgUtils.error('Ident:estimation:recurCheck2','rarx')
end
d=na+sum(nb);
nbm=nb+nk-1;ncbm=na+cumsum([0 nbm]);
ii = 1:na+sum(nbm);
i = 1:na;
for ku=1:ns-1
    i = [i ncbm(ku)+nk(ku):ncbm(ku+1)];
end

dm = na+sum(nbm);

if nargin<7, phi=zeros(dm,1);      end
if nargin<6, p0=10000*eye(d);      end
if nargin<5, th0=eps*ones(d,1);    end
if isempty(phi),phi=zeros(dm,1);   end
if isempty(p0),p0=10000*eye(d);    end
if isempty(th0),th0=eps*ones(d,1); end
if length(th0)~=d
    ctrlMsgUtils.error('Ident:estimation:recurCheck3','rarx(Z,NN,adm,adg,th0,...)')
end
[th0nr,th0nc]=size(th0);
if th0nr<th0nc, th0=th0';end

p=p0;th=th0;
if adm(1)=='f', R1=zeros(d,d);lam=adg;end
if adm(1)=='k', [sR1,SR1]=size(adg);
    if sR1~=d || SR1~=d
        ctrlMsgUtils.error('Ident:estimation:recurCheck4','rarx(Z,NN,''kf'',R1,...)')
    end
    R1 = adg; lam = 1;
end
if adm(2)=='g', grad=1;else grad=0;end
thm = zeros(nz,length(th));
yhat = zeros(nz,1);
for kcou=1:nz
    yh=phi(i)'*th;
    epsi=z(kcou,1)-yh;
    if ~grad,K=p*phi(i)/(lam + phi(i)'*p*phi(i));
        p=(p-K*phi(i)'*p)/lam+R1;
    else
        K=adg*phi(i);
    end
    if adm(1)=='n'
        K = K/(eps+phi(i)'*phi(i));
    end
    th = th+K*epsi;

    %epsilon=z(kcou,1)-th'*phi(i);

    phi(ii+1)=phi(ii);
    if na>0,phi(1)=-z(kcou,1);end
    if any(ncbm>0),phi(ncbm(1:ns-1)+1)=z(kcou,2:ns)';end

    thm(kcou,:)=th';yhat(kcou)=yh;
end
