function pctdemo_plot_mvar(fig, VaR, mVaR, time, names)
%PCTDEMO_PLOT_MVAR Create the graphs for the Parallel Computing Toolbox 
%Marginal  Value at Risk demos.
%   pctdemo_plot_mvar(fig, VaR, mVaR, time, names) graphs the value at risk 
%   and the marginal value at risk stored in VaR and mVaR.  

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:34 $
    
    if ~ishandle(fig)
        % The user closed the figure.
        return;
    end
    set(fig, 'Visible', 'on');
    figure(fig);
    ax = axes('parent', fig);
    
    numStocks = numel(names);
    
    % Plot the mVaR of the individual stocks.
    %
    % mVaR is a cell array of matrices.  We want to calculate the mean and the  
    % standard deviation of all the matrices over the cell array index.
    % We create a 3 dimensional array where the 3rd dim corresponds to the cell 
    % array index.
    p = cat(3, mVaR{:}); 
    m = mean(p, 3);
    s = std(p, 1, 3);
    errorbar(ax, repmat(time(:), 1, numStocks), m, s, '.');
    hold(ax, 'on');
    grid(ax, 'on');
    
    % Plot the VaR of the portfolio.
    %
    % VaR is a cell array of column vectors and we want to calculate the mean 
    % and the standard deviation of the vectors over the cell array index.
    % Similar to the above, we convert VaR into a matrix, where the column index
    % corresponds to the cell array index.
    p = [VaR{:}];
    m = mean(p, 2);
    s = std(p, 1, 2);
    errorbar(ax, time, m, 3*s, 'ro-');
    legend(ax, names{:}, 'Portfolio', 'Location', 'BestOutside');
    hold(ax, 'off');
    
    xlabel(ax, 'Trading day');
    ylabel(ax, 'Relative VaR/mVaR');
end % End of pctdemo_plot_mvar.
