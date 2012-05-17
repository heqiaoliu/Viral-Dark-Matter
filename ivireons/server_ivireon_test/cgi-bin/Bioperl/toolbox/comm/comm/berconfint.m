function [ber, interval] = berconfint(nErrs, nTrials, level)
%BERCONFINT BER and confidence interval of Monte Carlo simulation.
%   [BER INTERVAL] = BERCONFINT(NERRS, NTRIALS) returns the error
%   probability BER and the confidence interval INTERVAL with 95%
%   confidence for a Monte Carlo simulation of NTRIALS trials with NERRS
%   errors.
%
%   [BER INTERVAL] = BERCONFINT(NERRS, NTRIALS, LEVEL) returns the error
%   probability BER and the confidence interval INTERVAL with confidence
%   level LEVEL for a Monte Carlo simulation of NTRIALS trials with NERRS
%   errors.
% 
%   See also BINOFIT, MLE (both in Statistics Toolbox).

%   Copyright 1996-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2005/02/14 16:07:15 $

if (nargin < 2)
    error('comm:berconfint:minArgs', 'BERCONFINT requires at least 2 arguments.');
elseif (~is(nErrs, 'nonnegative') || ~is(nErrs, 'integer'))
    error('comm:berconfint:nErrs', 'NERRS must be a nonnegative integer.');
elseif (~is(nTrials, 'positive') || ~is(nTrials, 'integer'))
    error('comm:berconfint:nTrials', 'NTRIALS must be a positive integer.');
elseif (nErrs > nTrials)
    error('comm:berconfint:bigNErrs', 'NERRS cannot exceed NTRIALS.');
elseif (nargin == 2)
    [ber interval] = binofit(nErrs, nTrials);
elseif (~is(level, 'real') || any(level<0) || any(level>1))
    error('comm:berconfint:level', 'Confidence level must be between 0 and 1.');
else
    [ber interval] = binofit(nErrs, nTrials, 1-level);
end
