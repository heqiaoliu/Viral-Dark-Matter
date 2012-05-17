function yhat = soevaluate1(nlobj, regmat)
%SOEVALUATE: Single output evaluate method, return the value of LINEAR at given input.
%
%  yhat = soevaluate(nlobj, regmat)

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:54:44 $

% Author(s): Qinghua Zhang

%no=nargout;
ni=nargin;
error(nargchk(2,2,ni,'struct'))

if ~isa(nlobj,'linear')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch2','soevaluate1','LINEAR')
end

if ~isinitialized(nlobj)
    ctrlMsgUtils.error('Ident:idnlfun:unInitializedNL','LINEAR')
end

if iscell(regmat) && numel(regmat)==1
    % Tolerate cellarray data
    regmat = regmat{1};
end

if isempty(regmat)
    yhat = zeros(size(regmat));
    return
end

%[nobs, regdim] = size(regmat);

param = nlobj.Parameters;

%error(mdlddchk(param, regdim));

yhat = regmat * param.LinearCoef + param.OutputOffset;

% FILE END

