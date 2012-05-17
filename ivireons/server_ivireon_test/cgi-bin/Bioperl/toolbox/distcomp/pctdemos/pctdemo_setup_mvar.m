function [fig, numSims, numTimes, stock, names, weights, time, confLevel] = pctdemo_setup_mvar(difficulty)
%PCTDEMO_SETUP_MVAR Perform the initialization for the Parallel Computing
%Toolbox Marginal Value at Risk demos.
%   [fig, numSims, numTimes, stock, names, weights, time, confLevel] = ...
%    pctdemo_setup_mvar(difficulty);
%   Outputs:
%     numSims    The number of simulations we should perform. 
%     numTimes   The number of times the simulations should be repeated.
%     stock      The stock prices.
%     names      The names of the stocks.
%     weight     The weight that the stocks have in our portfolio.
%     times      The times at which we should calculate the value at risk.
%     confLevel  The confidence level at which we should calculate the 
%                value at risk.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:43 $
    
    % Demo details
    %
    % We use a numerical aproach to approximate the mariginal Value at Risk for 
    % a portfolio of stocks. This numerical approach uses a stocastic process to
    % simulate the behaviour of the stocks. It also incorporates the
    % cross-correlations between the individual stocks so that random walk
    % process, on average, maintains the particular variance matrix of the data.

    %
    % When we have run the monte-carlo simulation of the stocks, the VaR and
    % mVar values are estimated using a conditional mean method as outlined in
    % the article
    %
    % Winfried G. Hallerbach, "Decomposing Portfolio Value-at-Risk: A General
    %  Analysis", May 1999. <http://www.tinbergen.nl/discussionpapers/99034.pdf>
    %
    % Having produced a number of numerical results for mVaR and VaR, these
    % values are then used to place confidence intervals on our expected values
    % for the true mVaR and VaR. These values are plotted with the expected
    % errors.
    
    fig = pDemoFigure();
    clf(fig);
    set(fig, 'Visible', 'off');
    
    % Define the number of runs and simulations per run.
    numTimes = 16;
    minTimes = 2;
    numSims = 20000;
    numTimes = max(minTimes, round(numTimes*difficulty));
    
    % Define the confidence level at which we calculate the VaR and mVaR.
    confLevel = 95;
    
    % We load the variables |stock| and |names| from a MAT file.
    stock = []; % Remove mlint warning
    names = []; % Remove mlint warning
    load pctdemo_data_mvar;
    % Now size(stock, 2) == numel(names) == 7.
    
    % Let's create some random weights for these stocks in our
    % portfolio, and set the times at which we will calculate VaR.
    weights = [1 1 2 2 1 3 2];
    time = 10:2:50;
end % End of pctdemo_setup_mvar.
