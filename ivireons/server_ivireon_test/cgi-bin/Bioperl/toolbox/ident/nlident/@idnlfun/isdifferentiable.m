function status = isdifferentiable(nlobj, mlnetop)
%ISDIFFERENTIABLE True for differentiable nonlinearity estimator object.
%
%  This function, @idnlfun/isdifferentiable, always returns True, and can be
%  overloaded in some sub-classes.
%
%  When this functions is called, nlobj is either a scalar object or an
%  homogeneous object array of an sub-class of idnlfun which does not has
%  method overloading this one.
%
%  If nlobj is an heterogeneous array, then  @idnlfunVector/isdifferentiable
%  overloads the present method.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:59:14 $

% Author(s): Qinghua Zhang

status = true;

% FILE END