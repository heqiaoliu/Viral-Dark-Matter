function str = whyStop(this, flag)
%WHYSTOP  Describes in words the optimization termination status. 

% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.3 $ $Date: 2009/10/16 04:56:50 $

switch flag
    case 1
        str = 'Near (local) minimum, (norm(g) < tol).';
    case 2
        str = 'Change in parameters was less than the specified tolerance.';
    case 3
        str = 'Change in cost (actual improvement %) was less than the specified tolerance.';
    case 4
        str = 'Magnitude of search direction was smaller than the specified tolerance.';
    case 0
        str = 'Maximum number of iterations reached.';
    case -1
        str = 'Estimation was terminated prematurely by the user.';
    case -2
        str = 'Problem is infeasible: SVD of Jacobian failed.';
    case -3
        str = 'Number of function evaluations exceeded MaxFunEvals.';
    case -4
        str = 'No improvement along the search direction with line search.';
    case -5
        str = 'Divergent gradient calculation.';
    otherwise
        str = '';
end