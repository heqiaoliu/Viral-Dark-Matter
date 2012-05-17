function [fig, constant, GJR, horizon, nPaths, eFit, sFit] = pctdemo_setup_garch(difficulty)
%PCTDEMO_SETUP_GARCH Perform the initialization for the Parallel Computing
%Toolbox GARCH demos.
%   [fig, constant, GJR, horizon, nPaths, eFit, sFit] = ...
%   pctdemo_setup_garch(difficulty)
%   Outputs:
%     fig           The output figure for the demos.
%     constant, GJR Two models of the NASDAQ returns.
%     horizon       The time horizon (in number of days) that we should 
%                   simulate.
%     nPaths        The number of simulations to make.
%     eFit, sFit    Residuals and standard deviations obtained when using the
%                   GJR model to the NASDAQ returns.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/08/11 15:40:29 $
    
    % Demo details
    %
    % For each daily NASDAQ model, we simulate several paths over a one year VaR
    % horizon. We assume 252 trading days per annum.
    %
    %
    % The two models of the NASDAQ returns:
    %
    % The first model is the most traditional, and simply assumes a constant
    % mean, constant volatility process with conditionally Gaussian returns.
    %
    % The second model also assumes a constant mean, but allows for
    % time-varying volatility by fitting the NASDAQ series to a GJR model 
    % with conditionally t-distributed returns. Thus, the latter model
    % compensates for asymmetries, or leverage effects, in the equity 
    % portfolio as well as the fat tails, or excess kurtosis, often observed
    % in financial data.
    %
    % For details regarding the GJR model, see the article
    %
    % Glosten, L.R., R. Jagannathan, and D.E. Runkle, "On the Relation between
    %   Expected Value and the Volatility of the Nominal Excess Return on 
    %   Stocks", The Journal of Finance, Vol. 48, 1993, pp 1779-1801.
    %
    % The NASDAQ series contains daily closing values of the NASDAQ Composite
    % Index. The sample period is from January 2, 1990 to December 31, 2001, 
    % for a total of 3028 daily equity index observations.
    %
    
    fig = pDemoFigure();
    clf(fig);
    figure(fig);
    set(fig, 'Name', 'Value-at-Risk Simulation');
    ax = axes('parent', fig);

    data = load('Data_EquityIdx');
    NASDAQ = data.Dataset.NASDAQ;
    Nasdaq = price2ret(NASDAQ);
    
    % Just for reference, we display the daily NASDAQ closings.
    startDate = datenum('02-Jan-1990');
    endDate = datenum('31-Dec-2001');
    Dates = (startDate:endDate)';
    
    plot(ax, Dates(isbusday(Dates)), NASDAQ);
    datetick(ax, 'x')
    grid(ax, 'on')
    title (ax, 'NASDAQ Composite Index: Daily Closing Index Level')
    xlabel(ax, 'Date')
    ylabel(ax, 'Index Level')
    % We make the x-axis tight and do not modify the y-axis.
    a = axis;
    axis(ax, [startDate, endDate, a(3:4)]);
    
    % We then fit the two models to the NASDAQ returns.
    constant = garchset('C', mean(Nasdaq), 'K', var(Nasdaq));
    GJR = garchset('VarianceModel', 'GJR', 'P', 1, 'Q', 1, 'Distribution', ...
                   'T', 'Display', 'off');
    
    % Note that we don't need the Errors and LLF output arguments.
    [GJR, Errors, LLF, eFit, sFit] = garchfit(GJR, Nasdaq); %#ok Ignoring params.
    
    % Set the number of simulated paths, or trials, per model and the
    % annual forecast horizon.
    nPaths  = 100000; 
    horizon = 252;
    
    nPaths = max(1, round(nPaths*difficulty));
end % End of pctdemo_setup_garch.
