function m = pem_f(data,m0,varargin)
%PEM_F Frequency domain data version of IDPOLY/PEM
%
%   Auxiliary routine to IDPOLY/PEM

%	L. Ljung 10-1-02,
%	Copyright 1986-2008 The MathWorks, Inc.
%	$Revision: 1.10.4.9 $  $Date: 2009/12/07 20:42:31 $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First check that the orders are OK for FD data:
if m0.na
    ctrlMsgUtils.warning('Ident:estimation:OEModelFreqData1')
    
    if isempty(pvget(m0,'ParameterVector'))
        m0.nf = m0.na+m0.nf;
        m0.na = 0;
    else
        a = pvget(m0,'a'); f = pvget(m0,'f');
        
        ff = zeros(size(f,1),size(f,2)+length(a)-1);
        for ku=1:size(f,1)
            ff(ku,:)=conv(a,f(ku,:));
        end
        m0 = pvset(m0,'f',ff,'a',1);
    end
    
end
if  any(m0.nc>0 | m0.nd>0) 
    ctrlMsgUtils.warning('Ident:estimation:OEModelFreqData2')
    m0 = pvset(m0,'na',0,'nc',0,'nd',0);
end

idm = pvget(m0,'idmodel');
algorithm = pvget(idm,'Algorithm'); 
Ts = pvget(idm,'Ts');
tr = pvget(m0,'Display');

% Next examine the data
[ny,nu] = size(m0);
[N,nyd,nud] = size(data);
if nyd~=1 || nud~=nu
    ctrlMsgUtils.error('Ident:general:modelDataDimMismatch')
end
Ne = get(data,'Ne');
Tsdat = pvget(data,'Ts'); 

% FILTER AND SHIFT DATA IF NECESSARY
foc = algorithm.Focus;
stabenf = false;
if ~isempty(foc)
    if ischar(foc) 
        if any(strcmpi(foc,{'simulation','stability'}))
            stabenf = true;
        end 
    else
        foc = foccheck(foc,Tsdat{1},[],'f');
        data = idfilt(data,foc); % exceptional case of cellarray of length==Ne=2=4
    end
end

realflag = realdata(data);
data = complex(data); %%LL

% Now data checks and data massaging are finished
%%%%%

% Set up for the initial state (estimate, backcast or zero)
inistate = pvget(m0,'InitialState');
eflag = false;
iniwasa = false;
if strncmpi(inistate,'a',1) %% always estimate without test
    iniwasa = true;
    inistate = 'Estimate'; 
end

if Ne>1 && (strcmpi(inistate,'Estimate'))
    ctrlMsgUtils.warning('Ident:estimation:X0EstMultiExp1');
    inistate = 'Backcast';
    m0.InitialState = 'Backcast';
end

par = pvget(m0,'ParameterVector');
% If 'e' and fixpar move to 'b'
fixp = pvget(m0,'FixedParameter');

% Backcast if fixedpar is set
if ~isempty(fixp) && any(strncmpi(inistate,{'e','a'},1)) %estimate or auto
    if strncmpi(inistate,'e',1)
        ctrlMsgUtils.warning('Ident:estimation:X0EstFixedPar')
    end
    inistate = 'Backcast';
    m0 = pvset(m0,'InitialState','BackCast');
end

% If 'auto' and an idfrd-conversion change to 'z'. 
% If 'e' give a warning and use 'Zero'.
if any(strncmpi(inistate,{'e','a','b'},1))
    ut = pvget(data,'Utility');
    if isfield(ut,'idfrd') && ut.idfrd
        if ~iniwasa %lower(inistate(1))=='a'
            ctrlMsgUtils.warning('Ident:estimation:X0EstFreqData')
        end
        inistate = 'Zero';
    end
end

%%Check if number of data will support estimation of initial values
Ncap = sum(N);
if Tsdat{1}==0
    m0.nk = zeros(size(m0.nk));
end

nxx = max(m0.nf,m0.nb+m0.nk-ones(size(m0.nk)));
nx = sum(nxx);
npar = nx+sum(m0.nb)+sum(m0.nf);

if npar>Ncap
    if (npar-nx)>Ncap
        ctrlMsgUtils.error('Ident:estimation:tooFewSamples')
    end
    if strncmpi(inistate,'e',1) && ~iniwasa
        ctrlMsgUtils.warning('Ident:estimation:X0EstTooFewData');
    end
    inistate = 'Zero';
    m0.InitialState = 'Zero';
end


if any(strncmpi(inistate,{'e','a'},1)) ||...
        (strncmpi(inistate,'b',1) && isempty(par)) %LL Problem då par ej empty och back

    if strcmpi(tr,'full')
        disp('Adding extra input to model to facilitate initial state estimation...')
    end
    
    [data,m0] = LocalAddInput(data,m0,Tsdat,Ne,par,nu,nx);
    idm = pvget(m0,'idmodel');
    eflag = true;
end

%%LL Pname is mixed up in the above
% Now initial state is finished

% Estimate initial state if par is empty (new model)
Inpd = pvget(m0,'InputDelay');
dats = nkshift(data,Inpd);

[ze,Ne,ny,nu,Tsdata,Name,Ncaps,errflag,ynorm] = idprep_fp(dats,0);
if ~isempty(errflag.message), error(errflag), end
if ~isempty(Name), dats.Name = Name; end
%error(errflag)
if ischar(algorithm.MaxSize)
    algorithm.MaxSize = idmsize(max(Ncaps),sum([m0.na,m0.nb,m0.nc,m0.nd,m0.nf]));
end

if abs(Ts-Tsdata)>10*eps
    ctrlMsgUtils.warning('Ident:estimation:modelDataTsMismatch',...
        sprintf('%f',Ts),sprintf('%f',Tsdata),sprintf('%f',Tsdata))

    m0 = pvset(m0,'Ts',Tsdata);
end

par = pvget(idm,'ParameterVector');
parempt = false;

if isempty(par)
    parempt = true;
    mcov = pvget(m0,'CovarianceMatrix');
    
    % Estimate initial states separately
    %try
    m0 = inival_f(dats,m0,eflag,realflag);
    %end
    if stabenf
        % why not always stabilize initial model (r.s., sep 28, 2007)?
        Ts = pvget(m0,'Ts');
        if Ts>0
            thresh = algorithm.Advanced.Threshold.Zstability;
        else
            thresh = algorithm.Advanced.Threshold.Sstability;
        end
        m0 = pvset(m0,'f',fstab(pvget(m0,'f'),Ts,thresh));
    end
    
    if ischar(mcov)
        m0 =  pvset(m0,'CovarianceMatrix','None');
    end

    par = pvget(pvget(m0,'idmodel'),'ParameterVector');
    
    if strncmpi(inistate,'b',1) % remove the extra model
        nu = size(m0,'nu');
        lsub.type = '()';
        lsub.subs = {1, 1:nu-1};
        m0 = subsref(m0,lsub);
        eflag = false;
        m0 = pvset(m0,'InitialState','backcast');
        nu = nu-1;
        for kexp = 1:length(ze);
            ze{kexp} = ze{kexp}(:,[1:nu+1,nu+3]); 
        end
        par = pvget(m0,'ParameterVector');
    end
end

%paini = par;
fixflag = false;
fixp = pvget(m0,'FixedParameter');
if ~isempty(fixp)
    fixflag = true;
    if (iscell(fixp) || ischar(fixp)) && isempty(pvget(m0,'PName'))
        m0 = setpname(m0);
        %idm = pvget(m0,'idmodel');
        fixp = pnam2num(fixp,pvget(m0,'PName'));
    end
end
if fixflag && parempt
    par(fixp) = zeros(length(fixp),1);
    m0 = parset(m0,par);
end

estinfo = pvget(m0,'EstimationInfo');
estinfo.Misc = struct('eflag',eflag,'realflag',realflag,'init',inistate);
m0 = pvset(m0,'EstimationInfo',estinfo);

%%%%
% *** Minimize the prediction error criterion ***
Estimator = createEstimator(m0,ze);
OptimInfo = minimize(Estimator);

% update the model with the set of new values for states and parameters
m = updatemodel(m0, dats, OptimInfo, Estimator);
m = setdatid(m,getid(data),ynorm);
m = timemark(m);
%%%%

%--------------------------------------------------------------------------
function [z,sys] = LocalAddInput(z,sys,Tsdat,Ne,par,nu,nx)
% Add an extra input channel to data and model objects in order to
% facilitate estimation of initial states

uold = pvget(z,'InputData');
fre = pvget(z,'Radfreqs');
inters = pvget(z,'InterSample');

for kexp = 1:Ne
    u{kexp} = [uold{kexp},exp(i*fre{kexp}*Tsdat{kexp})];
    inters{nu+1,kexp} = 'zoh';
end

z = pvset(z,'InputData',u,'InterSample',inters);
if isempty(par) % modify orders for extra input
    sys = pvset(sys,...
        'nb',[sys.nb nx],...
        'nf',[sys.nf nx],...
        'nk',[sys.nk 1],...
        'InputDelay',[pvget(sys,'InputDelay');0],...
        'InitialState','z');
else
    b = pvget(sys,'b');
    f = pvget(sys,'f');
    ford = sum(sys.nf);
    Tsmodel = pvget(sys,'Ts');
    fi = zeros(1,ford+1);
    fi(1) = 1;
    fi(end) = 0.9;% To avoid division by zero at start
    fi = fstab(fi,Tsmodel);
    bi = zeros(1,ford+1);
    bi(2:end) = eps*ones(1,ford);

    ff = idextmat(f,fi,Tsmodel);
    bb = idextmat(b,bi,Tsmodel);
    sys = pvset(sys,'b',bb,'f',ff,...
        'InputDelay',[pvget(sys,'InputDelay');0],...
        'InitialState','z');
end
