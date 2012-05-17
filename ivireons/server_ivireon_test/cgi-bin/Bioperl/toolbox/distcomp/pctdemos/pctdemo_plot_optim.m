function pctdemo_plot_optim(fig, risk, returns)
%PCTDEMO_PLOT_OPTIM Create the graphs for the Parallel Computing Toolbox 
%Portfolio Optimization demos.
%   pctdemo_plot_optim(fig, risk, returns) plots the effective frontier given
%   by the risk and the returns vectors.  The graph is shown in the figure fig.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:35 $
    
    if ~ishandle(fig)
        % The user closed the figure.
        return;
    end
    clf(fig);
    set(fig, 'Visible', 'on');
    figure(fig);
    ax = axes('parent', fig);

    plot(ax, risk, returns, 'o-');
    xlabel(ax, 'Risk');
    ylabel(ax, 'Expected returns');
    title(ax, 'The efficient frontier');
end % End of pctdemo_plot_optim.
