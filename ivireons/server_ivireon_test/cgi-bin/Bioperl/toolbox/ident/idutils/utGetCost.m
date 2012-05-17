function F = utGetCost(R, criterion)
% COST Various cost functions for minimization
% R: Error matrix (N-by-ny)
% criterion: one of 'det','trace', ..

% Note: We do not need criterion=sae perhaps.
%

% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2007/11/09 20:17:12 $

% Calculate the cost function
switch lower(criterion)
    case 'det'
        F = det_err(R);
    case 'trace'
        % todo: check if cost should be affected LimitError 
        F = sum_sqr_err(R);
    case 'sae' %not supported currently
        F = sum_abs_err(R);
end

%-------------------------------------------------
function F = sum_sqr_err(R)
% Sum of squared errors
F = trace((R'*R)/numel(R)); %works for both unfolded R and its per-output form

%-------------------------------------------------
function F = det_err(R)
% determinant of error matrix
F = det(R'*R/size(R,1));

if ~isfinite(F) || F<0 ||~isreal(F)
    F = inf;
end


%-------------------------------------------------
function F = sum_abs_err(R)
% Sum of absolute errors

F = sum(abs(R));

%-------------------------------------------------
function k = localTuningConstant(R)
% Tuning constant for Huber cost function.

% Robust measure of spread: estimate standard deviation of the residuals.
s = median( abs(R - median(R)) ) / 0.6745;

% Tuning constant (always >= 1)
k = max(1.345*s, 1);
