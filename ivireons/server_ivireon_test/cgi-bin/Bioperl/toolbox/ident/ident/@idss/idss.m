function sys = idss(varargin)
%IDSS  Create IDSS model structure
%
%   M = IDSS(A,B,C,D)
%   M = IDSS(A,B,C,D,K,X0,Ts)
%   M = IDSS(A,B,C,D,K,X0,Ts,'Property',Value,..)
%   M = IDSS(MOD)
%       Where MOD is any SS, TF, or ZPK model or any IDMODEL object.
%
%   M: returned as a model structure object describing the discrete-
%      time model
%
%      x[k+1] = A x[k] + B u[k] + K e[k] ;      x[0] = X0
%        y[k] = C x[k] + D u[k] + e[k]
%
%   A,B,C,D and K are the state-space matrices.  X0 is the initial
%   condition, if any, and Ts is the sampling time.  For Ts == 0, a
%   continuous-time model is constructed.
%
%   Trailing K, X0, and Ts can be omitted, in which case they default
%   to K = zeros(nx,ny), X0 = zeros(nx,1), and Ts = 1.  Here nx and
%   ny are the number of states and outputs, i.e. size(C) = [nx ny].
%
%   M = IDSS(MOD) translates the model information in MOD.
%   If MOD is an LTI object with no InputGroup 'Noise' defined
%   an IDSS model with no noise characteristics (K = 0) is obtained.
%   However, by default a unit variance noise source will be added to
%   the output. To add no noise, add ...,'NoiseVariance',zeros(ny,ny),...
%   to the input arguments.
%   If MOD has an InputGroup 'Noise', these inputs are interpreted
%   as independent white noise sources with unit variances. Then K
%   and NoiseVariance are computed from the Kalman filter for this model.
%
%   M = IDSS creates an empty object.
%
%   See IDHELP SSBB for how to deal with State-space black-box models
%   and IDHELP SSSTRUC for dealing with State-space models with internal
%   structure. For more info on IDSS properties, type IDPROPS IDSS or
%   SET(IDSS). 
%
%   See also SETSTRUC, IDPOLY, IDPROC, N4SID, PEM, SS.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.26.4.9 $  $Date: 2009/11/09 16:23:38 $

ni = nargin;
if ni==0
    sys = idss([],[],[],[]);
    return
end
if ni == 1 && isa(varargin{1},'double')
    [nY,nU] = size(varargin{1});
    sys = idss([],zeros(0,nU),zeros(nY,0),varargin{1});
    return
end

if isa(varargin{1},'idss')
    if ni~=1
        ctrlMsgUtils.error('Ident:general:useSetForProp','IDSS')
    end
    sys = varargin{1};
    return
end

if (isa(varargin{1},'ss') || isa(varargin{1},'zpk') || isa(varargin{1},'tf'))
    sysin = ss(varargin{1});
    od = get(varargin{1},'OutputDelay');
    if norm(od)>0
        ctrlMsgUtils.warning('Ident:transformation:LTI2IdModelOutputDelay','IDSS')
    end
    
    if isa(varargin{1},'ss') 
        od = get(varargin{1},'InternalDelay');
        if norm(od)>0
            ctrlMsgUtils.warning('Ident:transformation:SS2IDSSInternalDelay')
        end
    else
        od = get(varargin{1},'ioDelay');
        if norm(od)>0
            ctrlMsgUtils.warning('Ident:transformation:LTI2IDSSioDelay',upper(class(varargin{1})))
        end
    end
    
    [a,b,c,d] = ssdata(varargin{1});
    dd = d;
    [ny,nu] = size(d);
    nr = [];
    groups = get(varargin{1},'InputGroup');
    if isstruct(groups)
        if isfield(groups,'Noise')
            nr = groups.Noise;
        elseif isfield(groups,'noise')
            nr = groups.noise;
        end
    else %old CSTB syntax
        try
            nr = find(strcmpi(groups(:,2),'noise'));
        end
    end
    inpd = get(sysin,'InputDelay');
    if isempty(nr) % no noise
        k = zeros(size(a,1),size(c,1));
        pinno = eye(ny);%  This may be questionable: Noise added in simulations
        inno = 1:nu;
    else
        if isa(groups,'cell')
            nono = groups{nr,1};
        else
            nono = nr;
        end
        
        if min(nono) ~= nu-length(nono)+1
            ctrlMsgUtils.error('Ident:idmodel:idssNoiseInputOrder')
        end
        set(sysin,'InputDelay',zeros(nu,1)); %will not use input delays to compute k.
        inno = 1:(min(nono)-1);
        minno = max(inno);if isempty(minno),minno=0;end
        b = b(:,inno);
        dd = d(:,inno);
        was = ctrlMsgUtils.SuspendWarnings;
        try
            [~,k,pp] = kalman(sysin,eye(length(nono)),zeros(ny,ny),zeros(length(nono),ny));
            if get(sysin,'Ts')
                pinno = c*pp*c'+d(:,minno+1:end)*d(:,minno+1:end)';
            else
                pinno = d(:,minno+1:end)*d(:,minno+1:end)';
            end
        catch
            k = zeros(size(a,1),ny);
            pinno = eye(ny);  %see above
            %disp('K set to zero')
            
        end
        delete(was)
    end
    
    sys = idss(a,b,c,dd,k,zeros(size(a,1),1),...
        abs(get(varargin{1},'Ts')),'NoiseVariance',pinno,...
        'InputDelay',inpd(inno),varargin{2:end});
    
    sys = localCopyCommonData(sys, varargin{1});
    
    xlabel = get(sysin,'StateName');
    if ~isempty(xlabel) && ~isequal('',xlabel{:}) && length(unique(xlabel))==length(xlabel)
        sys = pvset(sys,'StateName',xlabel);
    end
    if get(varargin{1},'Ts')==0
        sys = pvset(sys,'InputDelay',get(varargin{1},'InputDelay'));
    end
    return
end
nkflag = 0;
if isa(varargin{1},'idmodel')
    oldsys1 = varargin{1};
    oldsys =  oldsys1;
    if isa(oldsys1,'idpoly')
        nk = pvget(oldsys1,'nk');
        if any(nk>1) && pvget(oldsys1,'Ts')>0
            oldsys = pvset(oldsys1,'nk',(nk>=1));
            nkflag = 1;
        end
    end
    [a,b,c,d,k,x0]=ssdata(oldsys);
    lam = pvget(oldsys,'NoiseVariance');
    if norm(lam)==0
        k = zeros(size(k));
    end
    ts = pvget(oldsys,'Ts');
    sys = idss(a,b,c,d,k,x0,ts,'NoiseVariance',lam,varargin{2:end});
    
    if isa(oldsys,'idarx')
        ms = getarxms(pvget(oldsys,'na'),pvget(oldsys,'nb'),pvget(oldsys,'nk'));
        if any(any(isnan(ms.As))')
            ms.Cs = ms.As(1:size(ms.Cs,1),:);
        end
        sys = pvset(sys,'As',ms.As,'Bs',ms.Bs,'Cs',ms.Cs,...
            'Ds',ms.Ds,'Ks',ms.Ks,'X0s',ms.X0s);
        covv = pvget(oldsys,'CovarianceMatrix');
        if any(any(isnan(ms.As))') && ~ischar(covv)
            sys = pvset(sys,'CovarianceMatrix',[[covv,covv];[covv,covv]]);
        else
            sys = pvset(sys,'CovarianceMatrix',covv);
        end
    end
    
    if nkflag
        if strcmp(pvget(sys,'SSParameterization'),'Structured')
            sys = pvset(sys,'SSParameterization','Free');
            sys = pvset(sys,'nk',nk);
            sys = pvset(sys,'SSParameterization','Structured');
        else
            sys = pvset(sys,'nk',nk);
        end
    end
    sys = inherit(sys,oldsys);
    if isa(oldsys,'idpoly')||isa(oldsys,'idproc')
        ut = pvget(sys,'Utility');
        ut.Idpoly = {noisecnv(oldsys1)};
        sys = uset(sys,ut);
    end
    return
end

% Quick exit for idss objects

superiorto('idpoly')
superiorto('iddata')
try
    superiorto('lti','zpk','ss','tf','frd')
end
% Dissect input list
PVstart = find(cellfun('isclass',varargin,'char'), 1 );
if isempty(PVstart)
    DoubleInputs = ni;
else
    DoubleInputs = PVstart - 1;
    if PVstart==1
        ctrlMsgUtils.error('Ident:idmodel:idssCheck1')
    end
end

if DoubleInputs > 0 && DoubleInputs < 4
    ctrlMsgUtils.error('Ident:idmodel:idssNargChk')
end

nx = size(varargin{1},1);
%[ny] = size(varargin{3},1);
% nu = size(varargin{2},2);
[ny,nu] = size(varargin{4});
if nu == 0
    varargin{2} = zeros(nx,0);
    varargin{4} = zeros(ny,0);
end
if nx == 0
    varargin{1} = zeros(0,0);
    varargin{2} = zeros(0,nu);
    varargin{3} = zeros(ny,0);
end

% Default values, overwritten by input arguments
ABCDKXT = {[],[],[],[],zeros(nx,ny),zeros(nx,1),1};
ABCDKXT(1:DoubleInputs) = varargin(1:DoubleInputs);
error(abccheck(ABCDKXT{:}))
% Compute structure matrices as free initially
values = {'Free',[],[],[],[],[],[]};
for k=1:3,
    values{k+1} = NaN*ABCDKXT{k}; % Treat D, K and X0 correctly
end
if nu==0
    values{5} = zeros(size(values{4},1),0);
else
    for ku = 1:nu  %% To set nk in accordance with numerical values of D
        if norm(ABCDKXT{4}(:,ku))==0
            values{5}(:,ku) = zeros(ny,1);
        else
            values{5}(:,ku) = NaN*ones(ny,1);
        end
    end
end
for k=5:6,
    if norm(ABCDKXT{k})==0
        values{k+1} = ABCDKXT{k};
    else
        values{k+1} = NaN*ABCDKXT{k};
    end
end
testu = ABCDKXT(1:6);
status = abccheck(testu{:},'mat');
error(status)
[par,status] = findnan(ABCDKXT(1:6), values(2:7));
if nx>0
    values{8}=defnum([],'x',nx);
else
    values{8} = cell(0,1);
end
values{9}='Auto';
values{10}='Auto';
sys = cell2struct(values,...
    {'SSParameterization','As','Bs','Cs','Ds','Ks','X0s','StateName',...
    'InitialState', 'CanonicalIndices'},2);

idparent = idmodel(ny, nu);
idparent = pvset(idparent,'Ts',ABCDKXT{7},'ParameterVector',par,'CovarianceMatrix',[]);

sys = class(sys, 'idss', idparent);
sys = timemark(sys,'c');
% Finally, set any PV pairs, some of which may be in the parent.
if ~isempty(PVstart)
    PVPairs = varargin(PVstart:end);
    if rem(numel(PVPairs),2)~=0
        ctrlMsgUtils.error('Ident:general:CompletePropertyValuePairs','IDSS','idss')
    end
    try
        set(sys, varargin{PVstart:end})
    catch E
        throw(E)
    end
end


%--------------------------------------------------------------------------
function sys = localCopyCommonData(sys, sys0)
% Copy I/O names, Name, Notes, UserData from LTI sys0 to IDSS sys.

sys = pvset(sys,'InputName',sys0.InputName,'OutputName',sys0.OutputName,...
    'Name',sys0.Name,'Notes',sys0.Notes,'UserData',sys0.UserData);
