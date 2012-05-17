function nlobj = sosetParameterVector(nlobj, th)
%sosetParameterVector sets the parameters of a single LINEAR object.
%
%  nlobj = sosetParameterVector(nlobj, vector)

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:54:46 $

% Author(s): Qinghua Zhang

param = nlobj.Parameters;

if isempty(param)
    ctrlMsgUtils.error('Ident:idnlfun:parSetNonInitializedNL')
end

regdim = length(param.LinearCoef);
param.LinearCoef = th(1:regdim);
param.OutputOffset = th(regdim+1);

nlobj.Parameters = param;

% FILE END
