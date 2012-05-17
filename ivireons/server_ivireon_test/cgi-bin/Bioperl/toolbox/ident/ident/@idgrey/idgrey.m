function sys = idgrey(varargin)
%IDGREY Create IDGREY model structure representing a linear grey-box model.
%
%   M = IDGREY(FileName,ParameterVector,CDFile,FileArgument)
%   M = IDGREY(FileName,ParameterVector,CDFile,...
%              FileArgument,Ts,'Property',Value,...)
%
%   M: returned as a IDGREY model object describing a user defined
%      linear model structure.
%
%   FileName is the name of the MATLAB file that describes the structure.
%     It should have the format:
%
%     [A,B,C,D,K,X0] = FileName(ParameterVector,Ts,FileArgument)
%
%     where the output describes the linear system in innovations form:
%
%      xn(t) = A x(t) + B u(t) + K e(t) ;      x(0) = X0
%       y(t) = C x(t) + D u(t) + e(t)
%
%     in continuous or discrete time. Here xn(t) = x(t+Ts) in
%     discrete time and xn(t) = d/dt x(t) in continuous time.
%
%   ParameterVector is the (column) vector of nominal parameters that
%      determine the model matrices. These correspond to the free
%      parameters to be estimated.
%
%   CDFile describes how the user written MATLAB file handles
%   continuous/discrete time models.
%      CDFile = 'c' means that the user written MATLAB file always returns
%           the continuous time system matrices, no matter the value of Ts.
%           The sampling of the system will be done by the toolbox's
%           internal algorithms, in accordance with the indicated
%           data intersample behaviour. (DATA.InterSample).
%      CDFile = 'cd' means that the MATLAB file is written so that it returns
%           the continuous time system matrices when the argument Ts = 0,
%           and the discrete time system matrices, obtained by sampling with
%           sampling interval Ts when Ts > 0. In this case the user's choice
%           of sampling routines will override the toolbox's internal sampling
%           algorithms.
%      CDFile = 'd' means that the MATLAB file always returns discrete
%           time model matrices that may or may not depend on the
%           value of Ts.
%
%   FileArgument is an extra argument to the MATLAB file that can be used
%      in any suitable way.
%
%   Ts is the sampling interval of the model.
%      Default: Ts = 1 if CDFile = 'd'
%               Ts = 0 if CDFile = 'c' or 'cd'. (Continuous time model)
%
%   For more info on IDGREY properties, type "IDPROPS IDGREY". Note that
%   the specified MATLAB file (the "FileName" input argument) is stored in
%   a property called "MfileName". The value of "CDFile" is stored in a
%   property called "CDmfile".
%
%   See also IDSS, IDNLGREY.

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.15.4.8 $  $Date: 2010/03/22 03:48:46 $

ni = nargin;
if ni == 0
    sys = idgrey([],[],'c',[]);
    return
end

if (isa(varargin{1},'ss') || isa(varargin{1},'zpk') || isa(varargin{1},'tf') ||...
        (isa(varargin{1},'idmodel') && ~isa(varargin{1},'idgrey')) || isa(varargin{1},'idfrd') ) 
    ctrlMsgUtils.error('Ident:idmodel:convertToIdgrey')
end

% Quick exit for idgrey objects
if  isa(varargin{1},'idproc')
    sys = pvget(varargin{1},'idgrey');
    sys.DisturbanceModel = 'Model';
    return
end

if isa(varargin{1},'idgrey'),
    if ni~=1
        ctrlMsgUtils.error('Ident:general:useSetForProp','IDGREY');
    end
    sys = varargin{1};
    return
end

superiorto('idpoly')
superiorto('iddata')
try
    superiorto('lti','zpk','ss','tf','frd')
end

% Dissect input list
PVstart = find(cellfun('isclass',varargin(5:end),'char'),1,'first')+4;
if isempty(PVstart),PVstart=0;end

mfna = varargin{1};
if ~isempty(mfna)
    if ~ischar(mfna)
        ctrlMsgUtils.error('Ident:idmodel:idgreyInvalidMFile')
    end
end
par = varargin{2}; % Check size
if ~isa(par,'double')
    ctrlMsgUtils.error('Ident:idmodel:idgreyInvalidPar')
end

par = par(:);
cd = varargin{3};

if ~ischar(cd) || ~any(strcmpi(cd,{'c','cd','d'}))
    ctrlMsgUtils.error('Ident:idmodel:idgreyInvalidCdmfile')
end

if nargin>3
    arg = varargin{4};
else
    arg = [];
end

if nargin > 4 && (PVstart==6 || PVstart==0)
    Ts = varargin{5};
else
    if cd == 'd'
        Ts = 1;
    else
        Ts = 0;
    end
end

if ~isempty(varargin{1})

    try
        [A,B,C,D,K,X0] = feval(mfna,par,Ts,arg);
    catch Exc
        ctrlMsgUtils.error('Ident:idmodel:idgreyCheck1',mfna,Exc.message);
    end

    error(abccheck(A,B,C,D,K,X0,'mat'))
    if isempty(B)
        if size(B,1)~=size(A,1) || size(D,1)~=size(C,1)
            ctrlMsgUtils.error('Ident:idmodel:idgreyCheck2',mfna,size(A,1),size(C,1))
        end
    end
else
    Ts = 1;D = [];A = []; cd = 'c'; B = []; mfna = [];
end
ny = size(D,1);nx = size(A,1);nu =size(B,2);
sys.MfileName = mfna;
if nx>0
    sys.StateName = defnum([],'x',nx);
else
    sys.StateName = cell(0,1);
end

sys.CDmfile = cd;
sys.FileArgument = arg;
sys.InitialState = 'Model';
sys.DisturbanceModel = 'Model';
idparent = idmodel(ny, nu);
idparent = pvset(idparent,'Ts',Ts,'ParameterVector',par,'CovarianceMatrix',[]);
sys = class(sys, 'idgrey', idparent);
sys = timemark(sys,'c');

% If the parameter vector is a scalar, make sure that it is still indexed:
% todo: this should not be necessary; the MATLAB file should always be called
% with right size of parameter vector.
if length(par)==1
    try
        [A,B,C,D,K,X0] = feval(mfna,[par;1],Ts,arg); %#ok<NASGU>
    catch %#ok<CTCH>
        ctrlMsgUtils.warning('Ident:idmodel:idgreyCheck3')
    end
end
% Finally, set any PV pairs, some of which may be in the parent.
if PVstart>0
    try
        set(sys, varargin{PVstart:end})
    catch E
        throw(E)
    end
end
