function status = isconstructive(nlobj, mlnetop)
%ISDIFFERENTIABLE True if all the nonlinearity estimator objects are constructive
%
%  nlobj is an idnlfunVector object storing an heterogeneous array of
%  nonlinearity estimator objects.  
%
%  An nonlinearity estimator is said constructive if it can be estimated by
%  a non iterative algorithm.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:59:40 $

% Author(s): Qinghua Zhang

if nargin<2
  mlnetop = false;
end

status = true;
 
for k=1:numel(nlobj.ObjVector)
  if ~isconstructive(nlobj.ObjVector{k}, mlnetop)
    status = false;
    return
  end
end

% FILE END