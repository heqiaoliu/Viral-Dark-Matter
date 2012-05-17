function nlobj = soLinearInit(nlobj, lincoef)
%SOLINEARINIT initialize nonlinearity estimator with a linear model

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2009/11/09 16:24:03 $

% Author(s): Qinghua Zhang

if isfield(get(nlobj), 'LinearTerm') && strcmpi(nlobj.LinearTerm, 'off')
    % Note: "get(nlobj)" converts to a structure for "isfield".
    ctrlMsgUtils.warning('Ident:idnlfun:soLinearInit1',upper(class(nlobj)))
end

if isfield(get(nlobj), 'Parameters') && isfield(nlobj.Parameters, 'LinearCoef')
    % Note: "get(nlobj)" converts to a structure for "isfield".
    pm = nlobj.Parameters;
    pm.LinearCoef = lincoef;
    if isfield(pm, 'LinearSubspace')
        pm.LinearSubspace = eye(length(lincoef));
    end
    nlobj.Parameters = pm;
else
    ctrlMsgUtils.warning('Ident:idnlfun:soLinearInit2',upper(class(nlobj)))
end

% Oct2009
% FILE END
