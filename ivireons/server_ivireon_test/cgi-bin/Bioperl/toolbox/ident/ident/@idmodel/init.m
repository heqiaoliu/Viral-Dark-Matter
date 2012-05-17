function eta=init(eta0,R,par,sp)
%INIT Initial parameter values for iterative estimation.
%   M = INIT(M0) or M = INIT(M0,R,PAR,SP)
%
%   M0:Original model as any IDMODEL object (IDPOLY, IDSS, IDARX or IDGREY)
%   M: Modified M0 with new initial parameter values
%   R: variance of random initial parameters
%      (row vector with dim = dimension of parameter vector)
%      A scalar R gives the same variance R to all parameters.
%      Setting R = 0 just stabilizes M0 if that is possible within the
%      parameterization.
%   PAR: mean of initial parameters (PAR = [] gives default)
%   SP: SP='p' : stability of predictor is assured
%       SP='s' : stability of system is assured
%       SP='b' : both predictor and system will be stable
%
%   Defaults: SP='p', PAR = the parameter values of M0, R = 1.

%   L. Ljung 10-2-1990,9-26-1993
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.6.4.8 $ $Date: 2008/10/02 18:48:12 $

if nargin < 1
    disp('Usage: MI = INIT(M0)')
    disp('       MI = INIT(M0,VARIATION,NOMINAL_GUESS,STABILITY)')
    disp('       STABILITY is one of ''p'', ''s'', ''b''.')
    return
end
parvec = eta0.ParameterVector;
adv = pvget(eta0,'Advanced');
Zstab = adv.Threshold.Zstability;
Sstab = adv.Threshold.Sstability;
nd = length(parvec);
Ts = eta0.Ts;
if Ts
    Tstab = Zstab;
else
    Tstab = Sstab;
end
if nargin<2;R=[];end
if nargin<3;par=[];end
if nargin<4;sp=[];end

if isempty(R),
    R = ones(nd,1);
end,
if isempty(sp),
    sp = 'p';
elseif ~ischar(sp) || ~any(strcmpi(sp,{'p','s','b'}))
    ctrlMsgUtils.error('Ident:transformation:initCheck1')
end
if isempty(par),
    par = parvec;
end
par = par(:);
if length(R)==1
    R = R*ones(1,nd);
end

if length(R)~=nd
    ctrlMsgUtils.error('Ident:transformation:initCheck2')
end
if length(par)~=nd
    ctrlMsgUtils.error('Ident:transformation:initCheck3')
end

test = 2; nr = 1;
if norm(R)==0
    noR = 1;
else
    noR = 0;
end

projk = 0; proja = 0;

if isa(eta0,'idss')
    if strcmp(pvget(eta0,'SSParameterization'),'Free')
        if strcmp(pvget(eta0,'DisturbanceModel'),'Estimate') && (sp=='b' || sp=='p')
            projk = 1;
        end
        if (sp=='s' || sp=='b') || (strcmp(pvget(eta0,'DisturbanceModel'),'None') && sp=='p')
            proja = 1;
        end
    end
end
while ~isempty(test) && test && nr<200
    parval=diag(sqrt(R))*randn(nd,1)+par;
    eta  = parset(eta0,parval);
    if isa(eta0,'idpoly') && (sp=='s' || sp=='b')
        eta=pvset(eta,'a',fstab(get(eta,'a'),Ts,Tstab));
        eta=pvset(eta,'f',fstab(get(eta,'f'),Ts,Tstab));
        eta=pvset(eta,'d',fstab(get(eta,'d'),Ts,Tstab));

    end
    if isa(eta0,'idpoly') && (sp=='p' || sp=='b')
        eta=pvset(eta,'c',fstab(get(eta,'c'),Ts,Tstab));
        eta=pvset(eta,'f',fstab(get(eta,'f'),Ts,Tstab));
    end

    [a,b,c,d,k]=ssdata(eta);
    if proja
        a = stab(a,Ts); eta = pvset(eta,'A',a);
    end


    if projk
        if Ts
            if max(abs(eig(a-k*c)))>Zstab
                k = ssssaux('kric',a,c,k*k',eye(size(c,1)),k);
                eta = pvset(eta,'K',k);
            end
        else
            if iscstbinstalled
                if max(real(eig(a-k*c)))>Sstab
                    ny = size(c,1);
                    k = lqe(a,k,c,eye(ny),eye(ny),eye(ny));
                    eta = pvset(eta,'K',k);
                end
            end
        end
    end

    if sp=='s',
        if Ts
            test = max(abs(eig(a)))>Zstab;
        else
            test = max(real(eig(a)))>Sstab;
        end
    elseif sp=='p',
        if Ts
            test = max(abs(eig(a-k*c)))>Zstab;
        else
            test = max(real(eig(a-k*c)))>Sstab;
        end
    else
        if Ts
            test = max([max(abs(eig(a))), max(abs(eig(a-k*c)))])>Zstab;
        else
            test = max([max(real(eig(a))), max(real(eig(a-k*c)))])>Sstab;
        end
    end
    nr=nr+1;
    if nr==200
        ctrlMsgUtils.error('Ident:transformation:stabilizationFailure')
    end
    if noR
        nr = 200;
        if test
            ctrlMsgUtils.warning('Ident:transformation:initUnstablePredictor')
        end
    end
end

%--------------------------------------------------------------------------
function As = stab(A,T)
% stabilize A matrix by flipping the unstable poles

[V,D] = eig(A);
if cond(V)>10^8,
    [V,D] = schur(A);
    [V,D] = rsf2csf(V,D);
end

if T>0
    test = max(abs(diag(D)))<1;
else
    test = max(real(diag(D)))<0;
end

if test
    As = A;
    return
end

[n,n] = size(D);
for kk=1:n
    if T>0
        if abs(D(kk,kk))>1
            D(kk,kk) = 1/D(kk,kk);
        end
    else
        if real(D(kk,kk))>0
            D(kk,kk) = -real(D(kk,kk))+i*imag(D(kk,kk));
        end
    end
end
As = real(V*D*inv(V));
