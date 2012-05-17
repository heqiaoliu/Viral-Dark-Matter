function [yhat, jcb, dy_x]= soevaluate(nlobj, regmat)
%SOEVALUATE: Single object evaluate method of RIDGENET estimators.
%
%  [yhat, jcb, dy_x]= soevaluate(nlobj, regmat)

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2008/10/02 18:55:21 $

% Author(s): Qinghua Zhang

no=nargout; ni=nargin;
error(nargchk(2,2,ni,'struct'))

if ~isa(nlobj,'ridgenet')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch2','soevaluate','RIDGENET')
end

if isa(nlobj,'customnet') && isempty(nlobj.UnitFcn)
    ctrlMsgUtils.error('Ident:idnlfun:emptyUnitFcn')
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

% [nobs, regdim] = size(regmat);

param = nlobj.Parameters;

[nlregdim, nbunits] = size(param.Dilation);
% linregdim = size(param.LinearCoef,1);
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

if no>1
    [fsig , gsig] = unitfcn(nlobj, (xnl*iw + ib(ones(nbdata,1),:)));
else
    fsig = unitfcn(nlobj, (xnl*iw + ib(ones(nbdata,1),:)));
end

yhat = fsig * ow + ob(ones(nbdata,1),:) + xlin*plw;

if no>1
    
    gsig = ow(:,ones(1,nbdata))' .* gsig;
    % NOTE: only for single output, as ow is a vector
    
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

% FILE END
