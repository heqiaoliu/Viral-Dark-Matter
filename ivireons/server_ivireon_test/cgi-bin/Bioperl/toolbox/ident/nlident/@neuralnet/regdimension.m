function dim = regdimension(nlobj)
%REGDIMENSION: returns the dimension of regressors
%
% Note : for scalar object only

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:54:51 $

% Author(s): Qinghua Zhang

if numel(nlobj)>1
    ctrlMsgUtils.error('Ident:idnlfun:scalarNLRequired','regdimension')
end

if isempty(nlobj.Network)
    dim = -1;
    return;
end

dim = nlobj.Network.inputs;
if isempty(dim)
    dim = -1;
else
    dim = dim{1}.size;
    if dim==0
        dim = -1;
    end
end

% FILE END
