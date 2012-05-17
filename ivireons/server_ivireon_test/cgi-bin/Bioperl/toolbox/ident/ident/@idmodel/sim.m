function [y,ysd] = sim(varargin)
%SIM  Simulate time response of linear models to arbitrary inputs.
%   Y = SIM(MODEL,U)
%
%   MODEL: a linear model (IDMODEL) such as IDSS, IDPOLY, IDARX, IDGREY or
%   IDPROC.
%
%   U: the input data that could be given as an IDDATA object
%   (where only the input channels are used) or as a matrix
%   U = [U1 U2 ..Un] with the column vector Uk as the k:th input.
%   Example: U = iddata([],idinput(200),'Ts',0.1);
%
%   Y: The simulated output. If U is an IDDATA object, Y is also
%   delivered as an IDDATA object, otherwise as a matrix, whose k:th
%   column is the k:th output channel.
%
% Simulation with additive noise:
%   For simulation with noise, there are two options:
%   Option 1: With Y = SIM(MODEL,U,'Noise') a noise corrupted simulation is
%       obtained, where the additive Gaussian noise contribution is scaled
%       and colored according to the information contained in MODEL.
%   Option 2: Noisy simulations for a specific noise source E are obtained
%       by appending Ny (= Number of outputs) noise channels E to U either
%       in the IDDATA or the matrix format. When using this option, do not
%       use the 'Noise' string (Option 1) as input variable.
%
% Simulation of continuous-time models:
%   The input data must be specified using an IDDATA object (not double
%   matrix). The model is first sampled according to the
%   information in the input U ('Ts' and 'InterSample' properties). Note
%   that for discrete time models the intersample data properties are
%   ignored, and the returned Y has the same sampling interval as U,
%   regardless of the model's sampling interval.
%
% Simulation in frequency domain:
%   If U is a frequency-domain IDDATA object, the simulation is performed in
%   the frequency domain and Y is returned as a frequency domain IDDATA object.
%   If U is continuous-time frequency domain data (Ts=0), the MODEL should
%   also be continuous time. Bandlimited frequency domain data
%   (U.InterSample = 'bl') is treated as continuous-time data in the
%   simulation even if U.Ts is not zero.
%
% Computing standard deviations of response:
%   With  [Y,YSD] = SIM(MODEL,U,...) the estimated standard deviation of the
%   simulated output, YSD, is also computed. YSD is of the same format as Y.
%   See also IDMODEL/SIMSD for a Monte-Carlo method to compute the standard
%   deviation.
%
% Handling multi-experiment input:
%   If U is a multiple experiment IDDATA object, so will Y be. Initial
%   conditions, if specified, may be specified separately for each
%   experiment (see below).
%
% Specifying initial conditions for starting the simulation:
%   Y = SIM(MODEL,U, INIT) or
%   Y = SIM(MODEL,U,'InitialState',INIT)
%   allows specification of initial states of the model. If MODEL is not an
%   IDSS or IDGREY model, the states of the model are defined as those
%   corresponding to IDSS(MODEL). The following options are available for
%   specifying INIT:
%       INIT = 'm' (default) uses the model's initial state (zero for
%               models that are not IDSS, IDGREY or IDPROC).
%       INIT = 'z' uses zero initial conditions.
%       INIT = X0 (column vector). Uses X0 as the initial state.
%              For multi-experiment data U, X0 may have as many columns as
%              there are experiments to allow for different initial
%              conditions for each experiment.
%    If you want initial state values that minimize the prediction-error
%    fit to a given data object, use the "findstates" command to estimate
%    those values.
%
% See IDINPUT, IDMODEL for input generation and model creation
% and COMPARE, PREDICT for model evaluation.
%
% See also IDINPUT, SIMSD, COMPARE, STEP, PREDICT, IDNLARX/SIM,
% IDNLHW/SIM, IDNLGREY/SIM, FINDSTATES.

%   L. Ljung 10-1-86, 9-9-94
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.24.4.20 $  $Date: 2009/12/07 20:42:29 $

no = nargout;
error(nargchk(0,2,no,'struct'))

hw = ctrlMsgUtils.SuspendWarnings('Ident:iddata:MoreOutputsThanSamples',...
    'Ident:iddata:MoreInputsThanSamples');

repeat =  0; % Flag to avoid infinite loops
if isa(varargin{end},'char') && strcmp(varargin{end},'Repeat')
    repeat = 1;
    iddatrep = varargin{end-1};
end
nr = find(strncmpi(varargin,'in',2));

init =[];
if ~isempty(nr)
    nr = nr(end);
    if length(varargin)<nr+1
        ctrlMsgUtils.error('Ident:general:optionsValuePair','InitialState','sim','idmodel/sim')
    end
    init = varargin{nr+1};
    if ~isa(init,'char') && ~isa(init,'double')
        ctrlMsgUtils.error('Ident:analysis:IniSpec2','sim','idmodel/sim')
    end
    varargin(nr:nr+1)=[];%
end
nr = find(strncmpi(varargin,'no',2));
noise = 'off';
if ~isempty(nr)
    noise = 'on';
    varargin(nr)=[];%
end
y=[];ysd=[];
data = varargin{1};
thmod = varargin{2};
if length(varargin)>2 && isempty(init)
    init = varargin{3};
end
%{
if length(varargin)>3 % Inhib = 1 is a call from the GUI
    inhib = varargin{3};
else
    inhib = 0;
end
%}

if isa(data,'idmodel') % Forgive order
    data1 = thmod;
    thmod = data;
    data = data1;
end
if isnan(thmod)
    ctrlMsgUtils.error('Ident:analysis:simNaNsInModel')
end

if isa(data,'idfrd')
    ctrlMsgUtils.error('Ident:analysis:simUsingFRF')
end

if no<2
    thmod = pvset(thmod,'CovarianceMatrix','None'); % To avoid extra calculations
end
% First check data sizes
if isa(data,'iddata')
    dom = pvget(data,'Domain');
    dom = lower(dom(1));
    [uni,Tsd,inters] = dunique(data);
    [N,~,nud,Nexp] = size(data);
    if ~isreal(thmod);
        if realdata(data) && dom=='f';%strcmp(pvget(dom,'Frequency')
            %{
            warning('Ident:analysis:simCheck',...
                ['The model is complex and the input is derived from a real time-domain signal.\n',...
                'To build an output-input data set you must do [y, complex(u)];'])
            %}
            data = complex(data); % To handle simulation of complex model with real FD data.
        end
    end
else
    [N,nud] = size(data);
    uni = 1;
    Nexp =1;
    inters = 'zoh';
    Tsd = 1;
    dom = 't';
end
[ny,nu] = size(thmod);
enableE = 0;
if nu~=nud,
    if nud == nu + ny,
        enableE = 1;
    else
        ctrlMsgUtils.error('Ident:analysis:simDataModelDimMismatch',nu,nu+ny)
    end
end

if strcmp(noise,'on')
    if enableE
        ctrlMsgUtils.warning('Ident:analysis:simWithNoise')
        
    else
        if isa(data,'iddata')
            for kexp = 1:Nexp
                e{kexp} = randn(N(kexp),ny);
            end
            data = [data,iddata([],e,Tsd)];
        else
            data = [data,randn(N,ny)];
        end
        enableE = 1;
    end
end
if isempty(init), init = 'm'; end
if iscell(init)
    ctrlMsgUtils.error('Ident:analysis:X0val','sim','idmodel/sim')
elseif ischar(init)
    init = lower(init(1));
    if init == 'e'
        ctrlMsgUtils.error('Ident:analysis:simInvalidINITVal1')
    elseif ~any(init==['z','m'])
        ctrlMsgUtils.error('Ident:analysis:X0val','sim','idmodel/sim')
    end
end
if strcmp(class(thmod),'idgrey') && strcmp(pvget(thmod,'CDmfile'),'cd') ...
        && pvget(thmod,'Ts')==0
    ctrlMsgUtils.warning('Ident:analysis:idgreyCustomSampling')
end

thss = idss(thmod);
T=pvget(thss,'Ts');
x0c = pvget(thss,'X0');
nnc = size(x0c,1); % The number of states in the original system
% Do away with continuous time right away:
if T==0 && ~repeat   % To avoid infinite loops
    if ~isa(data,'iddata')
        ttes = pvget(thmod,'Utility'); % This is really to honor old syntax
        try
            Td = ttes.Tsdata; %method = 'z';
            if Td == 0, Td=1;end
        catch
            es = pvget(thmod,'EstimationInfo');
            try
                Td = es.DataTs;
                if Td == 0, Td=1;end
            catch
                Td = [];
            end
        end
        if isempty(Td)
            ctrlMsgUtils.error('Ident:analysis:simCTModelData')
        end
        Tsd = Td; inters = 'zoh';
        [ny,nu] = size(thss);
        data = iddata([],data,Td);
        iddatrep = 0; % The return the output in the right format even after a second call
    else
        iddatrep = 1;
    end
    
    u=pvget(data,'InputData');
    u1 = [];
    for kexp = 1:length(u);
        u1=[u1,u{kexp}(1,1:nu).'];
    end
    if init=='z'
        init = zeros(nnc,1);
    elseif init=='m'
        init = x0c;
    end
    % Now init is a vector/matrix
    [nxi,mexp]=size(init);
    if nxi~=nnc
        ctrlMsgUtils.error('Ident:analysis:IniRows',nnc)
    end
    if mexp==1 && Nexp>1
        init = init*ones(1,Nexp);
        mexp = Nexp;
    end
    if mexp~=Nexp
        ctrlMsgUtils.error('Ident:analysis:IniSize');
    end
    if uni %Same sampling character of all experiments
        
        if Tsd>0 && ~(strcmpi(inters,'bl') && dom=='f')
            % For a BL discrete time FD data set no sampling should be done
            if strcmp(inters,'bl')
                ctrlMsgUtils.warning('Ident:analysis:simBLtimeDomainData')
                
                inters = 'foh';
            end
            [th,Gll] = c2d(thss,Tsd,inters);
        else % no sampling: CT data or BL&fd sim
            th = thss; Gll = [];% eye(nnc);
            
        end
        
        if ~isempty(Gll)
            init = Gll*[init;u1];
        end
        if no < 2
            y = sim(th,data,init,iddatrep,'Repeat');
        else
            [y,ysd] = sim(th,data,init,iddatrep,'Repeat');
        end
        
    else % different data characteristics
        Tsd = pvget(data,'Ts');
        inters = pvget(data,'InterSample');
        for kexp = 1:Nexp
            if Tsd{kexp}>0 && ~(strcmpi(inters{kexp},'bl') &&dom=='f')
                % For a BL discrete time FD data set no sampling should be done
                if strcmpi(inters{kexp},'bl')
                    ctrlMsgUtils.warning('Ident:analysis:simBLtimeDomainData')
                    inters{kexp} = 'foh';
                end
                [th,Gll] = c2d(thss,Tsd{kexp},inters{kexp});
            else % no sampling: CT data or BL&fd sim
                th = thss; Gll = [];% eye(nnc);
            end
            if ~isempty(Gll)
                initk = Gll*[init(:,kexp);u1(:,kexp)];
            else
                initk = init(:,kexp);
            end
            if no ==1
                yk = sim(th,getexp(data,kexp),initk,iddatrep,'Repeat');
                if isempty(y)
                    y = yk;
                else
                    y = merge(y,yk);
                end
            else
                [yk,ysdk] = sim(th,getexp(data,kexp),initk,iddatrep,'Repeat');
                if isempty(y)
                    y = yk; ysd = ysdk;
                else
                    y = merge(y,yk); ysd = merge(ysd,ysdk);
                end
            end
        end
    end % if uni
    if no == 0
        utidplot(th,y,'Simulated')
        clear y ysd
    end
    return
end
% From here on the model is a Discrete time model or we have CT model and CT
% FD data


if isa(data,'iddata')
    Tdc = pvget(data,'Ts'); Td = cat(1,Tdc{:});
    % Disable check if BL DT data and CT model
    if any(abs(Td-T)>10*eps)
        ctrlMsgUtils.warning('Ident:analysis:dataModelTsMismatch')
        if any(Td==0)
            ctrlMsgUtils.error('Ident:analysis:simDTModelData')
        end
    end
end

% if ~pvget(thss,'Ts')%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%     thss = c2d(thss,Td);
%     T = Td;
%     x0c=get(thss,'x0');
% end
[a,b,c,d,k,x0]=ssdata(thss);
LAM=pvget(thss,'NoiseVariance');
adv = pvget(thss,'Advanced');
if dom=='t'
    if pvget(thss,'Ts')==0
        if max(real(eig(a)))>adv.Threshold.Sstability
            ctrlMsgUtils.warning('Ident:analysis:unstableSim')
        end
    else
        stablim = adv.Threshold.Zstability;
        if max(abs(eig(a)))>stablim,
            ctrlMsgUtils.warning('Ident:analysis:unstableSim')
        end
    end
end
Inpd = pvget(thss,'InputDelay')';

[ny,n]=size(c);
[n,nu]=size(b);
if enableE
    sqrlam=sqrtm(LAM);
    b = [b k*sqrlam];
    d = [d sqrlam];
end
if isa(data,'iddata')
    
    iddatflag = 1;
    if any(cat(1,Inpd)~=0)
        if enableE
            Inpd = [Inpd,zeros(ny,1)];
        end
        if T==0 && Tdc{1}>0 % this can only happen
            % for FD BL data
            Inpd = Inpd/Tdc{1};
        end
        data = nkshift(data,Inpd,'append');  % This works for CT too in the FD
    end
    zee = pvget(data,'InputData');
    fre = pvget(data,'Radfreqs');
else
    iddatflag= 0;
    %zee = {data};
    if iscell(Inpd)
        Inpd=Inpd{1};
    end
    if norm(Inpd)>eps
        %if ~inhib
        % ['The model''s InputDelay can be handled  safely only if',...
        %        ' the data is an IDDATA object.']);
        %else
        [Ncap,nudum] = size(data);
        nk1 = Inpd;
        Ncc = min([Ncap,Ncap+min(nk1)]);
        for ku = 1:length(nk1)
            u1 = data(max([nk1,0])-nk1(ku)+1:Ncc-nk1(ku),ku);
            newsamp = Ncap-length(u1);
            if nk1(ku)>0
                u1= [zeros(newsamp,1);u1];
            else
                u1 = [u1;zeros(newsamp,1)];
            end
            data(:,ku) = u1;
        end
        %end
    end
    zee = {data};
end
Ne = length(zee);

ThrowFreqDataWarn = false;
for kexp=1:Ne
    ze = zee{kexp};
    [Ncap,nze]=size(ze);
    if ~any(nze==[nu nu+ny])
        ctrlMsgUtils.error('Ident:analysis:simCheck1')
    end
    if ~strcmpi(init(1),'m')
        if strcmpi(init(1),'z')
            x0c = zeros(nnc,1);
        else
            [nxr,nxc] = size(init);
            if nxr~=nnc,
                ctrlMsgUtils.error('Ident:analysis:IniRows',n)
            end
            if nxc~=1 && nxc~=Ne
                ctrlMsgUtils.error('Ident:analysis:IniSize');
                
            end
            if nxc>1
                x0c = init(:,kexp);
            else
                x0c = init;
            end
        end
        
    end
    
    if dom=='t'
        x0 = x0c;
        %{
        if T==0
            x0 = gs{kexp}*[x0c;ze(1,1:nu)'];
        else
            x0 = x0c;
        end
        %}
        x=ltitr(a,b,ze,x0);
        yc{kexp}=(c*x.'+d*ze.').';
    else
        if T == 0
            frejust = 1i*fre{kexp};
        else
            Tdf = Tdc{kexp};
            %{
            if iscell(Tdc)
                Tdf = Tdc{kexp};
            else
                Tdf = Tdcc{kexp};
            end
            %}
            frejust = exp(1i*fre{kexp}*Tdf);
        end
        x0 = x0c;
        xh=freqkern(a,[b x0],[ze,frejust],frejust);
        yc{kexp}=(c*xh+d*ze.').';
    end
    y = yc{kexp};
    
    if no>1
        if dom=='f'
            ThrowFreqDataWarn = true;
            ysdc{kexp} = [];
        else
            nue = size(ze,2);
            mbb = idpolget(thss);
            if ~isempty(mbb)
                if ~isempty(pvget(mbb{1},'CovarianceMatrix'))
                    for kk = 1:length(mbb)
                        mb = mbb{kk}(:,1:nue);
                        try
                            temp = idsimcov(mb,ze,y(:,kk));
                        catch
                            temp = [];
                        end
                        if ~isempty(temp)
                            ysd(:,kk) = temp;
                        end
                    end
                end
                ysdc{kexp} = ysd;
            else
                ysdc{kexp} = [];
            end
        end
    end
end % kexp

if ThrowFreqDataWarn
    ctrlMsgUtils.warning('Ident:analysis:simCheck2')
end

if repeat
    iddatflag = iddatrep;
end
if iddatflag
    una = pvget(data,'InputName');
    unam = pvget(thss,'InputName');
    war = 0;
    for ku = 1:length(unam);
        if ~strcmp(una{ku},unam{ku})
            war = 1;
        end
    end
    if war
        ctrlMsgUtils.warning('Ident:analysis:uNameMismatch')
    end
    y = data;
    y = pvset(y,'OutputData',yc,'InputData',[],'OutputName',pvget(thss,'OutputName'),...
        'OutputUnit',pvget(thss,'OutputUnit'));
    if no>1
        if isempty(ysdc{1})
            ysd = [];
        else
            ysd = data;
            ysd= pvset(ysd,'OutputData',ysdc,'InputData',[],'OutputName',pvget(thmod,'OutputName'),...
                'OutputUnit',pvget(thss,'OutputUnit'));
        end
    end
else % no iddata
    y = yc{1};
    if no>1
        if isempty(ysdc{1})
            ysd = [];
        else
            ysd = ysdc{1};
        end
    end
end
if no == 0
    utidplot(thss,y,'Simulated');
    clear y
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
