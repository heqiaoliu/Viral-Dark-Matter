function option = configureOptimizationOptions(sys, algo, option, varargin)
%CONFIGUREOPTIMIZATIONOPTIONS Configure model specific options to be used
%with given optimizer.
%   OPTION: struct used by estimator containing algorithm properties.
%   SYS:    IDSS model the estimator is working on. Properties of SYS may
%           be modified locally for estimation purposes. Such modification
%           are temporary and are not returned as final result to user
%           (e.g., Focus, MaxSize, InitialState changes based on data).

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2009/03/09 19:13:53 $

option = commonOptimConfig(sys, algo, option);
[ny,nu] = size(sys);

% Set up the struc fields
es = pvget(sys,'EstimationInfo');
init = es.InitialState;
ftdom = lower(es.DataDomain(1));
Tsdata = es.DataTs;
Ts = pvget(sys,'Ts');
struc.init = init;
struc.Qperp = []; %initialize Qperp field
struc.oeflag = 0;
struc.realflag = es.Misc.realflag;

% handle fixed parameters
fixp = pvget(sys,'FixedParameter');
par = getParameterVector(sys);
struc.Npar = length(par);
struc.pname = pvget(sys,'PName');

if ischar(pvget(sys,'CovarianceMatrix'))
    struc.cov = false;
else
    struc.cov = true;
end

sspar = sys.SSParameterization;
%{
if ~isa(Estimator,'idestimatorpack.idminimizer') && strcmpi(sspar,'free')
    % only idminimizer can handle free parameterization
    sspar = 'Structured';
end
%}

if strcmp(sspar,'Free')
    struc.type = 'ssfree';
elseif (strcmp(sspar,'Structured') || strcmp(sspar,'Canonical')) && (Ts>0)
    struc.type = 'ssnans';
else 
    struc.type = 'ssgen';
end

lambda = pvget(sys,'NoiseVariance');
if ~any(lambda(:)) || ~all(isfinite(lambda(:))) || norm(lambda)<eps || any(eig(lambda)<=0)
    %% This is to protect from strange initial model
    lambda = eye(size(lambda));
end
struc.lambda = lambda;

struc.ny = ny;
struc.nu = nu;

switch struc.type
    case {'ssnans','ssgen'}
        struc.filearg = struct('as',sys.As, 'bs',sys.Bs, 'cs',sys.Cs, ...
            'ds',sys.Ds, 'ks',sys.Ks, 'x0s',sys.X0s);

        if strcmp(struc.type,'ssnans')
            struc.modT = -1;
        else
            struc.modT = Tsdata;
            struc.intersample = es.Misc.intd;
            struc.Tflag = 1;
            struc.mfile = 'ssmodxx';
            struc.model = sys;
        end

    case 'ssfree'
        option.ComputeProjFlag = true;

        if Ts==0
            struc.modT = 0;
        else
            struc.modT = -1;
        end

        dkx = [0,0,0];
        if any(isnan(sys.X0s)) && ~strcmp(struc.init,'Backcast')
            dkx(3) = 1;
        end
        if any(any(isnan(sys.Ks))')
            dkx(2) = 1;
        end
        if any(any(isnan(sys.Ds))')
            dkx(1) = 1;
        end

        struc.dkx = dkx;
        [a,b,c,d,k,x0] = ssdata(sys);
        nk = es.Misc.nk; %original nk
        struc.a = a;
        struc.b = b;
        struc.c = c;
        struc.d = d;
        struc.k = k;
        struc.x0 = x0; %%xi??
        %struc.nu = size(b,2);
        struc.nx = size(a,1);
        %struc.ny = size(c,1);
        struc.nk = (nk>0);
end

% set oeflag
switch struc.type
    case 'ssnans'
        if ~any(any(isnan(struc.filearg.ks))')
            if norm(struc.filearg.ks)==0
                struc.oeflag = 1;
            end
        end
    case 'ssgen'
        %m0 = struc.model;
        lnp = length(pvget(sys,'ParameterVector'));
        sys = parset(sys,randn(lnp,1));
        if norm(pvget(sys,'K'))==0
            struc.oeflag = 1;
        end
end

struc.domain = es.DataDomain;
Ncaps = option.DataSize;
Ne = length(Ncaps); % number of experiments
struc.Ne = Ne;

% calculate Nobs
Nobs = sum(Ncaps);
if strncmpi(struc.init,'b',1) && ~strcmp(struc.type,'ssgen')
    A = pvget(sys,'A');
    Nobs = Nobs - size(A,1)*Ne/ny;
end
struc.Nobs = Nobs;

% Process fixed parameters
struc.fixparind = [];
if ~isempty(fixp)
    fixflag = true;
    if (iscell(fixp) || ischar(fixp))
        fixp = pnam2num(fixp, pvget(sys,'PName')); %assuming Pname is not empty
    end
    struc.fixparind = fixp;
end

% compute a data-driven projection
if option.ComputeProjFlag
    Qp = utComputeProjection(struc);
    struc.Qperp = Qp;
    struc.Npar = size(Qp,2);
end

% Add "struc" to option
option.struc = struc;

% fix MaxSize and Focus
par = pvget(sys,'ParameterVector'); 
if ischar(algo.MaxSize)
    option.MaxSize = idmsize(max(Ncaps),length(par));
end
