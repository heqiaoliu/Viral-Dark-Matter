function [yhat, jcb, dy_x]= getJacobian(nlobj, regmat, varargin)
%GETJACOBIAN: Compute parameter and state Jacobians for poly1d estimator.
%
%  [yhat, jcb, dy_x]= getJacobian(nlobj, regmat)
%
% doParJac: if false, jcb is not calculated.

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:54:56 $

% Author(s): Qinghua Zhang

no=nargout; ni=nargin;
error(nargchk(2,3,ni,'struct'))

if ~isinitialized(nlobj)
    ctrlMsgUtils.error('Ident:idnlfun:nonInitNLForJacobian')
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
