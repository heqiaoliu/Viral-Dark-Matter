function utidplot(nlsys, data, signalname)
%UTIDPLOT  Utility code used for plotting data.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $  $Date: 2010/03/31 18:22:43 $

% Determine the name of the figure.

%**************************************************************************
% Turning off uitabgroup warnings
%**************************************************************************
oldState = warning('off','MATLAB:uitabgroup:OldVersion');
warnCleaner = onCleanup(@() warning(oldState));
%**************************************************************************
figname = pvget(nlsys, 'Name');
if ~isempty(figname)
    figname = [figname ': ' nlsys.EstimationInfo.Status];
else
    figname = nlsys.EstimationInfo.Status;
end
if ~isa(data, 'iddata')
    was = warning('off','Ident:iddata:MoreOutputsThanSamples');
    data = iddata(data, []);
    warning(was)
end
if isempty(data)
    disp('Empty data set.')
    return;
end

% Retrieve variables from data and nlsys.
ne = size(data, 'Ne');
prederr = pvget(data, 'OutputData');
SamplingInstants = pvget(data, 'SamplingInstants');
ExperimentName = pvget(data, 'ExperimentName');
Domain = pvget(data, 'Domain');
ny = size(nlsys, 'Ny');
OutputName = pvget(nlsys, 'OutputName');
OutputUnit = pvget(nlsys, 'OutputUnit');
TimeUnit = pvget(nlsys, 'TimeUnit');

% Determine line colors to use.
cols = get(0, 'defaultAxesColor');
if (sum(cols) < 1.5)
    cols = {'r'};
else
    cols = {'r'};
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
            if ~isreal(prederr{i}(:, j))
                prederr{i}(:,j) = abs(prederr{i}(:, j));
                abstext = ' (Absolute value)';
            else
                abstext = '';
            end
            plot(SamplingInstants{i}, prederr{i}(:, j), cols{1});
            if isempty(OutputName{j})
                title([signalname,' output #' int2str(j), abstext]);
            else
                title([signalname, ' output #' int2str(j) ': ' OutputName{j}, abstext]);
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
            if ~isreal(prederr{i}(:, j))
                prederr{i}(:,j) = abs(prederr{i}(:, j));
                abstext = ' (Absolute value)';
            else
                abstext = '';
            end
            plot(SamplingInstants{i}, prederr{i}(:, j), cols{1});
            if isempty(OutputName{j})
                title([expname,' ',signalname, ' output #' int2str(j), abstext]);
            else
                title([expname,' ',signalname, ' output #' int2str(j) ': ' OutputName{j}, abstext]);
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