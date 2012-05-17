function [yhat, jcb, dy_x]= soevaluate1(nlobj, regmat)
%SOEVALUATE: Single object evaluate method of the POLY1D estimator.
%
%  [yhat, jcb, dy_x]= soevaluate(nlobj, regmat)

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:55:03 $

% Author(s): Qinghua Zhang

no=nargout; ni=nargin;
error(nargchk(2,2,ni,'struct'))

if ~isa(nlobj,'poly1d')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch2','soevaluate1','POLY1D');
end

if ~isinitialized(nlobj)
    ctrlMsgUtils.error('Ident:idnlfun:unInitializedNL',upper(class(nlobj)))
end

if isempty(regmat)
    yhat = zeros(size(regmat));
    return
end
if iscell(regmat)
    % Tolerate cellarray data
    regmat = regmat{1};
end

[nobs, regdim] = size(regmat);
if regdim~=1
    ctrlMsgUtils.error('Ident:idnlfun:scalarInputOnly','POLY1D')
end

coef = nlobj.Coefficients;
degree = length(coef)-1;
nobs = size(regmat,1);

if no>1
    jcb = ones(nobs, degree+1);
    for kd = degree:-1:1
        jcb(:,kd) = regmat.*jcb(:,kd+1);
    end
    yhat = jcb * coef';
else
    yhat = ones(nobs,1)*coef(degree+1);
    power = ones(nobs,1);
    for kd = degree:-1:1
        power = power.*regmat;
        yhat = yhat + power * coef(kd);
    end
end

if no>2
    dy_x = jcb(:,2:end) * (coef(1:end-1).*(degree:(-1):1))';
end

% FILE END
