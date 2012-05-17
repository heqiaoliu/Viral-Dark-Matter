function pctdemo_plot_radar(fig, residual)
%PCTDEMO_PLOT_RADAR Create the graphs for the Parallel Computing Toolbox 
%Radar Tracking demos.
%   pctdemo_plot_radar(fig, residual) graphs the standard deviation of the 
%   location estimation error.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:36 $
    
    if ~ishandle(fig)
        % The user closed the figure.
        return;
    end
    clf(fig);
    set(fig, 'Visible', 'on');
    figure(fig);
    ax = axes('parent', fig);

    % We graph the standard deviation of the range estimate error as
    % a function of the Measurement Number.  
    % On the graph, notice that the standard deviation increases as a function 
    % of time.  This indicates clearly that our Kalman filter is suboptimal.
    stddev = std(residual, 0, 2);
    plot(ax, stddev);
    xlabel(ax, 'Time');
    ylabel(ax, 'Standard deviation of error in feet');
    title(ax, 'Standard deviation of location estimate error');
    axis(ax, 'tight');    
end % End of pctdemo_plot_radar.
