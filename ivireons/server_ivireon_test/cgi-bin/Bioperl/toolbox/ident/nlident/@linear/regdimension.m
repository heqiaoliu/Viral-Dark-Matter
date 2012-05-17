function dim = regdimension(nlobj)
%REGDIMENSION: returns the dimension of regressors
%
% Note : for scalar object only

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2009/11/09 16:24:06 $

% Author(s): Qinghua Zhang

if numel(nlobj)>1
    ctrlMsgUtils.error('Ident:idnlfun:scalarNLRequired','regdimension')
end

param = nlobj.Parameters;

% Note: testing OutputOffset instead of isempty(param) due to linear model
% extension. To implement the option disabling OutputOffset, OutputOffset
% should not be set to empty. Oct 2009.
if isempty(param.OutputOffset)
    dim = -1;
else
    dim = length(param.LinearCoef);
end

% Oct2009
% FILE END
