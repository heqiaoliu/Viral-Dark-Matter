function dim = regdimension(nlobj)
%REGDIMENSION: returns the dimension of regressors
%
% Note : for scalar object only

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:55:44 $

if numel(nlobj)>1
    ctrlMsgUtils.error('Ident:idnlfun:scalarNLRequired','regdimension')
end

param = nlobj.Parameters;

if isempty(param)
    dim = -1;
else
    dim = length(param.RegressorMean);
end

% FILE END
