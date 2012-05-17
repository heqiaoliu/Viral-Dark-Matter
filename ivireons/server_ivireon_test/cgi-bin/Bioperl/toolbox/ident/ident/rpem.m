function [thm,yhat,p,phi,psi] = rpem(z,nn,adm,adg,th0,p0,phi,psi)
%RPEM   Computes estimates recursively for a general model.
%   [THM,YHAT] = RPEM(Z,NN,adm,adg)
%
%   z : An IDDATA object or the output-input data matrix z = [y u].
%       The routine is for single output data only. The number of inputs
%       must be one or more.
%   NN : NN=[na nb nc nd nf nk], The orders and delay of a general
%        input-output model (see also PEM).
%
%   adm: Adaptation mechanism. adg: Adaptation gain
%       adm='ff', adg=lam: Forgetting factor algorithm, with forgetting
%                          factor lam
%       adm='kf', adg=R1:  The Kalman filter algorithm with R1 as covariance
%                          matrix of the parameter changes per time step
%       adm='ng', adg=gam: A normalized gradient algorithm, with gain gam
%       adm='ug', adg=gam: An Unnormalized gradient algorithm with gain gam
%
%   THM: The resulting estimates. Row k contains the estimates "in alpha-
%        betic order" corresponding to data up to time k (row k in Z)
%
%   YHAT: The predicted values of the outputs. Row k corresponds to time k.
%
%   Initial value of parameters(TH0) and of "P-matrix" (P0) can be given by
%   [THM,YHAT,P] = RPEM(Z,NN,adm,adg,TH0,P0)
%
%   Initial and last values of auxiliary data vectors phi and psi are
%   obtained by [THM,YHAT,P,phi,psi] = RPEM(Z,NN,adm,adg,TH0,P0,phi0,psi0).
%
%   See also PEM, RARMAX, RARX, ROE, RBJ AND RPLR.

%   L. Ljung 10-1-89
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.7.4.4 $  $Date: 2008/10/02 18:46:17 $

if nargin < 4
    disp('Usage: MODEL_PARS = RPEM(DATA,ORDERS,ADM,ADG)')
    disp('       [MODEL_PARS,YHAT,COV,PHI,PSI] = RPEM(DATA,ORDERS,ADM,ADG,TH0,COV0,PHI,PSI)')
    disp('       ADM is one of ''ff'', ''kf'', ''ng'', ''ug''.')
    return
end

if ~any(strncmpi(adm,{'ff','kf','ng','ug'},2))
    ctrlMsgUtils.error('Ident:estimation:recurCheck1','rpem')
end
adm = lower(adm(1:2));

if isa(z,'iddata')
    y = pvget(z,'OutputData');
    u = pvget(z,'InputData');
    z = [y{1},u{1}];
end

[nz,ns]=size(z);nu=ns-1;
if ns==1
    ctrlMsgUtils.error('Ident:estimation:rpemTimeSeries')
end
%nll=length(nn);
if length(nn)~=3+3*nu
    ctrlMsgUtils.error('Ident:estimation:rpemOrders')
end
na = nn(1); nb = nn(2:ns); nc = nn(ns+1); nd = nn(ns+2);
if any(nb==0)
    ctrlMsgUtils.error('Ident:estimation:rpemNBCheck')
end
nf=nn(ns+3:ns+2+nu);nk=nn(ns+3+nu:ns+2+2*nu);
if any(nk<1)
    ctrlMsgUtils.error('Ident:estimation:recurCheck2',...
        'The "%s" command requires input delay nk to be greater than zero. Shift input data if necessary.','rpem')
end

d = sum(nn(1:ns+2+nu));
ng = nc+nf;
nam = (na>0)*max([na,nd,nc]);
nbm = (nb>0).*max(max(nb,nd)+nk-1,ng);
ncm = nc;
ndm = (nd>0)*max(nd,nc);
nfm = (nf>0).*max(nd,ng);

%First indices for each par:
%ina = (na>0)*1;
inbt = (nam+cumsum([0 nbm])+1);
inb = (nb>0).*inbt(1:nu);
inct = inbt(ns);
inc = (nc>0)*inct;
indt = (inct+ncm);
ind = (nd>0)*indt;
infft = (indt+ndm+cumsum([0 nfm]));
inff = (nf>0).*infft(1:nu);
lastind = infft(nu)+nfm(nu)-1;
%initind = [ina inb inc ind inff];

%Indices in theta-vector
%tia=1:na;
tib = na+1:na+sum(nb);
tic = na+sum(nb)+1:na+sum(nb)+nc;
nnid = na+sum(nb)+nc+nd;
tid = na+sum(nb)+nc+1:nnid;
tif = nnid+1:nnid+sum(nf);

ia = 1:na;
ic = inc:inc+nc-1;
id = ind:ind+nd-1;
ibs = []; ifs = [];
for ku=1:nu
    ibs = [ibs inb(ku)-1+nk(ku):inb(ku)+nk(ku)+nb(ku)-2];
    ifs = [ifs inff(ku):inff(ku)+nf(ku)-1];
end
i = [ia ibs ic id ifs];
dm = lastind;

if nargin<8
    psi = zeros(dm,1);
end
if nargin<7
    phi = zeros(dm,1);
end
if nargin<6
    p0 = 10000*eye(d);
end
if nargin<5
    th0 = eps*ones(d,1);
end
if isempty(psi)
    psi = zeros(dm,1);
end
if isempty(phi)
    phi = zeros(dm,1);
end
if isempty(p0)
    p0 = 10000*eye(d);
end
if isempty(th0)
    th0 = eps*ones(d,1);
end
if length(th0)~=d
    ctrlMsgUtils.error('Ident:estimation:recurCheck3','rpem(Z,NN,adm,adg,th0,...)')
end

[th0nr,th0nc] = size(th0);
if th0nr<th0nc
    th0 = th0';
end

p = p0; th = th0;
if adm(1)=='f',
    R1 = zeros(d,d);
    lam = adg;
end
if adm(1)=='k',
    [sR1,SR1]=size(adg);
    if sR1~=d || SR1~=d
        ctrlMsgUtils.error('Ident:estimation:recurCheck4','rpem(Z,NN,''kf'',R1,...)')
    end
    R1=adg;lam=1;
end
if adm(2)=='g'
    grad=1;
else
    grad=0;
end
thm = zeros(nz,length(th));
yhat = zeros(nz,1);
for kcou=1:nz
    yh=phi(i)'*th;
    epsi=z(kcou,1)-yh;
    if ~grad
        K=p*psi(i)/(lam + psi(i)'*p*psi(i));
        p=(p-K*psi(i)'*p)/lam+R1;
    else
        K=adg*psi(i);
    end
    if adm(1)=='n',
        K=K/(eps+psi(i)'*psi(i));
    end
    th=th+K*epsi;
    d=[1;th(tid)];
    if nc>0
        c=fstab([1;th(tic)])';
    else
        c=1;
    end
    th(tic)=c(2:nc+1);
    if ~isempty(tif)
        tif3=tif(1);
    else
        tif3=0;
    end
    if ~isempty(tib)
        tib3=tib(1);
    else
        tib3=0;
    end
    for ku=1:nu,
        if nf(ku)>0,
            f=fstab([1;th(tif3:tif3+nf(ku)-1)])';
        else
            f=1;
        end
        g=conv(f,c);
        th(tif3:tif3+nf(ku)-1)=f(2:nf(ku)+1);
        if nb(ku)+nf(ku)>0
            w(ku)=th([tib3:tib3+nb(ku)-1 tif3:tif3+nf(ku)-1])'*...
                phi([inb(ku)+nk(ku)-1:inb(ku)+nk(ku)+nb(ku)-2 inff(ku):inff(ku)+nf(ku)-1]);
        else
            w(ku)=0;
        end
        tif3=tif3+nf(ku);tib3=tib3+nb(ku);
        if nb(ku)>0,
            util(ku)=d'*[z(kcou,ku+1);phi(inb(ku)+nk(ku)-1:inb(ku)+nk(ku)+nd-2)]-...
                g'*[0;psi(inb(ku):inb(ku)+ng(ku)-1)];
        end
        if nf(ku)>0
            wtil(ku)=d'*[w(ku);-phi(inff(ku):inff(ku)+nd-1)]+g'*[0;psi(inff(ku):inff(ku)+ng(ku)-1)];
        end
    end
    v=[z(kcou,1);-phi(ia)]'*[1;th(ia)]-sum(w);
    epsilon=v-th([tic tid])'*phi([ic id]);

    if na>0
        ytil=d'*[z(kcou,1);-phi(1:nd)]+c'*[0;psi(1:nc)];
    end


    if nc>0
        epstil=c'*[epsilon;-psi(ic)];
    end
    if nd>0
        vtil=c'*[v;psi(ind:ind+nc-1)];
    end
    phi(2:dm)=phi(1:dm-1);psi(2:dm)=psi(1:dm-1);
    if na>0
        phi(1)=-z(kcou,1);
        psi(1)=-ytil;
    end
    for ku=1:nu
        if nb(ku)>0
            phi(inb(ku))=z(kcou,1+ku);psi(inb(ku))=util(ku);
        end
        if nf(ku)>0
            phi(inff(ku))=-w(ku);psi(inff(ku))=-wtil(ku);
        end
    end
    if nc>0
        phi(inc)=epsilon;
        psi(inc)=epstil;
    end
    if nd>0
        phi(ind)=-v;
        psi(ind)=-vtil;
    end

    thm(kcou,:)=th';yhat(kcou)=yh;
end

