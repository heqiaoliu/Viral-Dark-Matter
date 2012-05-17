function status = isconstructive(nlobj, mlnetop)
%ISCONSTRUCTIVE True for constructive nonlinearity estimator object.
%
%  An nonlinearity estimator is said constructive if it can be estimated by
%  a non iterative algorithm.
%
%  This function, @idnlfun/isconstructive, always returns True, and can be
%  overloaded in some sub-classes.
%
%  When this functions is called, nlobj is either a scalar object or an
%  homogeneous object array of an sub-class of idnlfun which does not has
%  method overloading this one.
%
%  If nlobj is an heterogeneous array, then  @idnlfunVector/isconstructive
%  overloads the present method.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:59:13 $

% Author(s): Qinghua Zhang

status = true;

% FILE END