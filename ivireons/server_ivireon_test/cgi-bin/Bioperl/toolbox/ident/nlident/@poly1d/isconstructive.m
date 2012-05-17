function status = isconstructive(nlobj, mlnetop)
%ISCONSTRUCTIVE True for constructive nonlinearity estimator object.
%
%  An nonlinearity estimator is said constructive if it can be estimated by
%  a non iterative algorithm.
%
%  This function, @poly1d/isconstructive, always returns true.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/06/07 14:44:19 $

% Author(s): Qinghua Zhang

status = true;

% FILE END