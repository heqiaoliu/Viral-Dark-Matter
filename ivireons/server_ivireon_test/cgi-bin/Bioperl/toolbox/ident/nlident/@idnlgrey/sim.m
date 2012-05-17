function [ys, ysd, xfinal] = sim(nlsys, data, varargin)
%SIM  Simulates an IDNLGREY model.
%
%   YS = SIM(NLSYS, DATA);
%   YS = SIM(NLSYS, DATA, 'Noise');
%   YS = SIM(NLSYS, DATA, X0INIT);
%   YS = SIM(NLSYS, DATA, 'Noise', XOINIT);
%   YS = SIM(NLSYS, DATA, 'Noise', 'InitialState', X0INIT);
%   [YS, YSD, XFINAL] = SIM(NLSYS, DATA, 'Noise', 'InitialState', X0INIT);
%
%   The input-output arguments are as follows.
%
%   NLSYS holds the IDNLGREY model whose output is to be simulated.
%
%   DATA is the input-noise data = [U E]. Here U is the input data that can
%   be given either as an IDDATA object (with the signal defined as input)
%   or as a matrix U = [U1 U2 ... Um], where the k:th column vector is
%   input Uk. Similarly, E is either an IDDATA object or a matrix of noise
%   inputs (with as many columns as there are outputs) that are added to
%   the respective outputs. If E is omitted and 'Noise' is not given as an
%   input argument, then a noise-free simulation is obtained. If E is
%   omitted and 'Noise' is given as an input argument, then Gaussian noise
%   created by randn(size(YS))*sqrtm(NLSYS.NoiseVariance) will be added to
%   YS. If both E and 'Noise' are given, then E specifies the noise to add
%   to YS. For time-continuous IDNLGREY objects, DATA passed as a matrix
%   will lead to that the data sample interval, Ts, is set to one.
%
%   X0INIT specifies the initial state to use:
%      'zero'       : use a zero initial state x(0) with all states
%                     fixed (nlsys.InitialStates.Fixed is thus ignored).
%      'fixed' or   : nlsys.InitialState determines the values of the
%      'model'        initial states, but all states are fixed
%                     (nlsys.InitialStates.Fixed is thus ignored).
%                     Default.
%      vector/matrix: a column vector of appropriate length is used as
%                     initial state. For multiple experiment DATA, x(0) may
%                     be a matrix whose columns give different initial
%                     states for each experiment. All initial states are
%                     kept fixed (nlsys.InitialStates.Fixed is thus
%                     ignored).
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
%                     Fixed  : true (or a true 1-by-Ne vector). Any false
%                              value will be ignored.
%
%   The initial state can also be specified through the property-value pair
%   with name 'InitialState' or 'X0' followed by the value X0INIT.
%
%   YS is the simulated output. If DATA is an IDDATA object, then YS will
%   also be an IDDATA object. Otherwise, YS will be a matrix where the k:th
%   output is found in the k:th column of YS. If DATA is a multiple
%   experiment IDDATA object, so will YS be.
%
%   YSD is []. In the future, it will contain the estimated standard
%   deviation of the simulated output.
%
%   XFINAL contains the final states computed. In the single experiment
%   case it is a column vector of length Nx. For multi-experiment data,
%   XFINAL is an Nx-by-Ne matrix with the i:th column specifying the
%   initial state of experiment i.
%
%   If sim is called without an output argument, then the simulated
%   output(s) will be shown in a plot window.
%
%   Example:
%      U  = iddata([], idinput(200), 'Ts', 0.1);
%      E  = iddata([], randn(200, 1), 'Ts', 0.1);
%      YS = sim(NLSYS, [U E]);
%
%   See also IDNLGREY/IDNLGREY, IDNLGREY/PREDICT, IDNLGREY/PE,
%   IDNLGREY/PEM.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.9 $ $Date: 2010/03/31 18:22:46 $
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

% Check that the function is called with 2 to 5 input arguments.
error(nargchk(2, 5, nin, 'struct'));

% Allow NLSYS and DATA arguments to be swapped.
if (isa(nlsys, 'iddata') || isa(nlsys, 'cell') || isnumeric(nlsys))
    datatmp = nlsys;
    nlsys = data;
    data = datatmp;
end

% Check that NLSYS is an IDNLGREY object.
if ~isa(nlsys, 'idnlgrey')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','sim','IDNLGREY')
end

% Check NLSYS.
error(isvalid(nlsys, 'OnlyFileName'));

% Check that DATA is an IDDATA object or a matrix of appropriate size.
[errmsg, data, nlsys, warningtxt, retmat, noisefree] = checkgetiddata(data, nlsys, 'sim');
error(errmsg)

% Display warning messages.
for i = 1:size(warningtxt,1)
    warning(warningtxt{i,1}, warningtxt{i,2});
end

% Check for 'Noise' in the input argument list.
noiseind = [];
for i = 1:length(varargin)
    if ((ndims(varargin{i}) == 2) && ischar(varargin{i}) && ~isempty(varargin{i}))
        if ~isempty(strmatch(lower(varargin{i}), 'noise'))
            noiseind = [noiseind(:)' i];
        end
    end
end
addnoise = false;
if ~isempty(noiseind)
    if ((length(noiseind) > 1) || ((length(varargin) > 2) && ismember(2, noiseind)))
        ctrlMsgUtils.error('Ident:general:InvalidSyntax','sim','idnlgrey/sim')
    elseif ~(noisefree)
        ctrlMsgUtils.warning('Ident:analysis:simWithNoise')
    else
        noisefree = false;
        addnoise = true;
    end
    varargin = {varargin{setdiff((1:length(varargin)), noiseind)}};
end

% Check remaining part of varargin.
if isempty(varargin)
    x0init = 'model';
elseif (length(varargin) == 1)
    x0init = varargin{1};
elseif (length(varargin) == 2)
    if ((ndims(varargin{1}) == 2) && ischar(varargin{1}))
        if (isempty(varargin{1}) || isempty(strmatch(lower(varargin{1}), {'initialstate' 'x0'})))
            ctrlMsgUtils.error('Ident:general:InvalidSyntax','sim','idnlgrey/sim')
        end
    end
    x0init = varargin{2};
else
    ctrlMsgUtils.error('Ident:general:InvalidSyntax','sim','idnlgrey/sim')
end
if ischar(x0init)
    if (ndims(x0init) ~= 2) || ~isempty(strmatch(lower(x0init), {'initialstate' 'x0'}))
        ctrlMsgUtils.error('Ident:idnlmodel:idnlgreyX0val1','sim','idnlgrey/sim')
    end
end

% Check X0INIT.
ne = size(data, 'ne');
[errmsg, x0init] = checkgetx0(nlsys.InitialStates, x0init, ne, false);
error(errmsg)

% Perform simulation.
[ys, tmp, xfinal] = getSimResult(nlsys, data(:, :, 1:nlsys.Order.nu), cat(1, x0init.Value));
if (length(ys) ~= ne)
    ctrlMsgUtils.error('Ident:analysis:idnlgreyIncompleteSim1')
else
    n = size(data, 'n');
    for i = 1:length(ys)
        if ~all(size(ys{i}) == [n(i) nlsys.Order.ny])
            ctrlMsgUtils.error('Ident:analysis:idnlgreyIncompleteSim2',i)
        end
    end
end

% Handle the noisy case.
if ~(noisefree)
    if addnoise
        % 'Noise' was specified in the input argument list.
        for i = 1:ne
            % Add noise to the output.
            ys{i} = ys{i}+randn(size(ys{i}))*sqrtm(pvget(nlsys, 'NoiseVariance'));
        end
    else
        % The noise was provided in DATA.
        u = pvget(data, 'InputData');
        for i = 1:ne
            % Add noise to the output.
            ys{i} = ys{i}+u{i}(:, nlsys.Order.nu+1:end);
        end
    end
end

% Plot or return predicted output.
if (nout == 0)
    % Plot ys.
    simplot(nlsys, data, ys);
    clear ys xfinal;
else
    % If the input data was a matrix, then let the output data be a matrix.
    if (retmat)
        ys = ys{1};
    else
        ys = pvset(data, 'OutputData', ys, 'InputData', [],        ...
            'OutputName', pvget(nlsys, 'OutputName'), ...
            'OutputUnit', pvget(nlsys, 'OutputUnit'));
    end
    ysd = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Local function.                                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function simplot(nlsys, data, ymod)
%PLOT  Plots the outputs obtained by sim.
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
                title(['Simulated output #' int2str(j)]);
            else
                title(['Simulated output #' int2str(j) ': ' OutputName{j}]);
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
        if (isempty(ExperimentName{i})  || (ne == 1))
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
                title([expname 'Simulated output #' int2str(j)]);
            else
                title([expname 'Simulated output #' int2str(j) ': ' OutputName{j}]);
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
