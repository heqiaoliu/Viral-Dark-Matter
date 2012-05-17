function res = isaimp(nlsys)
%ISAIMP  Tests if a model is an impulse response model, computed by
%   IMPULSE.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/06/13 15:24:33 $

% Check that the function is called with one argument.
error(nargchk(1, 1, nargin, 'struct'));

% Return result.
res = 0;

% FILE END