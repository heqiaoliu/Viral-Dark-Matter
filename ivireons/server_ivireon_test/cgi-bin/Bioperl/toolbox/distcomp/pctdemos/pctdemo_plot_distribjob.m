function pctdemo_plot_blackjackbench(plotType, varargin)
%PCTDEMO_PLOT_BLACKJACKBENCH Create the graphs for the Parallel Computing Toolbox
%benchmarking blackjack demos.
%   The function can create four different types of graphs. 
%   1) pctdemo_plot_blackjackbench('speedup', numTasks, time, refTime,
%      titleStr) shows the speedup curve obtained by comparing the
%      execution times in the vector time to the sequential execution time
%      stored in refTime.  The number of tasks corresponding to time is
%      stored in numTasks.
%   2) pctdemo_plot_blackjackbench('barTime', numTasks, time, titleStr)
%      displays a simple bar chart of the execution times in the vector
%      time as a function of number of tasks.
%   3) pctdemo_plot_blackjackbench('fields', times, description, ...
%      fieldsToShow) displays a bar chart of all the execution times stored
%      in the fields fieldsToShow of the struct array times.
%   4) pctdemo_plot_blackjackbench('normalizedFields', times, ...
%      description, fieldsToShow) normalizes the execution times stored in
%      the fields fieldsToShow of the struct array times to obtain the
%      execution time per task.  It then displays a bar chart of the
%      execution time per task for each of those fields.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/11/24 14:57:22 $

    switch plotType
      case 'speedup'
        numTasks = varargin{1};
        time = varargin{2};
        refTime = varargin{3};
        titleStr = varargin{4};
        speedup(numTasks, time, refTime, titleStr);
      case 'barTime'
        numTasks = varargin{1};
        time = varargin{2};
        titleStr = varargin{3};
        barTime(numTasks, time, titleStr);
      case 'fields'
        times = varargin{1};
        description = varargin{2};
        fieldsToShow = varargin{3};
        fields(times, description, fieldsToShow, 'Time in seconds');
      case 'normalizedFields'
        times = varargin{1};
        description = varargin{2};
        fieldsToShow = varargin{3};
        normalized = normalizeTimes(times, fieldsToShow);
        fields(normalized, description, ...
               fieldsToShow, 'Normalized time in seconds');
    end
end

function speedup(numTasks, time, refTime, titleStr)
    speedup = numTasks.*refTime./time;
    fig = figure;
    ax = axes('parent', fig);
    bar(ax, speedup);
    set(ax, 'XTickLabel', numTasks);
    title(ax, titleStr);
    ylabel(ax, 'Speedup');
    xlabel(ax, 'Number of tasks')
end

function barTime(numTasks, time, titleStr)
    fig = figure;
    ax = axes('parent', fig);
    bar(ax, time);
    set(ax, 'XTickLabel', numTasks);
    title(ax, titleStr);
    ylabel(ax, 'Seconds');
    xlabel(ax, 'Number of tasks')
end

function fields(times, description, fieldsToShow, yLabelText)
    fieldsToShow = fieldsToShow(:);
    cols = ceil(sqrt(length(fieldsToShow)));
    rows = ceil(length(fieldsToShow)/cols);
    fig = figure;
    for j = 1:length(fieldsToShow)
        ax = subplot(rows, cols, j, 'parent', fig);
        numTasks = [times.numTasks];
        values = [times.(fieldsToShow{j})];
        bar(ax, values);
        set(ax, 'XTickLabel', numTasks);
        title(ax, description.(fieldsToShow{j}));
        ylabel(ax, yLabelText);
        xlabel(ax, 'Number of tasks');
    end
end

function normalized = normalizeTimes(times, fieldsToShow)
    numTasks = [times.numTasks];
    normalized.(fieldsToShow{1}) = [times.(fieldsToShow{1})]./numTasks;
    for i = 2:length(fieldsToShow)
        normalized.(fieldsToShow{i}) = [times.(fieldsToShow{i})]./numTasks;
    end
    normalized.numTasks = numTasks;
end

