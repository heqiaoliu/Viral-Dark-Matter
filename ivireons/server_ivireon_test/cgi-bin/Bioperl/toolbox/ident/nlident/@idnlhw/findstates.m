function [x0,report] = findstates(model, data, x0init, varargin)
%FINDSTATES Estimate initial states of IDNLHW model for a given data set.
%
% The states of an IDNLHW model are defined as the states of its embedded
% linear model (MODEL.LinearModel). If the linear model is not in
% state-space form, the states should be interpreted as those
% corresponding to its IDSS-converted format (see SSDATA).
%
% Calling Syntax:
%   X0 = FINDSTATES(MODEL, DATA) estimates the states of MODEL that provide
%   the best (least-squares) fit to output signal in DATA. X0 is the value
%   of states at time DATA.TStart. 
%   Inputs:
%       MODEL: an IDNLHW model object.
%       DATA:  an IDDATA object with matching input/output dimensions. For
%       multi-experiment data, X0 is a matrix, where column k corresponds
%       to experiment k of DATA.
%   Output:
%       X0: estimated initial state vector.
%
%   X0 = FINDSTATES(MODEL, DATA, X0INIT) allows specification of an initial
%   guess for value of X0. X0INIT must be a vector of length equal to the
%   number of model's states. Enter X0INIT = [] to use the default value
%   for initial states guess (determined from data).
%   
%   X0 = FINDSTATES(MODEL, DATA, X0INIT, PVPairs) allows specification of
%   property-values pairs representing the algorithm properties that
%   control the numerical optimization process. By default, algorithm
%   properties are read from MODEL.Algorithm. Use PV pairs to override
%   those values. Useful properties to set are SearchMethod, MaxSize,
%   Tolerance, and Display. Note that 'Criterion' used for operating point
%   search is always 'Trace'. 
%   
%   [X0, REPORT] = FINDSTATES(...) delivers a report on results of numerical
%   optimization that is performed to search for the model states. Note
%   that numerical optimization will not be used if model has no output
%   nonlinearities (MODEL.OUTPUTNONLINEARITY is UNITGAIN for all outputs).
%
% See also IDNLARX/FINDSTATES, IDMODEL/FINDSTATES, IDNLHW/FINDOP,
% IDMODEL/SSDATA. 

% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2009/04/21 03:23:06 $

error(nargchk(2, Inf, nargin,'struct'))

linmod = getlinmod(model);
A = ssdata(linmod);
Nx = size(A,1);
if Nx==0
    x0 = [];
    report = 'There are no states in the model.';
    return;
end

if nargin<3 || isempty(x0init)
    x0init = []; %to be scaled by data
end

% check data, update model algorithm and compensate data for inputNL
[model,data,x0init] = LocalValidateInput(model,data,x0init,Nx,varargin{:});

YNL = model.OutputNonlinearity;

if isall(YNL,'unitgain')
    [err, x0] = pe(linmod,data,'init','e');
    report = 'No numerical optimization used.';
    return
elseif isempty(x0init)
    x0init = zeros(Nx,1);
end

try
    modelobj = nlutilspack.idnlhwstatemodel(model,x0init);    
    Estimator = createEstimator(modelobj, data);
    OptimInfo = minimize(Estimator);
catch E
    throw(E)
end

x0 = var2obj(modelobj,OptimInfo.X,Estimator.Option);

if nargout>1
    % create report    
    report = struct(...
        'SearchMethod',model.Algorithm.SearchMethod,...
        'WhyStop',Estimator.whyStop(OptimInfo.ExitFlag),...
        'Iterations',OptimInfo.Output.iterations,...
        'FinalCost',OptimInfo.Cost,...
        'FirstOrderOptimality',OptimInfo.Output.firstorderopt);
end

%--------------------------------------------------------------------------
function [model,data,x0init] = LocalValidateInput(model,data,x0init,Nx,varargin)
% validate inputs

UNL = model.InputNonlinearity;
nu = length(UNL);

try
    data = idutils.utValidateData(data,model,'time',true,'findstates');
catch E
    throw(E)
end

Ne = size(data,'Ne');
if ~isempty(x0init) && (~isrealmat(x0init) || ~isequal(size(x0init),[Nx,Ne]))
    ctrlMsgUtils.error('Ident:analysis:findstatesInvalidInput1',Nx,Ne)
end

% compensate data for input nonlinearity
u = pvget(data,'InputData');
for k = 1:length(u)
    for i = 1:nu
        u{k}(:,i) = soevaluate(UNL(i), u{k}(:,i));
    end
end
data = pvset(data, 'InputData', u);

% Check if algorithm properties must be updated
ni = nargin;
if ni>4
    % PV pairs were specified

    if rem(ni,2)~=0
        ctrlMsgUtils.error('Ident:general:CompleteOptionsValuePairs',...
            'findstates','idnlhw/findstates')
    end

    % parse algorithm properties
    [fnames, fvalues, pvlist] = algoshortcut(varargin);
    %pvlist(1:2:end) = lower(pvlist(1:2:end));
    if ~isempty(pvlist)
        if ischar(pvlist{1})
            ctrlMsgUtils.error('Ident:general:unrecognizedInput',...
                pvlist{1},'idnlhw/findstates')
        else
            ctrlMsgUtils.error('Ident:general:InvalidSyntax',...
                'findstates','idnlhw/findstates')
        end
    end

    if ~isempty(fnames)
        algo = pvget(model, 'Algorithm');
        algo = setmfields(algo, fnames, fvalues);
        model = pvset(model, 'Algorithm', algo);
    end
end
