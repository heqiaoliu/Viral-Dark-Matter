function th = getParameterVector(sys)
%getParameterVector returns the parameter vector of IDNLARX model.
%
%  vector = getParameterVector(sys)

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:58:23 $

% Author(s): Qinghua Zhang

th = getParameterVector(pvget(sys, 'Nonlinearity'));
   
% FILE END