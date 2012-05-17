function [zz, x0] = predict(sys, data, K, varargin)
% PREDICT computes the k-step ahead prediction with an IDNLARX model.
%
%  YP = PREDICT(MODEL, DATA, K)
%
%  MODEL: the IDNLARX model object.
%  DATA: the output-input data, an IDDATA object.
%  K: prediction horizon. Old outputs up to time t-K are used to
%     predict the output at time t. All relevant inputs are used.
%     (Default K=1).
%
%  YP: the resulting predicted output as an IDDATA object. If DATA
%      contains multiple experiments, so will YP.
%
%  YP = PREDICT(SYS, DATA, K, INIT) or
%  YP = PREDICT(MODEL,DATA,K,'InitialState',INIT) allows to specify the
%      initialization.
%
%  INIT: initialization specification, one of
%
%    - 'e': estimated initial values such that the first predicted outputs
%      match the first output samples in DATA. This the default value. It
%      does not correspond to the initial state minimizing the prediction
%      error, which can be obtained with IDNLARX/FINDSTATES.
%
%    - X0: a real column vector, for the state vector corresponding to an
%      appropriate number of output and input data samples prior to the
%      simulation start time. To build an initial state vector from a given
%      set of input-output data or to generate equilibrium states, see
%      IDNLARX/FINDSTATES and IDNLARX/FINDOP. For multi-experiment DATA,
%      X0 may be a matrix whose columns give different initial states for
%      different experiments.
%
%    - 'z', zero initial state, equivalent to a zero vector of appropriate
%      size.
%
%    - an IDDATA object, containing output and input data samples prior to
%      the simulation start time. If it contains more data samples than
%      necessary, only the last samples are taken into account. This syntax
%      is equivalent to SIM(MODEL, U, 'InitialState', DATA2STATE(MODEL,INIT))
%      where DATA2STATE transforms the IDDATA object INIT to a state
%      vector.
%
%  See also IDNLARX/SIM, IDNLARX/FINDOP, IDNLARX/DATA2STATE,
%  IDNLARX/FINDSTATES.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.10 $ $Date: 2009/10/16 04:56:59 $

% Author(s): Qinghua Zhang

no=nargout; ni=nargin;
error(nargchk(2,inf,ni, 'struct'))

x0 = [];

[xinit, matching, ~, progdisp] = ...
    simpredictoptions({'InitialState', 'Matching'}, {'e', 'z', 'm'}, varargin{:});

if ni<3 || isempty(K)
    K = 1;
elseif ~isposintscalar(K) && ~(isscalar(K)&&isinf(K))
    ctrlMsgUtils.error('Ident:analysis:predictInvalidHorizon')
end

if ~isa(sys,'idnlarx')
    if isa(data,'idnlarx') && (isa(sys,'iddata') || isreal(sys))
        sys1 = data;
        data = sys;
        sys = sys1;
        clear sys1
    else
        ctrlMsgUtils.error('Ident:general:objectTypeMismatch','predict','IDNLARX')
    end
end

if ~isestimated(sys)
    ctrlMsgUtils.error('Ident:utility:nonEstimatedModel','predict','nlarx')
end

na = sys.na;
nb = sys.nb;
nk = sys.nk;
[ny, nu] = size(sys);

% Convert matrix to iddata if necessary.
if isa(data, 'iddata')
    iddataflag = true;
else
    iddataflag = false;
end
[data, errmsg] = datacheck(data, ny, nu);
error(errmsg)

% Get original data size (possibly extract noise data from u)
[nsamp0, nyd, nud, nex] = size(data);
% Note: nyd is already checked in datacheck above.

% Warning on data properties
if iddataflag
    msg = datapropwarns(data, sys, ...
        {'Ts', 'OutputName', 'OutputUnit', 'InputName', 'InputUnit', 'TimeUnit'});
    for km = 1:length(msg)
        warning('Ident:general:dataModelPropMismatch', msg{km})
    end
end

dataT0 =  data.Tstart;

custreg = pvget(sys, 'CustomRegressors');
if isempty(custreg)
    custreg = cell(ny,1);
elseif ~iscell(custreg)
    custreg = {custreg};
end

maxidelay = reginfo(na, nb, nk, custreg);
maxd = max(maxidelay);

allmaxd = getDelayInfo(sys, 'all');
nx = sum(allmaxd);

if maxd==0  %maxd=0 means static model. Process as if K=1.
    K = 1;
end

% Long prediction by simulation
%===============================
if isinf(K)
    if (ischar(xinit) && strcmpi(xinit,'e'))
        xinit = data(1:maxd);
        zz = sim(sys, data, 'matching', xinit);
    elseif matching
        zz = sim(sys, data, 'matching', xinit);
    else
        zz = sim(sys, data, xinit, progdisp);
    end
    
    if ~iddataflag
        zz = zz.y;
    end
    
    if no==0
        utidplot(sys,zz,'Predicted')
        clear zz x0
    end
    return
end
%== End  Long prediction by simulation==

% Initial state processing
if ischar(xinit) && strcmpi(xinit,'z')
    xinit = zeros(nx,1);
end
if maxd==0
    if isrealmat(xinit) && ~isempty(xinit)
        ctrlMsgUtils.warning('Ident:analysis:modelWithNoStates')
    end
    % xinit = [];
elseif ischar(xinit) && strcmpi(xinit,'e')
    % Do nothing
elseif isrealmat(xinit) % Using state vector
    [xir, xic] = size(xinit);
    if nx~=xir
        ctrlMsgUtils.error('Ident:analysis:x0Size', nx)
    end
    if xic~=1 && xic~=nex
        if nex==1
            ctrlMsgUtils.error('Ident:analysis:x0Size', nx)
        else
            ctrlMsgUtils.error('Ident:analysis:x0SizeMultiExp')
        end
    end
    if xic<nex
        xinit = xinit(:,ones(1,nex)); % expand to multi-experiments.
    end
    
    wstatus = warning;
    warning('off','Ident:iddata:MoreOutputsThanSamples');
    warning('off','Ident:iddata:MoreInputsThanSamples');
    
    % Convert to iddata
    zinit = cell(1,nex);
    for kex = 1:nex
        yinit = zeros(maxd, ny);
        uinit = zeros(maxd, nu);
        pt = 0;
        for ky=1:ny
            chs = allmaxd(ky);
            yinit(maxd:-1:(maxd-chs+1),ky) = xinit(pt+1:pt+chs,kex);
            pt = pt + chs;
        end
        for ku=1:nu
            chs = allmaxd(ny+ku);
            uinit(maxd:-1:(maxd-chs+1),ku) = xinit(pt+1:pt+chs,kex);
            pt = pt + chs;
        end
        zinit{kex} = iddata(yinit, uinit);
    end
    if nex>1
        zinit = merge(zinit{:});
    else
        zinit = zinit{1};
    end
    zinit = dataPropCopy(zinit, data);
    % data = [zinit; data];  % Cannot get this line work. Replaced by the following loop.
    cdata = cell(nex,1);
    for kex=1:nex
        cdata{kex} = [getexp(zinit, kex); getexp(data, kex)];
    end
    data = merge(cdata{:});
    clear cdata
    
    warning(wstatus)
    
elseif isa(xinit,'iddata')
    [ininsamp, ininyd, ininud, ininex] = size(xinit);
    if ininyd~=ny
        ctrlMsgUtils.error('Ident:analysis:idnlarxInitIODim')
    end
    
    if nex>1 && ininex==1
        [mxinit{1:nex}] = deal(xinit);
        xinit = merge(mxinit{:});
    elseif nex~=ininex
        ctrlMsgUtils.error('Ident:analysis:idnlarxPredictInitNex')
    end
    
    % if xinit has less than maxd samples, error out
    if min(ininsamp)<maxd
        ctrlMsgUtils.error('Ident:analysis:idnlarxInitNsamp',maxd)
    end
    
    if matching
        % This is the "first values" case.
        
        % if xinit has more than maxd samples, keep the first maxd samples
        if max(ininsamp)>maxd
            xinit = xinit(1:maxd); % This works also for multi-exp
        end
        
        % Match first output values
        ydata = pvget(data, 'OutputData');
        for kex=1:nex  % loop over experiments
            xinitkex = getexp(xinit,kex);
            ydata{kex}(1:maxd,:) = xinitkex.y;
        end
        data = pvset(data, 'OutputData', ydata);
        
    else
        % This is the "past values" case.
        if ininud~=nu
            ctrlMsgUtils.error('Ident:analysis:idnlarxInitIODim')
        end
        
        % Keep the last maxd samples
        TStart = pvget(data,'Tstart');
        Tsdat = pvget(data,'Ts');
        zinit = cell(1,nex);
        for kex = 1:nex
            zinitk = getexp(xinit, kex);
            zinitk.Tstart = TStart{1};
            zinitk.Ts = Tsdat;
            zinitk = zinitk(end-maxd+1:end);
            zinit{kex} = zinitk;
        end
        if nex>1
            zinit = merge(zinit{:});
        else
            zinit = zinit{1};
        end
        
        zinit = dataPropCopy(zinit, data);
        % data = [zinit; data]; % Cannot get this line work. Replaced by the following loop.
        cdata = cell(nex,1);
        for kex=1:nex
            cdata{kex} = [getexp(zinit, kex); getexp(data, kex)];
        end
        data = merge(cdata{:});
        clear cdata
    end
    
else
    ctrlMsgUtils.error('Ident:analysis:idnlmodelINITval','predict','idnlarx/predict')
end
%End of Initial state processing

% Compute ycustind, the indices of the custom regressors involving output
% and mxind, the indices in mxdata corresponing to customreg function arguments.
nstandreg = sum([na, nb], 2);
custregflagvec = false(ny,1);
ycustind = cell(ny,1);
mxind = cell(ny,1);
xcell = cell(ny,1);
for ky=1:ny
    if ~isempty(custreg{ky}) && isa(custreg{ky},'customreg')
        custregflagvec(ky) = true;
        ncr = numel(custreg{ky});
        yflag = false(1,ncr); % For row vectors ycustind{ky}, (1,ncr) instead of (ncr,1)
        xcell{ky} = cell(ncr,1);
        mxind{ky} = cell(ncr,1);
        for kcr=1:ncr
            if any(custreg{ky}(kcr).ChannelIndices<=ny)
                yflag(kcr) = true;
                mxind{ky}{kcr} = sub2ind([maxd+1, ny+nu], ...
                    maxd+1-custreg{ky}(kcr).Delays, ...
                    custreg{ky}(kcr).ChannelIndices);
            end
        end
        ycustind{ky} =  find(yflag);
    end
end

% Xyind is the indices of entries of Xydata used to update Xregmat at each iteration.
% In the MO case, linear index is used instead of subscripts, since the entries do not
% form a sub-matrix of Xydata.
Xyind = cell(ny,1);
Xindsamp = 1+maxd;
for ky=1:ny
    Xyind{ky} = zeros(1, sum(na(ky,:),2));
    pt = 0;
    for kky=1:ny
        nseq = 1:na(ky,kky);
        Xyind{ky}(:,pt+nseq) = Xindsamp(:,ones(1,na(ky,kky))) - nseq ...
            + maxd*(kky-1);  % This is to convert subscripts to linear index
        pt = pt+na(ky,kky);
    end
end

zdata = cell(nex,1);

for kex=1:nex
    datakex = getexp(data,kex);
    nsampkex = size(datakex,1);
    ydata = datakex.y;
    udata  = datakex.u;
    
    [yvec, regmat] = makeregmat(sys, datakex);
    
    if ~iscell(regmat)
        regmat = {regmat};
    end
    
    if nsampkex<=maxd
        ctrlMsgUtils.error('Ident:general:tooFewDataSamples','predict')
    end
    
    % Make the lengths of yvec and regmat equal for different output
    for ky=1:ny
        regmat{ky} = regmat{ky}((maxd-maxidelay(ky)+1):end,:);
    end
    
    km = min(nsampkex-maxd, K);
    km = max(1, km);
    
    if km<=1 % One-step prediction, fast computation
        %km = 1;
        ydata(maxd+1:end,:) = evaluate(sys.Nonlinearity, regmat);
        
    else  % km>1
        
        yhatData = ydata;
        
        if progdisp,
            nregsamp = nsampkex-km;
            if nregsamp>0
                nregunder20 = 20/nregsamp; % variable used by wait bar
            end
            
            if nex==1
                fprintf('Prediction: ')
            else
                fprintf('Prediction for experiment no. %d in the data set: ', kex)
            end
            fprintf('%3d%%', 0)
            wcnt=0;
            CheckwbNlarxPredict(0, nregsamp, nregunder20, wcnt);
        end
        
        Xregmat = cell(ny,1);
        for ks=maxd:(nsampkex-km)
            % Initialize state
            Xydata = ydata((ks+1-maxd):ks,:); % maxd rows
            
            % Loop over km steps
            for kk=1:km
                for ky=1:ny
                    Xregmat{ky} = regmat{ky}(ks-maxd+kk,:);
                    Xregmat{ky}(1:sum(na(ky,:))) = Xydata(Xyind{ky});
                    if  custregflagvec(ky)
                        mxdata = [[Xydata; ydata(ks+kk,:)], udata((ks-maxd+kk):(ks+kk),:)]; % maxd+1 rows
                        for kcr=ycustind{ky} % loop over custom regressors involving outputs only
                            xcell{ky}{kcr} = num2cell(mxdata(mxind{ky}{kcr}));
                            regval = custreg{ky}(kcr).Function(xcell{ky}{kcr}{:});
                            if isscalar(regval) && isnumeric(regval) && isreal(regval)
                                Xregmat{ky}(nstandreg(ky)+kcr) = regval;
                            else
                                ctrlMsgUtils.error('Ident:idnlmodel:invalidCustomreg1')
                            end
                        end
                    end
                end
                
                % Update state
                Xydata(1:end-1,:) = Xydata(2:end,:);
                Xydata(end,:) = evaluate(sys.Nonlinearity, Xregmat);
                
                if ks==maxd  % first prediction, fill up also predictions shorter than km
                    yhatData(ks+kk,:) = Xydata(end,:);
                end
            end
            
            yhatData(ks+km,:) = Xydata(end,:);
            
            if progdisp
                CheckwbNlarxPredict(ks);
            end
        end %for ks
        
        if progdisp
            fprintf('\b\b\b\b%3d%%\n',100)
        end
        
        ydata = yhatData;
    end %if km<=1
    
    zdata{kex} = datakex;
    zdata{kex}.u = [];
    zdata{kex}.y = ydata;
end %for kex

for kex=1:nex
    zdata{kex} = zdata{kex}(end-nsamp0(kex)+1:end,:,:);
end

if nex==1
    zz = zdata{1};
    if ~iddataflag
        zz = zz.y;
    else
        zz.Tstart = dataT0;
    end
else
    zz = merge(zdata{:});
    zz.Tstart = dataT0;
end

if no==0
    utidplot(sys,zz,'Predicted')
    clear zz x0
end

% end of @idnlarx/predict.m

%==================================================================
function wcnt0 = CheckwbNlarxPredict(kk, nregsamp0, nregunder200, wcnt0)

persistent nregsamp nregunder20 wcnt
if ~kk
    [nregsamp, nregunder20, wcnt] = deal(nregsamp0, nregunder200, wcnt0);
end

if nregsamp>40
    wb=ceil(kk*nregunder20);
    if wb>wcnt
        fprintf('\b\b\b\b%3d%%', round(wb*5))
        wcnt=wb;
    end
else
    fprintf('\b\b\b\b%3d%%', round(kk/nregsamp*100))
end

wcnt0 = wcnt;

%---------------------------------------------------
function zinit = dataPropCopy(zinit, data)
% Copy properties of data to zinit

zinit.OutputName = data.OutputName;
zinit.OutputUnit = data.OutputUnit;
zinit.InputName = data.InputName;
zinit.InputUnit = data.InputUnit;
zinit.Ts = data.Ts;
zinit.TimeUnit = data.TimeUnit;

% FILE END
