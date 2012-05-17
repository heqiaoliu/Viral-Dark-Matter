function status = isinitialized(nlobj)
%ISINITIALIZED True for initialized nonlinearity estimator.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 21:02:05 $

% Author(s): Qinghua Zhang

status = all(~isnan(nlobj.LinearInterval));

% FILE END