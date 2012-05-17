function [V, truelam, e, jac] = getErrorAndJacobian(sys, data, ...
    parinfo, option, doJac, varargin)
%GETERRORANDJACOBIAN  Returns the error and the Jacobian of the IDPOLY
%   model at the point specified by parinfo.
%
%   [V,TRUELAM, E, JAC, ERR, JACFLAG] = GETERRORANDJACOBIAN(NLSYS, DATA, ...
%      PARINFO, OPTION, DOJAC, OEFLAG);
%
%   Inputs:
%      SYS     : IDPOLY object.
%      DATA    : IDDATA object.
%      PARINFO : a structure with fields Value, Minimum and Maximum for a
%                combined list of free parameters and initial states. Use
%                obj2var to generate PARINFO.
%      OPTION  : structure with optimization algorithm properties.
%      DOJAC   : compute Jacobian (true) or not (false).
%
%   Outputs:
%      V       : loss function (Ny-by-Ny matrix).
%      TRUELAM : true innovations based loss, a Ny-by-Ny matrix.
%      E       : a sum(N(k))*Ny-1 matrix with prediction errors, for k = 1,
%                2, ..., Ne. The data for one experiment remains together
%                in a way that errors for individual outputs are vertically
%                stacked beneath each other.
%      JAC     : a sum(N(k))*Ny-by-Nest Jacobian matrix, where Nest is the
%                number of estimated entities (parameters as well as initial
%                states).
%      ERRFLAG : boolean vector with Ne elements; true means that the
%                corresponding prediction error element could not be
%                computed.
%      JACFLAG : boolean Ne-by-Nest matrix, where Nest is the number of
%                estimated entities (parameters as well as initial states).
%                A true entry at (j, k) means that the Jacobian entry for
%                the j:th data experiment and the k:th  parameter failed to
%                be computed and has therefore been replaced by zeros.
%
%   See also PEM, VAR2OBJ, OBJ2VAR.

% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2009/04/21 03:22:30 $

e = []; jac = [];

% Failure case handling
% If any parameter value is NaN or Inf, set Eflag, Jflag to true and return.
failedIter = ~all(isfinite(parinfo.Value));

if failedIter
    [V, truelam, e, jac] = LocalHandleFailure(option,parinfo);
    return
end

if nargin>5
    oeflag = varargin{1};
else
    oeflag = false;
end

% par has all parameters - fixed+free+estimated states
par = var2obj(sys, parinfo.Value, option.struc);

struc = option.struc;
dom = struc.domain;
if strncmpi(dom,'f',1)
    if ~doJac
        [V, truelam] = gnnew_fp(data, par, option, oeflag);
    else
        [V, truelam, e, jac] = gnnew_fp(data, par, option, oeflag);
    end
else
    % time domain data
    switch lower(struc.init(1))
        case {'e','b'}
            if ~doJac
                [V, truelam] = gnx(data, par, option, oeflag);
            else
                [V, truelam, e, jac] = gnx(data, par, option, oeflag);
            end
            
        case 'z'
            if ~doJac
                [V, truelam] = gntrad(data, par, option, oeflag);
            else
                [V, truelam, e, jac] = gntrad(data, par, option, oeflag);
            end
    end
end
if any(isinf(V(:)))
    [V, truelam, e, jac] = LocalHandleFailure(option, parinfo);
end
e = -e; %sign is different in idminimizer/lsqnonlin

%--------------------------------------------------------------------------
function [V,lamtrue,Re,R] = gntrad(zc, par, algorithm, oeflag)
%Calculate Jacobian and error when InitialState is zero

nn = algorithm.struc;
%V = [];
lamtrue = []; R = []; Re = [];

% common prep code for gnx and gntrad
[a,b,c,d,f,fst,nu,na,nb,nc,nd,nf,nk,nfm,lim,maxsize,index,stablim,stab,...
    Nexp,instab] = ...
    LocalPreparePoly(par,nn,algorithm);

if instab
    V = Inf;
    return;
end

if nu>0
    nmax = max([na nb+nk-ones(1,nu) nc nd nf]);
else
    nmax = max([na nc]);
end

% *** Prepare for gradients calculations ***
n = na+sum(nb)+nc+nd+sum(nf);
ni = max([length(a)+nd-2 nb+nd-2 nf+nc-2 1]);
M = floor(maxsize/n);
n1 = length(index);
R1 = zeros(0,n1+1);

V = 0;
lamtrue = 0;
%NNcap = 0;
nnobs = sum(Nexp)-length(Nexp)*(ni+sum([na nb nc nd nf]));

for kexp = 1:length(Nexp)
    z = zc{kexp};
    %z = [z.y,z.u];
    Ncap = Nexp(kexp);
    v = filter(a,1,z(:,1));
    for k = 1:nu,
        if ~isempty(b)
            w(:,k) = filter(b(k,:),f(k,:),z(:,k+1));
            v = v-w(:,k);
        end
    end
    e = pefilt(d,c,v,zeros(1,ni)); % Note pefilt. This could be discussed.
    
    if lim==0
        el = e;
    else
        ll = lim*ones(size(e,1),1);
        la = abs(e)+eps*ll;
        regul = sqrt(min(la,ll)./la);
        llrder = find(regul~=1);
        regulder = regul;
        regulder(llrder) = regul(llrder)/2;
        el = e.*regul;
    end
    
    lamtrue = lamtrue+e'*e;
    V = V + el(nmax+1:end,:)'*el(nmax+1:end,1);
    
    %nnobs = nnobs+nobs;
    if nargout>2
        if oeflag
            try
                vmodel = n4sid(el,5,'cov','none');
                vmodel = pvset(vmodel,'A',oestab(pvget(vmodel,'A'),0.99,1));
            catch
                vmodel = idpoly(1,1,'noisevar',lamtrue);
            end
        end
        %if sum(nf)==0 , clear w, end
        if na>0, yf=filter(-d,c,z(:,1)); end
        if nc>0, ef=filter(1,c,e); end
        if nd>0, vf=filter(-1,c,v); end
        for k=1:nu
            gg = conv(c,f(k,:));
            uf(:,k) = filter(d,gg,z(:,k+1));
            if nf(k)>0
                wf(:,k) = filter(-d,gg,w(:,k));
            end
        end
        
        % *** Compute the gradient PSI. If N>M do it in portions ***
        for k = nmax:M:Ncap-1
            jj = (k+1:min(Ncap,k+M));
            psi = zeros(length(jj),n);
            for kl = 1:na
                psi(:,kl) = yf(jj-kl);
            end
            ss = na; ss1 = na+sum(nb)+nc+nd;
            for ku = 1:nu
                for kl = 1:nb(ku)
                    psi(:,ss+kl) = uf(jj-kl-nk(ku)+1,ku);
                end
                for kl=1:nf(ku)
                    psi(:,ss1+kl) = wf(jj-kl,ku);
                end
                ss = ss+nb(ku);
                ss1 = ss1+nf(ku);
            end
            
            for kl = 1:nc, psi(:,ss+kl) = ef(jj-kl); end
            ss = ss+nc;
            for kl = 1:nd, psi(:,ss+kl) = vf(jj-kl); end
            
            psi = psi(:,index);
            if lim~=0
                psi = psi.*(regulder(jj)*ones(1,n1));
            end
            if oeflag
                [num,den] = tfdata(vmodel,'v');
                psi = filter(num,den,psi(end:-1:1,:))*sqrt(pvget(vmodel,'NoiseVariance'));
            end
            R1 = triu(qr([R1;[psi,el(jj)]]));
            [nRr,nRc] = size(R1);
            R1 = R1(1:min(nRr,nRc),:);
        end
        %  R=R1(1:n1,1:n1);Re=R1(1:n1,n1+1);
    end
    clear w uf wf
end
if nargout>2
    R = R1(1:n1+1,1:n1);
    Re = R1(1:n1+1,n1+1); %note the sign difference
end

V = V/nnobs;
%{
% do not adjust by Wt because e/psi are not adjusted either
% in multi-output case, this adjustment would be relevant
if ~isDet
    V = V*Wt;
end
%}
lamtrue = lamtrue/nnobs;

%--------------------------------------------------------------------------
function [V, lamtrue, Re, R ] = gnx(z, par, algorithm, oeflag)
%Calculate Jacobian and error when InitialState is Estimate or Backcast

nn = algorithm.struc;
%V = [];
lamtrue = []; R = []; Re = [];

% common prep code for gnx and gntrad
[a,b,c,d,f,fst,nu,na,nb,nc,nd,nf,nk,nfm,lim,maxsize,index,stablim,stab,...
    Nexp,instab,sqrWt,Wt,isDet] = ...
    LocalPreparePoly(par,nn,algorithm);
if instab
    V = Inf;
    return;
end

init = nn.init;
if nargout==2,
    grest = false;
else
    grest = true;
end

try
    xi = par(nn.xi);
catch
    xi = [];
end

if isempty(nfm), nfm=0; end
if nfm==0 && nd==0
    afd = a;
    bfdt = b;
    cf = c;
    nft = zeros(1,nu);
else
    ff = 1;
    bd = zeros(nu,size(b,2)+size(d,2)-1);
    for ku = 1:nu
        bd(ku,:) = conv(b(ku,:),d);
        ff = conv(ff,f(ku,:));
    end
    nft = zeros(1,nu);
    for ku=1:nu
        ftt = 1; %nft(ku)=0;
        for kk=1:nu
            if kk~=ku
                ftt = conv(ftt,f(kk,:));
                nft(ku) = nft(ku)+nf(kk);
            end
        end
        ft(ku,1:length(ftt)) = ftt;
        lltemp = conv(bd(ku,:),ft(ku,:));
        bfdt(ku,1:length(lltemp)) = lltemp;
    end
    ff = ff(1:sum(nf)+1);
    afd = conv(conv(a,ff),d);
    cf = conv(ff,c);
end

if grest && max(sum(nf),nd)>0
    nbb = sum(nft)+sum(nb)+nd*nu;
    dbdb = zeros(sum(nb),nbb);
    csb = [0,cumsum(nb)];
    s1 = 0;
    dbdd = [];
    dadf = [];
    dcdf = [];
    for ku = 1:nu
        fttemp = ft(ku,1:nft(ku)+1);
        dbdb(csb(ku)+1:csb(ku+1),s1+1:s1+nd+nb(ku)+nft(ku)) = ...
            LocalChvar(conv(d,fttemp),nb(ku),0);
        s1 = s1+nd+nb(ku)+nft(ku);
        bftemp = conv(b(ku,:),ft(ku,:));
        bftemp = bftemp(nk(ku)+1:nk(ku)+nb(ku)+nft(ku));
        dbdd = [dbdd, LocalChvar(bftemp,nd,1)];
        dadf = [dadf; LocalChvar(conv(a,conv(d,fttemp)),nf(ku),0)];
        dcdf = [dcdf; LocalChvar(conv(c,fttemp),nf(ku),0)];
    end
    
    dbdf = [];
    for ku = 1:nu % This is the column loop
        dbdfrow = [];
        for kku = 1:nu % This is the row loop
            if kku~=ku
                ftilde=1;ftord=0;
                for kt=1:nu
                    if kt~=ku && kt~=kku,
                        ftilde = conv(ftilde,f(kt,:));ftord=ftord+nf(kt);
                    end
                end
                dbdfrow = [dbdfrow, LocalChvar(...
                    conv(ftilde(1:ftord+1),bd(kku,nk(kku)+1:nk(kku)+nb(kku)+nd)),...
                    nf(ku),1)];
            else
                dbdfrow = [dbdfrow,zeros(nf(ku),nft(ku)+nb(ku)+nd)];
            end
        end
        if any(nb==0) && size(dbdfrow,2)>sum(nb)+sum(nf)+nc+nd
            dbdfrow = dbdfrow(:,1:sum(nb)+sum(nf)+nc+nd);
        end
        
        dbdf = [dbdf; dbdfrow];
    end
    
    trfm = [LocalChvar(conv(d,ff),na,0), zeros(na,nbb+nc+sum(nf))];
    trfm = [trfm; zeros(sum(nb),na+nd+sum(nf)), dbdb,zeros(sum(nb), nc+sum(nf))];
    trfm = [trfm; zeros(nc,na+nd+sum(nf)+nbb), LocalChvar(ff,nc,0)];
    trfm = [trfm; LocalChvar(conv(a,ff),nd,0), dbdd, zeros(nd,nc+sum(nf))];
    trfm = [trfm; dadf, dbdf, dcdf];
    if strncmpi(init,'e',1)
        [nllr,nllc] = size(trfm);
        trfm = [[trfm,zeros(nllr,length(xi))];...
            [zeros(length(xi),nllc),eye(length(xi))]];
    end
else
    trfm = [];
end

if strncmpi(init,'e',1)
    % this is never true for multi-exp data; hence replace z with z{1}
    
    [V,Re,R,Nobs,lamtrue] =...
        gnaxss2(z{1},afd,bfdt,cf,nft+nb+nd,nk,lim,grest,xi,index,...
        trfm,maxsize,oeflag,length(par),Wt,isDet);
else  % i-e. Torben Knudsen
    
    [V,Re,R,Nobs,lamtrue]...
        = gntk(z,afd,bfdt,cf,nft+nb+nd,nk,lim,grest,index,trfm,maxsize,...
        oeflag,length(par),Wt,isDet);
end

%--------------------------------------------------------------------------
function [V,Re,R,Nobs,lamtrue] = ...
    gntk(ze,a,b,c,nb,nk,lim,grest,index,trfm,maxsize,oeflag,truenpar,varargin)
% subroutine used by gnx

% Note: Here ze is a cell array.
if ~iscell(ze);
    ze = {ze};
end
Re = []; R =[];

%if max(abs(roots(c)))>1,V=inf;Re=[];R=[];Nobs=1;lamtrue = V;return,end
na = length(a)-1;
nc = length(c)-1;
nn = [na nb nc];
npar = na+sum(nb)+nc;
n = npar;
tstart = 1+max([na nb+nk-1]);
tstart = max(tstart,max([nk,1])+2);

V = 0; Nobs = 0; lamtrue = 0;
for kexp = 1:length(ze);
    z = ze{kexp};
    [Ncap,nz] = size(z);
    nu = nz-1;
    nobs = Ncap-tstart+1;
    if nobs<nc
        ctrlMsgUtils.error('Ident:estimation:tooFewSamples')
    end
    
    y = z(:,1);
    u = z(:,2:end);
    v = zeros(Ncap,1);
    for ku = 1:nu
        v = v+filter(b(ku,:),1,u(:,ku));
    end
    
    w = filter(a,1,y)-v;
    w = w(tstart:end);
    ecb = filter(1,c,w(end:-1:1));
    wc = filter(c(end:-1:2),1,ecb(Ncap-tstart+1:-1:Ncap-tstart+2-nc)); %todo: Ncap-tstart+2-nc may be <0
    wc = filter(c,1,zeros(1,nc),wc(end:-1:1));
    ei = filter(1,c,wc(nc:-1:1));
    e = filter(c(end:-1:2),1,ei(end:-1:1));
    e = filter(1,c,w,-e(end:-1:1));%e(1) svsrar mot z(tstart)
    if lim==0
        el = e;
    else
        ll = lim*ones(size(e,1),1);
        la = abs(e)+eps*ll;
        regul = sqrt(min(la,ll)./la);
        
        el = e.*regul;
        regule{kexp} = regul;
    end
    V = V + el'*el;
    lamtrue = lamtrue + e'*e;
    Nobs = Nobs + nobs;
    ec{kexp} = e;
    eic{kexp} = ei;
    elc{kexp} = el;
    ecbc{kexp} = ecb;
end
V = V/Nobs;

%{
% do not adjust by Wt because e/psi are not adjusted either
% in multi-output case, this adjustment would be relevant
if ~isDet
    V = V*Wt;
end
%}

lamtrue = lamtrue/(Nobs-truenpar);
if isnan(V)
    V = inf;lamtrue = inf;
    return
end

if ~grest,
    return
end

if oeflag
    dat = iddata(elc,[]);
    try
        vmodel = n4sid(dat,5,'cov','none');
        vmodel = pvset(vmodel,'A',oestab(pvget(vmodel,'A'),0.99,1));
    catch
        vmodel = idpoly(1,1,'noisevariance',V);
    end
end

nr1 = length(index);
R1 = zeros(0,nr1+1);
M = floor(maxsize/n);
%grad=zeros(n,1);
%{
if isempty(trfm),
    nr1 = n;
else
    nr1 = size(trfm,1);
end
%}

for kexp = 1:length(ze);
    z = ze{kexp};
    [Ncap,nz] = size(z);
    nu = nz-1;
    ei = eic{kexp};
    el = elc{kexp};
    e = ec{kexp};
    ecb = ecbc{kexp};
    nobs = Ncap-tstart+1;
    y = z(:,1);u=z(:,2:end);
    dec = ltk2(y,u,ecb,c,nc,tstart,na,nb,nk,nobs,ei);
    elong = [zeros(tstart-nc-1,1);ei.';e];
    y(1:tstart-na-1) = zeros(tstart-na-1,1);
    for ku = 1:nu
        u(1:tstart-nk(ku)-nb(ku),ku) = zeros(tstart-nk(ku)-nb(ku),1);
    end
    
    y = [zeros(nc-tstart+1,1);y];
    u = [zeros(nc-tstart+1,nu);u];
    ef = filter(1,c,elong);
    yf = filter(1,c,y);uf=[];
    for ku = 1:nu
        uf(:,ku) = filter(1,c,u(:,ku));
    end
    
    ir = filter(1,c,[1;zeros(length(yf),1)]);
    zf = [-yf uf ef elong];
    [N,nz] = size(zf);
    zi = -dec;
    if kexp==1
        nk1 = [1 nk 1];
    end
    if isempty(nk1)
        nm = max(nn);
    else
        nm = max(nn+nk1)-1;
        if nm-max(nk1)<1
            nm  = nm + 1;
        end
    end
    tstart1 = nm+1;
    z = [-y u elong];
    if nc>0
        mod = -zi*toeplitz(c(end:-1:2),[c(end),zeros(1,length(c)-2)]);
        mod1 = zeros(tstart1-1,n); %psis=[];
        ss = 0;
        for kz = 1:nz-1
            if nn(kz)>0
                mod1(1+nk1(kz):end,ss+1:ss+nn(kz)) = ...
                    toeplitz(z(1:tstart1-1-nk1(kz),kz),[z(1,kz),zeros(1,nn(kz)-1)]);
            end
            ss = ss+nn(kz);
        end
        ll = conv2(ir,mod.');
        l2 = conv2(ir,mod1);
    else
        %l1 = ir;
        l2 = ir;
    end
    for kloop = nm:M:N-1
        jj = kloop+1:min(N,kloop+M);
        psi = zeros(length(jj),n);
        
        ss = 0;
        for kz = 1:nz-1
            for kk = 1:nn(kz)
                psi(:,ss+kk) = zf(jj-kk+1-nk1(kz),kz);
            end
            ss = ss+nn(kz);
        end
        try
            psi = psi+ll(1+jj(1)-tstart1:length(jj)+jj(1)-tstart1,:)...
                -l2(jj,:);
        end
        if ~isempty(trfm)
            psi = psi*trfm.';
        end
        psi = psi(:,index);
        jjarg = jj-tstart1+1;
        if max(jjarg)>size(psi,1);%(regule{kexp})
            jjarg = jjarg(1:end-1);
            psi = psi(1:end-1,:);
        end
        if lim~=0
            regul = regule{kexp};
            llrder = find(regul~=1);
            regulder = regul;
            regulder(llrder) = regul(llrder)/2;
            psi = psi.*(regulder(jjarg)*ones(1,size(psi,2)));
        end
        if oeflag
            [num,den] = tfdata(vmodel,'v');
            psi = filter(num,den,psi(end:-1:1,:))*sqrt(pvget(vmodel,'NoiseVariance'));
        end
        
        R1 = triu(qr([R1;[psi,el(jjarg)]]));
        [nRr,nRc] = size(R1);
        R1 = R1(1:min(nRr,nRc),:);
    end
end % loop over kexp

nr1 = size(psi,2);
if nr1>nRr || nr1 > nRc+1
    ctrlMsgUtils.error('Ident:estimation:tooFewSamples')
end
R = R1(1:nr1+1,1:nr1);
Re = R1(1:nr1+1,nr1+1);

%--------------------------------------------------------------------------
function [V,Re,R,nobs,lamtrue] = ...
    gnaxss2(z,a,b,c,nb,nk,lim,grest,xi,index,trfm,maxsize,...
    oeflag,truenpar,varargin)

Re = []; R = []; %nobs = 0;
if nargin<10
    xi = [];
end
%if max(abs(roots(c)))>1,
%   V=inf;Re=[];R=[];lamtrue = V;
%   return,
%end

[Ncap,nz] = size(z);
%nu = nz-1;
y = z(:,1);
na = length(a)-1;
nc = length(c)-1;
[nu,nbb] = size(b);
nss = max([na,nc,nbb-1]);
if length(xi)<nss,
    xi = [];
    [nrtrf,nctrf] = size(trfm);
    ext = nss+na+sum(nb)+nc-nctrf;
    if ext~=0
        trfm(nrtrf+(1:ext),nctrf+(1:ext)) = eye(ext);
    end
elseif length(xi)>nss,
    nss = length(xi);
end

if isempty(xi),
    xi = zeros(nss,1);
end

AKC = [[-c(2:nc+1).';zeros(nss-nc,1)],[eye(nss-1);zeros(1,nss-1)]];
bb = [b,zeros(nu,nss-nbb+1)];
B = bb(:,2:end).';
K = zeros(nss,1);       Kc = K;
Kc(1:nc) = c(2:end).';  K = Kc;
try
    K(1:na) = K(1:na)-a(2:end).';
end

C = [1,zeros(1,nss-1)];
if isempty(b)
    if isempty(nb)
        BKD = []; D = []; %BKD = B; D =0; %was []  and  [];
    else
        BKD = B; D = 0;
    end
else
    D = b(:,1).';
    BKD = B-Kc*D;
end

% *** Compute the gradient PSI. If N>M do it in portions ***
nx = nss; ny = 1; npar = na+nc+sum(nb);
%n = length(index);
if grest
    rowmax = max(npar,nx+nz);
else
    rowmax = nx;
end

M = floor(maxsize/rowmax);

V = 0; lamtrue = 0;
X0 = xi; dx0 = zeros(nx,1);
dXk = zeros(nx,npar);
%{
if isempty(trfm)
    nr1 = n;
else
    nr1 = size(trfm,1);
end
%}
nr1 = truenpar;%length(index);
R1 = zeros(0,nr1+1);
nobs = Ncap;
for kc = 1:M:Ncap
    jj = (kc:min(Ncap,kc-1+M));
    if jj(length(jj))<Ncap
        jjz = [jj,jj(length(jj))+1];
    else
        jjz = jj;
    end
    
    psi = zeros(length(jj),npar);
    
    x = ltitr(AKC,[K BKD],z(jjz,:),X0);
    yh = (C*x.'+[0 D]*z(jjz,:).').';
    e = z(jj,1:ny)-yh(1:length(jj),:);
    X0 = x(end,:).';
    if lim==0
        el = e;
    else
        ll = lim*ones(size(e,1),1);
        la = abs(e)+eps*ll;
        regul = sqrt(min(la,ll)./la);
        llrder = find(regul~=1);
        regulder = regul;
        regulder(llrder) = regul(llrder)/2;
        el = e.*regul;
    end
    V = V + el'*el;
    lamtrue = lamtrue + e'*e;
    if oeflag
        try
            vmodel = n4sid(el,5,'cov','none');
            vmodel = pvset(vmodel,'A',oestab(pvget(vmodel,'A'),0.99,1));
        catch
            vmodel = idpoly(1,1,'noisevariance',lamtrue/length(e));
        end
    end
    if grest
        if kc==1
            %beg = 2;
            endx = 1;
        else
            %beg = 1;
            endx = 0;
        end
        psix0 = ltitr((AKC).',C.',[endx;zeros(length(jjz),1)],dx0);
        psix0 = psix0(2:length(jj)+1,:);
        dx0 = psix0(end,:).';
        
        kl = 1;
        
        for kk = 1:na
            Bfake = zeros(nss,1); Bfake(kk) = -1;
            dX = dXk(:,kl);
            psix = ltitr(AKC,Bfake,y(jjz),dX);
            
            psi(:,kl) = psix(1:length(jj),:)*C.';
            dXk(:,kl) = psix(end,:).';
            kl = kl+1;
        end
        %col = na;
        for ku = 1:nu
            for kk = 1:nb(ku)
                if kk==1 && nk(ku)==0
                    psi(:,kl) = filter(1,c,z(jj,ku+1));
                else
                    Bfake = zeros(nss,1);
                    Bfake(nk(ku)-1+kk) = 1;
                    dX = dXk(:,kl);
                    psix = ltitr(AKC,Bfake,z(jjz,ku+1),dX);
                    psi(:,kl) = psix(1:length(jj),:)*C.';
                    dXk(:,kl) = psix(end,:).';
                end
                kl = kl+1;
            end
            
        end
        for kk = 1:nc
            Bfake = zeros(nss,1);
            Bfake(kk) = 1;
            dX = dXk(:,kl);
            psix = ltitr(AKC,Bfake,y(jjz)-yh,dX);
            psi(:,kl) = psix(1:length(jj),:)*C.';
            dXk(:,kl) = psix(end,:).';
            kl = kl+1;
        end
        
        psi = [psi,psix0];
        if ~isempty(trfm)
            psi = psi*trfm.';
        end
        
        psi = psi(:,index);
        
        if lim~=0
            psi = psi.*(regulder*ones(1,size(psi,2)));
        end
        if oeflag
            [num,den] = tfdata(vmodel,'v');
            psi = filter(num,den,psi(end:-1:1,:))*sqrt(pvget(vmodel,'NoiseVariance'));
        end
        
        R1 = triu(qr([R1;[psi,el]]));
        [nRr,nRc] = size(R1);
        R1 = R1(1:min(nRr,nRc),:);
    end %if grest
end % end loop
if grest
    R = R1(1:nr1+1,1:nr1);
    Re = R1(1:nr1+1,nr1+1);
end
V = V/length(z);
%{
% do not adjust by Wt because e/psi are not adjusted either
% in multi-output case, this adjustment would be relevant
if ~isDet
    V = V*Wt;
end
%}
lamtrue = lamtrue/(length(z)-truenpar);%%%

%--------------------------------------------------------------------------
function [V, truelam, e, jac ] = ...
    LocalHandleFailure(option, parinfo)
% return appropriately sized values for cost, error and jacobian

struc = option.struc;
%nex = struc.Ne;
%Nobs = option.DataSize;
ny = struc.ny;
npar = length(parinfo.Value);
truelam = inf(ny);
V = truelam;
e = -inf(npar+1,1);
jac = zeros(npar+1,npar);

%--------------------------------------------------------------------------
function [a,b,c,d,f,fst,nu,na,nb,nc,nd,nf,nk,nfm,lim,maxsize,index,...
    stablim,stab,Nexp,instab,sqrWt,Wt,isDet] = ...
    LocalPreparePoly(par,nn,algorithm)
% common code between gnx and gntrad

Wt = algorithm.Weighting;
sqrWt = [];

%{
% not required for single-output models
was = warning('off', 'MATLAB:sqrtm:SingularMatrix');
sqrWt = sqrtm(Wt);
warning(was)
%}

isDet = strcmpi(algorithm.Criterion,'det');
lim = algorithm.LimitError;
maxsize = algorithm.MaxSize;
stablim = algorithm.Advanced.Zstability;
stab = strcmp(algorithm.Focus,'Stability');
Nexp = algorithm.DataSize;

% indices of estimated parameters
index = setdiff(1:length(par),nn.fixparind);

nu = nn.nu; na = nn.na; nb = nn.nb; nc = nn.nc;
nd = nn.nd; nf = nn.nf; nk = nn.nk;

nfm = max(nf);

a = [1 par(nn.nai).'];
c = [1 par(nn.nci).'];
d = [1 par(nn.ndi).'];
b = zeros(nu,max(nb+nk));
f = zeros(nu,nfm+1);
fst = zeros(1,nu);
instab = false;

rc = []; ra = [];
% note: roots is expensive
if ~isscalar(c)
    rc = roots(c);
end
if (~isempty(rc) && max(abs(rc))>stablim)
    instab = true;
    return
else
    if ~isscalar(a)
        ra = roots(a);
    end
    if (stab && ~isempty(ra) && max(abs(ra))>stablim)
        instab = true;
        return
    end
end
if nu>0
    for ku = 1:nu
        b(ku,nk(ku)+1:nk(ku)+nb(ku)) = par(nn.nbi{ku}).';
        f(ku,1:nf(ku)+1) = [1 par(nn.nfi{ku}).'];
        if nf(ku)>0,
            fst(ku) = max(abs(roots(f(ku,:))));
        else
            fst(ku) = 0;
        end
    end
    if max(fst)>stablim,
        instab = true;
        return
    end
end

%--------------------------------------------------------------------------
function mat = LocalChvar(a,n,ind)

if n==0, mat=zeros(0,length(a)-1+ind); return, end
if n==1,
    if ind==0, mat=a; else mat=[0 a]; end
    return,
end

if ind==0
    mat = toeplitz([a zeros(1,n-1)].',[a(1) zeros(1,n-1)]).';
else
    mat = toeplitz([0 a zeros(1,n-1)].',zeros(1,n)).';
end
