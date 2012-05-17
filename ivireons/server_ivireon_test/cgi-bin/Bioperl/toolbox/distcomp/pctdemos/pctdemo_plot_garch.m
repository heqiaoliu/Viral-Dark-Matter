function pctdemo_plot_garch(fig, constantCumReturns, GJRCumReturns)
%PCTDEMO_PLOT_GARCH Create the graphs for the Parallel Computing Toolbox GARCH demos.
%   pctdemo_plot_garch(fig, constantCumReturns, GJRCumReturns) displays the 
%   cumulative distribution function of each simulated models.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:32 $
    
    % First, graph the cumulative distribution function. 
    % Now examine the cumulative distribution function (CDF) of each simulated
    % model and compare the VaR at various probabilities.
    %
    % Notice that two plots are shown. The first plot illustrates the entire
    % CDF. The second plot highlights the lower tail of the distributions, 
    % corresponding to portfolio losses, and allows a more detailed 
    % comparison of the two models.
    %
    % In particular, notice that at the VaR "crossover" point both models 
    % incur the same portfolio loss of about 44%.
    %
    % However, at high confidence levels (i.e., low probabilities), the GJR
    % model predicts a significantly higher VaR. The following table compares
    % the VaR percentage losses of the two simulation models:
    %
    %                            VaR Losses
    %                             (Percent)
    %                      ----------------------
    % Confidence Level      Constant      GJR
    %    (Percent)         Volatility  Volatility
    % ----------------     ----------  ----------
    %       90                19.5         2.0
    %       95                28.7        13.7
    %       98                38.9        31.4
    %       99                45.1        47.0
    %       99.5              51.1        64.4
    %
    % This table of VaR losses can be obtained by running the following block 
    % of code:
    % 
    %   confidence = [90, 95, 98, 99, 99.5];
    %   VaR = zeros(2, numel(confidence));
    %   for i = 1:numel(confidence)
    %       probability = 100 - confidence(i);
    %       GJRVaR = -prctile(GJRCumReturns, probability);
    %       constantVaR = -prctile(constantCumReturns, probability);
    %       VaR(:, i) = [constantVaR; GJRVaR];
    %   end
    %   
    %   disp('Predicted VaR at various confidence intervals');
    %   disp([confidence; VaR])
    
    if ~ishandle(fig)
        % The user closed the figure.
        return;
    end
    set(fig, 'Visible', 'on');

    % Let's graph the entire cumulative distribution function.
    subplot(2, 1, 1, 'parent', fig);
    % cdfplot does not allow us to specify the target axes, so we set the focus
    % on fig.
    figure(fig);
    h1 = cdfplot(constantCumReturns);
    ax = get(h1, 'parent');
    hold(ax, 'on')
    h1 = cdfplot(GJRCumReturns);
    set(h1, 'color', 'red', 'LineStyle', '--')
    axis(ax, [-1 1 0 1])
    hold(ax, 'off')
    title (ax, 'Simulated NASDAQ Cumulative Return CDF')
    legend(ax, 'Constant Volatility/Gaussian Distribution', ...
    	      'GJR Volatility/T Distribution', 'Location', 'NorthWest')
    xlabel(ax, 'NASDAQ Return')
    ylabel(ax, 'Probability')
    
    
    % Graph a closeup of the cumulative distribution function.
    subplot(2, 1, 2, 'parent', fig);
    % cdfplot does not allow us to specify the target axes, so we set the focus
    % on fig.
    figure(fig);
    h1 = cdfplot(constantCumReturns);
    ax = get(h1, 'parent');
    hold(ax, 'on')
    h1 = cdfplot(GJRCumReturns);
    set(h1, 'color', 'red', 'LineStyle', '--')
    axis(ax, [-0.6 0 0 0.1])
    hold(ax, 'off')
    
    title (ax, 'Simulated NASDAQ Cumulative Return CDF')
    legend(ax, 'Constant Volatility/Gaussian Distribution', ...
    	      'GJR Volatility/T Distribution', 'Location', 'NorthWest')
    xlabel(ax, 'NASDAQ Return')
    ylabel(ax, 'Probability')
   
end % End of pctdemo_plot_garch.
