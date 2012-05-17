function [x0, estinfo] = findstates(nlsys, data, x0init)
%FINDSTATES  Estimates the initial states of an IDNLGREY model.
%
%             X0  = FINDSTATES(NLSYS, DATA);
%   [X0, ESTINFO] = FINDSTATES(NLSYS, DATA);
%   [X0, ESTINFO] = FINDSTATES(NLSYS, DATA, X0INIT);
%
%   The input-output arguments are as follows.
%
%   NLSYS holds the IDNLGREY model whose output is to be predicted.
%
%   DATA is the output-input data = [Y U]. Here U is the input data that
%   can be given either as an IDDATA object or as a matrix  U = [U1 U2 ...
%   Um], where the k:th column vector is input Uk.  Similarly, Y is either
%   an IDDATA object or a matrix of outputs (with as many columns as there
%   are outputs). For time-continuous IDNLGREY objects, DATA passed as a
%   matrix will lead to that the data sample interval, Ts, is set to one.
%
%   X0INIT specifies the "initial" initial state strategy to use:
%      'zero'       : use a zero initial state x(0) and estimate all states
%                     (nlsys.InitialStates.Fixed is thus ignored). Notice
%                     that all states are estimated, whereas they are fixed
%                     in PREDICT.
%      'estimate'   : nlsys.InitialState determines the values of the
%                     initial states, but all initial states are estimated
%                    (nlsys.InitialStates.Fixed is thus ignored).
%      'model'      : nlsys.InitialState determines the values of the
%                     initial states, which initial states to estimate, as
%                     well as their maximum and minimum values. Default.
%      vector/matrix: a column vector of appropriate length is used as
%                     initial state. For multiple experiment DATA, x(0) may
%                     be a matrix whose columns give different initial
%                     states for each experiment. With this option, all
%                     initial states are estimated (and not fixed as in
%                     PREDICT) (nlsys.InitialStates.Fixed is thus ignored).
%      struct array : an Nx-by-1 structure array with fields:
%                     Name   : name of the state (a string).
%                     Unit   : unit of the state (a string).
%                     Value  : value of the states (a finite real 1-by-Ne
%                              vector, where Ne is the number of
%                              experiments.)
%                     Minimum: minimum values of the states (a real 1-by-Ne
%                              vector or a real scalar, in which case all
%                              initial states have the same minimum value).
%                     Maximum: maximum values of the states (a real 1-by-Ne
%                              vector or a real scalar, in which case all
%                              initial states have the same maximum value).
%                     Fixed  : a boolean 1-by-Ne vector, or a scalar
%                              boolean (applicable for all states)
%                              specifying whether the initial state is
%                              fixed or not.
%
%   X0 contains the initial states used. In the single experiment case it
%   is a column vector of length Nx. For multi-experiment data, X0 is an
%   Nx-by-Ne matrix with the i:th column specifying the initial state of
%   experiment i.
%
%   ESTINFO is an optional output (a structure or an Ne-by-1 structure
%   array) containing basic information about the estimation result (some
%   of the fields normally stored in NLSYS.EstimationInfo). For multi-
%   experiment data, X0 is estimated per experiment contained in DATA and
%   ESTINFO will then be an Ne-by-1 structure array with elements providing 
%   initial state estimation information related to each experiment.
%
%   See also IDNLGREY/IDNLGREY, IDNLGREY/PE, IDNLGREY/PREDICT,
%   IDNLGREY/SIM, IDNLGREY/PEM.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:53:46 $
%   Written by Peter Lindskog.

% Retrieve the number of inputs.
nin = nargin;

% Check that the function is called with 2 or 3 input arguments.
error(nargchk(2, 3, nin, 'struct'));

% Allow NLSYS and DATA arguments to be swapped.
if (isa(nlsys, 'iddata') || isa(nlsys, 'cell') || isnumeric(nlsys))
    datatmp = nlsys;
    nlsys = data;
    data = datatmp;
end

% Check that NLSYS is an IDNLGREY object.
if ~isa(nlsys, 'idnlgrey')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','findstates','IDNLGREY');
end

% Check NLSYS.
error(isvalid(nlsys, 'OnlyFileName'));

% Check that DATA is an IDDATA object or a matrix of appropriate size.
[errmsg, data, nlsys, warningtxt] = checkgetiddata(data, nlsys, 'findstates');
error(errmsg)

% Check X0INIT and initialize X0 using X0INIT.
if (nin < 3)
    x0init = 'model';
end
ne = size(data, 'ne');
[errmsg, x0init] = checkgetx0(nlsys.InitialStates, x0init, ne, 'f');
error(errmsg)

% Display warning messages.
for i = 1:size(warningtxt,1)
    warning(warningtxt{i,1}, warningtxt{i,2});
end

% If so specified, estimate the initial state.
estinfo = struct('Method', cell(ne, 1), 'DataName', '', 'WhyStop', '', 'Iterations', []);
[estinfo.Method] = deal('Not estimated');
DataName = pvget(data, 'Name');
if isempty(DataName)
    DataName = inputname(2);
end
ExperimentName = pvget(data, 'ExperimentName');
for i = 1:ne
    if isempty(ExperimentName{i})
        estinfo(i).DataName = [DataName ', Exp ' num2str(i)];
    else
        estinfo(i).DataName = [DataName ', ' ExperimentName{i}];
    end
end
if any(any(~cat(1, x0init.Fixed)))
    nlsys.CovarianceMatrix = 'None';     % Do not estimate the covariance matrix.
    for i = 1:length(nlsys.Parameters)   % Do not estimate the parameters.
        nlsys.Parameters(i).Fixed = true(size(nlsys.Parameters(i).Fixed));
    end
    Value = cat(1, x0init.Value);
    Minimum = cat(1, x0init.Minimum);
    Maximum = cat(1, x0init.Maximum);
    Fixed = cat(1, x0init.Fixed);
    WhyStop = cell(ne, 1);
    Iterations = num2cell(zeros(ne, 1));
    for i = 1:ne
        if ((ne > 1) && ~strcmpi(nlsys.Algorithm.Display, 'off'))
            fprintf('\nInitial state, experiment %d ', i);
        end
        nlsys.InitialStates = struct('Name',    {x0init.Name},            ...
                                     'Unit',    {x0init.Unit},            ...
                                     'Value',   num2cell(Value(:, i)'),   ...
                                     'Minimum', num2cell(Minimum(:, i)'), ...
                                     'Maximum', num2cell(Maximum(:, i)'), ...
                                     'Fixed',   num2cell(Fixed(:, i)'));
        if any(~cat(1, nlsys.InitialStates.Fixed))
            % Perform estimation of initial states for experiment i.
            nlsys = pem(getexp(data, i), nlsys);
            WhyStop{i} = nlsys.EstimationInfo.WhyStop;
            Iterations{i} = nlsys.EstimationInfo.Iterations;
        else
            % No estimation.
            WhyStop{i} = 'Not estimated';
            if ((ne > 1) && ~strcmpi(nlsys.Algorithm.Display, 'off'))
                fprintf('\n   No free initial state\n');
            end
        end
        x0est = cat(1, nlsys.InitialStates.Value);
        for j = 1:nlsys.Order.nx
            x0init(j).Value(i) = x0est(j);
        end
    end
    [estinfo.Method] = deal(nlsys.EstimationInfo.Method);
    [estinfo.WhyStop] = deal(WhyStop{:});
    [estinfo.Iterations] = deal(Iterations{:});
else
    if (nlsys.Order.nx > 0)
        ctrlMsgUtils.warning('Ident:estimation:allFixedStates')
    else
        ctrlMsgUtils.warning('Ident:estimation:noStates')
    end
end

% Retrieve x0 from x0init.
x0 = cat(1, x0init.Value);
