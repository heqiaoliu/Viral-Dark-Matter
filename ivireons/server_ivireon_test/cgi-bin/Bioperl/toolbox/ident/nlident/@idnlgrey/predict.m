function [yp, x0, xfinal] = predict(nlsys, data, k, x0init)
%PREDICT  Computes the k-step ahead prediction of an IDNLGREY model.
%
%                YP  = PREDICT(NLSYS, DATA);
%   [YP, X0, XFINAL] = PREDICT(NLSYS, DATA);
%   [YP, X0, XFINAL] = PREDICT(NLSYS, DATA, K);
%   [YP, X0, XFINAL] = PREDICT(NLSYS, DATA, K, X0INIT);
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
%   K is the prediction horizon, and can be set to an integer between 1 and
%   inf (pure simulation). As IDNLGREY assumes an output error model
%   structure, where prediction and simulation coincide, K has no meaning.
%   Default is inf (pure simulation), which is also obtained if K is empty.
%
%   X0INIT specifies the initial state strategy to use:
%      'zero'       : use a zero initial state x(0) and keep all states
%                     fixed (nlsys.InitialStates.Fixed is thus ignored).
%      'fixed'      : nlsys.InitialState determines the values of the
%                     initial states, but all states are kept fixed
%                     ((nlsys.InitialStates.Fixed is thus ignored).
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
%                     initial states are kept fixed
%                     (nlsys.InitialStates.Fixed is thus ignored).
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
%   YP is the predicted output. If DATA is an IDDATA object, then YP will
%   also be an IDDATA object. Otherwise, YP will be a matrix where the k:th
%   output is found in the k:th column of YP. If DATA is a multiple
%   experiment IDDATA object, so will YP be.
%
%   X0 contains the initial states used. In the single experiment case it
%   is a column vector of length Nx. For multi-experiment data, X0 is an
%   Nx-by-Ne matrix with the i:th column specifying the initial state of
%   experiment i.
%
%   XFINAL contains the final states computed. In the single experiment
%   case it is a column vector of length Nx. For multi-experiment data,
%   XFINAL is an Nx-by-Ne matrix with the i:th column specifying the
%   initial state of experiment i.
%
%   If predict is called without an output argument, then the predicted
%   output(s) will be shown in a plot window.
%
%   See also IDNLGREY/IDNLGREY, IDNLGREY/PE, IDNLGREY/SIM, IDNLGREY/PEM.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.9 $ $Date: 2010/03/31 18:22:44 $
%   Written by Peter Lindskog.

% Retrieve the number of inputs and outputs.

%**************************************************************************
% Turning off uitabgroup warnings
%**************************************************************************
oldState = warning('off','MATLAB:uitabgroup:OldVersion');
warnCleaner = onCleanup(@() warning(oldState));
%**************************************************************************

nin = nargin;
nout = nargout;

% Check that the function is called with 2 to 4 arguments.
error(nargchk(2, 4, nin, 'struct'));

% Allow NLSYS and DATA arguments to be swapped.
if (isa(nlsys, 'iddata') || isa(nlsys, 'cell') || isnumeric(nlsys))
    datatmp = nlsys;
    nlsys = data;
    data = datatmp;
end

% Check that NLSYS is an IDNLGREY object.
if ~isa(nlsys, 'idnlgrey')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','predict','IDNLGREY');
end

% Check NLSYS.
error(isvalid(nlsys, 'OnlyFileName'));

% Check that DATA is an IDDATA object or a matrix of appropriate size.
[errmsg, data, nlsys, warningtxt, retmat] = checkgetiddata(data, nlsys, 'predict');
error(errmsg)

% Check K.

if (nin > 2) && ~isempty(k) && ((ndims(k) ~= 2) || ~isnumeric(k) || ~isreal(k) || ...
        ((~isscalar(k) || (rem(k, 1) ~= 0) || (k < 1)) && (k ~= inf)))
    ctrlMsgUtils.error('Ident:analysis:predictInvalidHorizon')    
end

% Check X0INIT and initialize X0 using X0INIT.
if (nin < 4)
    x0init = 'model';
end
ne = size(data, 'ne');
[errmsg, x0init] = checkgetx0(nlsys.InitialStates, x0init, ne, true);
error(errmsg)

% If so specified, estimate the initial state.
if any(any(~cat(1, x0init.Fixed)))
    nlsys.CovarianceMatrix = 'None';     % Do not estimate the covariance matrix.
    nlsys.Algorithm.Display = 'Off';     % Do not display estimation information on the screen.
    for i = 1:length(nlsys.Parameters)   % Do not estimate the parameters.
        nlsys.Parameters(i).Fixed = true(size(nlsys.Parameters(i).Fixed));
    end
    Value = cat(1, x0init.Value);
    Minimum = cat(1, x0init.Minimum);
    Maximum = cat(1, x0init.Maximum);
    Fixed = cat(1, x0init.Fixed);
    for i = 1:ne
        nlsys.InitialStates = struct('Name',    {x0init.Name},            ...
            'Unit',    {x0init.Unit},            ...
            'Value',   num2cell(Value(:, i)'),   ...
            'Minimum', num2cell(Minimum(:, i)'), ...
            'Maximum', num2cell(Maximum(:, i)'), ...
            'Fixed',   num2cell(Fixed(:, i)'));
        nlsys = pem(getexp(data, i), nlsys);
        x0est = cat(1, nlsys.InitialStates.Value);
        for j = 1:nlsys.Order.nx
            x0init(j).Value(i) = x0est(j);
        end
    end
end
x0 = x0init;

% Display warning messages.
for i = 1:size(warningtxt,1)
    warning(warningtxt{i,1}, warningtxt{i,2});
end

% Perform simulation.
[yp, tmp, xfinal] = getSimResult(nlsys, data, cat(1, x0.Value));

% Plot or return predicted output.
if (nout == 0)
    % Plot y and yp.
    predictplot(nlsys, data, yp);
    clear yp x0 xfinal;
else
    % If DATA is a matrix, then let the output yp be a matrix.
    if (retmat)
        yp = yp{1};
    else
        data.y = yp;
        data.u = [];
        yp = data;
    end
    x0 = cat(1, x0.Value);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Local function.                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function predictplot(nlsys, data, ymod)
%PLOT  Plots the outputs obtained by predict.
% Determine the name of the figure.
figname = pvget(nlsys, 'Name');
if ~isempty(figname)
    figname = [figname ': ' nlsys.EstimationInfo.Status];
else
    figname = nlsys.EstimationInfo.Status;
end

% Retrieve variables from data and nlsys.
ne = size(data, 'ne');
SamplingInstants = pvget(data, 'SamplingInstants');
ExperimentName = pvget(data, 'ExperimentName');
Domain = pvget(data, 'Domain');
ny = size(nlsys, 'ny');
OutputName = pvget(nlsys, 'OutputName');
OutputUnit = pvget(nlsys, 'OutputUnit');
TimeUnit = pvget(nlsys, 'TimeUnit');

% Determine line colors to use.
cols = get(0, 'defaultAxesColor');
if (sum(cols) < 1.5)
    cols = 'y';
else
    cols = 'b';
end

% Determine whether tab plotting can be used or not.
usetabs = usejava('awt') && (ne > 1);

% Plotting.
if (usetabs)
    % Plot with one tab per experiment.
    figh = gcf;
    set(figh, 'Name', figname, 'NextPlot', 'replacechildren');
    set(0, 'CurrentFigure', figh);
    h = uitabgroup();
    tab = zeros(ne, 1);
    for i = 1:ne
        if isempty(ExperimentName{i})
            ExperimentName{i} = ['Exp' int2str(i)];
        end
        tab(i) = uitab(h, 'title', ExperimentName{i});
        axes('parent', tab(i));
        for j = 1:ny
            subplot(ny, 1, j);
            plot(SamplingInstants{i}, ymod{i}(:, j), cols);
            if isempty(OutputName{j})
                title(['Predicted output #' int2str(j)]);
            else
                title(['Predicted output #' int2str(j) ': ' OutputName{j}]);
            end
            if ~isempty(OutputUnit{j})
                ylabel(['y_' int2str(j) ' (' OutputUnit{j} ')']);
            else
                ylabel(['y_' int2str(j)]);
            end
            if ((j == ny) && ~isempty(TimeUnit))
                xlabel([Domain ' (' TimeUnit ')']);
            end
            axis('tight');
        end
    end
else
    % Standard plot without tabs.
    for i = 1:ne
        if (isempty(ExperimentName{i}) || (ne == 1))
            expname = '';
        else
            expname = ['. ' ExperimentName{i}];
        end
        if (i == 1)
            figh = gcf;
            set(figh, 'Name', [figname expname], 'NextPlot', 'replacechildren');
            set(0, 'CurrentFigure', figh);
        else
            figure('Name', [figname expname]);
        end
        if ~isempty(expname)
            expname = [expname(3:end) '. '];
        end
        for j = 1:ny
            subplot(ny, 1, j);
            plot(SamplingInstants{i}, ymod{i}(:, j), cols);
            if isempty(OutputName{j})
                title([expname 'Predicted output #' int2str(j)]);
            else
                title([expname 'Predicted output #' int2str(j) ': ' OutputName{j}]);
            end
            if ~isempty(OutputUnit{j})
                ylabel(['y_' int2str(j) ' (' OutputUnit{j} ')']);
            else
                ylabel(['y_' int2str(j)]);
            end
            if ((j == ny) && ~isempty(TimeUnit))
                xlabel([Domain ' (' TimeUnit ')']);
            end
            axis('tight');
        end
    end
end
