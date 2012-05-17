function [yhat,x0]=predict(sys, data, K, varargin)
% PREDICT computes prediction with an IDNLHW model.
%
%  YP = PREDICT(MODEL, DATA)
%
%  MODEL: the IDNLHW object.
%  DATA: The output-input data, an IDDATA object.
%  YP: the resulting predicted output as an IDDATA object. If DATA
%      contains multiple experiments, so will YP.
%
%  YP = PREDICT(SYS, DATA, K, INIT) or
%  YP = PREDICT(MODEL,DATA,K,'InitialState',INIT) allows to specify the
%      initialization.
%
%  INIT: initialization specification, one of
%
%    - 'e': estimated initial states minimizing the sum of the squared
%      prediction errors. This is the default value.
%
%    - X0: a real column vector, for the initial state vector. To build an
%      initial state vector from a given set of input-output data or to
%      generate equilibrium states, see IDNLHW/FINDSTATES and IDNLHW/FINDOP.
%      For multi-experiment DATA, X0 may be a matrix whose columns give
%      different initial states for different experiments.
%
%    - 'z', zero initial state, equivalent to a zero vector of appropriate
%      size.
%
%  K: prediction horizon, ignored for IDNLHW models which are of Output
%    Error character.
%
%  See also IDNLHW/SIM, IDNLHW/FINDOP, IDNLHW/FINDSTATES.

% Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2008/10/02 18:54:20 $

% Author(s): Qinghua Zhang

ni = nargin;
no = nargout;
error(nargchk(2,inf,ni, 'struct'));

% Set up default value
xinit = simpredictoptions({'InitialState'}, {'e', 'z', 'm'}, varargin{:});

if ni>2 && ~(isempty(K) || (isreal(K) && isscalar(K) && round(K)==K))
    ctrlMsgUtils.error('Ident:analysis:predictInvalidHorizon')
end

% Interchange model and data arguments if necessary
if isa(sys,'iddata') && isa(data, 'idnlhw')
    tempo = sys;
    sys = data;
    data = tempo;
    clear tempo
end

[ny, nu] = size(sys);

if isa(data, 'iddata')
    iddataflag = 1;
    [nobs,ndy,ndu,nde] = size(data);
    
    if ndu~=nu
        ctrlMsgUtils.error('Ident:general:modelDataInputDimMismatch')
    end
    
elseif ~isempty(data) && isnumeric(data) && ndims(data)==2 && all(all(isfinite(data)))
    iddataflag = 0;
    nde = 1;
    
    if size(data,2)==(ny+nu)    % y and u data provided
        data = iddata(data(:,1:ny), data(:,ny+1:end));
    elseif size(data,2)==nu       % only u data provided
        data = iddata(zeros(size(data,1),ny), data);
    else
        ctrlMsgUtils.error('Ident:general:modelDataDimMismatch')
    end
else
    ctrlMsgUtils.error('Ident:general:invalidData')
end

% first input check: must be a valid IDNLHW model
if ~isa(sys,'idnlhw')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','predict','IDNLHW')
end

if ~isestimated(sys)
    ctrlMsgUtils.error('Ident:utility:nonEstimatedModel','predict','nlhw')
end

% Warning on data properties
if iddataflag
    msg = datapropwarns(data, sys, ...
        {'Ts', 'OutputName', 'OutputUnit', 'InputName', 'InputUnit', 'TimeUnit'});
    for km=1:length(msg)
        %todo
        warning('Ident:general:dataModelPropMismatch', msg{km});
    end
end

if isrealmat(xinit)
    if isvector(xinit)
        xinit = xinit(:);
    end
    A = ssdata(getlinmod(sys));
    nx = size(A,1);
    if size(xinit,1)~=nx
        ctrlMsgUtils.error('Ident:analysis:x0Size', nx)
    end
    if size(xinit,2)~=nde && size(xinit,2)~=1
        if nde==1
            ctrlMsgUtils.error('Ident:analysis:x0Size', nx)
        else
            ctrlMsgUtils.error('Ident:analysis:x0SizeMultiExp')
        end
    end
elseif ischar(xinit) && strcmpi(xinit,'e')
    xinit = findstates(sys, data,[],'Display','off');
elseif ~(ischar(xinit) && strcmpi(xinit,'z'))
    ctrlMsgUtils.error('Ident:analysis:idnlmodelINITval','predict','idnlhw/predict')
end

if nde>1 && size(xinit,2)==1
    xinit = xinit(:,ones(1,nde));
end

yhat = data;
yhat.u = [];

if nde>1
    x0 = cell(1, nde);
    ydata = cell(nde,1);
    for ke=1:nde
        [ydata{ke}, x0{ke}] = SingleExpPredict(sys, getexp(data,ke), xinit(:,ke));
    end
    yhat = pvset(yhat, 'OutputData', ydata);
else
    [yhat.y, x0] = SingleExpPredict(sys, data, xinit);
end

if ~iddataflag
    yhat = yhat.y;
end

if no>1
    if ischar(x0) || iscellstr(x0)
        A = ssdata(getlinmod(sys));
        x0 = zeros(size(A,1), nde);
    elseif nde>1
        x0 = cell2mat(x0);
    end
elseif no==0
    utidplot(sys,yhat,'Predicted')
    clear yhat x0
end

%=======================================================================
function [yhat, xinit] = SingleExpPredict(sys, data, xinit)
% Predict for single experiment

nobs = size(data,1);
%x0 =[];
nb = pvget(sys,'nb');

[ny, nu] = size(nb);

inmdl = pvget(sys, 'InputNonlinearity');
if ~isa(inmdl,'unitgain')
    for ku=1:nu
        data.u(:,ku) = soevaluate(inmdl(ku), data.u(:,ku)); % diagonal nonlinearity
    end
end

if isnumeric(xinit)
    % To use user-specified xinit, convert the linear model to IDSS object.
    linsys = getlinmod(sys);
    yhat = sim(linsys, data.u, 'InitialState', xinit);
else
    yhat = zeros(nobs, ny);
    B = pvget(sys,'b');
    F = pvget(sys,'f');
    for ky=1:ny
        for ku=1:nu
            yhat(:,ky) = yhat(:,ky) + filter(B{ky,ku}, F{ky,ku}, data.u(:,ku));
        end
    end
end

outmdl = pvget(sys, 'OutputNonlinearity');
if ~isa(outmdl,'unitgain')
    for ky=1:ny
        yhat(:,ky) = soevaluate(outmdl(ky), yhat(:,ky)); % diagonal nonlinearity
    end
end

% FILE END
