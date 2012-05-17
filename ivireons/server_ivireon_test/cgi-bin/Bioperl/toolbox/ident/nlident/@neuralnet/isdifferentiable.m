function status = isdifferentiable(nlobj, mlnetop)
%ISDIFFERENTIABLE True for differentiable nonlinearity estimator object.
%
%  This function, @neuralnet/isdifferentiable returns false unless mlnetop=true.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 21:01:26 $

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