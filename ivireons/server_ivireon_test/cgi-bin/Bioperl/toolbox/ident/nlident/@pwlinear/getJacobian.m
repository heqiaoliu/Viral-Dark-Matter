function [yhat, jcb, dy_x]= getJacobian(nlobj, regmat, doParJac)
%GETJACOBIOAN: Single object getJacobian method of PWLINEAR estimators.
%
%  [yhat, jcb, dy_x]= getJacobian(nlobj, regmat)
%
% doParJac: if false, jcb is not calculated, but dy_x may be calculated if no>2.

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/02 18:55:06 $

% Author(s): Qinghua Zhang

no=nargout;

if nargin<3
    doParJac = true;
else
    jcb = [];
end

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
    ctrlMsgUtils.error('Ident:idnlfun:scalarInputOnly','PWLINEAR')
end

param = nlobj.internalParameter;
numunits = numel(param.Translation);

plw = param.LinearCoef;

ib = param.Translation;
ow = param.OutputCoef;
ob = param.OutputOffset;

xnl = regmat;
if size(plw, 1)==1
    xlin = regmat;
else
    xlin = zeros(nobs,0);
end

if no>1
    [fsig , gsig] = unitfcn(nlobj, (xnl(:,ones(1,numunits)) + ib(ones(nobs,1),:)));
    gsig = ow(:,ones(1,nobs))' .* gsig; % moved here from below by QZ on 11/26/2007
else
    fsig = unitfcn(nlobj, (xnl(:,ones(1,numunits)) + ib(ones(nobs,1),:)));
end

yhat = fsig * ow + ob(ones(nobs,1),:) + xlin*plw;

% gsig = ow(:,ones(1,nobs))' .* gsig;

if no>1 && doParJac
    gib = gsig;
    gow = fsig;
    gob = ones(nobs,1);
    gplw = xlin;
    
    jcb = [gib, gow, gob, gplw];
end

if no>2
    % Note: gsig is already multiplied by ow above
    dy_x = sum(gsig,2) +  sum(plw,1);
end

% FILE END
