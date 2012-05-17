function  th = sogetParameterVector(nlobj)
%sogetParameterVector returns the parameter vector of a single POLY1D object.
%
%  th = sogetParameterVector(nlobj)

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/06/07 14:44:26 $

% Author(s): Qinghua Zhang

th = nlobj.prvCoefficients(:);

% FILE END