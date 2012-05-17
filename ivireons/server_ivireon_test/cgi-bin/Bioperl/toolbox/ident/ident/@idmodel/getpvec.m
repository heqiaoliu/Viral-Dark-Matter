function th = getpvec(sys)
%getParameterVector returns the parameter vector of an IDMODEL model.
%
%  vector = getParameterVector(sys)

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:52:58 $

th = pvget(sys, 'ParameterVector');
   
% FILE END