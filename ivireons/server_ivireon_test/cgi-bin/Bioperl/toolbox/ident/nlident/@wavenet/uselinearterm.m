function status = uselinearterm(nlobj)
%USELINEARTERM returns true if the nonlinearity estimator takes into account LinearTerm.
%
%   status = uselinearterm(nlobj)
%
%This function,overloading idnlfun/uselinearterm, always return true.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:55:58 $

% Author(s): Qinghua Zhang

if numel(nlobj)>1
    ctrlMsgUtils.error('Ident:idnlfun:scalarNLRequired','uselinearterm')
end

status = true;

% FILE END