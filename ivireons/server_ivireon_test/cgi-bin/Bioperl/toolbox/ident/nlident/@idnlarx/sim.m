function  zz = sim(sys, data, varargin)
% SIM simulates a dynamic system with an IDNLARX model.
%
% YS = SIM(MODEL, U)
%
%  MODEL: the IDNLARX model object.
%  U: the input data for simulation, an IDDATA object (where only the
%    input channels are used) or a matrix.
%  YS: the simulated output, an IDDATA object If U is an IDDATA
%    object, a matrix otherwise.
%
%  YS = SIM(MODEL,U,'Noise') produces a noise corrupted simulation with an
%    additive Gaussian noise scaled according to the value of the
%    NoiseVariance property of MODEL. (For particular user-chosen noise
%    sequences, see below.)
%
%  YS = SIM(MODEL, U, 'InitialState', INIT) allows to specify the
%    initialization.
%
%  INIT: initial condition specification, one of
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
%      size. This is the default value.
%
%    - an IDDATA object, containing output and input data samples prior to
%      the simulation start time. If it contains more data samples than
%      necessary, only the last samples are taken into account. This syntax
%      is equivalent to SIM(MODEL, U, 'InitialState', DATA2STATE(MODEL,INIT))
%      where DATA2STATE transforms the IDDATA object INIT to a state
%      vector.
%
%  To make noisy simulations with particular user-chosen noises, the noise
%  signals E should be an IDDATA object or a matrix, in accordance with the
%  input data U. Let Ny be the number of outputs of MODEL. In the IDDATA
%  case, E contains Ny noises channels as input data, whereas its output
%  data is empty. In the matrix case, E has Ny columns corresponding to the
%  noise channels. In both cases the noisy simulation is made by
%  SIM(MODEL, [U E]).
%
%  See also IDNLARX/PREDICT, IDNLARX/FINDOP, IDNLARX/DATA2STATE,
%  IDNLARX/FINDSTATES, IDNLHW/SIM, IDNLGREY/SIM, IDMODEL/SIM.

% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.8.15 $ $Date: 2009/11/09 16:23:56 $

% Author(s): Qinghua Zhang

ni = nargin;
error(nargchk(2,inf,ni, 'struct'));

no = nargout;
ctrlMsgUtils.SuspendWarnings('Ident:iddata:MoreOutputsThanSamples',...
    'Ident:iddata:MoreInputsThanSamples');

% Process optional arguments
[xinit, matching, defaultnoise, progdisp] = ...
    simpredictoptions({'Noise', 'InitialState', 'Matching'}, {'z', 'm'}, varargin{:});


% Tolerate the syntax sim(data, model, ...)
if ~isa(sys,'idnlarx')
    if isa(data,'idnlarx') && (isa(sys,'iddata') || isreal(sys))
        sys1 = data;
        data = sys;
        sys = sys1;
        clear sys1
    else
        ctrlMsgUtils.error('Ident:general:objectTypeMismatch','sim','IDNLARX')
    end
end

if ~isestimated(sys)
    ctrlMsgUtils.error('Ident:utility:nonEstimatedModel','sim','nlarx')
end

na = sys.na;
nb = sys.nb;
nk = sys.nk;
[ny, nu] = size(sys);

noisysim = false; % Flag for user specified noise.

% Return trivial result if empty data.
if isempty(data)
    if isa(data, 'iddata')
        zz = data;
        zz.u = [];
    else
        zz = zeros(0,ny);
    end
    if no==0
        utidplot(sys,zz,'Simulated')
        clear zz
    end
    ctrlMsgUtils.warning('Ident:analysis:simEmptyData')
    return
end

% Convert matrix to iddata if necessary.
if isa(data, 'iddata')
    iddataflag = true;
else
    iddataflag = false;
    if ~(isreal(data) && isnumeric(data) && ndims(data)==2)
        ctrlMsgUtils.error('Ident:general:invalidData')
    end
    ncols = size(data,2);
    if ncols==nu
        data = iddata([], data);
    elseif ncols==(nu+ny)
        noisysim = true;
        noisecell = {data(:,nu+1:nu+ny)}; % Note: cell array is used for multi-exp data.
        data = iddata([], data(:,1:nu));
    else
        ctrlMsgUtils.error('Ident:general:modelDataDimMismatch')
    end
end

% Get original data size (possibly extract noise data from u)
[nsamp0, ~, nud, nex] = size(data);
if nud==nu+ny
    noisysim = true;
    noisecell = pvget(data(:,:,nu+1:nu+ny), 'InputData');
    data = data(:,:,1:nu); % Remove noise data
elseif nud~=nu
    ctrlMsgUtils.error('Ident:analysis:simDataModelDimMismatch',nu,nu+ny)
end
% Note: no check on nyd, since OutputData is never used in simulation.

% Double noise warning
if defaultnoise && noisysim
    ctrlMsgUtils.warning('Ident:analysis:simWithNoise')
end

% Warning on data properties
if iddataflag
    msg = datapropwarns(data, sys, ...
        {'Ts', 'InputName', 'InputUnit', 'TimeUnit'});
    % Note: 'OutputName', 'OutputUnit' are not checked for simulation.
    for km=1:length(msg)
        %todo
        warning('Ident:general:dataModelPropMismatch', msg{km});
    end
end

dataT0 =  data.Tstart;

% Fill output data with zeros (Simulation should never use the outputs in data)
if nex==1
    data.y = zeros(nsamp0, ny);
else
    data.y =  mat2cell(zeros(sum(nsamp0), ny), nsamp0, ny); % multi-experiments case
end

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

% Compute ycustind, the indices of the custom regressors involving output
% and mxind, the indices in mxdata corresponding to customreg function arguments.
nstandreg = sum([na, nb], 2);
custregflagvec = false(ny,1);
ycustind = cell(ny,1);
mxind = cell(ny,1);
xcell = cell(ny,1);
for ky=1:ny
    if ~isempty(custreg{ky}) && isa(custreg{ky},'customreg')
        custregflagvec(ky) = true;
        ncr = numel(custreg{ky});
        yflag = false(1, ncr);  % For row vectors ycustind{ky}, (1,ncr) instead of (ncr,1)
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
        ycustind{ky} = find(yflag);
    end
end

% Initial state processing
if ischar(xinit) && strcmpi(xinit,'z')
    xinit = zeros(nx,1);
end
if maxd==0
    if isrealmat(xinit) && ~isempty(xinit)
        ctrlMsgUtils.warning('Ident:analysis:modelWithNoStates')
    end
    xinit = [];
elseif isrealmat(xinit) % Using state vector
    [xir, xic] = size(xinit);
    if nx~=xir
        ctrlMsgUtils.error('Ident:analysis:idnlarxInitRows',nx)
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
    
    if noisysim
        %Increase also the length of noisecell
        for kex=1:nex
            noisecell{kex} = [zeros(maxd, ny); noisecell{kex}];
        end
    end
    
    %warning(wstatus)
    
elseif isa(xinit,'iddata')
    [ininsamp, ininyd, ininud, ininex] = size(xinit);
    if ininyd~=ny
        ctrlMsgUtils.error('Ident:analysis:idnlarxInitIODim')
    end
    if nex>1 && ininex==1
        [mxinit{1:nex}] = deal(xinit);
        xinit = merge(mxinit{:});
    elseif nex~=ininex
        ctrlMsgUtils.error('Ident:analysis:idnlarxSimInitNex')
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
        if iddataflag
            zinit = dataPropCopy(zinit, data);
        end
        % data = [zinit; data]; % Cannot get this line work. Replaced by the following loop.
        cdata = cell(nex,1);
        for kex=1:nex
            cdata{kex} = [getexp(zinit, kex); getexp(data, kex)];
        end
        data = merge(cdata{:});
        clear cdata
        
        if noisysim
            %Increase also the length of noisecell
            for kex=1:nex
                noisecell{kex} = [zeros(maxd, ny); noisecell{kex}];
            end
        end
    end
    
else
    ctrlMsgUtils.error('Ident:analysis:idnlarxINITval','sim','idnlarx/sim')
end
%End of Initial state processing

nsamp = size(data,1); % Note: nsamp may include the length of zinit. nsamp0 is the original data length.

if defaultnoise && ~noisysim
    % Fill noisecell with default noise.
    noisysim = true;  % defaultnoise --> noisysim
    noisecell = cell(nex,1);
    for kex=1:nex
        noisecell{kex} = randn(nsamp(kex), ny);
    end
end

% Scaling noise by NoiseVariance
if noisysim
    noisevar = pvget(sys, 'NoiseVariance');
    if all(isfinite(noisevar(:))) && all(size(noisevar)==ny)
        sqrnoisevar = sqrtm(noisevar);
        if all(isfinite(sqrnoisevar(:))) && isreal(sqrnoisevar)
            for kex=1:nex
                noisecell{kex} = noisecell{kex}*sqrnoisevar;
            end
        end
    end
end

% Fast simulation if non recurrent model
%=======================================
if all(all(na==0)) && all(cellfun(@isempty, ycustind))
    
    wstatus =  ctrlMsgUtils.SuspendWarnings('Ident:general:dataModelPropMismatch');
    zz = predict(sys, data, 1, 'InitialState', xinit);
    delete(wstatus);
    
    % Add noise
    ydata = pvget(zz,'OutputData');
    for kex=1:nex
        if noisysim
            ydata{kex} = ydata{kex} + noisecell{kex};
        end
        ydata{kex} = ydata{kex}(end-nsamp0(kex)+1:end,:,:); % Remove init data.
    end
    zz = pvset(zz, 'OutputData', ydata);
    
    if ~iddataflag
        zz = zz.OutputData;
    end
    
    if no==0
        utidplot(sys,zz,'Simulated')
        clear zz
    end
    return
end
% == End of fast sim ==

zdata = cell(nex,1);
Xregmat = cell(ny,1);

for kex=1:nex  % loop over experiments
    
    datakex = getexp(data,kex);
    nsampkex = size(datakex,1);
    ydata = datakex.y;
    udata  = datakex.u;
    
    [yvec, regmat] = makeregmat(sys, datakex);
    
    if ~iscell(regmat)
        regmat = {regmat};
        yvec = {yvec};
    end
    
    % equalize the lengths of yvec and regmat for different output
    for ky=1:ny
        yvec{ky} = yvec{ky}((maxd-maxidelay(ky)+1):end,:);
        regmat{ky} = regmat{ky}((maxd-maxidelay(ky)+1):end,:);
    end
    
    % Prepare indices for standard regressor update
    % Note 1: yindkk corresponds to, but is different from Xyind of predict.m
    % which operates on Xydata (state variables), not on ydata.
    % Note 2: yindkk must be computed in the loop of kex, because it depends
    % on nsampkex, the sample length of the experiment.
    
    tosumnaky = cell(ny,1);
    yindkk = cell(ny,1);
    for ky=1:ny
        tosumnaky{ky} = 1:sum(na(ky,:));
        yindkk{ky} = zeros(1,sum(na(ky,:),2));
        pt = 0;
        for kky=1:ny
            nseq = 1:na(ky,kky);
            yindkk{ky}(1,pt+nseq) = repmat(1+maxd, 1,na(ky,kky))-nseq ...
                + nsampkex*(kky-1);  % This is to convert subscripts to linear index
            % Linear index is used to extract elements of ydata not forming a sub-matrix.
            
            pt = pt+na(ky,kky);
        end
    end
    
    nregsamp = nsampkex-maxd;
    if nregsamp>0
        nregunder20 = 20/nregsamp; % variable used by wait bar
    else
        nregunder20 = 1;
    end
    if progdisp
        if nex==1
            fprintf('Simulation: ')
        else
            fprintf('Simulation for experiment no. %d in the data set: ', kex)
        end
        fprintf('%3d%%', 0)
        wcnt=0;
        CheckwbNlarxsim(0, nregsamp, nregunder20, wcnt);
    end
    
    for kk=1:nregsamp
        
        for ky=1:ny
            Xregmat{ky} = regmat{ky}(kk,:);
        end
        
        if noisysim
            yhatcurrent = evaluate(sys.Nonlinearity, Xregmat) + noisecell{kex}(kk+maxd,:);
        else
            yhatcurrent = evaluate(sys.Nonlinearity, Xregmat);
        end
        
        ydata(kk+maxd, :) = yhatcurrent;
        
        if any(~isfinite(yhatcurrent));
            msg = InfnanMsg(yhatcurrent, nex, kex);
            warning(msg.identifier,msg.message);
            ydata((kk+maxd):end, :) = NaN;
            break;
        end;
        
        if kk==nregsamp
            continue;  % No need to update data for the last iteration
        end;
        
        for ky=1:ny
            
            % Standard regressor update
            regmat{ky}(kk+1, tosumnaky{ky}) = ydata(kk+yindkk{ky});
            
            % Custom regressor update
            if custregflagvec(ky)
                mxdata = [ydata(kk+1:kk+1+maxd,:), udata(kk+1:kk+1+maxd,:)];
                for kcr=ycustind{ky} % loop over custom regressors involving outputs only
                    xcell{ky}{kcr} = num2cell(mxdata(mxind{ky}{kcr}));
                    regval = custreg{ky}(kcr).Function(xcell{ky}{kcr}{:});
                    if isscalar(regval) && isnumeric(regval) && isreal(regval)
                        regmat{ky}(kk+1, nstandreg(ky)+kcr) = regval;
                    else
                        ctrlMsgUtils.error('Ident:idnlmodel:invalidCustomreg1')
                    end
                end
            end;
        end;
        if progdisp
            CheckwbNlarxsim(kk);
        end
    end; %for kk
    
    zdata{kex} = datakex;
    zdata{kex}.u = [];
    zdata{kex}.y = ydata;
    
    if progdisp
        fprintf('\b\b\b\b%3d%%\n',100)
    end
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
    utidplot(sys,zz,'Simulated')
    clear zz
end

%End of @idnlarx/sim.m

%==================================================================
function wcnt0 = CheckwbNlarxsim(kk, nregsamp0, nregunder200, wcnt0)

persistent  nregsamp nregunder20 wcnt
if ~kk
    [~, nregsamp, nregunder20, wcnt] = deal(nregsamp0, nregunder200, wcnt0);
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

%----------------------------------------------------------------------
function msg = InfnanMsg(yhatcurrent, nex, kex)
if isnan(yhatcurrent)
    errtype = 'NaN';
else
    errtype = 'Inf';
end
if nex==1
    msg = sprintf('Simulation encountered %s values.', errtype);
    msg = struct('identifier','Ident:analysis:nonfiniteSim','message',msg);
else
    msg = sprintf('Simulation encountered %s values for input data corresponding to experiment number %d.', errtype, kex);
    msg = struct('identifier','Ident:analysis:nonfiniteSimMultiExp','message',msg);
end

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
