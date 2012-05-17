function nlsys = pvset(nlsys, varargin)
%PVSET  Assigns values to one or more properties of an IDNLGREY object.
%   All properties must be specified with their exact (case-sensitive)
%   names.
%
%   NLSYS = PVSET(NLSYS, 'PROPERTY', VALUE) sets the property 'PROPERTY'
%   of the IDNLGREY object NLSYS to VALUE. An equivalent syntax
%   is
%
%      NLSYS.PROPERTY = VALUE;
%
%   NLSYS = PVSET(NLSYS, 'PROPERTY1', VALUE1, 'PROPERTY2', VALUE2, ...)
%   sets multiple property values of NLSYS in one single operation.
%
%   For more information on IDNLGREY properties, type IDPROPS IDNLGREY.
%
%   See also IDNLMODEL/SET.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.9 $ $Date: 2008/10/02 18:53:59 $
%   Written by Peter Lindskog.

% Check that the function was called with at least three arguments.
nin = nargin;
error(nargchk(3, Inf, nin, 'struct'));

% Check that the function is called with one output argument.
nout = nargout;
error(nargoutchk(1, 1, nout, 'struct'));

% Check that the function was called with an odd number of arguments.
if (rem(nin, 2) ~= 1)
    ctrlMsgUtils.error('Ident:general:CompletePropertyValuePairs','IDNLGREY','idnlgrey');
end

ny = nlsys.Order.ny;

% Get property-value pairs.
property = {varargin{1:2:end}};
value = {varargin{2:2:end}};

% If included, place Order first in the property-value list.
ind = strmatch('Order', property, 'exact');
if ~isempty(ind)
    property = {property{ind} property{setdiff((1:length(property)), ind)}};
    value = {value{ind} value{setdiff((1:length(property)), ind)}};
end

% Loop through varargin and assign values to all specified IDNLGREY
% properties.
checkconsistency = false;
for i = 1:length(property)
    if ~ischar(property{i})
        ctrlMsgUtils.error('Ident:general:invalidPropertyNames')
    end
    
    switch property{i}
        % IDNLGREY specific properties.
        case 'FileName'
            if isa(value{i}, 'function_handle')
                nlsys.FileName = value{i};
            else
                if (ndims(value{i}) ~= 2) || ~ischar(value{i}) || ~isvarname(value{i})
                    ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyFileName')
                end
                nlsys.FileName = value{i}(:)';
            end
            checkconsistency = true;
        case 'Order'
            [errmsg, nlsys.Order] = checkgetOrder(value{i}, nlsys.Order);
            error(errmsg);
        case 'Parameters'
            [errmsg, nlsys.Parameters] = checkgetParameters(value{i}, false);
            error(errmsg);
            checkconsistency = true;
        case 'InitialStates'
            if ischar(value{i})
                if ((ndims(value{i}) ~= 2) || isempty(value{i}))
                    ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyCharInitSpec')
                elseif strncmpi(value{i}, 'Estimate', length(value{i}))
                    [nlsys.InitialStates.Fixed] = deal(false(1, size(nlsys, 'ne')));
                elseif strncmpi(value{i}, 'Zero', length(value{i}))
                    for j = 1:length(nlsys.InitialStates)
                        % Check that nlsys.InitialStates(j).Minimum <= 0.
                        if any(nlsys.InitialStates(j).Minimum > 0)
                            ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyX0val2',j)
                        end
                        % Check that nlsys.InitialStates(j).Maximum >= 0.
                        if any(nlsys.InitialStates(j).Maximum < 0)
                            ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyX0val3',j)
                        end
                    end
                    [nlsys.InitialStates.Value] = deal(zeros(1, size(nlsys, 'ne')));
                else
                    ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyCharInitSpec')
                end
            else
                [errmsg, nlsys.InitialStates] = checkgetInitialStates(value{i}, nlsys.Order.nx, false);
                error(errmsg);
                checkconsistency = true;
            end
        case 'FileArgument'
            if iscell(value{i})
                nlsys.FileArgument = value{i};
                checkconsistency = true;
            else
                ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyFileArg1')
            end
        case 'CovarianceMatrix'
            if (ndims(value{i}) ~= 2)
                ctrlMsgUtils.error('Ident:idnlmodel:invalidCovarianceMatrix')
            elseif ischar(value{i})
                if isempty(value{i})
                    ctrlMsgUtils.error('Ident:idnlmodel:invalidCovarianceMatrix')
                elseif ~isempty(strmatch(lower(value{i}), 'none'))
                    nlsys.CovarianceMatrix = 'None';
                elseif ~isempty(strmatch(lower(value{i}), 'estimate'))
                    nlsys.CovarianceMatrix = 'Estimate';
                else
                    ctrlMsgUtils.error('Ident:idnlmodel:invalidCovarianceMatrix')
                end
            elseif isnumeric(value{i})
                if ~isempty(value{i})
                    if (~isreal(value{i}) || ~all(all(isfinite(value{i}))))
                        ctrlMsgUtils.error('Ident:general:CovarianceMatrixNotReal')
                    elseif (size(value{i}, 1) ~= size(value{i}, 2))
                        ctrlMsgUtils.error('Ident:general:CovarianceMatrixNotSquare')
                    elseif (~isequal(norm(value{i}), 0) && (norm(value{i}'-value{i})/norm(value{i}) > sqrt(eps)))
                        ctrlMsgUtils.error('Ident:general:CovarianceMatrixNotSymmetric')
                    elseif ~all(diag(value{i}) >= 0)
                        ctrlMsgUtils.error('Ident:general:CovarianceMatrixNotPosSemidefinite')
                    end
                end
                nlsys.CovarianceMatrix = value{i};
            else
                ctrlMsgUtils.error('Ident:idnlmodel:invalidCovarianceMatrix')
            end
            checkconsistency = true;
        case 'Algorithm'
            [errmsg, nlsys.Algorithm] = checkgetAlgorithm(value{i}, ny);
            error(errmsg)
            checkconsistency = true;
        case 'SimulationOptions'
            [errmsg, nlsys.Algorithm.SimulationOptions] = checkgetAlgorithmProperty(property{i}, value{i}, ny);
            error(errmsg);
            checkconsistency = true;
        case {'GradientOptions' 'SearchMethod' 'Criterion' 'Weighting' 'MaxIter' 'Tolerance' 'LimitError' 'Display' 'Advanced'}
            [errmsg, nlsys.Algorithm.(property{i})] = checkgetAlgorithmProperty(property{i}, value{i}, ny);
            error(errmsg);
            %{
            if strcmpi(property{i}, 'weighting')
                checkconsistency = true;
            end
            %}
        case 'EstimationInfo'
            ctrlMsgUtils.error('Ident:general:readOnlyProp','EstimationInfo','IDNLGREY')
            
            % IDNLMODEL specific property.
        otherwise
            try
                nlsys.idnlmodel = pvset(nlsys.idnlmodel, property{i}, value{i});
            catch E
                throw(E)
            end
            checkconsistency = true;
    end
end

% If nlsys is a static system and Solver is specified to not be
% 'FixedStepDiscret' or 'Auto', then change the Solver to
% 'FixedStepDiscrete' and inform the user about it.
if ((nlsys.Order.nx == 0) && ~ismember(nlsys.Algorithm.SimulationOptions.Solver, {'Auto' 'FixedStepDiscrete'}))
    nlsys.Algorithm.SimulationOptions.Solver = 'FixedStepDiscrete';
    ctrlMsgUtils.warning('Ident:idnlmodel:discreteSolverForStaticSystem')
end

% Check consistency of nlsys.
if (checkconsistency)
    error(isvalid(nlsys, 'SkipFileName'));
end

% Update time stamp and, if necessary, status of EstimationInfo.
nlsys = timemark(nlsys, 'l');
EstimationInfo = pvget(nlsys, 'EstimationInfo');
if strcmp(EstimationInfo.Status(1:3), 'Est')
    EstimationInfo.Status = 'Model modified after last estimate';
    nlsys.EstimationInfo = EstimationInfo;
end
