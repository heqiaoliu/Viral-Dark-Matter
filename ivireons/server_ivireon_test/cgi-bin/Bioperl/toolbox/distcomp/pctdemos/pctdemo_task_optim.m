function [rsk, ret] = pctdemo_task_optim(covMat, expRet, muVec)
%PCTDEMO_TASK_OPTIM Find the frontier for a stock portfolio with the given 
%mean and covariance.
%   [rsk, ret] = pctdemo_task_optim(covMat, expRet, muVec) returns the 
%   risk-return relationship in the stock portfolio that is optimal in the 
%   mean-variance sense. covMat and expRet are the covariance and mean returns 
%   of a collection of stocks and muVec is a vector of desired returns.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:57 $
    
    numStocks = length(expRet);
    options = optimset('Display', 'off', 'largescale', 'off');
    % Preallocate the output arrays
    rsk = zeros(1, numel(muVec));
    ret = zeros(1, numel(muVec));
    % The stock weights should be non-negative and sum up to one.  We can 
    % therefore easily write down the lower and upper bounds for them:
    lowerBound = zeros(1, numStocks);
    upperBound = ones(1, numStocks);
    % The equality constraint matrix stores two constraints:
    %   1) About the sum of the weights
    %   2) About the expected return
    Aequality = [ones(1, numStocks); expRet];
    % Iterate over the requested returns and solve one quadratic minimization
    % problem for each requested return.
    for i = 1:length(muVec)
        % Declare the right hand side of the equality constraints.
        % The sum of the weights should be 1, and the expected return should be 
        % muVec(i).
        bequality = [1; muVec(i)];
        eqWt = quadprog(covMat, [], [], [], Aequality,    ... 
                        bequality, lowerBound, upperBound,   ...
                        [], options);
        rsk(i) = eqWt' * covMat * eqWt;
        ret(i) = expRet * eqWt;
    end
end % End of pctdemo_task_optim.
