function [V, truelam, e, jac] = getErrorAndJacobian(sys, data, ...
    parinfo, option, doJac, varargin)
%GETERRORANDJACOBIAN  Returns the error and the Jacobian of the IDSS
%   model at the point specified by parinfo.
%
%   [V,TRUELAM, E, JAC, ERR, JACFLAG] = GETERRORANDJACOBIAN(NLSYS, DATA,
%   ...
%      PARINFO, OPTION, DOJAC, OEFLAG);
%
%   Inputs:
%      SYS     : IDSS object.
%      DATA    : IDDATA object or cell array of data values
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
%   See also PEM.

% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2009/04/21 03:22:32 $

jac = [];

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
if ~option.ComputeProjFlag
    par = var2obj(sys, parinfo.Value, option.struc);
else
    % there cannot be fixed par in this case
    par = parinfo.Value;
end

struc = option.struc;
dom = struc.domain;
e = [];
if strncmpi(dom,'f',1)
    if ~doJac
        [V, truelam] = gnnew_f(data, par, option, oeflag);
    else
        [V, truelam, e, jac] = gnnew_f(data, par, option, oeflag);
    end
else
    % time domain data
    switch struc.type
        case 'ssnans'
            if ~doJac
                [V, truelam] = gnnans(data, par, option, oeflag);
            else
                [V, truelam, e, jac] = gnnans(data, par, option, oeflag);
            end

        case 'ssfree'
            if ~doJac
                [V, truelam] = gnfree(data, par, option);
            else
                [V, truelam, e, jac] = gnfree(data, par, option);
            end

        case 'ssgen'
            if ~doJac
                [V, truelam] = gnns(data, par, option, oeflag);
            else
                [V, truelam, e, jac] = gnns(data, par, option, oeflag);
            end

    end %switch
end
if any(isinf(V(:)))
    [V, truelam, e, jac] = LocalHandleFailure(option, parinfo);
end

e = -e;

%--------------------------------------------------------------------------
function [V, truelam, e, jac ] = LocalHandleFailure(option, parinfo)
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

%disp('unstable')
%{
e = cell(1,nex);
jac = cell(1,nex);
for kex = 1:nex
    e{kex} = inf(Nobs(kex), ny);
    jac{kex} = zeros(Nobs(kex)*ny, npar);
end
e = cell2mat(e(:));
jac = cell2mat(jac(:));
%}

%--------------------------------------------------------------------------
function [V, lamtrue, Re, R] = gnfree(ze, par, algorithm)
% Error/Jacobian for idss with free ss-parameterization

struc = algorithm.struc;

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
if strncmpi(struc.init,'b',1)
    back = 1;
end

step = 0.0001; %%LL%%

V = inf; R = []; Re = []; lamtrue = V; %Nobs = 0;

if ~isempty(par)
    % par is not empty when only error (not gradient) is requested
    struc = ssfrupd(par,struc);
end

[p,n] = size(struc.c);
[n,m] = size(struc.b);

maxsize = algorithm.MaxSize;
lim = algorithm.LimitError;
stablim = algorithm.Advanced.Zstability;
stab = strcmp(algorithm.Focus,'Stability');

if stab
    stabtest = max(abs(eig(struc.a)))>stablim;
else
    stabtest = false;
end

ei = eig(struc.a - struc.k*struc.c);
if max(abs(ei))>stablim || stabtest
    return
end

rowmax = size(struc.a,1);
M = floor(maxsize/rowmax);
X01 = struc.x0;
V = zeros(p,p); lamtrue =V;
Nobs = 0;
ele = cell(1,length(ze));
for kexp = 1:length(ze)
    z = ze{kexp};
    %y = z(:,1:p); u = z(:,p+1:end);
    clear yh
    Ncap = size(z,1);
    nobs = Ncap;
    if back
        X01 = x0est(z,struc.a,struc.b,struc.c,struc.d,struc.k,p,m,maxsize,sqrlam);
        X01e{kexp} = X01;
        nobs = nobs - length(X01)/p;
    end
    for kc = 1:M:Ncap
        jj = (kc:min(Ncap,kc-1+M));
        if jj(length(jj))<Ncap,
            jjz = [jj,jj(length(jj))+1];
        else
            jjz = jj;
        end
        if kc == 1
            X0 = X01;
        end
        xh = ltitr(struc.a-struc.k*struc.c, ...
            [struc.k struc.b-struc.k*struc.d],...
            z(jjz,:),X0);

        yh(jj,:) = (struc.c*xh(1:length(jj),:).'+ struc.d*z(jj,p+1:end).').';
        [nxhr,nxhc] = size(xh);
        X0 = xh(nxhr,:).';
    end

    e = z(:,1:p)-yh;
    if lim==0
        el = e;
    else
        ll = ones(Ncap,1)*lim;
        la = abs(e)+eps*ll;
        regul = sqrt(min(la,ll)./la);
        el = e.*regul;
        regule{kexp} = regul;
    end
    ele{kexp} = el;
    V = V + el'*el;
    lamtrue = lamtrue + e'*e;
    Nobs = Nobs + nobs;
end % over kexp

V = V/Nobs; 
if ~isDet
    V = V*Wt;
end

lamtrue = lamtrue/(Nobs-length(par)/p);
if any(~isfinite(V(:)))
    V = inf;
    return
end

if nargout==2
    return
end
ny = p;

% update sqrlam for current residues
if isDet 
    % This is for the det-criterion: The gradient of
    % det(V) is proportional to the gradient of tr(el*inv(V)*el)
    nv0 = V;
    if (isempty(nv0) || (norm(nv0-nv0') > sqrt(eps)) || min(eig(nv0))<=0 )
        nv0 = eye(ny)/Nobs; %todo: scaling suspect
    end
    sqrlam = inv(sqrtm(nv0)); 
else
    % trace criterion
    % sqrlam  remains as before
end

Qperp = struc.Qperp;
dkx = struc.dkx;
if back
    dkx(3) = 0;
end

%sqrlam=struc.sqrlam;
A = struc.a; 
B = struc.b;
C = struc.c;
D = struc.d;
K = struc.k;
x0 = struc.x0;

nk = struc.nk;
if isempty(nk)
    snk = 0;
else
    snk = sum(nk==0);
end

npar = n*(p+m) + dkx(1)*snk*p+ dkx(2)*n*p + dkx(3)*n;

npar1 = size(Qperp,2);
ncol = npar1+1; %size(C,1);
M = floor(maxsize/ncol/p); % max length of a portion of psi
R1 = zeros(0,ncol);

for kexp = 1:length(ze)
    z = ze{kexp};
    u = z(:,p+1:end);
    el = ele{kexp};
    if ~(lim==0),
        regul = regule{kexp};
        llrder = find(regul~=1);
        regulder = regul;
        regulder(llrder) = regul(llrder)/2;
    end

    Ncap = size(z,1);
    if back
        X01 = X01e{kexp};
        x0 = X01;
    end

    if ~isempty(B), % If not time series
        for kc = 1:M:Ncap
            jj = (kc:min(Ncap,kc-1+M));
            if jj(end)<Ncap
                jjz = [jj,jj(end)+1];
            else
                jjz = jj;
            end
            psi = zeros(length(jj)*p,npar);
            X = ltitr((A-K*C), [K B-K*D], z(jjz,:), x0);
            nXr = size(X,1); 
            x0 = X(end,:).';

            a0 = zeros(n,n);
            b0 = zeros(n,m);
            c0 = zeros(p,n);
            d0 = zeros(p,m);
            k0 = zeros(n,p);
            dcur =1;
            for j = 1:n*(p*(1+dkx(2))+m),   % Gradients w.r.t. A,B,C and K
                a = a0; b = b0; c = c0; d = d0; k = k0;
                idx = 1; len = n*n;
                a(:) = Qperp(idx:len,j);
                idx = idx+len; len = n*m;
                b(:) = Qperp(idx:idx+len-1,j);
                if dkx(2)
                    idx = idx+len; len = n*p;
                    k(:) = Qperp(idx:idx+len-1,j);
                end
                idx = idx+len; len = n*p;
                c(:) = Qperp(idx:idx+len-1,j);
                if kc==1
                    if back
                        x0p = x0est(z,A+step*a,B+step*b,C+step*c,D,...
                            K+step*k,p,m,maxsize,sqrlam);
                        x0d=(x0p-X01)/step;
                    else
                        x0d = zeros(n,1);
                    end
                else
                    x0d = x0dk(:,dcur);
                end

                Xbar = ltitr(A-K*C, [a-k*C-K*c, k, b-k*D], [X z(jjz,:)], x0d);
                x0dk(:,dcur) = Xbar(end,:).';
                psitmp = (Xbar(1:length(jj),:)*C.' + X(1:length(jj),:)*c.');
                if ~(lim==0)
                    psitmp = psitmp.*regulder(jj,:);
                end
                psitmp = psitmp*sqrlam;

                psi(:,dcur) = psitmp(:);
                dcur = dcur+1;
            end  % for j

            if dkx(1) % Gradient w.r.t. D
                for j=1:m*p
                    if any(ceil(j/p)==find(nk==0))
                        dd = d0(:);
                        dd(j) = 1;
                        d(:) = dd;
                        if dkx(2),
                            if kc==1
                                if back
                                    x0p = x0est(z,A,B,C,D+step*d,K,p,m,maxsize,sqrlam);
                                    x00 = (x0p-X01)/step;
                                else
                                    x00 = zeros(n,1);
                                end
                            else
                                x00 = x0dk(:,dcur);
                            end

                            Xbar = ltitr(A-K*C, -K*d, u(jjz,:) , x00);
                            x0dk(:,dcur) = Xbar(end,:).';
                            psitmp = ( Xbar(1:length(jj),:)*C.' + u(jj,:)*d.' );
                        else
                            psitmp = (u(jj,:)*d.');
                        end
                        if ~(lim==0)
                            psitmp = psitmp.*regulder(jj,:);
                        end
                        psitmp = psitmp*sqrlam;
                        psi(:, dcur) = psitmp(:);
                        dcur = dcur+1;
                    end  % for
                end % ceil
            end % if D

            if dkx(3) % Gradient w.r.t x0
                for j = 1:n,
                    if kc==1
                        x00 = zeros(n,1);
                        x00(j) = 1;
                    else
                        x00 = x0dk(:,dcur);
                    end

                    % We hit an assertion with LTITR(A,B,u) when A is complex
                    % and the inner dimension of B*u is zero.  This needs to be
                    % fixed, but for now I am working around it.  It's also not
                    % clear to me that A-K*C should ever really be complex..
                    % currently I'm only seeing the assertion on the IBM.  GJW
                    %
                    % Xbar = ltitr(A-K*C, zeros(n,0), zeros(length(jjz),0) , x00);
                    Xbar = ltitr(A-K*C, zeros(n,1), zeros(length(jjz),1) , x00);
                    x0dk(:,dcur) = Xbar(end,:).';
                    psitmp = Xbar(1:length(jj),:)*C.';
                    if ~(lim==0)
                        psitmp = psitmp.*regulder(jj,:);
                    end
                    psitmp = psitmp*sqrlam;
                    psi(:,dcur) = psitmp(:);
                    dcur = dcur+1;
                end   % for
            end  % if x0

            elt = el(jj,:)*sqrlam;
            evec = elt(:);
            R1 = triu(qr([R1;[psi,evec]]));
            [nRr,nRc] = size(R1);
            R1 = R1(1:min(nRr,nRc),:);
        end % kc-loop

    else  % If time series
        [n,p]=size(K);
        y = z;
        N = length(y);

        npar = 2*n*p + dkx(3)*n;
        for kc = 1:M:N-1
            jj = (kc:min(N,kc-1+M));
            if jj(end)<N
                jjz = [jj,jj(end)+1];
            else
                jjz = jj;
            end
            psi = zeros(length(jj)*p,npar);
            X = ltitr((A-K*C),K,y(jjz,:),x0);
            nXr = size(X,1); x0=X(end,:).';

            a0 = zeros(n,n);
            c0 = zeros(p,n);
            k0 = zeros(n,p);
            dcur =1;
            for j = 1:n*p*2,   % Gradients w.r.t. A,C and K
                a = a0;
                c = c0;
                k = k0;
                b = B;
                d = D;
                idx = 1; len = n*n;
                a(:) = Qperp(idx:len,j);
                idx = idx+len; len = n*p;
                k(:) = Qperp(idx:idx+len-1,j);
                idx = idx+len; len = n*p;
                c(:) = Qperp(idx:idx+len-1,j);
                if kc==1
                    if back
                        x0p = x0est(z,A+step*a,B+step*b,C+step*c,D+step*d,...
                            K+step*k,p,m,maxsize,sqrlam);
                        x0d=(x0p-X01)/step;
                    else
                        x0d = zeros(n,1);
                    end
                else
                    x0d = x0dk(:,dcur);
                end

                Xbar = ltitr(A-K*C, [a-k*C-K*c, k], [X y(jjz,:)], x0d);
                x0dk(:,dcur) = Xbar(end,:).';
                psitmp = (Xbar(1:length(jj),:)*C.' + X(1:length(jj),:)*c.');
                if ~(lim==0)
                    psitmp = psitmp.*regulder(jj,:);
                end

                psitmp = psitmp*sqrlam;
                psi(:,dcur) = psitmp(:);
                dcur = dcur+1;
            end

            if dkx(3) % Gradient w.r.t x0
                for j = 1:n
                    if kc==1
                        x00 = zeros(n,1);
                        x00(j) = 1;
                    else
                        x00 = x0dk(:,dcur);
                    end

                    Xbar = ltitr(A-K*C, zeros(n,1), y(jjz,1) , x00 );
                    x0dk(:,dcur) = Xbar(end,:).';
                    psitmp = (Xbar(1:length(jj),:)*C.');
                    if ~(lim==0)
                        psitmp = psitmp.*regulder(jj,:);
                    end

                    psitmp = psitmp*sqrlam;
                    psi(:,dcur) = psitmp(:);
                    dcur = dcur+1;
                end
            end
            elt = el(jj,:)*sqrlam;
            evec = elt(:);
            R1 = triu(qr([R1;[psi,evec]]));
            [nRr,nRc]=size(R1);
            R1 = R1(1:min(nRr,nRc),:);
        end % kc-loop
    end %if time series
end %kexp loop

R = R1(1:npar+1,1:npar);
Re = R1(1:npar+1,npar+1:ncol);

%{
if ~isequal(npar+1,ncol)
    erro('Multiple columns of error vectors returned.')
end
%}

if any(any(isnan(R1))') || any(any(isinf(R1))')
    V = inf;
end

%--------------------------------------------------------------------------
function [V, lamtrue, Re, R] = gnnans(ze, par, algorithm, oeflag)
%Compute Error/Jacobian for SSGEN type (such as tructured par)
% Note models are always discrete time in this routine

struc = algorithm.struc;

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

maxsize = algorithm.MaxSize;
lim = algorithm.LimitError;
%stablim = algorithm.Advanced.Zstability;
stab = strcmp(algorithm.Focus,'Stability');
%sqrlam = struc.sqrlam;
modarg = struc.filearg;
%T = struc.modT;
stablim = algorithm.Advanced.Zstability;

% indices of estimated parameters
index = setdiff(1:length(par),struc.fixparind);
%index = algorithm.estindex;

%nd = length(par);
n = length(index);
V = inf; lamtrue = inf; Re = []; R = []; %Nobs = 0;

[A,B,C,D,K,X01] = ssmodxx(par,modarg);
if any(~isfinite(A))
    return
end

try
    ei = eig(A-K*C);
catch
    return
end

if stab
    stabtest = max(abs(eig(A)))>stablim;
else
    stabtest = 0;
end

if max(abs(ei))>stablim || stabtest
    return
end

[nx,nu] = size(B);
[ny,nx] = size(C);
nz = ny+nu;

back = 0;
if strcmpi(struc.init(1),'b')
    back = 1;
end

step = 0.0001;
if ~iscell(ze)
    ze = {ze};
end

if nargout<=2
    grest = 0;
else
    grest = 1;
end

% First compute the residuals and the loss function
rowmax = nx;
V = zeros(ny,ny);
lamtrue = V;
Nobs = 0;
M = floor(maxsize/rowmax);
R1 = zeros(0,n+1);
for kexp = 1:length(ze)
    %{
    if oeflag == 2
        ee{kexp} = zeros(0,ny);
    end
    %}
    z = ze{kexp};
    Ncap = size(z,1);
    nobs = Ncap;
    if back
        X01 = x0est(z,A,B,C,D,K,ny,nu,maxsize,sqrlam);
        nobs = nobs - length(X01)/ny;
    end

    e = zeros(Ncap,ny);
    for kc = 1:M:Ncap
        jj = (kc:min(Ncap,kc-1+M));
        if jj(length(jj))<Ncap,
            jjz = [jj,jj(length(jj))+1];
        else
            jjz = jj;
        end
        %psitemp = zeros(length(jj),ny);
        %psi = zeros(ny*length(jj),n);
        if kc == 1
            X0 = X01;
        end
        x = ltitr(A-K*C,[K B-K*D],z(jjz,:),X0);
        e(jj,:) = z(jj,1:ny)-x(1:length(jj),:)*C.'-z(jj,ny+1:end)*D.';
        [nxr,nxc] = size(x); 
        X0 = x(nxr,:).';
    end % kc
    if lim==0
        el = e;
    else
        ll = ones(length(e),1)*lim;
        la = abs(e)+eps*ll;
        regul = sqrt(min(la,ll)./la);
        %             llrder = find(regul~=1);
        %             regulder = regul;
        %             regulder(llrder) = regul(llrder)/2;
        el = e.*regul;
    end
    %ele{kexp}=el;
    %regule{kexp}=regul;
    V = V + el'*el;
    lamtrue = lamtrue + e'*e;
    Nobs = Nobs + nobs;
end %kexp
V = V/Nobs;
if ~isDet
    V = V*Wt;
end
lamtrue = lamtrue/Nobs;
if  any(~isfinite(V(:))) || any(~isfinite(lamtrue(:)))
    V = inf;
    return
end

% update sqrlam for current residues
if isDet 
    % This is for the det-criterion: The gradient of
    % det(V) is proportional to the gradient of tr(el*inv(V)*el)
    nv0 = V;
    if (isempty(nv0) || (norm(nv0-nv0') > sqrt(eps)) || min(eig(nv0))<=0 )
        nv0 = eye(ny)/Nobs; %todo: scaling suspect
    end
    sqrlam = inv(sqrtm(nv0));
else
    % trace criterion
    % sqrlam remains as before
end

%{
if oeflag==2
    V = e; 
end
%}

if oeflag == 1
    ee = e; %gnnans(ze,par,algorithm,2);
    dat = iddata(ee,[]);
    try
        vmodel = n4sid(dat,3*ny,'cov','none');
        vmodel = pvset(vmodel,'A',oestab(pvget(vmodel,'A'),0.99,1));
        esqr = sqrtm(pvget(vmodel,'NoiseVariance'));
        [av, bv, cv, dv, kv] = ssdata(vmodel); 
        cv1 = cv;
        av = av';
        cv = esqr*kv';
        kv = cv1'*(sqrlam*sqrlam');
        dv = esqr*(sqrlam*sqrlam');
    catch
        av = zeros(1,1);
        cv = zeros(ny,1);
        kv = zeros(1,ny);
        dv = sqrlam;%esqr*(sqrlam*sqrlam)';
    end
    sqrlam = eye(ny); 
end

if nargout<3
    return
end

% *** Prepare for gradients calculations ***
% *** Compute the gradient PSI. If N>M do it in portions ***

rowmax = max(n*ny,nx+nz);
M = floor(maxsize/rowmax);
R1 = zeros(0,n+1);

for kexp = 1:length(ze)
    %{
    if oeflag == 2
        ee{kexp} = zeros(0,ny);
    end
    %}
    z = ze{kexp};
    Ncap = size(z,1);

    if back
        X01 = x0est(z,A,B,C,D,K,ny,nu,maxsize,sqrlam);
        nobs = nobs - length(X01)/ny;
    end

    for kc=1:M:Ncap
        jj = (kc:min(Ncap,kc-1+M));
        if jj(length(jj))<Ncap,
            jjz = [jj,jj(length(jj))+1];
        else
            jjz = jj;
        end
        psi = zeros(ny*length(jj),n);
        if kc == 1
            X0 = X01;
        end
        x = ltitr(A-K*C,[K B-K*D],z(jjz,:),X0);
        e = z(jj,1:ny)-x(1:length(jj),:)*C.'-z(jj,ny+1:end)*D.';
        [nxr,nxc] = size(x);
        X0 = x(nxr,:).';
        if lim==0
            el = e;
        else
            ll = ones(length(jj),1)*lim;
            la = abs(e)+eps*ll;
            regul = sqrt(min(la,ll)./la);
            llrder = find(regul~=1);
            regulder = regul;
            regulder(llrder) = regul(llrder)/2;
            el = e.*regul;
        end
        %{
        if oeflag == 2
            ee{kexp} = [ee{kexp};el];
        end
        %}
        if grest
            elt = el*sqrlam;
            evec = elt(:);
            kkl = 1;
            An = modarg.as';%An';
            Nrna = find(isnan(An(:)));
            zv = zeros(nx*nx,1);
            for ka = Nrna'
                zv(ka) = 1;
                dA = reshape(zv,nx,nx)';
                zv(ka) = 0;
                if kc==1
                    if back
                        x0p = x0est(z,A+step*dA,B,C,D,K,ny,nu,maxsize,sqrlam);
                        dX = (x0p-X01)/step;
                    else
                        dX = zeros(nx,1);
                    end
                else
                    dX = dXk(:,kkl);
                end
                psix = ltitr(A-K*C,dA,x,dX);
                [rpsix,cpsix] = size(psix);
                dXk(:,kkl) = psix(rpsix,:)';
                psitemp = (C*psix(1:length(jj),:).').';
                if ~(lim==0)
                    psitemp = psitemp.*regulder;
                end
                psitemp = psitemp*sqrlam;

                if oeflag
                    psitemp1 = ltitr(av,kv,psitemp(end:-1:1,:));
                    psitemp = psitemp1*cv.'+ psitemp(end:-1:1,:)*dv.';
                end
                psi(:,kkl) = psitemp(:);kkl=kkl+1;
            end
            Bn = modarg.bs';%Bn';
            Nrnb = find(isnan(Bn(:)));
            zv = zeros(nx*nu,1);
            for ka = Nrnb'
                zv(ka) = 1;
                dB = reshape(zv,nu,nx)';
                zv(ka) = 0;
                if kc==1,
                    if back
                        x0p = x0est(z,A,B+step*dB,C,D,K,ny,nu,maxsize,sqrlam);
                        dX = (x0p-X01)/step;
                    else
                        dX = zeros(nx,1);
                    end
                else
                    dX = dXk(:,kkl);
                end
                psix = ltitr(A-K*C,dB,z(jjz,ny+1:ny+nu),dX);
                [rpsix,cpsix] = size(psix);
                dXk(:,kkl) = psix(rpsix,:)';
                psitemp = (C*psix(1:length(jj),:).').';
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
            Cn = modarg.cs;%Cn';
            Nrnc = find(isnan(Cn(:)));
            zv = zeros(ny*nx,1);
            for ka = Nrnc'
                zv(ka) = 1;
                dC = reshape(zv,nx,ny)';
                zv(ka) = 0;
                if kc==1,
                    if back
                        x0p = x0est(z,A,B,C+step*dC,D,K,ny,nu,maxsize,sqrlam);
                        dX = (x0p-X01)/step;
                    else
                        dX = zeros(nx,1);
                    end
                else
                    dX = dXk(:,kkl);
                end
                psix = ltitr(A-K*C,-K*dC,x,dX);
                [rpsix,cpsix] = size(psix);
                dXk(:,kkl) = psix(rpsix,:)';
                psitemp = (C*psix(1:length(jj),:).' + dC*x(1:length(jj),:).').';

                if ~(lim==0)
                    psitemp = psitemp.*regulder;
                end

                psitemp = psitemp*sqrlam;
                if oeflag
                    psitemp1 = ltitr(av,kv,psitemp(end:-1:1,:));
                    psitemp = psitemp1*cv.'+psitemp(end:-1:1,:)*dv.';
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
                if kc==1
                    if back
                        x0p = x0est(z,A,B,C,D+step*dD,K,ny,nu,maxsize,sqrlam);
                        dX = (x0p-X01)/step;
                    else
                        dX = zeros(nx,1);
                    end
                else
                    dX = dXk(:,kkl);
                end

                psix = ltitr(A-K*C,-K*dD,z(jjz,ny+1:ny+nu),dX);
                [rpsix,cpsix] = size(psix);
                dXk(:,kkl) = psix(rpsix,:)';
                psitemp = (C*psix(1:length(jj),:).' + ...
                    [zeros(ny,ny),dD]*z(jj,:).').';

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
            Kn = modarg.ks';%Kn';
            Nrnk = find(isnan(Kn(:)));
            zv = zeros(ny*nx,1);
            for ka = Nrnk'
                zv(ka) = 1;
                dK = reshape(zv,ny,nx)';
                zv(ka) = 0;
                if kc==1,
                    if back
                        x0p = x0est(z,A,B,C,D,K+step*dK,ny,nu,maxsize,sqrlam);
                        dX = (x0p-X01)/step;
                    else
                        dX = zeros(nx,1);
                    end
                else
                    dX = dXk(:,kkl);
                end
                psix = ltitr(A-K*C,[-dK*C,dK,-dK*D],[x,z(jjz,:)],dX);
                [rpsix,cpsix] = size(psix);
                dXk(:,kkl) = psix(rpsix,:)';
                psitemp = (C*psix(1:length(jj),:).').';
                if ~(lim==0)
                    psitemp = psitemp.*regulder;
                end
                psitemp = psitemp*sqrlam;
                if oeflag
                    psitemp1 = ltitr(av,kv,psitemp(end:-1:1,:));
                    psitemp = psitemp1*cv.'+psitemp(end:-1:1,:)*dv.';
                end
                psi(:,kkl) = psitemp(:);kkl=kkl+1;
            end

            if ~back
                Nrnx = find(isnan(modarg.x0s(:)));
                zv = zeros(nx,1);
                for ka = Nrnx'
                    if kc==1
                        dX = zeros(nx,1);
                        dX(ka) = 1;
                    else
                        dX = dXk(:,kkl);
                    end

                    psix = ltitr(A-K*C,zeros(size(A,1),1),zeros(length(jj),1),dX);
                    [rpsix,cpsix] = size(psix);
                    dXk(:,kkl) = psix(rpsix,:)';
                    psitemp = (C*psix(1:length(jj),:).').';
                    if ~(lim==0)
                        psitemp = psitemp.*regulder;
                    end
                    psitemp = psitemp*sqrlam;
                    if oeflag
                        psitemp1 = ltitr(av,kv,psitemp(end:-1:1,:));
                        psitemp = psitemp1*cv.'+psitemp(end:-1:1,:)*dv.';
                    end
                    psi(:,kkl) = psitemp(:);kkl=kkl+1;
                end
            end
            psi = psi(:,index(:)');
            R1 = triu(qr([R1;[psi,evec]]));
            [nRr,nRc] = size(R1);
            R1 = R1(1:min(nRr,nRc),:);
        end
    end % loop
    %Nobs = Nobs +nobs;
end %kexp

R = R1(1:n+1,1:n);
Re = R1(1:n+1,n+1);

if any(~isfinite(V(:))) || any(~isfinite(R1(:)))
    V = Inf;
    R =[];
    Re =[];
end

%{
if oeflag ==2
    V = ee;
end
%}

