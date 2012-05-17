function sys = setParameterVector(sys, th)
%setParameterVector set the parameters of IDNLARX object.
%
%   sys = setParameterVector(sys, vector)

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:58:43 $

% Author(s): Qinghua Zhang

nlobj = pvget(sys, 'Nonlinearity');
nlobj = setParameterVector(nlobj, th);
sys = pvset(sys,'Nonlinearity', nlobj);

% FILE END