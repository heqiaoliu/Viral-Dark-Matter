function F = cost(this, R)
%COST  Various cost functions for minimization.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2007/11/09 20:18:28 $

Options = this.Options;
F = utGetCost(R, Options.Criterion);