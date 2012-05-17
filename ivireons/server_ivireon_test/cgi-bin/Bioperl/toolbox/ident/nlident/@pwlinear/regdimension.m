function dim = regdimension(nlobj)
%REGDIMENSION: returns the dimension of regressors
%
% Note : restricted to scalar object.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:55:11 $

% Author(s): Qinghua Zhang

if numel(nlobj)>1
    ctrlMsgUtils.error('Ident:idnlfun:regdimension1')
end

dim = 1;

% FILE END