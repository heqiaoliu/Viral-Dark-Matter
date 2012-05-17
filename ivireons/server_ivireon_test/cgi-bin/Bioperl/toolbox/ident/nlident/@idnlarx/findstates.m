function [x0,report] = findstates(model, data, x0init, foc, varargin)
%FINDSTATES Estimate initial states of IDNLARX model for a given data set.
%
%   X0 = FINDSTATES(MODEL, DATA) estimates the states of MODEL that
%   minimize the error between the output measurements in DATA and the
%   predicted output of the model.
%
%   X0 = FINDSTATES(MODEL, DATA, X0INIT) allows specification of an initial
%   guess for value of X0. X0INIT must be a vector of length equal to the
%   number of model's states (= sum(getDelayInfo(MODEL)) ). Enter X0INIT =
%   [] to use the default value for initial states guess (determined from
%   data).
%
%   X0 = FINDSTATES(MODEL, DATA, X0INIT, PRED_OR_SIM) allows switching
%   between prediction-error (default) and simulation-error minimization.
%   Acceptable values values for PRED_OR_SIM are:
%      'prediction': Estimate initial states such that the difference
%                    between DATA output and 1-step ahead predicted
%                    response of the model are minimized. This is the
%                    default.
%      'simulation': Estimate initial states such that the difference
%                    between DATA output and simulated response of the
%                    model are minimized. This estimation can be
%                    considerably slower than 'prediction'.
%
%   X0 = FINDSTATES(MODEL, DATA, X0INIT, PRED_OR_SIM, PVPairs) allows
%   specification of property-values pairs representing the algorithm
%   properties that control the numerical optimization process. By default,
%   algorithm properties are read from MODEL.Algorithm. Use PV pairs to
%   override those values. Useful properties to set are SearchMethod,
%   MaxSize, Tolerance, and Display. Note that 'Criterion' used for
%   operating point search is always 'Trace'. Also, SearchMethod =
%   'lsqnonlin' usually works faster than other search methods
%   ('lsqnonlin' requires Optimization Toolbox(TM).)
%
%   [X0, REPORT] = FINDSTATES(...) delivers a report on results of
%   numerical optimization that is performed to search for the model
%   states.
%
%   State definition: The states of an IDNLARX model are defined using time
%   delayed input/output variables of the model. The number of delayed
%   terms used for each I/O variable is dictated by the maximum lag of
%   that variable in the model's regressors. See idnlarx/getDelayInfo for
%   more information.
%
%   See also IDNLHW/FINDSTATES, IDNLARX/FINDOP, IDNLARX/DATA2STATE,
%   GETDELAYINFO, GETREG.  

% Description of function's inputs and outputs:
%   Inputs:
%      MODEL:       An IDNLARX model object.
%      DATA:        An IDDATA object with matching input/output dimensions.
%                   For multi-experiment data, X0 is a matrix, where column
%                   k corresponds to experiment k of DATA.
%      X0INIT:      An initial guess of state vector/matrix.
%      PRED_OR_SIM: String 'prediction' or 'simulation'.
%      PV pairs:    Minimization algorithm properties as property-value
%                   pairs.
%   Outputs:
%      X0:     Estimated initial state vector.
%      REPORT: A report on optimization results, delivered as a struct.

% Written by: Rajiv Singh
% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.10 $ $Date: 2009/10/16 04:56:54 $

error(nargchk(2, Inf, nargin,'struct'))

Delays = getDelayInfo(model);
Nx = sum(Delays); % number of states
if Nx==0
    x0 = [];
    report = 'There are no states in the model.';
    return;
end

if nargin<3 || isempty(x0init)
    x0init = []; %to be scaled by data
end

if nargin<4 || isempty(foc)
    foc = 'p';
end


[model,data,x0init] = LocalValidateInput(model,data,x0init,foc,Delays,varargin{:});

Nsamp = size(data,1); Nsamp = min(Nsamp);
try
    showDisplay = ~strcmpi(model.Algorithm.Display,'off');
    modelobj = nlutilspack.idnlarxstatemodel(model, x0init, foc);
    if isempty(x0init) && strncmpi(foc,'s',1)
        % get good initial value by running a search over only first Nx samples
        Nsamp = min(Nx,Nsamp);
        Estimator = createEstimator(modelobj, data(1:Nsamp));
        if showDisplay
            disp('Calculating an initial guess for state vector values...')
        end
        OptimInfo = minimize(Estimator);
        modelobj.Data.X0guess = modelobj.var2obj(OptimInfo.X,Estimator.Option);

        if showDisplay
            disp(' ')
            disp('Updating state vector to best fit data...')
        end
    end

    Estimator = createEstimator(modelobj, data);
    OptimInfo = minimize(Estimator);
catch E
    throw(E)
end

x0 = var2obj(modelobj,OptimInfo.X,Estimator.Option);

if nargout>1
    % create report   
    if strncmpi(foc,'p',1)
        cost = '1-step prediction error minimization';
    else
        cost = 'Simulation error minimization';
    end

    report = struct(...
        'EstimationCriterion',cost,...
        'SearchMethod',model.Algorithm.SearchMethod,...
        'WhyStop',Estimator.whyStop(OptimInfo.ExitFlag),...
        'Iterations',OptimInfo.Output.iterations,...
        'FinalCost',OptimInfo.Cost,...
        'FirstOrderOptimality',OptimInfo.Output.firstorderopt);
end

%--------------------------------------------------------------------------
function [model,data,x0init] = LocalValidateInput(model,data,x0init,foc,Delays,varargin)
% validate inputs

try
    data = idutils.utValidateData(data,model,'time',true,'findstates');
catch E
    throw(E)
end

Nsamp = size(data,1); Nsamp = min(Nsamp);
Nx = sum(Delays);
Ne = size(data,'Ne');
if ~isempty(x0init) && (~isrealmat(x0init) || ~isequal(size(x0init),[Nx,Ne]))
    ctrlMsgUtils.error('Ident:analysis:findstatesInvalidInput1',Nx,Ne);
end

% Check if algorithm properties must be updated
ni = nargin;
if ni>5
    % PV pairs were specified

    if rem(ni-1,2)~=0
        ctrlMsgUtils.error('Ident:general:CompleteOptionsValuePairs',...
            'findstates','idnlarx/findstates')
    end

    % parse algorithm properties
    [fnames, fvalues, pvlist] = algoshortcut(varargin);
    %pvlist(1:2:end) = lower(pvlist(1:2:end));
    if ~isempty(pvlist)
        if ischar(pvlist{1})
            ctrlMsgUtils.error('Ident:general:unrecognizedInput',...
                pvlist{1},'idnlarx/findstates')
        else
            ctrlMsgUtils.error('Ident:general:InvalidSyntax','findstates','idnlarx/findstates')
        end
    end

    if ~isempty(fnames)
        algo = pvget(model, 'Algorithm');
        algo = setmfields(algo, fnames, fvalues);
        model = pvset(model, 'Algorithm', algo);
    end
end

% Handle Focus
% focus should be 'prediction' or 'simulation'
if ~any(strncmpi(foc,{'prediction','simulation'},length(foc)))
    ctrlMsgUtils.error('Ident:analysis:findstatesInvalidInput2')
end


% Reduce data size for focus = 'prediction' to fist N samples, where N is
% max(Delays) or sum(Delays).
if strncmpi(foc,'p',1)
    mD = max(Delays);
    if strncmpi(model.Algorithm.SearchMethod,'lsq',3)
        mD = Nx; %lsqnonlin cannot handle under-determined cases
    end
    if Nsamp>=mD
        data = data(1:mD);
    else
        ctrlMsgUtils.error('Ident:analysis:findstatesTooFewSamples',mD);
    end
end
