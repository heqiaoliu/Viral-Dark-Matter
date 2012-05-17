function nlobj = initridgenet(nlobj, y, x)
%INITRIDGENET

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2009/11/09 16:24:10 $

% Author(s): Qinghua Zhang

numunits = nlobj.NumberOfUnits;
if ~isnonnegintscalar(numunits)
    ctrlMsgUtils.error('Ident:general:positiveIntPropVal','NumberOfUnits')
end

[nobs, regdim] = size(x);

nonlble = nlobj.NonlinearRegressors;
if ischar(nonlble) && strcmpi(nonlble, 'all')
    nonlble = 1:regdim;
end

if isempty(x) % Initialization without data
    xrange = [-1, 1];
    regmean = 0;
    pct = [];
    lct = [];
else
    
    pmat = zeros(regdim, length(nonlble));
    ind = sub2ind(size(pmat), nonlble, 1:length(nonlble));
    pmat(ind) = 1;
    
    regmean = mean(x,1);
    x = x - regmean(ones(nobs,1), :);  %  regmat mean removal
    
    % Nonlinear regressors
    pct = pmat * PCAProjection(x*pmat);
    xnl =  x * pct;
    
    xrange = [min(xnl,[],1); max(xnl,[],1)]';
    
    % Linear regressors
    if strcmpi(nlobj.LinearTerm, 'on')
        lct = PCAProjection(x);
    else
        lct = zeros(regdim, 0);
    end
    xlin =  x * lct;
    clear x
end

[f, g, r] = unitfcn(nlobj, 0);

if isempty(numunits) || ischar(numunits)
    numunits =10; % Default value
    nlobj = pvset(nlobj, 'NumberOfUnits', numunits);
end

[iw, ib] = SubInit(xrange,numunits, r(1,:));

param.RegressorMean = regmean;
param.NonLinearSubspace = pct;
param.LinearSubspace = lct;

param.LinearCoef = zeros(size(xlin,2),size(y,2));
param.Dilation = iw';
param.Translation = ib';
param.OutputCoef = zeros(numunits,size(y,2));
param.OutputOffset = mean(y,1);

nlobj.Parameters = param;

%----------------------------------------------
function [w,b]=SubInit(xrange, numunits, xscale)

nx = size(xrange,1);

if ~nx || ~numunits
    w = zeros(numunits,nx);
    b = zeros(numunits,1);
    return
end

% Avoid xrange(:,2)==xrange(:,1)
xrange(:,2) = xrange(:,2) + (xrange(:,2)==xrange(:,1));

rmc = 2*rand(numunits,nx)-1;
inm = 1./sqrt(sum(rmc.*rmc,2));
rmc = rmc .* inm(:,ones(1,nx));

wscale = 2.8*xscale*numunits^(1/nx);

w =  wscale*rmc;
if numunits~=1
    b =  wscale*linspace(-1,1,numunits)' .* sign(w(:,1));
else
    b = 0;
end

xrate = 2 ./ (xrange(:,2)-xrange(:,1));
b = b + w*(1-xrange(:,2).*xrate);
w = w .* xrate(:, ones(numunits,1))';

%=================================================================
function P = PCAProjection(x)
% PCA projection matrix
if isempty(x)
  P = [];
else
  [U, S, V] = svd(x,0);
  S = diag(S);  % now S is a vector
  mask = (S>=max(size(x))*eps(max(S))); % Thresholding
  S = S(mask);
  V = V(:,mask);
  P = V * diag(1 ./ S) * sqrt(size(x,1));
end

% Oct2009
% FILE END








