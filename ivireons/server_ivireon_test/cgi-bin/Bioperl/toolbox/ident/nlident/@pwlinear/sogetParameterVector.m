function  th = sogetParameterVector(nlobj)
%sogetParameterVector returns the parameter vector of a single PWLINEAR object.
%
%  th = sogetParameterVector(nlobj)

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 21:01:43 $

% Author(s): Qinghua Zhang

param = nlobj.internalParameter;
th = [param.Translation(:); ...
      param.OutputCoef(:); ...
      param.OutputOffset(:); ...
      param.LinearCoef(:)]; 

% FILE END