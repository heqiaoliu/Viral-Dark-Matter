function option = configureOptimizationOptions(sys, algo, option, varargin)
%CONFIGUREOPTIMIZATIONOPTIONS Configure model specific options to be used
%with given optimizer.
%   OPTION: struct used by estimator containing algorithm properties.
%   SYS:    IDGREY model the estimator is working on. Properties of SYS may
%           be modified locally for estimation purposes. Such modification
%           are temporary and are not returned as final result to user
%           (e.g., Focus, MaxSize, InitialState changes based on data).

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.8 $ $Date: 2009/12/07 20:42:26 $

option = commonOptimConfig(sys, algo, option);
[ny,nu] = size(sys);

% Set up the struc fields
es = pvget(sys,'EstimationInfo');
init = es.InitialState;
ftdom = lower(es.DataDomain(1));
Tsdata = es.DataTs;
%Ts = pvget(sys,'Ts');
struc.init = init;
struc.oeflag = false;
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

struc.model = sys;
struc.type = 'ssgen';
struc.modT = Tsdata;
lambda = pvget(sys,'NoiseVariance');
if ~any(lambda(:)) || ~all(isfinite(lambda(:))) || norm(lambda)<eps || any(eig(lambda)<=0)
    %% This is to protect from strange initial model
    lambda = eye(size(lambda));
end
struc.lambda = lambda;
struc.ny = ny;
struc.nu = nu;

% set oeflag
sys1 = parset(sys,randn(struc.Npar,1)); % sys1 need not be saved
%todo: a random parameter set may not work with specified ODE file.
try
    if norm(pvget(sys1,'K'))==0
        struc.oeflag = true;
    end
catch E
    %{
    ctrlMsgUtils.error('Ident:idmodel:idgreySSDataCheck3',...
        pvget(sys1,'MfileName'),mat2str(pvget(sys1,'ParameterVector')),E.message)
    %}
    %assume false
    struc.oeflag = false;
end

% IDPROC handling
if strcmp(pvget(sys,'MfileName'),'procmod')
    arg = pvget(sys,'FileArgument');
    dnr = arg{6}; %parameter numbers for the delay parameters
    bnr = arg{7}; %parameter number and bounds [dn-by-3]
    struc.dflag = dnr;
    if ~isempty(bnr)
        struc.bounds = bnr;
    end
end

intd = es.Misc.intd;
struc.intersample = intd;
if strcmp(sys.CDmfile,'c')
    struc.Tflag = 1; % Sample system (not if bl though)
    if strcmp(intd,'bl'),
        if Tsdata
            ctrlMsgUtils.warning('Ident:estimation:BLFreqDataForCTModel',...
                sprintf('%g',Tsdata))
        end
        struc.Tflag = 0; % No sampling
        struc.modT = 0;  % CT model
    end
else
    struc.Tflag = 0;
end
struc.domain = ftdom;

Ncaps = option.DataSize;
Ne = length(Ncaps); % number of experiments
struc.Ne = Ne;
struc.Nobs = sum(Ncaps);

% Process fixed parameters
struc.fixparind = [];
if ~isempty(fixp)
    %fixflag = true;
    if (iscell(fixp) || ischar(fixp))
        fixp = pnam2num(fixp, pvget(sys,'PName')); %assuming Pname is not empty
    end
    struc.fixparind = fixp;
end

% Add "struc" to option
option.struc = struc;

% fix MaxSize and Focus
%par = pvget(sys,'ParameterVector');
if ischar(algo.MaxSize)
    option.MaxSize = idmsize(max(Ncaps),struc.Npar);
end
