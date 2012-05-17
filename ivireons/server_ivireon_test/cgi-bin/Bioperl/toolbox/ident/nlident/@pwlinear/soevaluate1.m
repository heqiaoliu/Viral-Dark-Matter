function [yhat, jcb, dy_x]= soevaluate1(nlobj, regmat)
%SOEVALUATE: Single object evaluate method of PWLINEAR estimators.
%
%  [yhat, jcb, dy_x]= soevaluate(nlobj, regmat)

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:55:12 $

% Author(s): Qinghua Zhang

no=nargout; ni=nargin;
error(nargchk(2,2,ni,'struct'))

if ~isa(nlobj,'pwlinear')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch2','soevaluate1','PWLINEAR');
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
else
    fsig = unitfcn(nlobj, (xnl(:,ones(1,numunits)) + ib(ones(nobs,1),:)));
end

yhat = fsig * ow + ob(ones(nobs,1),:) + xlin*plw;

if no>1
    
    gsig = ow(:,ones(1,nobs))' .* gsig;
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
