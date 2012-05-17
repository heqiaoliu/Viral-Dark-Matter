function nlobj = soinitreset(nlobj)
%SOINITRESET resets the initialization of nonlinearity estimators
%
%  NL = SOINITRESET(NL0)
%
%This function is normally called from idnlfun/initreset.
%This is a generic function and is overloaded by some subclasses of idnlfun.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:53:40 $

% Author(s): Qinghua Zhang

if ~isscalar(nlobj)
    ctrlMsgUtils.error('Ident:idnlfun:scalarNLRequired','soinitreset')
end

nlobj.Parameters = [];

% FILE END