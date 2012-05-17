function status = isfreegain(nlobj)
%ISFREEGAIN returns true if the nonlinearity estimator has a free gain.
%
%  status = isfreegain(nlobj)
%
%This method function, overloading idnlfun/isfreegain,  always return false.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 21:02:04 $

% Author(s): Qinghua Zhang

status = false;

% FILE END