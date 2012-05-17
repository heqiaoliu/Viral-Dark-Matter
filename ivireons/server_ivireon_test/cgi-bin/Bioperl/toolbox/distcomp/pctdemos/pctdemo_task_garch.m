function accumReturns = pctdemo_task_garch(spec, nSamples, nPaths, eFit, sFit)
%PCTDEMO_TASK_GARCH A vectorizing wrapper function around garchsim.
%   The function restricts the amount of data that we get from garchsim to the
%   bare minimum.  This reduction has a significant effect when the return data
%   is large and it is transmitted over the network.
%   
%   The function only returns the cumulative returns as that reduces network
%   traffic tremendously.    

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:51 $    

    % The simplest approach would be to call garchsim once to perform nPaths
    % simulations, and then calculate the cumulative returns.  However, this
    % would require us to keep 3 matrices of the size nSamples-by-nPaths in
    % memory, which makes this approach unfeasible for large simulations on
    % machines with little memory.
    %
    % Our approach here is to call garchsim multiple times, each time performing
    % pathsPerIter(i) simulations.  After each call to garchsim, we calculate 
    % the cumulative returns and discard the 3 matrices of the size
    % nSamples-by-pathsPerIter(i). 
    approxPathsPerIter = 1000;
    numIters = max(1, fix(nPaths/approxPathsPerIter));
    [pathsPerIter, numIters] = pctdemo_helper_split_scalar(nPaths, numIters);
    accumReturns = cell(1, numIters);
    if (nargin < 5)
        for i = 1:numIters
            [residual, sigmas, returns] = garchsim(spec, nSamples, ...
                                                   pathsPerIter(i)); %#ok Tell mlint we never use the first two output arguments.
            accumReturns{i} = sum(returns);
        end
    else
        for i = 1:numIters
            [residual, sigmas, returns] = garchsim(spec, nSamples, ...
                                                   pathsPerIter(i), [], ...
                                                   [], [], eFit, sFit); %#ok Tell mlint we never use the first two output arguments.
            accumReturns{i} = sum(returns);
        end
    end
    % Concatenate the cumulative returns into a single vector.
    accumReturns = cat(2, accumReturns{:});
end % End of pctdemo_task_garch.
