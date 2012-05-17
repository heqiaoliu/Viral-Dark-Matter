function m=ivx(data,nn,xe,maxsize,Tsamp,p)
%IVX Compute instrumental variable estimates for ARX-models.
%
%   MODEL = IVX(DATA, ORDERS, INSTRUMENTS)
%
%       MODEL: returned as the IV-estimate of the ARX-model
%       A(q) y(t) = B(q) u(t-nk) + v(t)
%       along with relevant structure information. See HELP IDPOLY for
%       the exact structure of MODEL.
%
%       Z : the input-output data as an IDDATA object. See HELP IDDATA.
%
%       ORDERS: A matrix of form [na nb nk] gives the orders and delays
%       associated with the above model.
%
%       INSTRUMENTS : is the vector of instrumental variables. This should
%       be of the same size as the output data (i.e. DATA.y). So if DATA
%       contains several experiments, INSTRUMENTS must be a cell array with
%       as many signals as there are experiments. See IV4 for good,
%       automatic choices of instruments. A multioutput variant is given by
%       IDARX/IVX.
%
%   MODEL = IVX(DATA, ORDERS, INSTRUMENTS, MAXSIZE)
%       Makes certain that no matrix with more than MAXSIZE elements is
%       formed by the algorithm. MAXSIZE should be a reasonably large
%       positive integer (default: 250000 on most computers; see IDMSIZE).
%
%   See also ARX, ARXSTRUC, IVAR, IV4, IDARX/IVX.

%   L. Ljung 10-1-86, 4-12-87
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.13.4.13 $  $Date: 2009/12/22 18:53:37 $

%
% *** Some initial tests on the input arguments ***
%

error(nargchk(3,6,nargin,'struct'))

if nargin<6, p=1;end
if nargin<5, Tsamp=1;end
if nargin<4, maxsize=[];end
if maxsize<0,maxsize=[];end
if Tsamp<0,Tsamp=1;end
if p<0,p=1;end
if isempty(Tsamp),Tsamp=1;end,
ny=size(nn,1);
nr=ny;
if ~iscell(xe)
    xe={xe};
end
datan = '';
if p==1 && isa(data,'iddata')
    try
        [mdum,data,p,fixflag,fixp] = arxdecod(data,nn,inputname(1));
        if isa(data,'iddata'), datan = data.Name; end
    catch E
        error(E.identifier,strrep(E.message,'"arx"','"ivx"'))
    end
    if size(mdum,'ny')>1
        m = ivx(data,mdum,xe,maxsize,Tsamp,p);
        return
    end
end
if isa(data,'frd') || isa(data,'idfrd')
    data = iddata(idfrd(data));
end
if p==1
    if ~isa(data,'iddata')
        data = iddata(data(:,1:ny),data(:,ny+1:end),Tsamp);
    end
    if strcmpi(pvget(data,'Domain'),'time')
        [ze,Ne,~,nu,Ts,Name,Ncaps,errflag] = idprep(data,0,datan);
    else
        [ze,Ne,~,nu,Ts,Name,Ncaps,errflag] = idprep_f(data,0,datan);
    end
    if ~isempty(errflag.message), error(errflag), end
    if ~isempty(Name), data.Name = Name; end
    
else % This is a call from inival or iv
    ze = data;
    if ~iscell(ze),ze={ze};end
    Ne = length(ze);

    %ny = 1;
    nz = size(ze{1},2);
    nu = nz-1;
    Ncaps = cellfun('length',ze);
end

if length(xe)~=Ne
    ctrlMsgUtils.error('Ident:estimation:ivx1')
end

for kexp = 1:Ne
    [Nc,nx] = size(xe{kexp});
    %Ncaps = [Ncaps,size(ze{kexp},1)];
    if Ncaps(kexp)~=Nc || nx~=1
        ctrlMsgUtils.error('Ident:estimation:ivx2')
    end
end

%maxsdef = idmsize(max(Ncaps));
if isempty(maxsize)
    maxsize = idmsize;
end

if isa(data,'iddata') && strcmpi(pvget(data,'Domain'),'frequency')
    [a,b,cov,warntxt] = ivx_f(data,xe,nn(1),nn(2:nu+1),nn(nu+2:2*nu+1),maxsize);
    was = ctrlMsgUtils.SuspendWarnings('Ident:idmodel:idpolyUseCellForBF');
    m = idpoly(a,b,'Ts',Ts);
    delete(was)
    
    was = ctrlMsgUtils.SuspendWarnings;
    e = pe(data,m,'e');
    delete(was)
    
    ey = pvget(e,'OutputData');
    ey = cat(1,ey{:});
    loss = ey'*ey;
    V = loss/length(ey);
    npar = length(pvget(m,'ParameterVector'));
    nv = loss/(length(ey)-npar);
    idm = pvget(m,'idmodel');
    idm = idmname(idm,data);
    it_inf = pvget(idm,'EstimationInfo');
    it_inf.DataLength = sum(Ncaps);
    it_inf.DataTs = data.Ts;
    it_inf.DataDomain = 'Frequency';
    it_inf.DataInterSample = data.InterSample;
    it_inf.Status = 'Estimated model (IVX)';
    it_inf.Method = 'IVX';
    it_inf.DataName = Name;
    it_inf.LossFcn = V;
    it_inf.FPE = V*(1+2*npar/sum(Ncaps));
    if ~isempty(warntxt)
        it_inf.Warning = warntxt;
    end

    idm = pvset(idm,'MaxSize',maxsize,'EstimationInfo',it_inf,'NoiseVariance',nv,...
        'CovarianceMatrix',V*cov);
    
    m = pvset(m,'idmodel',idm);
    return
end

%[nnr,nnc]=size(nn);

if nr>1, %multioutput case
    th = idarx;
    ny = nr; nu = (nc-nr)/2;
    th = llset(th,{'na','nb','nk'},{nn(:,1:ny),nn(:,ny+1:ny+nu),...
        nn(:,ny+nu+1:end)});
    m = ivx(data,th,xe,maxsize,Tsamp,p);
    return,
end
if length(nn)~=1+2*nu
    ctrlMsgUtils.error('Ident:estimation:ivx3');
end
na=nn(1);nb=nn(2:1+nu);nk=nn(2+nu:1+2*nu);n=na+sum(nb);
%
% construct regression matrix
%
nmax=max([na+1 nb+nk])-1;
M=floor(maxsize/n);
Rxx=zeros(na);Ruu=zeros(sum(nb));Rxu=zeros(na,sum(nb));Rxy=zeros(na);
Ruy=zeros(sum(nb),na); F=zeros(n,1);
for kexp=1:Ne
    z = ze{kexp};
    x = xe{kexp};
    Ncap = Ncaps(kexp);
    for k=nmax:M:Ncap-1
        jj=(k+1:min(Ncap,k+M));
        phix=zeros(length(jj),na); phiy=phix; phiu=zeros(length(jj),sum(nb));
        for kl=1:na, phiy(:,kl)=-z(jj-kl,1); phix(:,kl)=-x(jj-kl); end
        ss=0;
        for ku=1:nu
            for kl=1:nb(ku), phiu(:,ss+kl)=z(jj-kl-nk(ku)+1,ku+1);end
            ss=ss+nb(ku);
        end
        Rxy=Rxy+phix'*phiy;
        if nu>0,Ruy=Ruy+phiu'*phiy;
            Rxu=Rxu+phix'*phiu;
            Ruu=Ruu+phiu'*phiu;
        end
        Rxx=Rxx+phix'*phix;
        if na>0, F(1:na)=F(1:na)+phix'*z(jj,1);end
        F(na+1:n)=F(na+1:n)+phiu'*z(jj,1);
    end
end
clear phiu, clear phix, clear phiy,
%
% compute estimate
%
if nu==0,TH=pinv(Rxy)*F;end
if nu>0,TH=pinv([Rxy Rxu;Ruy Ruu])*F;end
if p==0, m=TH; return,end
%
% proceed to build up THETA-matrix
%
m = idpoly;
m=llset(m,{'na','nb','nk','nf','nc','nd'},{na,nb,nk,zeros(size(nb)),0,0});
m=parset(m,TH);
m.Ts = Tsamp;

%
% build up the theta-matrix
%
e=pe(ze,m,'z');
V=e'*e/(length(e)-nmax);%%LL%% Check what we should divide by
wtxt = '';
try
    cov=V*pinv([Rxx Rxu; Rxu.' Ruu]); %todo: should use Rxu' rather than Rxu.'?
catch
    ctrlMsgUtils.warning('Ident:estimation:illConditionedCovar2')
    cov=[];
    wtxt = 'Covariance matrix estimate unreliable. Not stored.';
end

if p==2 % internal call from iv4
    m1.model=m;
    m1.cov=cov;
    m1.V = V;
    m=m1;
else
    idm = pvget(m,'idmodel');
    it_inf = pvget(idm,'EstimationInfo');
    it_inf.DataLength = sum(Ncaps);
    it_inf.DataTs = data.Ts;
    it_inf.DataInterSample = data.InterSample;%'Zero order hold';
    it_inf.Status = 'Estimated model (IVX)';
    it_inf.Method = 'IVX';
    it_inf.DataName = Name;
    it_inf.LossFcn = V;
    it_inf.FPE = V*(1+2*length(TH)/sum(Ncaps));
    if ~isempty(wtxt)
        it_inf.Warning = wtxt;
    end
    idm = pvset(idm,'ParameterVector',TH,'MaxSize',maxsize,'CovarianceMatrix',cov,...
        'EstimationInfo',it_inf,'Ts',Ts,'NoiseVariance',V);%'InputName',...
    idm = idmname(idm,data);
    m = pvset(m,'idmodel',idm);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [a,b,cov,wtxt] = ivx_f(data,YHd,na,nb,nk,maxsize)

wtxt = '';
realflag = realdata(data);
nm = max([na,nb+nk-1]);
nu = length(nb);
%n1 = na + sum(nb);
Yc = pvget(data,'OutputData');
Uc = pvget(data,'InputData');
Wc = pvget(data,'Radfreqs');
if isa(YHd,'iddata')
    YHc = pvget(YHd,'OutputData');
else
    YHc = YHd;
end
R=0;Re=0;Rc = 0;
Tc = pvget(data,'Ts');
if isempty(maxsize) || ischar(maxsize) % safety
    maxsize = idmsize;
end
M = floor(maxsize/(nm+1));

for kexp = 1:length(Yc)

    Y1 =Yc{kexp};
    YH1 = YHc{kexp};
    U1 = Uc{kexp};
    w1 = Wc{kexp};
    T = Tc{kexp};
    N = size(Y1,1);
    for kM = 1:M:N
        jj= kM:min(N,kM-1+M);
        Y =Y1(jj,:);
        YH = YH1(jj,:);
        U = U1(jj,:);
        w = w1(jj);
        if T>0,
            OM=exp(-1i*[0:nm]'*w'*T); %#ok<NBRAK>

            inda = 2:na+1;
            YY = Y;
        else
            OM=ones(1,length(w));
            for kom=1:nm
                OM=[OM;(1i*w').^kom];
            end
            inda = na:-1:1;
            YY = Y.*OM(na+1,:).';
        end
        DH = (OM(inda,:).').*(-YH*ones(1,na));
        D = (OM(inda,:).').*(-Y*ones(1,na));
        Db = [];

        for ku = 1:nu
            if T>0,
                ind=nk(ku)+1:nk(ku)+nb(ku);
            else
                ind=nb(ku):-1:1;
            end
            temp=(OM(ind,:).').*(U(:,ku)*ones(1,nb(ku)));
            Db=[Db temp];
        end
        if realflag
            R = R + real([DH Db]'*[D Db]);
            Rc = Rc + real([DH Db]'*[DH Db]);
            Re = Re + real([DH Db]'*YY);
        else
            R = R + [DH Db]'*[D Db];
            Rc = Rc + [DH Db]'*[DH Db];
            Re = Re + [DH Db]'*YY;
        end
    end
end
t = pinv(R)*Re;
a = [1 t(1:na).'];
b = [];
ind = na;
for ku = 1:nu
    b = idextmat(b,[zeros(1,nk(ku)),t(ind+1:ind+nb(ku)).'],T);
    ind  = ind+nb(ku);
end

try
    cov = pinv(Rc);
catch
    ctrlMsgUtils.warning('Ident:estimation:illConditionedCovar2')
    cov=[];
    wtxt = 'Covariance matrix estimate unreliable. Not stored.';
end
