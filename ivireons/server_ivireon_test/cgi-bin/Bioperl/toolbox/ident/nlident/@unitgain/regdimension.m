function dim = regdimension(nlobj)
%REGDIMENSION: returns the dimension of regressors
%
%  Always return 1, because UNITGAIN is used for scalar input only.
%
%  This is a method of UNITGAIN implemented for compatibility with
%  other objects.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 21:02:37 $

% Author(s): Qinghua Zhang

dim = 1;
% FILE END
