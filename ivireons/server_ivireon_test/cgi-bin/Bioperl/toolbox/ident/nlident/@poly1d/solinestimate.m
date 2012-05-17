function  nlobj = solinestimate(nlobj, yvec, regmat)
%SOLINESTIMATE estimates the linear coeffients of a single POLY1D object
%
%  nlobj = solinestimate(nlobj, yvec, regmat)
%
%  For POLY1D solinestimate is identical to soinitialize.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/06/07 14:44:29 $

% Author(s): Qinghua Zhang

nlobj = soinitialize(nlobj, yvec, regmat);

% FILE END
