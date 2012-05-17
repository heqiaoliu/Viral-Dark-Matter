function [pVaR, mmVaR] = pctdemo_task_mvar(numTimes, hVal, w, t, nSim, confLevel)
%PCTDEMO_TASK_MVAR Calculate marginal value at risk and value at risk 
%using Monte-Carlo simulation.
%   [pVaR, mmVaR] = pctdemo_task_mvar(numTimes, hVal, w, t, nSim, ...
%   confidenceLevel) returns two cellarrays with numTimes elements.  
%   Each pair of elements pVaR{i} and mmVaR{i} contains the value at risk of 
%   the portfolio and the marginal value at risk of the individual stocks in 
%   the portfolio, respectively. 
%   Inputs:
%     numTimes        How many times the simulations should be repeated.  
%                     Must be a positive integer.
%     hVal            The stock prices
%     w               The stock weights in the portfolio.
%     t               The times at which we calculate the VaR and the mVaR.
%     nSim            The number of simulatons to run
%     confidenceLevel The confidence level at which we calculate the portfolio 
%                     VaR and the mVaR of the individual stocks.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:56 $
    
    pVaR = cell(numTimes, 1);
    mmVaR = cell(numTimes, 1);
    for i = 1:numTimes
        [pVaR{i}, mmVaR{i}] = iMVarAndVaR(hVal, w, t, nSim, confLevel);
    end
end % End of pctdemo_task_mvar.


function [pVaR, mmVaR] = iMVarAndVaR(hVal, w, t, nSim, confidenceLevel)
%IMVARANDVAR Marginal Value at Risk calculation derived from 
%Monte-Carlo simulation.
%   [pVaR, mmVaR] = iMVarAndVaR(hVal, w, t, nSim, confidenceLevel)
%   returns the value at risk of the portfolio, pVaR, and the marginal value at 
%   risk of the individual stocks in the portfolio, mmVaR.
%   Inputs:
%     hVal            The stock prices
%     w               The stock weights in the portfolio.
%     t               The times at which we calculate the VaR and the mVaR.
%     nSim            The number of simulatons to run
%     confidenceLevel The confidence level at which we calculate the portfolio 
%                     VaR and the mVaR of the individual stocks.

    % theta represents the range of returns around pVaR used to estimate
    % mVaR.
    theta = 0.05;
    % We let alpha store the probability of losses.
    alpha = 100 - confidenceLevel; 
    
    alpha = alpha(1, 1);
    theta = theta(1, 1);
    nSim = nSim(1, 1);
    sz = size(hVal);
    
    % The normalised instrument weights (1 x nAsset).
    w = w(:)/sum(w);
    if sz(2) ~= length(w)
        error('distcomp:demo:InvalidArgument', ...
            'no. of elements in Weights must be same as Stock i/p dimension 2');
    end
    
    %% Run Monte-Carlo simulation and calculate portfolio returns.
    t = t(:)';
    sim_t = 0:max(t);
    ind = ismember(sim_t, [0 t]);
    
    % We obtain a matrix of the size time x numSims x numStocks.
    sim = iMVaR_seq_multimc(hVal, sim_t, nSim); 
    
    % Downsample sim results to the times we asked for.
    sim = sim(ind, :, :);
    sz = size(sim);
    nTimes = sz(1) - 1;
    o_nTimes = ones(nTimes, 1);
    iVal = sim(o_nTimes, :, :);
    sim = sim(2:end, :, :);
    
    % An asset cannot be worth less than zero.
    sim(sim <= 0) = NaN;
    % Evaluate the instruments return.
    ri = (sim - iVal)./iVal;
    nSim = sz(2);
    nAsset = sz(3);
    % Sum ri according to weights and reshape back to original size.
    ri = reshape(ri, nTimes*nSim, nAsset);
    rp = ri*w;
    
    % The portfolio returns for each sim (numTimes x numSims).
    rp = reshape(rp, nTimes, nSim);
    ri = reshape(ri, nTimes, nSim, nAsset);
    r_i = ri;
    r_p = rp;
    
    % Marginal Value at Risk calculation
    %
    % Some useful variables.
    sz = size(r_i);
    nTimes = sz(1);
    nSim = sz(2);
    nAsset = sz(3);
    o_nAsset = ones(nAsset, 1);
    o_nSim = ones(nSim, 1);
    
    % Evaluate alpha percentile across simulations and transpose to dim 1.
    pVaR_t = prctile(r_p', alpha);
    pVaR = pVaR_t';
    
    % Finds the confidenceLevel-th percentile (just by counting) of all 
    % simulation runs to find the value above which the portfolio will end up at
    % the confidence level confidenceLevel.
    
    % Find the simulations where r_p is between pVaR+-theta.
    mask = (r_p > pVaR(:, o_nSim) - theta) & (r_p < pVaR(:, o_nSim) + theta);
    % The number of port sims that end up in the theta gap around VaR.
    s_mask = sum(mask, 2);
    
    % Evaluate E(r_i) for the simulations above.
    mmVaR = reshape(sum(r_i.*mask(:, :, o_nAsset), 2), nTimes, nAsset) ... 
            ./s_mask(:, o_nAsset);
    
    % Now make sure that the sum of the component VaR's is equal
    % to the portfolio VaR (different due to skewed tail in returns).
    phi = pVaR ./ (mmVaR*w);
    mmVaR = mmVaR .* phi(:, o_nAsset);
end % End of iMVarAndVaR.

function aVal = iMVaR_seq_multimc(hVal, t, nSim)
% iMVaR_SEQ_MULTIMC
% Monte-Carlo simulation of Marginal Value at Risk

    % Calculate the number of assets.
    nAsset = size(hVal, 2);
    nTimes = length(t);
    
    % Calculate the returns statistics.
    retVal = (hVal(2:end, :) - hVal(1:end-1, :)) ./ hVal(1:end-1, :);
    mRet = mean(retVal);
    volat = std(retVal);
    
    corrRnd = zeros(nAsset, nTimes, nSim);
    cholMat = chol(corrcoef(retVal))';
       
    for i = 1:nSim
       corrRnd(:,:,i) = cholMat*randn(nAsset, nTimes);
    end
    
    aVal = zeros(nTimes, nSim, nAsset);
    
    for i = 1:nAsset
        mc_mRet = mRet(i);
        mc_volat = volat(i);
        iVal = hVal(end,i);
        rndMat = squeeze(corrRnd(i,:,:));
        
        % Calculate the time length.
        tLen = length(t);
    
        % Initialise the delta time vector.
        dt = zeros(tLen, 1);
        dt(1) = t(1);
        dt(2:end) = diff(t);
    
        % Initialise the drift and volatility values.
        drifts = mc_mRet.*dt;
        stds = mc_volat.*sqrt(dt);
    
        % Incorporate random variations into the simulation.
        if (tLen == 1)
            dVal = drifts + stds*randn(1, nSim);
        else
            if size(rndMat, 1) == 1
                rndMat = rndMat(:);
            end
            dVal = cumprod(((drifts(:,ones(1, nSim)) + ...
                stds(:,ones(1, nSim)).*rndMat) + 1), 1);
        end
    
        % Calculate the expected asset paths.
        aVal(:,:,i) = iVal*dVal;
    end
end % End of iMVaR_seq_multimc.
