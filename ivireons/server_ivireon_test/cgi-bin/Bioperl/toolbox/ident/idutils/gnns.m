function [V, lamtrue, Re, R] = gnns(ze, par, algorithm, oeflag)
% Jacobian and error computation function for idgrey/idss
%
% See also idss/getErrorAndJacobian.


% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2009/10/16 04:56:36 $

struc = algorithm.struc;

isDet = strcmpi(algorithm.Criterion,'det');
was = ctrlMsgUtils.SuspendWarnings('MATLAB:sqrtm:SingularMatrix');
if isDet
    sqrlam = inv(sqrtm(struc.lambda));
    if ~all(isfinite(sqrlam(:)))
        sqrlam = eye(size(algorithm.Weighting));
    end
else
    Wt = algorithm.Weighting;
    sqrlam = sqrtm(Wt);
end
delete(was)

back = 0;
if strncmpi(struc.init,'b',1)
    back = 1;
end

if ~iscell(ze)
    ze = {ze};
end

V = inf; R = []; Re = []; lamtrue = V; Nobs = 0;

maxsize = algorithm.MaxSize;
lim = algorithm.LimitError;
stablim = algorithm.Advanced.Zstability;
stab = strcmp(algorithm.Focus,'Stability');

T = struc.modT;
m0 = struc.model;
dt = nuderst(par.')/100;
try
    dflag = struc.dflag;
    dflag = dflag(:,1); % the parameter numbers
catch
    dflag = 0;
end

if any(dflag)
    for kd = 1:length(dflag)
        dflagg = dflag(kd);
        pardel = par(dflagg);

        if floor((pardel-dt(dflagg)/2)/struc.modT-1e4*eps)~=...
                floor((pardel+dt(dflagg)/2)/struc.modT+1e4*eps)
            pardel = pardel+1.1*dt(dflagg);
            
            % To avoid numerical derivative over different sample-delays
            dt(dflagg) = min(dt(dflagg),struc.modT);
            par(dflagg) = pardel;
        end
    end
end

m0 = parset(m0,par);
if ~struc.Tflag
    m0 = tset(m0,T);
end

[A,B,C,D,K,X00] = ssdata(m0);

if any(any(~isfinite(A)))
    return
end

if T>0 && struc.Tflag
    [A,B,Cc,D,K] = idsample(A,B,C,D,K,T,struc.intersample);
    if any(any(~isfinite(A)))
        return
    end
    if max(abs(eig(A-K*Cc)))>1   %%%LL%%%
        try
            K = ssssaux('kric',A,Cc,K*K',eye(size(K,2)),K);
        end
    end
end

[nx,nu] = size(B);
[ny,nx] = size(C);
%n = length(par);
nz = ny+nu;
%fprintf('%d\n ',nx)
try
    ei = eig(A-K*C);
catch
    return
end

if stab
    stabtest = max(abs(eig(A)))>stablim;
else
    stabtest = false;
end

if ~isempty(ei) && (max(abs(ei))>stablim || stabtest)
    return
end

rowmax = nx;
if rowmax>0
    M = floor(maxsize/rowmax);
else
    M = maxsize;
end

V = zeros(ny); lamtrue = V;
Nobs = 0;
Ne = length(ze);
for kexp = 1:Ne
    z = ze{kexp};
    Ncap = size(z,1);
    nobs = Ncap;
    if back
        X00 = x0est(z,A,B,C,D,K,ny,nu,maxsize,sqrlam);
        X0e{kexp} = X00;
    end
    X0 = X00;
    for kc = 1:M:Ncap
        jj = (kc:min(Ncap,kc-1+M));
        if jj(length(jj))<Ncap,
            jjz = [jj,jj(length(jj))+1];
        else
            jjz = jj;
        end
        xh = ltitr(A-K*C,[K B-K*D],z(jjz,:),X0);
        yh(jj,:) = (C*xh(1:length(jj),:).'+[zeros(ny) D]*z(jj,:).').';
        [nxhr,nxhc] = size(xh);X0=xh(nxhr,:).';
    end
    e = z(:,1:ny)-yh;
    if lim==0
        el = e;
    else
        ll = ones(size(e,1),1)*lim;
        la = abs(e)+eps*ll;
        regul = sqrt(min(la,ll)./la);
        llrder = find(regul~=1);
        regulder = regul;
        regulder(llrder) = regul(llrder)/2;
        el = e.*regul;
    end
    ele{kexp} = el;
    V = V + (el'*el);

    lamtrue = lamtrue + e'*e;
    Nobs = Nobs + nobs;
    clear yh
end %kexp

TrueNobs = max(Nobs -length(par)/ny,1);
if back
    TrueNobs = max(TrueNobs -length(X0)*Ne/ny,1);
end
V = V/Nobs; 
if ~isDet 
    V = V*Wt;
end
lamtrue = lamtrue/TrueNobs;

if struc.realflag
    V = real(V);
    lamtrue = real(lamtrue);
end

if any(~isfinite(V(:)))
    V = inf;
    return
end

if nargout==2
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
%       COMPUE PSI
%%%%%%%%%%%%%%%%%%%%%%%%%%

%sqrlam=struc.sqrlam;
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

if oeflag
    dat = iddata(ele,[]);
    try
        vmodel = n4sid(dat,3*ny,'cov','none');
        vmodel = pvset(vmodel,'A',oestab(pvget(vmodel,'A'),0.99,1));
        esqr = sqrtm(pvget(vmodel,'NoiseVariance'));
        [av,bv,cv,dv,kv] = ssdata(vmodel); cv1 = cv;
        av = av';
        cv = esqr*kv';
        kv = cv1'*(sqrlam*sqrlam');
        dv = esqr*(sqrlam*sqrlam');
    catch
        av = zeros(1,1);
        cv = zeros(ny,1);
        kv = zeros(1,ny);
        dv = sqrlam;
    end
    sqrlam = eye(ny); %todo: need sqrt(Nobs) scaling?
end

% indices of estimated parameters
index = setdiff(1:length(par),struc.fixparind);
%index = algorithm.estindex;

%nd = length(par);
n = length(index);
nd = n;

% *** Compute the gradient PSI. If N>M do it in portions ***
rowmax = max(n*ny,nx+nz);
M = floor(maxsize/rowmax);
R1 = zeros(0,nd+1);
%dt=nuderst(par.')/100;

for kexp = 1:length(ze);
    z = ze{kexp};
    Ncap = length(z);
    if back
        X0 = X0e{kexp};
    else
        X0 = X00;
    end

    for kc = 1:M:Ncap
        jj = (kc:min(Ncap,kc-1+M));
        if jj(length(jj))<Ncap
            jjz = [jj,jj(length(jj))+1];
        else
            jjz = jj;
        end
        %psitemp = zeros(length(jj),ny);
        psi = zeros(ny*length(jj),n);
        x = ltitr(A-K*C,[K B-K*D],z(jjz,:),X0);
        yh = (C*x(1:length(jj),:).'+[zeros(ny,ny) D]*z(jj,:).').';
        e = z(jj,1:ny)-yh;
        [nxr,nxc] = size(x);
        X0 = x(nxr,:).';
        if lim==0
            el = e*sqrlam;
        else
            ll = ones(length(jj),1)*lim;
            la = abs(e)+eps*ll;
            regul = sqrt(min(la,ll)./la);
            llrder = find(regul~=1);
            regulder = regul;
            regulder(llrder) = regul(llrder)/2;
            el = e.*regul*sqrlam;
        end

        evec = el(:);
        kkl = 1;
        for kl = index(:)'
            %drawnow
            th1 = par;
            th1(kl) = th1(kl)+dt(kl)/2;

            th2 = par;
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
            try
                dA = (A1-A2)/dt(kl);
                dB = (B1-B2)/dt(kl);
                dC = (C1-C2)/dt(kl);
                dD = (D1-D2)/dt(kl);
                dK = (K1-K2)/dt(kl);
            catch
                th2 = par;
                th2(kl) = th2(kl)+3*dt(kl)/2;
                m0 = parset(m0,th2);
                [A2,B2,C2,D2,K2,X2] = ssdata(m0);
                if T>0 && struc.Tflag
                    [A2,B2,Cc,D2,K2] = idsample(A2,B2,C2,D2,K2,T,struc.intersample);
                end
                dA = (A2-A1)/dt(kl);
                dB = (B2-B1)/dt(kl);
                dC = (C2-C1)/dt(kl);
                dD = (D2-D1)/dt(kl);
                dK = (K2-K1)/dt(kl);
            end
            if kc==1
                if back
                    X1 = x0est(z,A1,B1,C1,D1,K1,ny,nu,maxsize,sqrlam);
                    X2 = x0est(z,A2,B2,C2,D2,K2,ny,nu,maxsize,sqrlam);
                end
                dX = (X1-X2)/dt(kl);
            else
                dX = dXk(:,kl);
            end
            %dX
            psix = ltitr(A-K*C,[dA-dK*C-K*dC,dK,dB-K*dD-dK*D],[x,z(jjz,:)],dX);
            [rpsix,cpsix] = size(psix);
            dXk(:,kl) = psix(rpsix,:).';
            psitemp = (C*psix(1:length(jj),:).' + ...
                [dC,zeros(ny,ny),dD]*[x(1:length(jj),:),z(jj,:)].').';

            if ~(lim==0)
                psitemp = psitemp.*regulder;
            end
            psitemp = psitemp*sqrlam;
            if oeflag
                psitemp1 = ltitr(av,kv,psitemp(end:-1:1,:));
                psitemp = psitemp1*cv.'+psitemp(end:-1:1,:)*dv.';
            end

            psi(:,kkl) = psitemp(:);
            kkl = kkl+1;
        end

        R1 = triu(qr([R1;[psi,evec]]));
        [nRr,nRc] = size(R1);
        R1 = R1(1:min(nRr,nRc),:);
    end
end %kexp

if any(~isfinite(R1(:)))
    V = inf;
else
    R = R1(1:nd+1,1:nd);
    Re = R1(1:nd+1,nd+1);
end

%--------------------------------------------------------------------------
