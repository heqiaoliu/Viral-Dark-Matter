function dim = regdimension(nlobj)
%REGDIMENSION: returns the dimension of regressors
%
% Note : restricted to scalar object.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:55:19 $

% Author(s): Qinghua Zhang

if numel(nlobj)>1
    ctrlMsgUtils.error('Ident:idnlfun:scalarNLRequired','regdimension')
end

param = nlobj.Parameters;

if isstruct(param)
    dim = length(param.RegressorMean);
else
    dim = -1;
end

% FILE END