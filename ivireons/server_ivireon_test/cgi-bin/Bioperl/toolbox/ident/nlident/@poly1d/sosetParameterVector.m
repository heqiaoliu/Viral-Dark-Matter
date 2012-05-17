function nlobj = sosetParameterVector(nlobj, th)
%sosetParameterVector sets the parameters of a single POLY1D object.
%
%  nlobj = sosetParameterVector(nlobj, vector)

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/06/07 14:44:30 $

% Author(s): Qinghua Zhang

nlobj.prvCoefficients = th(:)';

% FILE END

