function pctdemo_plot_bench(fig, worker_names, data)
%PCTDEMO_PLOT_BENCH Create the graphs for the Parallel Computing Toolbox 
%Benchmarking demo.
%   PCTDEMO_PLOT_BENCH(fig, worker_names, data) plots a bar graph of benchmark 
%   times.  The columns of the data matrix should contain timing results from
%   PCTDEMO_TASK_BENCH.
%   worker_names should be a cell array of strings.
    
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:29 $

    if ~ishandle(fig)
        % The user closed the figure.
        return;
    end
    clf(fig);
    ax = axes('parent', fig);
    xlabels = {'LU'; 'FFT'; 'ODE'; 'Sparse'};

    % We have received an array of worker names, so we want to 
    % sort by the names of the workers.  This produces a clearer graph 
    % in case some workers are benchmarked more than once.
    [s, ind] = sort(worker_names); %#ok Tell mlint we only need the second return variable.
    worker_names = worker_names(ind);
    data = data(:, ind);

    b = bar(ax, data);
    l = legend(b);
    set(l, 'Interpreter', 'none', 'Location', 'BestOutside', 'String', worker_names);
    set(ax, 'XTickLabel', xlabels);
    title(ax, 'Distributed Computing BENCH Demo');
    ylabel(ax, 'Average bench execution time (seconds)');
    xlabel(ax, 'Benchmark type');

    set(fig, 'Visible', 'on');
    figure(fig);
end % End of pctdemo_plot_bench.
