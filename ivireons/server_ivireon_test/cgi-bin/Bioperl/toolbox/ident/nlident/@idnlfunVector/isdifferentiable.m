function status = isdifferentiable(nlobj, mlnetop)
%ISDIFFERENTIABLE True if all the nonlinearity estimator object are differentiable
%
%  nlobj is an idnlfunVector object storing an heterogeneous array of
%  nonlinearity estimator objects.  

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:59:41 $

% Author(s): Qinghua Zhang

if nargin<2
  mlnetop = false;
end

status = true;
 
for k=1:numel(nlobj.ObjVector)
  if ~isdifferentiable(nlobj.ObjVector{k}, mlnetop)
    status = false;
    return
  end
end

% FILE END