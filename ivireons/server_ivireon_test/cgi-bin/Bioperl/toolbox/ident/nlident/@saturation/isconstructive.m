function status = isconstructive(nlobj, mlnetop)
%ISCONSTRUCTIVE True for constructive nonlinearity estimator object.
%
%  An nonlinearity estimator is said constructive if it can be estimated by
%  a non iterative algorithm.
%
%  This function, @saturation/isconstructive, always returns false.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 21:02:03 $

% Author(s): Qinghua Zhang

status = false;

% FILE END