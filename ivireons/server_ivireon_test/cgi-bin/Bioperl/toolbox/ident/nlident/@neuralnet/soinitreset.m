function nlobj = soinitreset(nlobj)
%SOINITRESET resets nonlinearity estimator Parameters.
%
%  sonlobj = soinitreset(nlobj)
%

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:54:54 $

% Author(s): Qinghua Zhang

if ~isscalar(nlobj)
    ctrlMsgUtils.error('Ident:idnlfun:scalarNLRequired','soinitreset')
end

nlobj.Initialized = false;

% for ky=1:numel(nlobj)
%  nlobj(ky).Initialized = false;
% end

% FILE END