function option = configureOptimizationOptions(sys, algo, option, optimizer)
%CONFIGUREOPTIMIZATIONOPTIONS Configure model specific options to be used
%with given optimizer.
%   OPTION: struct used by estimator containing algorithm properties.
%   SYS:    IDPOLY model the estimator is working on. Properties of SYS may
%           be modified locally for estimation purposes. Such modification
%           are temporary and are not returned as final result to user
%           (e.g., Focus, MaxSize, InitialState changes based on data).

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.8 $ $Date: 2009/10/16 04:55:34 $

option = commonOptimConfig(sys, algo, option);

[ny,nu] = size(sys);

% Assemble "struc" (required for Jacobian computation)
struc.type = 'poly';
struc.na = sys.na;
struc.nb = sys.nb;
struc.nc = sys.nc;
struc.nd = sys.nd;
struc.nf = sys.nf;
struc.nk = sys.nk;

Nbcum  = struc.na + sum(struc.nb);
Nccum  = Nbcum + struc.nc;
Ndcum  = Nccum+struc.nd;
Nfcum  = Ndcum+sum(struc.nf);
struc.nai = 1:struc.na;
struc.nci = Nbcum+1:Nccum;
struc.ndi = Nccum+1:Ndcum;
struc.T = pvget(sys,'Ts');

s = 1; s1 = 1;
for ku = 1:nu
    struc.nbi(ku) = {struc.na+s:struc.na+s+struc.nb(ku)-1};
    struc.nfi(ku) = {Ndcum+s1:Ndcum+struc.nf(ku)+s1-1};
    s  = s+struc.nb(ku);
    s1 = s1+struc.nf(ku);
end

% deconstruct Data for efficiency
% todo: why pass iddata at all? set model.es.DataDomain and use it for
% domain-specific initializations
z = optimizer.Data;
if isa(z,'iddata')
    y = pvget(optimizer.Data,'OutputData');
    u = pvget(optimizer.Data,'InputData');
    ze = cell(1,length(y));
    for k = 1:length(y)
        ze{k} = [y{k},u{k}];
    end
    optimizer.Data = ze;
end

Ne = length(option.DataSize); % number of experiments
Ncaps = option.DataSize;
struc.ny = ny; 
struc.nu = nu; 
struc.Ne = Ne;
struc.init = sys.InitialState;
if ischar(pvget(sys,'CovarianceMatrix'))
    struc.cov = false;
else
    struc.cov = true;
end

par = getParameterVector(sys);
struc.Npar = length(par); %total number of parameters (no states)
fixp = pvget(sys,'FixedParameter');
struc.pname = pvget(sys,'PName');

% Process initial states
if Ne>1 && (strcmpi(struc.init,'Estimate'))
    ctrlMsgUtils.warning('Ident:estimation:invalidInitialState1')
    struc.init = 'Backcast';
end

% Domain-specific tweaks
if isa(z,'iddata') && strcmpi(z.Domain,'time')
    % time domain data
    struc.domain = 'time';
    
    if (Ne==1) && strcmpi(struc.init,'Backcast') && (struc.nc+sum(struc.nf)==0)
        ctrlMsgUtils.warning('Ident:estimation:invalidInitialState2')
        struc.init = 'Estimate';
    end

    if strcmp(struc.init,'Auto')
        if Ne>1
            struc.init = 'Backcast';
        else
            e1 = pe(ze,sys,'z');
            %e1 = pvget(e1,'OutputData');
            [e2,xi] = pe(ze,sys,'e');
            %e2 = pvget(e2,'OutputData');
            nor1 = norm(e1);
            nor2 = norm(e2);
            if nor1/nor2 > algo.Advanced.Threshold.AutoInitialState
                struc.init = 'Backcast';
            else
                struc.init = 'Zero';
            end
        end
    end

    % compute initial noise variance and states
    if strncmpi(struc.init,'e',1)
        [e,X0] = pe(ze,sys);
        if isempty(X0)
            ctrlMsgUtils.warning('Ident:estimation:NoStates')
            struc.init = 'Zero';
        end
        struc.xi = Nfcum+1:Nfcum+length(X0);
        %par = [par; X0];
        struc.X0 = X0;
    else
        e = pe(ze,sys);
        struc.xi = [];
        struc.X0 = [];
    end

    lim = algo.LimitError;
    struc.realflag = realdata(z);
else
    % frequency domain data
    struc.domain = 'frequency';
    lim = 0; %limit error is not meaningful for frequency domain data
    estinfo = pvget(sys,'EstimationInfo');
    Misc = estinfo.Misc;
    was = ctrlMsgUtils.SuspendWarnings;
    peini = 'e';
    if strncmpi(Misc.init,'z',1)
        peini = 'z';
    end
    try
        e = pe_f(z,idss(sys),peini,1,Misc.realflag);
    catch E
        if strcmp(E.identifier,'Ident:analysis:ssdataImproperModel')
            ctrlMsgUtils.error('Ident:estimation:ImproperCTModel')
        else
            rethrow(E)
        end
    end
    delete(was)
    struc.xi = [];
    struc.X0 = []; %always true for frequency domain data
    struc.type = 'poly';
    struc.realflag = Misc.realflag;
end

% OE flag
oeflag = false;
if struc.na+struc.nc+struc.nd==0
    oeflag = true;
end
struc.oeflag = oeflag;

% todo: why is e returned as a single vector in case of multi-exp data,
% expressed as cell array with Nexp matrices?
Ncape = length(e);
struc.lambda = e'*e/Ncape;
if ~all(isfinite(struc.lambda(:))) || ~any(struc.lambda(:))
    struc.lambda = eye(size(struc.lambda));
end

% Process fixed parameters
struc.fixparind = [];
if ~isempty(fixp)
    fixflag = true;
    if (iscell(fixp) || ischar(fixp))
        fixp = pnam2num(fixp, pvget(sys,'PName')); %assuming Pname is not empty
    end
    struc.fixparind = fixp;
end

% Fix LimitError
if lim~=0
    lim = median(abs(e-ones(Ncape,1)*median(e)))*lim/0.7;
end

option.LimitError = lim;

% fix MaxSize and Focus
if ischar(algo.MaxSize)
    option.MaxSize = idmsize(max(Ncaps),sum([struc.na,struc.nb,...
        struc.nc,struc.nd,struc.nf]));
end

% Calculate Nobs
if strcmpi(struc.domain,'time')
    switch lower(struc.init(1))
        case 'z'
            ni   = max([struc.na+struc.nd-1, struc.nb+struc.nd-2, struc.nf+struc.nc-2, 1]);
            Nobs = sum(Ncaps)-Ne*(ni+sum([struc.na, struc.nb, struc.nc, struc.nd, struc.nf]));
        case 'b'
            tstart = 1+max([struc.na, struc.nb+struc.nk-1]);
            tstart = max(tstart,max([struc.nk,1])+2);
            Nobs   = sum(Ncaps)-(tstart-1)*Ne;
        case 'e'
            % (never true for multi-exp data)
            Nobs = sum(Ncaps);
    end
else
    Nobs = sum(Ncaps);
end
struc.Nobs = Nobs;

% Add "struc" to option
option.struc = struc;
