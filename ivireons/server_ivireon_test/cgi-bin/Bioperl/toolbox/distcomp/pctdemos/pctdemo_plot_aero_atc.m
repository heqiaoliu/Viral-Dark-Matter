function [setupGraph, updateGraph] = pctdemo_plot_aero_atc()
%PCTDEMO_PLOT_AERO_ATC Returns functions that can create and update the graphs 
%for the Parallel Computing Toolbox Air Traffic Control Radar demos.
%   [setupGraph, updateGraph] = pctdemo_plot_aero_atc() returns the functions
%   that can set up and update the graphs.    

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:28 $

    setupGraph = @iSetupGraph;
    updateGraph = @iUpdateGraph;
end % End of pctdemo_plot_aero_atc.


function iUpdateGraph(figHandles, iterations, rainfall, Rrange, meanRrange)
%iUpdateGraph update the Air Traffic Control Radar demo graphs.
%   iUpdateGraph(figHandles, iterations, rainfall, Rrange, meanRrange)
%   updates a portion of the graphs in figHandles.  The struct figHandles graphs
%   must have been obtained from iSetupGraph.
%   The vectors iterations, rainfall, Rrange and meanRrange must all be of the 
%   same length, and iterations must be an index into the x-axis in the 
%   figures.  The function updates only the graph corresponding to the x-axis 
%   values given by iterations.    

    if ~ishandle(figHandles.fig)
        % The user closed the figure.
        return;
    end
    set(figHandles.fig, 'Visible', 'on');
    figure(figHandles.fig);
    
    nUpdateSubplot(figHandles.hRain, iterations, rainfall);
    nUpdateSubplot(figHandles.hRrange, iterations, Rrange);
    nUpdateSubplot(figHandles.hMean, iterations, meanRrange);
    
    function nUpdateSubplot(h, iterations, ydata)
        if ~ishandle(h)
            return;
        end
        tmpdata = get(h, 'YData');
        tmpdata(iterations) = ydata;
        set(h, 'YData', tmpdata);
        % Change the range on the y-axis if necessary.
        ax = get(h, 'Parent');
        ylim = get(ax, 'YLim');
        ylim(1) = min([ylim(1); ydata(:)]);
        ylim(2) = max([ylim(2); ydata(:)]);
        set(ax, 'YLim', ylim);
    end % End of nUpdateSubplot.
end % End of iUpdateGraph.


function figHandles = iSetupGraph(fig,  rainfall, Rrange)
%iSetupGraph set up the output figure for the Air Traffic Control Radar demos.
%   figHandles = iSetupGraph(fig, rainfall, Rrange) set up graphs in the figure 
%   fig with the x-axis as 1:n, where n is the length 
%   of the vectors rainfall and Rrange.  The two vectors must be of equal 
%   length.
    if ~ishandle(fig);
        % The user closed the figure.
        return;
    end
    figure(fig);
    clf(fig);
    set(fig, 'Visible', 'off');
    % We hard-code the ylimit on the mean position error axis.
    maxMeanRrange = 50;
    numiter = numel(rainfall);

    % Call the nested function to set up each of the 3 subplots and get a 
    % handle to the lineseries object storing the plot.

    % The rainfall graph.
    hRain = nSetupSubplot(fig, 1, numiter, max(rainfall), 'Rainfall');
    % The radar range graph.
    hRrange = nSetupSubplot(fig, 2, numiter, max(Rrange), 'Radar range');
    % The mean error in the aircraft estimation.
    hMean = nSetupSubplot(fig, 3, numiter, maxMeanRrange, 'Mean position error');

    figHandles = struct('fig', fig, 'hRain', hRain, ...
                        'hRrange', hRrange, 'hMean', hMean);

    function h = nSetupSubplot(fig, subpl, xmax, ymax, ylab)
        x = 1:xmax;
        tmp = nan(1, xmax);
        ax = subplot(3, 1, subpl, 'parent', fig);
        h = plot(ax, x, tmp);
        set(h, 'LineStyle', 'none', 'Marker', '*', 'MarkerSize', 6);
        axis(ax, [0 xmax 0 ymax])
        grid(ax, 'on');
        xlabel(ax, 'Iteration');
        ylabel(ax, ylab);
    end % End of nSetupSubplot.
end %End of iSetupGraph.
