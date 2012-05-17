function [yhat, jcb, dy_x]= getJacobian(nlobj, regmat, doParJac)
%GETJACOBIAN: Single object Jacobian computation method of RIDGENET estimators.
%
%  [yhat, jcb, dy_x]= getJacobian(nlobj, regmat)
%
% doParJac: if false, jcb is not calculated.


% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2008/10/02 18:55:17 $

% Author(s): Qinghua Zhang

no=nargout; ni=nargin;
error(nargchk(2,3,ni,'struct'))

if ni<3
    doParJac = true;
end
jcb = [];

if isa(nlobj,'customnet') && isempty(nlobj.UnitFcn)
    ctrlMsgUtils.error('Ident:idnlfun:emptyUnitFcn')
end

param = nlobj.Parameters;

[nlregdim, nbunits] = size(param.Dilation);
[nbdata, regdim] = size(regmat);

error(mdlddchk(param, regdim));

iw = param.Dilation;

regmean = param.RegressorMean;
pct = param.NonLinearSubspace;
lct = param.LinearSubspace;

plw = param.LinearCoef;

ib = param.Translation;
ow = param.OutputCoef;
ob = param.OutputOffset;

nbunits = length(ib);

regmat = regmat - regmean(ones(nbdata,1), :);  %  regressor mean removal
xnl = regmat * pct;
xlin = regmat * lct;

[fsig , gsig] = unitfcn(nlobj, (xnl*iw + ib(ones(nbdata,1),:)));

yhat = fsig * ow + ob(ones(nbdata,1),:) + xlin*plw;

if no<2
    return
end

gsig = ow(:,ones(1,nbdata))' .* gsig;
% NOTE: only for single output, as ow is a vector

if doParJac
    giw = kron(gsig,ones(1,nlregdim)) .* kron(ones(1,nbunits), xnl);
    gib = gsig;
    gow = fsig;
    gob = ones(nbdata,1);

    gplw = xlin;

    jcb = [giw, gib, gow, gob, gplw];
end

if no>2
    % Note that gsig is already multiplied by ow above
    dy_x = gsig * (pct*iw)' + (lct*plw(:,ones(1,nbdata)))';
end
