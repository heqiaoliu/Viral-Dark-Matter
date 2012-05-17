function sys = idpoly(varargin)
%IDPOLY  Create IDPOLY model structure.
%
%  M = IDPOLY(A,B,C,D,F,NoiseVariance,Ts)
%  M = IDPOLY(A,B,C,D,F,NoiseVariance,Ts,'Property',Value,..)
%
%  M: returned as a  model structure object describing the model
%
%     A(q) y(t) = [B(q)/F(q)] u(t-nk) + [C(q)/D(q)] e(t)
%
%  The variance of the white noise source e is NoiseVariance. Ts is
%  the sample interval. Ts = 0 means a continuous time model.
%  A,B,C,D and F are model's polynomials. IDPOLY model cannot be used to
%  represent multi-output systems. 
%
%  A, C, D are row vectors starting with 1. For a single-input
%  model, F and B are row vectors too such that F starts with 1 and B has
%  leading zeros denoting delays (nk). For multi-input systems, B and F are
%  cell arrays with Nu elements (Nu := number of inputs). You can also use
%  a double matrix with Nu rows, but the matrix format will be discontinued
%  in future. In time series case (model with no measured inputs), use []
%  for B and F polynomials.
%
%  Example: A = [1 -1.5 0.7], B = {[0 0.5 0 0.3], [0 0 1]}, Ts = 1 gives the
%  model y(t) - 1.5y(t-1) + 0.7y(t-2) = 0.5u1(t-1) + 0.3u1(t-3) + u2(t-2).
%
%  For a continuous time model, the polynomials are entered in descending
%  powers of s. Polynomials A, C, D and F are required to start with 1. 
%  Example: A = 1; B = {[1 2], 3}; C = 1; D = 1; F = {[1 0], 1}; 
%  Ts = 0 corresponds to the time-continuous system  Y = (s+2)/s U1 + 3 U2.
%
%  Trailing input arguments C, D, F, NoiseVariance, and Ts can be omitted,
%  in which case they are taken as 1's (except if B=[], then F=[]).
%
%  M = IDPOLY(SYS) creates an IDPOLY model for any single-output IDMODEL or
%      LTI object SYS. If SYS is an LTI model containing InputGroup
%      'Noise', that input will be treated as a white noise source when
%      computing the noise model of M. 
%
%  For more information on IDPOLY properties, type SET(IDPOLY). The
%  parameters of an IDPOLY model can be estimated using commands such as
%  ARX (if C=D=F=1), ARMAX (if F=D=1), OE (if A=C=D=1), BJ (if A=1) and PEM
%  (general case). An IDPOLY model can be transformed into other model
%  types such as IDSS and LTI objects using commands such as IDSS, TF, ZPK
%  etc.
%
%   See also POLYDATA, IDSS, IDPROC, IDARX, IDPROPS, ARX, ARMAX, BJ, OE,
%   PEM, IDMODEL/TF, IDPOLY/setPolyFormat. 

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.22.4.14 $ $Date: 2010/02/08 22:34:51 $

ni = nargin;
ABCDFT(1:7) = {[],[],[],[],[],1,1};
PVstart=[];
superiorto('iddata')
try
    superiorto('lti','zpk','ss','tf','frd')
end

doubleB = true;
if ni>0
    % Quick exit for idpoly objects
    if isa(varargin{1},'idpoly'),
        if ni~=1
            ctrlMsgUtils.error('Ident:general:useSetForProp','IDPOLY');
        end
        sys = varargin{1};
        return
    end
    if isa(varargin{1},'lti')
        LTIModel = varargin{1};
        if isa(varargin{1},'frd')
            ctrlMsgUtils.error('Ident:idmodel:frd2Idpoly')
        end
        [ny,nu] = size(LTIModel);
        if ny>1
            ctrlMsgUtils.error('Ident:transformation:MIMOmodel2idpoly')
        end
        [num, den, Ts] = tfdata(LTIModel);
        inpd = get(LTIModel,'InputDelay');
        if isa(LTIModel,'zpk') || isa(LTIModel,'tf')
            inpd = inpd + get(LTIModel,'ioDelay').';
        end
        
        % Separate out Noise channels from Input channels
        groups = get(LTIModel,'InputGroup');
        nr = [];
        if isstruct(groups)
            if isfield(groups,'Noise')
                nr = groups.Noise;
            elseif isfield(groups,'noise')
                nr = groups.noise;
            end
        else %old CSTB syntax
            if ~isempty(groups)
                nri = strcmpi(groups(:,2),'noise');
                if any(nri)
                    nr = groups{nri,1};
                end
            end
        end
        
        if isempty(nr) % no noise
            [num, den, negDelay] = localMakeMonic(num, den, Ts~=0, false);
            if any(negDelay)
                ctrlMsgUtils.warning('Ident:transformation:ImproperDiscreteLTI')
            end
            sys = idpoly(1,num,1,1,den,1,abs(Ts),'InputDelay',negDelay+inpd);
            sys = pvset(sys,'BFFormat',-1);
        elseif length(nr)>1
            ctrlMsgUtils.error('Ident:transformation:LTIMultiChannelNoise')
        elseif nu==1 % no input channels
            [num, den, ~, noiseVar] = localMakeMonic(num, den, Ts~=0, true);
            num = num{1}; den = den{1}; 
            sys = idpoly(1,[],num,den,[],noiseVar,Ts);
            sys = pvset(sys,'BFFormat',-1);
        else % combination of measured and noise input groups
            MeasInp = 1:nu~=nr;
            if any(inpd(~MeasInp)>0)
                ctrlMsgUtils.error('Ident:transformation:NoiseInputDelay')
            end
            [numMeas, denMeas, negDelay] = localMakeMonic(num(MeasInp),den(MeasInp),Ts~=0,false);
            [numNois, denNois, ~, noiseVar] = localMakeMonic(num(nr),den(nr),Ts~=0,true);
            numNois = numNois{1}; denNois = denNois{1};
            sys = idpoly(1,numMeas,numNois,denNois,denMeas,noiseVar,Ts,...
                'InputDelay',negDelay+inpd(MeasInp));
            sys = pvset(sys,'BFFormat',-1);
        end
        sys = localCopyCommonData(sys, LTIModel);
        
        return
    end %LTI conversion
    
    if isa(varargin{1},'idarx')
        sys1 = varargin{1};
        [A,B] = arxdata(sys1);
        nu = size(sys1,2);
        if size(sys1,1)>1
            ctrlMsgUtils.error('Ident:transformation:MIMOmodel2idpoly')
        end
        
        a = A(:).';
        b = squeeze(B);
        if nu == 1, b = b(:).'; end
        was = ctrlMsgUtils.SuspendWarnings('Ident:idmodel:idpolyUseCellForBF');
        sys = idpoly(a,b,'Ts',pvget(sys1,'Ts'));
        delete(was)
        sys = inherit(sys,sys1);
        cov1 = pvget(sys1,'CovarianceMatrix');
        if ~isempty(cov1)
            par1 = pvget(sys1,'ParameterVector');
            sys1 = parset(sys1,(1:length(par1))');
            sys1 = pvset(sys1,'CovarianceMatrix',[]);
            sys2 = idpoly(sys1);
            par2 = pvget(sys2,'ParameterVector');
            par3 = find(par2<0);
            par4 = find(par2>0);
            cov = cov1(abs(par2),abs(par2));
            cov(par3,par4) = - cov(par3,par4);
            cov(par4,par3) = - cov(par4,par3);
            sys = pvset(sys,'CovarianceMatrix',cov);
        end
        return
    end %ARX conversion
    
    if (isa(varargin{1},'idss') || isa(varargin{1},'idgrey'))
        sysold = varargin{1};
        ny = size(sysold,'ny');
        if ny>1
            ctrlMsgUtils.error('Ident:transformation:MIMOmodel2idpoly')
        end
        
        [sys,sysold] = idpolget(sysold,'d');
        if ~isempty(sys)
            sys = sys{1};
            sys = inherit(sys,sysold); % so that Notes, UserData, Name etc are inherited
            sys = pvset(sys,'NoiseVariance',pvget(sysold,'NoiseVariance'));%%%%%%%%%%%%%%%%%%
        end
        
        if isempty(sys) % Then we could not compute cov-info
            % but should still provide an IDPOLY version
            [a,b,c,d,f] = polydata(sysold);
            WARN = ctrlMsgUtils.SuspendWarnings('Ident:idmodel:idpolyUseCellForBF');
            sys = idpoly(a,b,c,d,f,'Ts',pvget(sysold,'Ts'),'NoiseVariance',pvget(sysold,'NoiseVariance'));
            delete(WARN)
            % sys = pvset(sys,'NoiseVariance',pvget(sysold,'NoiseVariance'));
            sys = inherit(sys,sysold);
        end
        
        if length(varargin)>1
            for ky = 1:ny
                try
                    set(sys,varargin{2:end})
                catch E
                    throw(E)
                end
            end
        end
        return
    end
    
    % Dissect input list
    PVstart = find(cellfun('isclass',varargin,'char'),1,'first');
    if isempty(PVstart)
        DoubleInputs = ni;
    else
        DoubleInputs = PVstart - 1;
        if PVstart==1
            ctrlMsgUtils.error('Ident:idmodel:idpolyCheck1')
        end
    end
    
    % Zero arguments is OK, creates an empty object
    if DoubleInputs == 1
        ctrlMsgUtils.error('Ident:idmodel:idpolyNargChk')
    end
    
    % Omitted arguments default to empty.. set them up now
    % Then add any user-specified arguments
    ABCDFT(1:DoubleInputs) = varargin(1:DoubleInputs);
    
    % Must find Ts first, since the creator treats poly's differently
    if ~isempty(PVstart)
        for kk = PVstart:2:length(varargin)
            if strcmpi(varargin{kk},'ts')
                ABCDFT{7} = varargin{kk+1};
            end
        end
    end
    
    % check that B and F polynomials use identical data type
    CL1 = cellfun('isclass',ABCDFT(1:5),'double');
    CL2 = cellfun(@iscell,ABCDFT(1:5));
    
    if any(~CL1([1 3 4]))
        ctrlMsgUtils.error('Ident:idmodel:idpolyPolyFormatACD')
    elseif any(~CL1 & ~CL2)
        ctrlMsgUtils.error('Ident:idmodel:idpolyPolyFormatBF')
    end
    
    doubleB = CL1(2); doubleF = CL1(5);
    if (~doubleB && doubleF && ~isempty(ABCDFT{5})) || (~doubleF && doubleB && ~isempty(ABCDFT{2}))
        ctrlMsgUtils.error('Ident:idmodel:idpolyBFFormatMismatch');
    end
    
    try
        [na,nb,nc,nd,nf,nk,par,nu] = polychk(ABCDFT{:});
    catch E
        throw(E)
    end
    
    if doubleB && nu>1
        % should have used cell arrays
        ctrlMsgUtils.warning('Ident:idmodel:idpolyUseCellForBF');
    end
    
else % if ni==0
    nu = 0;
    na = 0; nb = zeros(1,0); nc = 0; nd = 0; nf = zeros(1,0); nk = zeros(1,0);
    par = [];
    ABCDFT{6} = 0;
end

% BFFormat: Controls format of B and F polynomials in multi-input
% case. By default it is -1 which causes warning to be thrown prompting
% user to set it to either 1 or 0, via the setPolyFormat method:
%  - If 0, backward-compatibility mode is enabled. When cell arrays
%  become default in future, B and F would continue to be returned as
%  doubles.
%  - If 1, B and F immediately revert to cell arrays and any user code
%  operating on these matrices must be updated to prevent errors.
%
% If users do not set it, warnings will continue to be thrown and default
% format (double) will be used. Hence value of -1 will be treated as 0 for
% computation purposes.
%
% If users construct a model using cell arrays for B/F, the property will
% be set to 1 automatically and no warnings will be issued.
% 
% Effect on GET(SYS) display:
%   1. No changes in SISO models.
%   2. MISO with BFFormat = 1 ("double mode"): "compatibility mode" will be
%      displayed at the bottom.
%   3. MISO with BFFormat = 0 ("cell mode"): No special display
%   4. MISO with BFFormat = -1: A message similar to warning will be
%      displayed advising users to make their choice.

if ~doubleB
    BFFormat = 0; % cell format in use
else
    % double data was used in constructor
    BFFormat = -1; % force users to set it; warning issued only if nu>1
end

sys = struct('na',na,'nb',nb,'nc',nc,'nd',nd,'nf',nf,'nk',nk,...
    'InitialState','Auto','BFFormat',BFFormat);

% The parent for IDPOLY models is always single-output
idparent = idmodel(1, nu);
idparent = pvset(idparent,'Ts',ABCDFT{7},'ParameterVector',par,...
    'CovarianceMatrix',[]);
idparent = timemark(idparent,'c');
sys = class(sys,'idpoly', idparent);
sys = pvset(sys,'NoiseVariance',ABCDFT{6});
%sys = timemark(sys,'c');

% Finally, set any PV pairs, some of which may be in the parent.
if ~isempty(PVstart)
    try
        set(sys, varargin{PVstart:end})
    catch E
        throw(E)
    end
end

%--------------------------------------------------------------------------
function [num, den, negDelay, nv] = localMakeMonic(num, den, isDT, isNoise)
% Make denominator polynomial monic in the transfer function num/den.
% Return zero access over pole as negative delay for discrete-time data.

if ~iscell(num)
    num = {num};
    den = {den};
end

nu = size(num,2);
negDelay = zeros(nu,1);
nv = 1;

for ct = 1:nu
    numct = num{ct};
    denct = den{ct};
    
    nr = find(numct,1,'first');
    dr = find(denct,1,'first');
    
    if isNoise && nr~=dr
        ctrlMsgUtils.error('Ident:transformation:BiproperNoiseTFRequired')
    end
    
    if isDT
        % Remove leading zeros and normalize
        numct = numct(min(nr,dr):end)/denct(dr);
        den{ct} = denct(dr:end)/denct(dr);
        negDelay(ct) = min(nr-dr,0);
    else
        % only normalize
        numct = numct/denct(dr);
        den{ct} = denct/denct(dr);
    end
    
    if isNoise
        noisestd = 1;
        if numct(1)~=1
            noisestd = numct(1);
            numct = numct/noisestd;
        end
        nv = noisestd^2;
    end
    num{ct} = numct;
end

%--------------------------------------------------------------------------
function sys = localCopyCommonData(sys, sys0)
% Copy I/O names, Name, Notes, UserData from LTI sys0 to IDPOLY sys.

sys = pvset(sys,'InputName',sys0.InputName,'OutputName',sys0.OutputName,...
    'Name',sys0.Name,'Notes',sys0.Notes,'UserData',sys0.UserData);
