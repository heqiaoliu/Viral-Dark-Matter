function ymod = impulse(varargin)
%IMPULSE  Impulse response of IDMODELs and direct estimation from IDDATA sets.
%
%   IMPULSE(MOD) plots the impulse response of the IDMODEL model MOD (either
%   IDPOLY, IDARX, IDSS or IDGREY).
%
%   IMPULSE(DAT) estimates and plots the impulse response from the data set
%   DAT given as an IDDATA object. This does not apply to time series data.
%   To study subchannels, use IR = IMPULSE(DAT); IMPULSE(IR(INPUTS,OUTPUTS)).
%
%   For multi-input models, independent impulse commands are applied to each
%   input channel.
%
%   IMPULSE(MOD,'sd',K) also plots the confidence regions corresponding to
%   K standard deviations as a region around zero. Any response
%   outside this region is thus "significant". Add the argument
%   'FILL' after the models to show  the confidence region(s) as a
%   band instead: IMPULSE(M,'sd',3,'fill').
%
%   IMPULSE uses a stem plot by default. To change that into a regular plot
%   add the argument 'PLOT' after the models: IMPULSE(M,'plot'). In
%   this case, the uncertainty region is shown as a strip around
%   the response.
%
%   The time span of the plot is determined by the argument T: IMPULSE(MOD,T).
%   If T is a scalar, the time from -T/4 to T is covered. For an
%   impulse response estimated directly from data, this will also show feedback
%   effects in the data (response prior to t=0).
%   If T is a 2-vector, [T1 T2], the time span from T1 to T2 is covered.
%   For a continuous time model, T can be any vector with equidistant values:
%   T = [T1:ts:T2] thus defining the sampling interval. For discrete time models
%   only max(T) and min(T) determine the time span. The time interval is modified to
%   contain the time t=0, where the input impulse occurs. The initial state vector
%   is taken as zero, even when specified to something else in MOD.
%
%   NOTE: The pulse is normalized w.r.t. the sampling interval T so that
%   u(t) = 1/T for 0<t<T ans zero otherwise.
%
%   IMPULSE(MOD1,MOD2,..,DAT1,..,T) plots the impulse responses of multiple
%   IDMODEL models and IDDATA sets MOD1,MOD2,...,DAT1,... on a single plot.
%   The time vector T is optional.  You can also specify a color, line style,
%   and markers for each system, as in
%      IMPULSE(MOD1,'r',MOD2,'y--',MOD3,'gx').
%
%   When invoked with left-hand arguments and a model input argument
%      [Y,T,YSD] = IMPULSE(MOD)
%   returns the output response Y and the time vector T used for
%   simulation.  No plot is drawn on the screen.  If MOD has NY
%   outputs and NU inputs, and LT=length(T), Y is an array of size
%   [LT NY NU] where Y(:,:,j) gives the impulse response of the
%   j-th input channel. YSD contains the standard deviations of Y.
%
%   For a DATA input MOD = IMPULSE(DAT),  returns the model of the
%   impulse response, as an IDARX object. This can of course be plotted
%   using IMPULSE(MOD). This is useful for plotting when there are many inputs
%   and outputs: MOD = IMPULSE(DAT); IMPULSE(MOD(ky,ku)), where ky and ku
%   are selected inputs and outputs.
%
%   The calculation of the impulse response from data is based on a 'long'
%   FIR model, computed with suitably prewhitened input signals. The order
%   of the prewhitening filter (default 10) can be set to NA by the
%   name/value pair IMPULSE( ....,'PW',NA,... ) appearing anywhere
%   in the input argument list. NA must be a positive integer.
%
%   NOTE: IDMODEL/IMPULSE and IDDATA/IMPULSE are adjusted to the use with
%   identification tasks. If you have CONTROL SYSTEM TOOLBOX and want
%   to access the LTI/IMPULSE, use VIEW(MOD1,...,'impulse').

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.24.4.14 $  $Date: 2009/12/07 20:42:25 $

error(nargchk(1,Inf,nargin,'struct'))

NA = [];
varargin = low(varargin);
kpf = find(strcmp(varargin,'pw'));
NAspecified = false;
if ~isempty(kpf)
    if kpf == length(varargin)
        ctrlMsgUtils.error('Ident:general:CompleteOptionsValuePairs',...
            'impulse','iddata/impulse')
    end
    
    NA = varargin{kpf+1};
    if ~isa(NA,'double') || ~isempty(NA) && (~isscalar(NA) || NA<=0)
        ctrlMsgUtils.error('Ident:general:PosIntOptionValue',...
            'PW','impulse','iddata/impulse')
    end
    NAspecified = true;
end

if isempty(NA)
    NA = 10;
end

T=[];
%First find desired time span, if specified. That is a double, not
%preceded by 'pw' or 'sd':
for j = 1:length(varargin)
    if isa(varargin{j},'double')
        if j==1
            ctrlMsgUtils.error('Ident:analysis:ImpulseStepFirstArgModel')
        end
        tst = varargin{j-1};
        if ischar(tst)&&(strcmpi(tst,'pw')||strcmpi(tst,'sd'))
        else
            T = varargin{j};
        end
    end
end
%plotno=0; % How many subplots?
for k1 = 1:length(varargin)
    if isa(varargin{k1},'iddata');
        dat = varargin{k1};
        [N,ny,nu]= size(dat);
        if nu==0
            ctrlMsgUtils.error('Ident:analysis:ImpulseStepTimeSeriesData');
        end
        if ny==0
            ctrlMsgUtils.error('Ident:analysis:ImpulseStepNoOutputData');
        end
        Ts = pvget(dat,'Ts');Ts=Ts{1};
        if Ts==0
            ctrlMsgUtils.error('Ident:general:CTData','impulse');
        end
        %plotno = max([plotno,ny,nu]);
        inparg = inputname(k1);
        break
    end
end

dat = idutils.utValidateData(dat, [], 'both', true, 'impulse');
datn = pvget(dat,'Name');
if isempty(datn)
    datn = inparg;
end
u = dat.InputData;
uu =[];
for k = 1:length(u);
    uu = [uu;u{k}(:)];
end
if all(uu(:)==0|uu(:)==1) % then it was an idfrd
    NA = 0;
end
[Ncaps,ny,nu,Ne] = size(dat);
Ts = dat.Ts;  Ts = Ts{1};
Ncap = min(Ncaps); % the reason is that each experiment is shifted independently
if strcmpi(dat.Domain,'Frequency'), Ncap=2*Ncap;end
pedu = min(pexcit(iddata([],uu),NA));

if NA>pedu
    NA = min(floor(Ncap/2),pedu);
    if NAspecified
        ctrlMsgUtils.warning('Ident:analysis:ImpulseFilterOrder',NA);
    end
end

if isempty(T)
    n = floor(min([Ncap/3,70]));
elseif length(T)==1
    T = [-T/4,T];
end

if ~isempty(T)
    T(1) = min(T(1),0);
    n = floor((max(T)-min(T))/Ts) + 1;
end
ped = pexcit(dat,n);
ped = min(ped);
if NA > 0
    ma = arx(uu,NA);
    a = pvget(ma,'a');
    dat = idfilt(dat,{a,[1,zeros(size(a))]},'causal');
end

% Now determine time span to estimate impulse:
exfac = 3; % The factor of the excess of datasamples over the number of parameters

ut=pvget(dat,'Utility');
if isfield(ut,'idfrd') && ut.idfrd
    exfac = 1;
end

%n = min(n,ped);
%if n*nu>Ncap*4/9
n1 = floor(min(ped,4*Ncap/(4*exfac*nu+5)));
%end
n2 = min(n1,ped);% This many samples can be estimated
if ped==0
    ctrlMsgUtils.error('Ident:analysis:ZeroInput')
end
warflag = 0;
if isempty(T)
    n2 = min(n2,100);% 100 points suffice if nothing demanded.
    M1 = floor(n2/4);
    M2 = n2 - M1;
else
    if n2<n % then all the points asked for do not fit
        M1 = -floor(min(T(1),0)/Ts);
        %M2 = floor(max(T(2)
        if Ncap-M1<2*n2 || M1>n2/3
            M1 = floor(n2/4);
        end
        M2 = n2 - M1;
        warflag = 1;
    else % demanded interval OK
        M1 = -floor(min(T(1),0)/Ts);
        M2 = floor(T(end)/Ts)+1;
    end
end
n = (M2+M1);
if (~isempty(T)) && warflag
    ctrlMsgUtils.warning('Ident:analysis:ImpulseStepLargeTFinal',...
        sprintf('%0.5g',-M1*Ts),sprintf('%0.5g',(M2-1)*Ts))
end
dats = nkshift(dat,-M1*ones(1,nu));
y = pvget(dats,'OutputData');
u = pvget(dats,'InputData');
T = pvget(dats,'Ts'); T = T{1};
imp.time = (-M1:M2-1)*T;

for ky = 1:ny
    lsub.type='()';
    lsub.subs={':',ky,':'};
    was = ctrlMsgUtils.SuspendWarnings;
    dattemp = subsref(dats,lsub);
    m = arx(dattemp,[0 (M2+M1)*ones(1,nu) zeros(1,nu)]);
    delete(was)
    sd = sqrt(diag(m.cov));
    imp.B(ky,:,:) = reshape(m.par,M1+M2,nu).';
    imp.dB(ky,:,:) = reshape(sd,M1+M2,nu).';
    for ku=1:nu
        cov = m.cov((ku-1)*n+1:ku*n,(ku-1)*n+1:ku*n);
        L1 = [[eye(M1),zeros(M1,M2)];[zeros(M2,M1),tril(ones(M2,M2))]];
        cov1 = L1*cov*L1';
        imp.dBstep(ky,ku,:) = sqrt(diag(cov1));
    end
end
ut.impulse = imp;
if norm(imp.B(:))==0
    ctrlMsgUtils.error('Ident:analysis:ImpulseStepRespFailure')
end

model = idarx(eye(ny),imp.B,T);
model = pvset(model,'InputDelay',-M1*ones(1,nu),'Utility',ut);
model = pvset(model,'InputName',pvget(dat,'InputName'),'OutputName',...
    pvget(dat,'OutputName'),'InputUnit',pvget(dat,'InputUnit'),...
    'OutputUnit',pvget(dat,'OutputUnit'),'TimeUnit',pvget(dat,'TimeUnit'),...
    'Ts',T);
es = pvget(model,'EstimationInfo');
es.Status = 'Estimated (Impulse)';
es.Method = 'Impulse';
es.DataName = datn;
es.DataLength = sum(Ncaps);
es.DataTs = T;
es.DataInterSample = pvget(dat,'InterSample');
model= pvset(model,'EstimationInfo',es);

if nargout == 0
    impulse(model,varargin{2:end});
else
    ymod = model;
end

%--------------------------------------------------------------------------
function arg = low(arg)
for kk=1:length(arg)
    if ischar(arg{kk})
        arg{kk}=lower(arg{kk});
    end
end

