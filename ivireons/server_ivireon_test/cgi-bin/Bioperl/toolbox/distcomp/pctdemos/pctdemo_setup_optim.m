function [fig, muVec, covMat, expRet] = pctdemo_setup_optim(difficulty)
%PCTDEMO_SETUP_OPTIM Perform the initialization for the Parallel Computing
%Toolbox Portfolio Optimization demos.
%   [fig, muVec, covMat, expRet] = pctdemo_setup_optim(difficulty) 
%   Outputs:
%     fig    The output figure for the demos.
%     muVec All the desired returns
%     covMat The covariance matrix of the stock returns
%     expRet The expected stock returns

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:44 $
    
    % Demo details
    %
    % The efficient frontier of a collection of stocks is the set of points
    % (rsk, ret) such that for a given level of risk, call it rsk, we let ret be
    % the highest possible return of any portfolio selected from the given stock
    % collection.
    %
    % We calculate the efficient frontier in the following manner:
    % We define the risk to be the risk in the mean-variance sense, and fix the 
    % return ret.  We then find the portfolio that minimizes the risk.
    % This leads us to solve a quadratic minimization problem with the equality 
    % constraint that the portfolio weights sum to 1 and that the portfolio
    % must have the expected return ret.
    %
    % The stock weights in the portfolio must of course be between 0 and 1.
    
    fig = pDemoFigure();
    clf(fig);
    set(fig, 'Name', 'Portfolio Optimization');
    
    numPorts = 100;
    minPorts = 1;
    numPorts = max(minPorts, round(numPorts*difficulty));
    numStocks = 100;
    
    % Load the rets matrix from file.
    rets = [];
    load pctdemo_data_optim;
    numStocks = min(numStocks, size(rets, 2));
    % Generate the covariance matrix and the mean expected returns.
    covMat = cov(rets(:,1:numStocks));
    expRet = mean(rets(:,1:numStocks));
    
    retRange = [min(expRet(expRet>0)) max(expRet)];
    rangeFudge = abs(diff(retRange))/20;
    retRange = retRange + [rangeFudge -rangeFudge];
    % Generate a vector of required returns.
    muVec = linspace(retRange(1), retRange(2), numPorts);
    
    
    % Generate a graph of a few of the returns.
    stockSel = [1, 2, 3];
    ax = axes('parent', fig);
    plot(ax, rets(:,stockSel))
    xlabel(ax,'Trading day'); 
    ylabel(ax, 'Returns');
    axis(ax, 'tight');
    title(ax, sprintf('The daily returns of %d of the %d stocks', ...
                      numel(stockSel), numStocks));
    drawnow;
end % End of pctdemo_setup_optim.
