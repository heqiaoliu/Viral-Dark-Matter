function [V,Vt,e,psi] = gnnew_f(z,par,algorithm,oeflag)
%GNNEW_F Computes The Gauss-Newton search direction for frequency domain
%data.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.13.4.6 $  $Date: 2008/10/02 18:51:23 $
if nargin < 5
    oeflag = 0; % marks that e should be whitened, and psi filtered accordingly
end

struc = algorithm.struc;

switch struc.type
    case 'ssnans'
        if nargout==2
            [V,Vt] = gnnans_f(z,par,struc,algorithm,oeflag);
        else
            [V,Vt,psi,e,Nobs] = gnnans_f(z,par,struc,algorithm,oeflag);
        end
    case 'ssfree'
        if nargout==2
            [V,Vt] = gnfree_f(z,par,struc,algorithm);
        else
            [V,Vt,psi,e,Nobs] = gnfree_f(z,par,struc,algorithm);
        end
    case 'ssgen'
        if nargout==2
            [V,Vt] = gnns_f(z,par,struc,algorithm,oeflag);
        else
            [V,Vt,psi,e,Nobs] = gnns_f(z,par,struc,algorithm,oeflag);
        end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [V,lamtrue,R,Re,Nobs] = gnns_f(ze,par,struc,algorithm,oeflag)

realflag = struc.realflag;

isDet = strcmpi(algorithm.Criterion,'det');
was = warning('off', 'MATLAB:sqrtm:SingularMatrix');
if isDet
    sqrlam = inv(sqrtm(struc.lambda));
    if ~all(isfinite(sqrlam(:)))
        sqrlam = eye(size(algorithm.Weighting));
    end
else
    Wt = algorithm.Weighting;
    sqrlam = sqrtm(Wt);
end
warning(was)

back = 0;
if strcmpi(struc.init(1),'b')
    back = 1;
end
if ~iscell(ze)
    ze = {ze};
end
V = inf; R = []; Re = []; lamtrue = V; Nobs = [];
maxsize = algorithm.MaxSize;
lim = algorithm.LimitError;
T = struc.modT;
if T==0
    stablim = algorithm.Advanced.Sstability;
else
    stablim = algorithm.Advanced.Zstability;
end
stab = 0;
if ischar(algorithm.Focus) && ...
        any(strcmp(algorithm.Focus,{'Stability','Simulation'}))
    stab = 1;
end

m0 = struc.model;
dt = nuderst(par.')/1000;
try
    dflag = struc.dflag;
catch
    dflag = 0;
end
par1 = par;
%nkint = [];
zeorig = ze;
if ~isempty(dflag)
    dflag1 = dflag(:,1);
else
    dflag1 = [];
end
if any(dflag1)
    for kd = 1:length(dflag1)
        dflagg = dflag1(kd);
        pardel = par(dflagg);
        if floor((pardel-dt(dflagg)/2)/struc.modT)~=floor((pardel+dt(dflagg)/2)/struc.modT)
            pardel = pardel+1.1*dt(dflagg); % To avoid numerical derivative over different sample-delays
        end
        par(dflagg) = pardel;
    end
    par1 = par;
    nu = size(ze{1},2)-3;
    nkint = zeros(1,nu);
    if ~back
        for kd = 1:length(dflag1);
            ku = dflag(kd,2);
            nkint(ku) = floor(par(dflag1(kd))/T);
            par1(dflag1(kd)) = par1(dflag1(kd))-nkint(ku)*T;
        end
        for kexp = 1:length(ze);
            Fre = ze{kexp}(:,end);
            for ku = 1:size(ze{kexp},2)-3
                ze{kexp}(:,1+ku) = ze{kexp}(:,1+ku).*(Fre.^(-nkint(ku))); %%ku
            end
        end
    end
end
m0 = parset(m0,par1);
if ~struc.Tflag,
    m0 = pvset(m0,'Ts',T);
end
[A,B,C,D,K,X00] = ssdata(m0);

if T>0 && struc.Tflag
    [A,B,Cc,D,K] = idsample(A,B,C,D,K,T,struc.intersample);
end

if any(any(~isfinite(A)))
    return
end

[nx,nu] = size(B);
[ny,nx] = size(C);
%n = length(par);
nz = ny+nu;

try
    eig(A-K*C);
catch
    return
end

if stab
    if T==0
        if any(real(eig(A))>stablim);
            return
        end
        % when K is is estimated, add tests on eig(ei)
    else
        if max(abs(eig(A)))>stablim;
            return
        end
    end
end
rowmax = max(nx,1);

M = floor(maxsize/rowmax);
V = zeros(ny,ny);
lamtrue = V;
Nobs = 0;
Ne = length(ze);
ele = cell(1,Ne);
%if nargout==2       % just compute the function value
for kexp = 1:Ne
    z = ze{kexp};
    zorig = zeorig{kexp};
    Ncap = size(z,1);
    nobs = Ncap;
    X0 = X00;
    if back
        X0 = x0est_f(zorig,A,B,C,D,K,ny,nu,maxsize,M,sqrlam);
    end
    yh = zeros(Ncap,ny);
    %todo: why calculate yh in pieces?
    for kc = 1:M:Ncap
        jj = (kc:min(Ncap,kc-1+M));

        %x = freqkern(A,[B X0],z(jj,ny+1:end-1),z(jj,end)).';
        %yh = (C*x.' + D*z(jj,ny+1:end-2).').';

        yh(jj,:) = idltifr(A,[B X0],C,[D,zeros(size(D,1),1)],z(jj,ny+1:end-1),z(jj,end));
    end
    e = z(:,1:ny)-yh;
    ele{kexp} = e; %note lim=0 for freq data
    V = V + (e'*e);

    lamtrue = lamtrue + e'*e;
    Nobs = Nobs + nobs;
end %kexp
TrueNobs = max(Nobs -length(par)/ny,1);

% subtract contribution of states; r.s., Nov 07, 2007
if back
    TrueNobs = max(TrueNobs -length(X0)*Ne/ny,1);
end

V = V/Nobs;
if ~isDet
    V = V*Wt;
end

lamtrue = lamtrue/TrueNobs;
V = real(V+V')/2;
lamtrue = real(lamtrue+lamtrue')/2;
if any(~isfinite(V(:)))
    V = inf;
    lamtrue = V;
end

if nargout<=2
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%          COMPUTE PSI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% update sqrlam for current residues
if isDet
    nv0 = V;
    if (isempty(nv0) || (norm(nv0-nv0') > sqrt(eps)) || min(eig(nv0))<=0 )
        nv0 = eye(ny)/Nobs;
    end
    sqrlam = inv(sqrtm(nv0));
else
    % trace criterion
    % sqrlam is same as before
end

if oeflag
    sqrlam = sqrlam*sqrlam';
end

index = setdiff(1:length(par),struc.fixparind);%index=algorithm.estindex;
%nd = length(par);
n = length(index);
nd = n;

% *** Compute the gradient PSI. If N>M do it in portions ***
rowmax = max(n*ny,nx+nz);
M = floor(maxsize/rowmax);
R1 = zeros(0,nd+1);
dt = nuderst(par1.')/1000; % fix (improved convergence);
if back % use original pars
    par1 = par;
    m0 = parset(m0,par); % original pars.
    [A,B,C,D,K,X00] = ssdata(m0);
end

for kexp = 1:length(ze);
    %z = ze{kexp};
    if back
        z = zeorig{kexp}; % No shift
    else
        z = ze{kexp};
    end
    Ncap = size(z,1);

    if back
        X0 = x0est_f(z,A,B,C,D,K,ny,nu,maxsize,M,sqrlam);
    else
        X0 = X00;
    end
    e = ele{kexp};

    for kc = 1:M:Ncap
        jj = (kc:min(Ncap,kc-1+M));
        Njj = length(jj);
        %psitemp = zeros(length(jj),ny);
        psi = zeros(ny*length(jj),n);

        x = freqkern(A,[B X0],z(jj,ny+1:end-1),z(jj,end)).';
        %yh = (C*x.' + D*z(jj,ny+1:end-2).').'; %om back, så finns yh.
        CHX = mimofr(A,eye(nx),C,[],z(jj,end));
        CHX = mimprep1(CHX);

        %{
            e = z(jj,1:ny)-yh;
            if lim==0
                el = e*sqrlam;
            else
                ll = ones(length(jj),1)*lim;
                la = abs(e)+eps*ll;
                regul = sqrt(min(la,ll)./la);
                el = e.*regul*sqrlam;
            end
            evec = el(:);
        %}

        kkl = 1;
        for kl = index(:)'
            %drawnow
            th1 = par1;
            th1(kl) = th1(kl)+dt(kl)/2;
            th2 = par1;
            th2(kl) = th2(kl)-dt(kl)/2;
            m0 = parset(m0,th1);
            [A1,B1,C1,D1,K1,X1] = ssdata(m0);
            if T>0 && struc.Tflag
                [A1,B1,Cc,D1,K1] = idsample(A1,B1,C1,D1,K1,T,struc.intersample);
            end
            m0 = parset(m0,th2);
            [A2,B2,C2,D2,K2,X2] = ssdata(m0);
            if T>0 && struc.Tflag
                [A2,B2,Cc,D2,K2] = idsample(A2,B2,C2,D2,K2,T,struc.intersample);
            end

            dA = (A1-A2)/dt(kl);
            dB = (B1-B2)/dt(kl);
            dC = (C1-C2)/dt(kl);
            dD = (D1-D2)/dt(kl);
            %dK = (K1-K2)/dt(kl);
            if back
                X1 = x0est_f(z(jj,:),A1,B1,C1,D1,K1,ny,nu,maxsize,M,sqrlam); %jj??
                X2 = x0est_f(z(jj,:),A2,B2,C2,D2,K2,ny,nu,maxsize,M,sqrlam); %jj??
            end
            dX = (X1-X2)/dt(kl);

            Z = [dA,dB,dX]*[x,z(jj,ny+1:end-1)].';
            psitemp = (mimprep2(CHX,Z,Njj,ny)+dC*x.'+dD*z(jj,ny+1:end-2).').'*sqrlam;
            if ~(lim==0)
                psitemp = psitemp.*regul;
            end
            if oeflag
                psitemp = psitemp(:);
                ekk = e;
                psitemp = abs(ekk(:)).*psitemp;
            end
            psi(:,kkl)=psitemp(:);kkl=kkl+1;
        end

        elt = e(jj,:)*sqrlam;
        evec = elt(:);

        if realflag
            psi = [real(psi);imag(psi)];
            evec = [real(evec);imag(evec)];
        end
        R1 = triu(qr([R1;[psi,evec]]));
        [nRr,nRc] = size(R1);
        R1 = R1(1:min(nRr,nRc),:);
        %V = V+e'*e;
        %Nobs = Nobs+Njj;
    end
end %kexp
%{
V = V/Nobs; V =(V+V')/2;
if any(~isfinite(V(:)))
    V = inf;
end
lamtrue = V;
%}
if any(~isfinite(R1(:)))
    R = []; Re =[]; V = inf;
else
    R = R1(1:nd+1,1:nd);
    Re = R1(1:nd+1,nd+1);
end
%end % if nargout

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [V,lamtrue,R,Re,Nobs] = gnfree_f(ze,par,struc,algorithm)

realflag = struc.realflag;

isDet = strcmpi(algorithm.Criterion,'det');
was = warning('off', 'MATLAB:sqrtm:SingularMatrix');
if isDet
    sqrlam = inv(sqrtm(struc.lambda));
    if ~all(isfinite(sqrlam(:)))
        sqrlam = eye(size(algorithm.Weighting));
    end
else
    Wt = algorithm.Weighting;
    sqrlam = sqrtm(Wt);
end
warning(was)

if ~iscell(ze)
    ze = {ze};
end

back = 0;
if strcmpi(struc.init(1),'b')
    back = 1;
end
step = 0.00001;

V = inf; R = []; Re = []; lamtrue = V; Nobs = [];
if ~isempty(par)
    struc = ssfrupd(par,struc);
end

A = struc.a;
B = struc.b;
C = struc.c;
D = struc.d;
K = struc.k;
X01 = struc.x0;
[ny,n] = size(C);
[n,nu] = size(B);
T = struc.modT;

maxsize = algorithm.MaxSize;
%lim = algorithm.LimitError;
if T==0
    stablim = algorithm.Advanced.Sstability;
else
    stablim = algorithm.Advanced.Zstability;
end
stab = 0;
if ischar(algorithm.Focus) && any(strcmp(algorithm.Focus,{'Stability','Simulation'}));
    stab = 1;
end

if stab
    if T==0,
        stabtest = any(real(eig(A))>stablim);
    else
        stabtest = max(abs(eig(A)))>stablim;
    end
else
    stabtest = 0;
end
if stabtest
    return
end

rowmax = size(A,1);
M = floor(maxsize/rowmax);
V = zeros(ny,ny);
lamtrue =V;
Nobs = 0;
%if nargout == 2 % just compute the error
ele = cell(1,length(ze));
for kexp = 1:length(ze)
    z = ze{kexp};
    %{
    y = z(:,1:ny);
    u = z(:,ny+1:end-2);
    ux0 = z(:,end-1);
    farg = z(:,end);
    %}
    clear yh
    Ncap = size(z,1);
    nobs = Ncap;
    if back
        X01 = x0est_f(z,A,B,C,D,struc.k,ny,nu,maxsize,M,sqrlam);
        nobs = nobs - length(X01)/ny;
    end

    for kc=1:M:Ncap
        jj = (kc:min(Ncap,kc-1+M));
        %Njj = length(jj);
        X0 = X01;
        yh(jj,:) = idltifr(A,[B X0],C,[D,zeros(size(D,1),1)],z(jj,ny+1:end-1),z(jj,end));
    end

    e = z(:,1:ny)-yh;
    ele{kexp} = e;
    V = V+ e'*e;
    lamtrue = lamtrue + e'*e;
    Nobs = Nobs + nobs;
end % over kexp

V = V/Nobs; lamtrue = lamtrue/(Nobs-length(par)/ny);
if ~isDet
    V = V*Wt;
end

V = real(V+V')/2; lamtrue = real(lamtrue+lamtrue')/2;
if any(~isfinite(V(:)))
    V = inf;
    lamtrue = V;
end

if nargout<=2
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%          COMPUTE PSI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% update sqrlam for current residues
if isDet
    % This is for the det-criterion: The gradient of
    % det(V) is proportional to the gradient of tr(el*inv(V)*el)
    nv0 = V;
    if (isempty(nv0) || (norm(nv0-nv0') > sqrt(eps)) || min(eig(nv0))<=0 )
        nv0 = eye(ny)/Nobs;
    end
    sqrlam = inv(sqrtm(nv0));
else
    % trace criterion
    % sqrlam remains as before
end

Qperp = struc.Qperp;
dkx = struc.dkx;
if back
    dkx(3) = 0;
end
%sqrlam = struc.sqrlam; %todo
nk = struc.nk;
if isempty(nk)
    snk = 0;
else
    snk = sum(nk==0);
end

npar = n*(ny+nu) + dkx(1)*snk*ny+ dkx(2)*n*ny + dkx(3)*n;
npar1 = size(Qperp,2);
ncol = npar1+1;size(C,1);
M = floor(maxsize/ncol/ny); % max length of a portion of psi
R1 = zeros(0,ncol);
for kexp = 1:length(ze)

    z = ze{kexp};
    u = z(:,ny+1:end-2);
    Ncap = size(z,1);
    %nobs = Ncap;
    e = ele{kexp};
    %yh = zeros(Ncap,ny);
    if back
        X01 = x0est_f(z,A,B,C,D,K,ny,nu,maxsize,M,sqrlam);
    end
    for kc = 1:M:Ncap
        jj = (kc:min(Ncap,kc-1+M));
        Njj = length(jj);
        x0 = X01;
        psi = zeros(length(jj)*ny,npar);
        X = freqkern((A),[B x0], (z(jj,ny+1:end-1)), z(jj,end)).';
        CXH = mimprep1(mimofr(A,eye(n),C,[],z(jj,end)));
        %Z1 = [B x0]*z(jj,ny+1:end-1).';
        %YH1 = mimprep2(CXH,Z1,Njj,ny);
        %yh(jj,:) = YH1.' + z(jj,ny+1:end-2)*D.';

        %nXr = size(X,1);
        a0 = zeros(n,n);
        b0 = zeros(n,nu);
        c0 = zeros(ny,n);
        d0 = zeros(ny,nu);
        k0 = zeros(n,ny);
        dcur =1;
        for j = 1:n*(ny*(1+dkx(2))+nu),   % Gradients w.r.t. A,B,C and K
            a = a0; b = b0; c = c0; d = d0; k = k0;
            idx = 1; len = n*n;
            a(:) = Qperp(idx:len,j);
            idx = idx+len; len = n*nu;
            b(:) = Qperp(idx:idx+len-1,j);
            if dkx(2),
                idx = idx+len; len = n*ny;
                k(:) = Qperp(idx:idx+len-1,j);
            end
            idx = idx+len; len = n*ny;
            c(:) = Qperp(idx:idx+len-1,j);
            if back
                x0p = x0est_f(z(jj,:),A+step*a,B+step*b,C+step*c,D,K+step*k,...
                    ny,nu,maxsize,M,sqrlam); %% jj??
                x0d = (x0p-X01)/step;
            else
                x0d = zeros(n,1);
            end
            Z = [a,b,x0d]*[X z(jj,ny+1:end-1)].';
            YH = mimprep2(CXH,Z,Njj,ny);
            psitmp = (YH.' + X(1:length(jj),:)*c.')*sqrlam;
            %if ~(lim==0),psitmp=psitmp.*regul(jj,:);end
            psi(:,dcur) = psitmp(:);
            dcur = dcur+1;
        end  % for j

        if dkx(1), % Gradient w.r.t. D
            for j=1:nu*ny,
                if any(ceil(j/ny)==find(nk==0))
                    dd = d0(:);
                    dd(j) = 1;
                    d(:) = dd;
                    if dkx(2),
                        ctrlMsgUtils.error('Ident:estimation:noiseModelFreqData')
                        %{
                            if back
                                x0p = x0est_f(z(jj,:),A,B,C,D+step*d,K,ny,nu,maxsize,M,sqrlam);
                                x00=(x0p-X01)/step;
                            else
                                x00 = zeros(n,1);
                            end
                             Z = x00*z(jj,end-1).';
                            psitmp = (mimprep2(CXH,Z,Njj,ny) + d*u(jj,:)).'*sqrlam;
                            %}
                    else
                        psitmp = (u(jj,:)*d.')*sqrlam;
                    end
                    %if ~(lim==0),psitmp=psitmp.*regul(jj,:);end
                    psi(:, dcur)= psitmp(:);
                    dcur = dcur+1;
                end  % for
            end % ceil
        end % if D

        if dkx(3) % Gradient w.r.t x0
            for j = 1:n,
                x00 = zeros(n,1);
                x00(j) = 1;
                Z = x00*z(jj,end-1).';
                psitmp = mimprep2(CXH,Z,Njj,ny).'*sqrlam; %was psitmp1 (?)
                %if ~(lim==0),psitmp=psitmp.*regul(jj,:);end
                psi(:,dcur) = psitmp(:);
                dcur = dcur+1;
            end   % for
        end  % if x0
        %e(jj,:) = z(jj,1:ny) - yh(jj,:);
        elt = e(jj,:)*sqrlam;
        evec = elt(:);
        if realflag
            psi =  [real(psi); imag(psi)];
            evec = [real(evec); imag(evec)];
        end
        R1 = triu(qr([R1;[psi,evec]]));
        [nRr,nRc] = size(R1);
        R1 = R1(1:min(nRr,nRc),:);
    end % kc-loop
    %e = z(:,1:ny) - yh;
    %V = V + e'*e;
    %Nobs = Nobs +nobs;
end %kexp-loop
%{
V = V/Nobs;
V = (V+V')/2;
if any(~isfinite(V(:)))
    V = inf;
end
lamtrue = V;
%}

R = R1(1:npar+1,1:npar);
Re = R1(1:npar+1,npar+1:ncol);
if any(~isfinite(R1(:)))
    R = []; Re =[]; V = inf; lamtrue = V;
end
%end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [V,lamtrue,R,Re,Nobs] = gnnans_f(ze,par,struc,algorithm,oeflag)
%GNNANS_F

realflag = struc.realflag;
maxsize = algorithm.MaxSize;
%lim = algorithm.LimitError;

isDet = strcmpi(algorithm.Criterion,'det');
was = warning('off', 'MATLAB:sqrtm:SingularMatrix');
if isDet
    sqrlam = inv(sqrtm(struc.lambda));
    if ~all(isfinite(sqrlam(:)))
        sqrlam = eye(size(algorithm.Weighting));
    end
else
    Wt = algorithm.Weighting;
    sqrlam = sqrtm(Wt);
end
warning(was)

stab = 0;
if ischar(algorithm.Focus) && any(strcmp(algorithm.Focus,{'Stability','Simulation'}));
    stab = 1;
end

%sqrlam = struc.sqrlam; %sqrlam = eye(size(sqrlam));
%Note: sqrlam is not needed if oeflag=2

modarg = struc.filearg;
T = struc.modT;
if T==0
    stablim = algorithm.Advanced.Sstability;
else
    stablim = algorithm.Advanced.Zstability;
end
index = setdiff(1:length(par),struc.fixparind); %index=algorithm.estindex;
%nd = length(par);
n = length(index);
V = inf;
lamtrue = inf;
Re = [];
R = [];
Nobs = [];
[A,B,C,D,K,X0] = ssmodxx(par,modarg); %No sampling here

if any(any(~isfinite(A)))
    return
end

try
    eig(A-K*C);
catch
    return
end

if stab
    if T==0,
        stabtest = any(real(eig(A))>stablim);
    else
        stabtest = max(abs(eig(A)))>stablim;
    end
else
    stabtest = 0;
end

% activate ei-test when K is estimated:
%{
ei = eig(str.a - str.k*str.c);
if T==0,
    if any(real(ei))>stablim || stabtest
        return
    end
else
    if max(abs(ei))>stablim || stabtest
        return
    end
end
%}

if stabtest
    return
end

[nx,nu] = size(B);
[ny,nx] = size(C);
nz = ny+nu;
%p = ny;
back = 0;
if strcmpi(struc.init(1),'b')
    back = 1;
end
step = 0.0000001;
if ~iscell(ze)
    ze = {ze};
end

%----------------------------------
% calculate error and sqrlam
V = zeros(ny,ny);
Nobs = 0;
rowmax = max(n*ny,nx+nz);
M = floor(maxsize/rowmax);
ele = cell(1,length(ze));
for kexp = 1:length(ze)
    z = ze{kexp};
    Ncap = size(z,1);
    nobs = Ncap;
    if back
        X0 = x0est_f(z,A,B,C,D,K,ny,nu,maxsize,M,sqrlam);
        nobs = nobs - length(X0)/ny;
    end
    e = zeros(0,ny);
    for kc = 1:M:Ncap
        jj = (kc:min(Ncap,kc-1+M));
        ekc = z(jj,1:ny)-idltifr(A,[B X0],C,[D,zeros(size(D,1),1)],...
            z(jj,ny+1:end-1),z(jj,end));
        if oeflag ~=2
            V = V +ekc'*ekc;
        end
        e = [e;ekc];
    end

    ele{kexp} = e;
    Nobs = Nobs +nobs;
end %kexp

if oeflag==2
    V = ele;
    return
else
    V = real(V+V')/2;
    lamtrue = V;
    V = V/Nobs;
    if ~isDet
        V = V*Wt;
    end
    lamtrue = lamtrue/(Nobs-length(index)/ny);
    Vd = diag(V);
    V = V-diag(real(Vd)-Vd);
    ltd = diag(lamtrue);
    lamtrue = lamtrue+ diag(real(ltd)-ltd);
end

if nargout<=2
    % call with oeflag =2 always has nargout=1
    return;
end

% update sqrlam for current residues
if isDet
    % This is for the det-criterion: The gradient of
    % det(V) is proportional to the gradient of tr(el*inv(V)*el)
    nv0 = V;
    if (isempty(nv0) || (norm(nv0-nv0') > sqrt(eps)) || min(eig(nv0))<=0 )
        nv0 = eye(ny)/Nobs;
    end
    sqrlam = inv(sqrtm(nv0));
else
    % trace criterion
    % sqrlam is same as before
end

if oeflag == 1
    ee = gnnans_f(ze,par,struc,algorithm,2);
    sqr = sqrlam*sqrlam';
    sqrlam = eye(ny);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%          COMPUTE PSI
%%%%%%%%%%%%%%%%%%%%%%%%%%

% *** Compute the gradient PSI. If N>M do it in portions ***
R1 = zeros(0,n+1);
for kexp = 1:length(ze)
    if oeflag == 2
        ee{kexp} = zeros(0,ny);
    end
    z = ze{kexp};
    e = ele{kexp};
    Ncap = size(z,1);
    %nobs = Ncap;
    if back
        X0 = x0est_f(z,A,B,C,D,K,ny,nu,maxsize,M,sqrlam);
        %nobs = nobs - length(X0)/ny;
    end

    for kc = 1:M:Ncap
        jj = (kc:min(Ncap,kc-1+M));
        Njj = length(jj);

        %psitemp = zeros(length(jj),ny);
        psi = zeros(ny*length(jj),n);
        x = freqkern(A,[B X0],z(jj,ny+1:end-1),z(jj,end)).';
        CHX = mimofr(A,eye(nx),C,[],z(jj,end));
        CHX = mimprep1(CHX);
        %Z1 = [B X0]*z(jj,ny+1:end-1).';
        %e = z(jj,1:ny) - mimprep2(CHX,Z1,Njj,ny).'-z(jj,ny+1:end-2)*D.';
        %{
        if lim==0
            el = e;
        else
            % never true for freq data
            ll = ones(length(jj),1)*lim;
            la = abs(e)+eps*ll;
            regul = sqrt(min(la,ll)./la);
            el = e.*regul;
        end
        if oeflag == 2
            ee{kexp} = [ee{kexp};el];
        end
        %}

        %if grest
        elt = e(jj,:)*sqrlam;
        evec = elt(:);
        kkl = 1;
        An = modarg.as';
        Nrna = find(isnan(An(:)));
        zv = zeros(nx*nx,1);
        for ka = Nrna'
            zv(ka) = 1;
            dA = reshape(zv,nx,nx)';zv(ka)=0;
            if back
                x0p = x0est_f(z,A+step*dA,B,C,D,K,ny,nu,maxsize,M,sqrlam);
                dX = (x0p-X0)/step;
            else
                dX = zeros(nx,1);
            end
            Z = [dA dX]*[x z(jj,end-1)].';
            psitemp = mimprep2(CHX,Z,Njj,ny).'*sqrlam;
            %{
                if ~(lim==0)
                    psitemp = psitemp.*regul;
                end
            %}

            if oeflag
                eew = ee{kexp}(jj,:)*sqr;
                psitemp = abs(eew(:)).*psitemp(:);
            end

            psi(:,kkl) = psitemp(:);
            kkl = kkl+1;
        end

        Bn = modarg.bs';
        Nrnb = find(isnan(Bn(:)));
        zv = zeros(nx*nu,1);
        for ka = Nrnb'
            zv(ka) = 1;
            dB = reshape(zv,nu,nx)';
            zv(ka) = 0;
            if back
                x0p = x0est_f(z,A,B+step*dB,C,D,K,ny,nu,maxsize,M,sqrlam);
                dX = (x0p-X0)/step;
            else
                dX = zeros(nx,1);
            end

            Z = [dB dX]*z(jj,ny+1:end-1).';
            psitemp = mimprep2(CHX,Z,Njj,ny).'*sqrlam;
            %{
                if ~(lim==0)
                    psitemp = psitemp.*regul;
                end
            %}

            if oeflag
                eew = ee{kexp}(jj,:)*sqr;
                psitemp = abs(eew(:)).*psitemp(:);
            end
            psi(:,kkl) = psitemp(:);kkl=kkl+1;
        end

        Cn = modarg.cs;
        Nrnc = find(isnan(Cn(:)));
        zv = zeros(ny*nx,1);

        for ka = Nrnc'
            zv(ka) = 1;
            dC = reshape(zv,nx,ny)';
            zv(ka) = 0;
            if back
                x0p = x0est_f(z,A,B,C+step*dC,D,K,ny,nu,maxsize,M,sqrlam);
                dX = (x0p-X0)/step;
            else
                dX = zeros(nx,1);
            end
            Z = dX*z(jj,end-1).';
            psitemp = (mimprep2(CHX,Z,Njj,ny)+dC*x(1:Njj,:).').'*sqrlam;
            %{
                if ~(lim==0)
                    psitemp = psitemp.*regul;
                end
            %}
            if oeflag
                eew = ee{kexp}(jj,:)*sqr;
                psitemp = abs(eew(:)).*psitemp(:);
            end
            psi(:,kkl) = psitemp(:);kkl=kkl+1;
        end

        Dn = modarg.ds';%Dn';
        Nrnd = find(isnan(Dn(:)));
        zv = zeros(ny*nu,1);

        for ka = Nrnd'
            zv(ka) = 1;
            dD = reshape(zv,nu,ny)';
            zv(ka) = 0;
            if back
                x0p = x0est_f(z,A,B,C,D+step*dD,K,ny,nu,maxsize,M,sqrlam);
                dX = (x0p-X0)/step;
            else
                dX = zeros(nx,1);
            end

            Z = dX*z(jj,end-1).';
            psitemp = (mimprep2(CHX,Z,Njj,ny)+dD*z(jj,ny+1:ny+nu).').'*sqrlam;
            %{
                if ~(lim==0)
                    psitemp = psitemp.*regul;
                end
            %}
            if oeflag
                eew = ee{kexp}(jj,:)*sqr;
                psitemp = abs(eew(:)).*psitemp(:);
            end
            psi(:,kkl) = psitemp(:);
            kkl = kkl+1;
        end

        if ~back
            Nrnx = find(isnan(modarg.x0s(:)));
            %zv = zeros(nx,1);
            for ka = Nrnx'
                dX = zeros(nx,1);
                dX(ka) = 1;

                Z = dX*z(jj,end-1).';
                psitemp = (mimprep2(CHX,Z,Njj,ny)).'*sqrlam;
                %{
                if ~(lim==0)
                    psitemp = psitemp.*regul;
                end
                %}
                if oeflag
                    eew = ee{kexp}(jj,:)*sqr;
                    psitemp = abs(eew(:)).*psitemp(:);
                end
                psi(:,kkl) = psitemp(:);kkl=kkl+1;
            end
        end

        psi = psi(:,index(:)');
        if realflag
            psi =  [real(psi); imag(psi)];
            evec = [real(evec); imag(evec)];
        end
        R1 = triu(qr([R1;[psi,evec]]));
        [nRr,nRc] = size(R1);
        R1 = R1(1:min(nRr,nRc),:);
        %end %grest
    end % loop
end %kexp

R = R1(1:n+1,1:n);
Re = R1(1:n+1,n+1);
%{
V = V/Nobs;
lamtrue = lamtrue/(Nobs-length(index)/ny);
Vd = diag(V);
V = V-diag(real(Vd)-Vd);
ltd = diag(lamtrue);
lamtrue = lamtrue+ diag(real(ltd)-ltd);
%}

if any(~isfinite(R1(:)))
    %lamtrue = V;
    V = inf;
    lamtrue = V;
    R = [];
    Re = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CHX = mimprep1(CHX)
[p,n,N]=size(CHX);
CHX = reshape(shiftdim(CHX,1),n,N*p);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Y = mimprep2(CHX,Z,N,p)
if ndims(CHX)==2 && min(size(CHX))==1
    Y = reshape((CHX.*repmat(Z,1,p)).',N,p).';
else
    Y = reshape(sum(CHX.*repmat(Z,1,p)).',N,p).';
end
