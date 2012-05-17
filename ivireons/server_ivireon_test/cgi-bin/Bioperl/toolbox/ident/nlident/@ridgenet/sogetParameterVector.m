function  th = sogetParameterVector(nlobj)
%sogetParameterVector returns the parameter vector of a single RIDGENET object.
%
%  th = sogetParameterVector(nlobj)

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 21:01:55 $

% Author(s): Qinghua Zhang

param = nlobj.Parameters;
th = [param.Dilation(:); ...
      param.Translation(:); ...
      param.OutputCoef(:); ...
      param.OutputOffset(:); ...
      param.LinearCoef(:)]; 

% FILE END