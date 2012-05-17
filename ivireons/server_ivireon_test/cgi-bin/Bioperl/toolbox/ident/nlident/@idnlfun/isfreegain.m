function status = isfreegain(nlobj)
%ISFREEGAIN returns true if the nonlinearity estimator has a free gain.
%
%  status = isfreegain(nlobj)
%
%This function, idnlfun/isfreegain, always return true. It is overloaded in
%some subclasses.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:53:33 $

% Author(s): Qinghua Zhang

if numel(nlobj)>1
    ctrlMsgUtils.error('Ident:idnlfun:scalarNLRequired','isfreegain')
end

status = true;

% FILE END