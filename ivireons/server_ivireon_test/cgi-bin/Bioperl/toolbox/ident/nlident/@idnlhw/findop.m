function varargout = findop(nlsys, varargin)
%FINDOP Find operating point for Hammerstein-Wiener model.
% 
% An operating point is defined by the state (X) and input values (U) for
% the model. There are three ways of calculating the operating point:
%   (1) Using steady-state values of input and output signals:
%       [X,U] = FINDOP(SYS, 'steady', InputLevel)
%       [X,U] = FINDOP(SYS, 'steady', InputLevel, OutputLevel)
%       Determine X and U from steady-state specifications for model SYS.
%       Specify steady-state (constant) values for the model's input and
%       output channels. Use NaNs to denote unknown signal values. If
%       InputLevel is fully specified, OutputLevel is not required and
%       therefore need not be specified.  
%   
%   (2) Using snapshot of state and input values at a particular time
%       during the simulation of the model:
%       [X, U] = FINDOP(SYS, 'snapshot', T, UIN, X0)
%       Determine X and U at time T during the simulation of model SYS
%       using input UIN and initial states X0. Input should be specified as
%       a double matrix or an IDDATA object. The number of input channels in
%       UIN must match the number of inputs of SYS. Initial states X0 need
%       not be specified (assumed zero if not specified).
%       
%   (3) Using an Operating Point Specification object:
%       [X, U] = FINDOP(SYS, SPEC)
%       Search for equilibrium operating point using the input and output
%       signal specifications from object SPEC. Use OPERSPEC command to
%       obtain the SPEC object for model SYS. Once obtained, SPEC can be
%       configured to match specifications such as signal bounds, known
%       values, initial guesses etc. Type "help idnlhw/operspec" for more
%       information. The values of X and U are estimated using the
%       SearchMethod specified in model's Algorithm. The search is
%       performed for steady-state values of these variables. 
%
%    [X, U, REPORT] = FINDOP(...) delivers a report on optimization search
%    results when using option (1) or (3) above. Note that no numerical
%    optimization is performed with snapshot-based operating point
%    determination (option (2)).
%    
%    FINDOP(SYS, ..., PVPairs) allows specification of property-value pairs
%    for customizing the search method's algorithm (that is, override their
%    values in SYS.Algorithm). Useful properties to set are SearchMethod,
%    MaxSize, Tolerance, and Display. Note that Criterion used for operating
%    point search is always 'Trace' and 'Weighting' value is not used.
%
%  See also IDNLHW/OPERSPEC, IDNLHW/LINEARIZE, IDNLHW/FINDSTATES,
%  IDNLHW/SIM, IDNLARX/FINDOP. 

% Written by: Rajiv Singh
% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.10 $ $Date: 2009/03/09 19:15:00 $

ni = nargin;
no = nargout;
error(nargchk(2, Inf, ni,'struct'))

if ~isestimated(nlsys)
    ctrlMsgUtils.error('Ident:analysis:findopUninitializedModel')
end

% determine the type of specification
v = varargin{1};
if isa(v,'idutils.idnlhwopspec')
    try
        [varargout{1:no}] = LocalFindOpFromSpec(nlsys,varargin{:});
    catch E
        if strcmp(E.identifier,'Ident:estimation:unsupportedOptimAlgorithm')
            ctrlMsgUtils.error('Ident:analysis:findopUnderDetermined','idnlhw')             
        else
            throw(E)
        end
    end
elseif ischar(v)
    if strncmpi(v,'steady',length(v))
        % steady state specification
        try
            [varargout{1:no}] = LocalFindOpFromSteadyValues(nlsys,varargin{2:end});
        catch E
            throw(E)
        end
    elseif strncmpi(v,'snapshot',length(v))
        % snapshot specification
        try
            [varargout{1:no}] = LocalFindOpFromSnapshot(nlsys,varargin{2:end});
        catch E
            throw(E)
        end
    else
        ctrlMsgUtils.error('Ident:analysis:invalidFindopInput2','idnlhw/findop','idnlhw/operspec')
    end
else
    % same error as above
    ctrlMsgUtils.error('Ident:analysis:invalidFindopInput2','idnlhw/findop','idnlhw/operspec')
end


%--------------------------------------------------------------------------
function [x0, u0, report] = LocalFindOpFromSpec(nlsys,op,varargin)
% find operating point from given operspec object op

report = [];
easy = LocalValidateOP(op);
linmod = getlinmod(nlsys);
UNL = nlsys.InputNonlinearity;
%YNL = nlsys.OutputNonlinearity;
[A,B,C,D] = ssdata(linmod);
[ny,nu] = size(D);
Nx = size(A,1);

if easy
    u0 = op.Input.Value;
    ulin = LocalGetLinModInput(UNL,nu,u0);
    x0 = pinv(eye(Nx)-A)*B*ulin(:);

    if nargout>2
        str = 'NOTE: Input level is completely known.';
        msg = sprintf(['%s ',...
            'Equilibrium value of state is therefore determined as X = inv(I-A)*B*f(U), \n',...
            'where [A,B,C,D] = ssdata(SYS.LinearModel), U is input vector and f() is input nonlinearity.'],str);
        y0 = getJacobian(nlsys,u0,x0);
        report = struct(...
            'SearchMethod',sprintf('Not applicable (numerical optimization not used).\n%s',msg),...
            'WhyStop','',...
            'Iterations',[],...
            'FinalCost',[],...
            'FirstOrderOptimality',[],...
            'SignalLevels',struct('Input',u0(:)','Output',y0(:)')...
            );

    end
    return;
end

% ~easy case: Numerical optimization required
% Minimize ||ytarget - yequil|| for fixed y channels, where:
% yequil = g([C(I-A)\B+D]*f(u)); 
%          f: input NL; 
%          g: output NL.

% Check if algorithm properties must be updated
ni = nargin;
if ni>2
    % PV pairs were specified

    if rem(ni,2)~=0
        ctrlMsgUtils.error('Ident:general:CompleteOptionsValuePairs','findop','idnlhw/findop')
    end

    % parse algorithm properties
    [fnames, fvalues, pvlist] = algoshortcut(varargin);
    %pvlist(1:2:end) = lower(pvlist(1:2:end));
    if ~isempty(pvlist)
        if ischar(pvlist{1})
            ctrlMsgUtils.error('Ident:general:unrecognizedInput',pvlist{1},'idnlhw/findop')
        else
            ctrlMsgUtils.error('Ident:general:InvalidSyntax','findop','idnlhw/findop')
        end
    end

    if ~isempty(fnames)
        algo = pvget(nlsys, 'Algorithm');
        algo = setmfields(algo, fnames, fvalues);
        nlsys = pvset(nlsys, 'Algorithm', algo);
    end
end

u0s = op.Input;
y0s = op.Output;

% set up optimization problem
data = {y0s.Value};
modelobj = nlutilspack.idnlhwopmodel(nlsys,op);
Estimator = createEstimator(modelobj, data);
OptimInfo = minimize(Estimator); %yields optim values

% intrepret results
u0 = u0s.Value;
nu = length(u0);
u0(~u0s.Known) = OptimInfo.X(:)';
ulin = LocalGetLinModInput(UNL,nu,u0);
x0 = pinv(eye(Nx)-A)*B*ulin(:);
if nargout>2
    % create report
    algo = nlsys.Algorithm;
    y0 = getJacobian(nlsys,u0,x0);
    
    report = struct(...
        'SearchMethod',algo.SearchMethod,...
        'WhyStop',Estimator.whyStop(OptimInfo.ExitFlag),...
        'Iterations',OptimInfo.Output.iterations,...
        'FinalCost',OptimInfo.Cost,...
        'FirstOrderOptimality',OptimInfo.Output.firstorderopt,...
        'SignalLevels',struct('Input',u0(:)','Output',y0(:)')...
        );
end

%--------------------------------------------------------------------------
function [xN, u0, report]  = LocalFindOpFromSnapshot(nlsys,varargin)

report = struct(...
        'SearchMethod','Not applicable for simulation-snapshot based operating point determination.',...
        'WhyStop','',...
        'Iterations',[],...
        'FinalCost',[],...
        'FirstOrderOptimality',[],...
        'SignalLevels',struct('Input',[],'Output',[])...
        );
    
[ny,nu] = size(nlsys);
Ts = pvget(nlsys,'Ts');

ni = nargin;
if ni<3 
    ctrlMsgUtils.error('Ident:analysis:findopSnapshotTooManyInputs','idnlhw/findop')
end

T = varargin{1};
if ~isscalar(T) || ~isreal(T) || ~isfinite(T)
    ctrlMsgUtils.error('Ident:analysis:findopInvalidT1')
end

u = varargin{2};
if ~isa(u,'iddata') && ~(isrealmat(u) && all(isfinite(u(:))) && size(u,2)==nu)
    ctrlMsgUtils.error('Ident:analysis:findopInvalidU',nu)
elseif isa(u,'iddata')
    if ~strcmpi(u.Domain,'Time')
        ctrlMsgUtils.error('Ident:analysis:findopFreqDomainData')
    elseif size(u,'ne')>1
        ctrlMsgUtils.error('Ident:analysis:findopMultiExpDataNotSupported')
    end
end

if ~isa(u,'iddata')
    u = iddata([],u,Ts);
end

if T<u.TStart
    % same error message as above
    ctrlMsgUtils.error('Ident:analysis:findopInvalidT1')
end

if Ts~=u.Ts
    % sampling interval mismatch
    ctrlMsgUtils.error('Ident:analysis:TsMismatch')
    %u.Ts = Ts;
end

UNL = nlsys.InputNonlinearity;
linmod = getlinmod(nlsys);
[A,B] = ssdata(linmod);
Nx = size(A,1);
X0 = zeros(Nx,1);
if ni>3
    % X0 was specified
    x = varargin{3};
    if (ischar(x) && strncmpi('zero',x,length(x))) || isempty(x) 
        x = X0;
    elseif isrealvec(x) && (length(x)==Nx)
        x = x(:);
    else
        ctrlMsgUtils.error('Ident:analysis:findopSnapshotInvalidX0',Nx)
    end
    X0 = x;
end

N = floor((T-u.TStart)/Ts)+1;
Nsamp = size(u,1);
if N>Nsamp
    ctrlMsgUtils.error('Ident:analysis:findopInvalidT2')
end
u0 = u(N).u;
ulin = LocalGetLinModInput(UNL,nu,u.u);
x = ltitr(A,B,ulin,X0);
xN = x(N,:);
xN = xN(:);
if nargout>2
    report.SignalLevels.Input = u0;
    y0 = getJacobian(nlsys,u0,xN);
    report.SignalLevels.Output = y0;
end

%--------------------------------------------------------------------------
function varargout = LocalFindOpFromSteadyValues(nlsys,varargin)
% find operating point for a given set of input and output levels
% note: I/O levels may contain NaNs to denote unknown values

ni = nargin;
if ni<2
    ctrlMsgUtils.error('Ident:analysis:findopSteadyIOrequired')

end

op = operspec(nlsys);
nu = length(op.Input.Value);
ny = length(op.Output.Value);

u0 = varargin{1};
if ~(isrealvec(u0) && all(~isinf(u0)) && isequal(nu,length(u0)))
    ctrlMsgUtils.error('Ident:analysis:findopInvalidSteadyU','InputLevel',nu)
end
Ind = ~isnan(u0);
op.Input.Value(Ind) = u0(Ind);
op.Input.Known(~Ind) = false; % Known is true by default

varg = {};
if ni>2
    if ~ischar(varargin{2})
        y0 = varargin{2};
        if ~(isrealvec(y0) && all(~isinf(y0)) && isequal(ny,length(y0)))
            ctrlMsgUtils.error('Ident:analysis:findopInvalidSteadyUY','OutputLevel',ny)
        end
        Ind = ~isnan(y0);
        op.Output.Value(Ind) = y0(Ind);
        op.Output.Known(Ind) = true; % Known is false by default
        varg = varargin(3:end); % pv pairs
    else
        % pv pair begins
        varg = varargin(2:end);
    end
end

[varargout{1:nargout}] = LocalFindOpFromSpec(nlsys,op,varg{:});

%--------------------------------------------------------------------------
function easy = LocalValidateOP(op)
% check if OP spec is feasible and if an easy solution exists

easy = false;
Xu = op.Input;
if any((Xu.Value < Xu.Min) | (Xu.Value > Xu.Max))
    ctrlMsgUtils.error('Ident:analysis:findopInvalidOPSpec','Input.Value')
end

Xy = op.Output;
if any((Xy.Value < Xy.Min) | (Xy.Value > Xy.Max))
    ctrlMsgUtils.error('Ident:analysis:findopInvalidOPSpec','Output.Value')
end

if all(Xu.Known) %|| ~any(Xy.Known)
    % state vector can be determined using given value of input alone
    easy  = true;
    % Note: If ~any(Xy.Known), optimization still applies to keep signals
    % within constraints. This may be trivial if MIN/MAX bounds are -/+Inf.
end

if all(Xu.Known) && any(Xy.Known)
    ctrlMsgUtils.warning('Ident:analysis:findopIdnlhwOverSpecified');
end

%--------------------------------------------------------------------------
function ulin = LocalGetLinModInput(UNL,nu,u0)
% get output of input nonlinearity, which is input to linear block of
% idnlhw

ulin = zeros(size(u0,1),nu);
for ku = 1:nu
    ulin(:,ku) = soevaluate(UNL(ku),u0(:,ku));
end
