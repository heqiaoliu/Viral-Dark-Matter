function status = uselinearterm(nlobj)
%USELINEARTERM returns true if the nonlinearity estimator takes into account LinearTerm.
%
%   status = uselinearterm(nlobj)
%
%This function, idnlfun/uselinearterm, always return false. It is overloaded in
%some subclasses.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:53:42 $

% Author(s): Qinghua Zhang

if numel(nlobj)>1
    ctrlMsgUtils.error('Ident:idnlfun:scalarNLRequired','uselinearterm')
end

status = false;

% FILE END