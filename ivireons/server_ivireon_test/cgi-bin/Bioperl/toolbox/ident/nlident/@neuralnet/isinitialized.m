function status = isinitialized(nlobj)
%ISINITIALIZED True for initialized nonlinearity estimator.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 21:01:27 $

status = nlobj.Initialized && ~isempty(nlobj.Network) && ...
    regdimension(nlobj)>0;

% FILE END