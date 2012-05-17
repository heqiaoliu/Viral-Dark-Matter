function status = isconstructive(nlobj, mlnetop)
%ISCONSTRUCTIVE True for constructive nonlinearity estimator object.
%
%  An nonlinearity estimator is said constructive if it can be estimated by
%  a non iterative algorithm.
%
%  This function, @neuralnet/isconstructive returns false unless mlnetop=true.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 21:01:25 $

% Author(s): Qinghua Zhang

if nargin<2
  mlnetop = false;
end

if mlnetop
  status = true;
else
  status = false;
end

% FILE END