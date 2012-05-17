function  [nlobj,ei,nv,covmat] = soinitialize(nlobj, yvec, regmat, algo) %#ok<INUSD>
%SOINITIALIZE: single object initialization for LINEAR estimator.
%
%  [nlobj,ei,nv,covmat] = soinitialize(nlobj, yvec, regmat, algo)
%
%  yvec and regmat should be vector and matrix.
%
%  Note: "initialization" means non-iterative estimation for LINEAR.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.10 $ $Date: 2009/11/09 16:24:07 $

% Author(s): Qinghua Zhang

ni=nargin;
error(nargchk(4, 4, ni,'struct'))

if isempty(yvec) || isempty(regmat)
    ctrlMsgUtils.error('Ident:estimation:emptyData')
end
if iscell(yvec)
    % Tolerate cellarray data
    yvec = yvec{1};
end
if iscell(regmat)
    % Tolerate cellarray data
    regmat = regmat{1};
end

if ~isreal(yvec) || ~isreal(regmat) || ndims(yvec)~=2 || ndims(regmat)~=2
    ctrlMsgUtils.error('Ident:estimation:soinitialize1')
end
nobsd = size(yvec,1);
[nobs, regdim]=size(regmat);
if nobsd~=nobs
    ctrlMsgUtils.error('Ident:estimation:soinitialize2')
end

rdim = regdimension(nlobj);
if rdim>0 && rdim~=regdim
    ctrlMsgUtils.error('Ident:idnlfun:DataNLDimMismatch')
end

params = nlobj.Parameters;
if ~isempty(params.LinearCoef) && ~isinitialized(nlobj) % The 2nd condition checks empty fields.
    % Linear Model Extension
  lthLinearCoef = length(params.LinearCoef);
    params = nlobj.Parameters;
  params.LinearCoef =  [params.LinearCoef; zeros(regdim-lthLinearCoef,1)]; % zero packing due to customreg
    resi = yvec-regmat*params.LinearCoef;
    params.OutputOffset = mean(resi, 1);
    nv = sum((resi - params.OutputOffset).^2)/max(1,nobs-1);
    covmat = [];
    
else
    regmean = mean(regmat, 1);
    ymean = mean(yvec,1);
    hw = ctrlMsgUtils.SuspendWarnings; % Turning off warnings
  [lincoef, stdlin, nv]= lscov(regmat-regmean(ones(nobs,1),:), yvec-ymean);
    delete(hw)                         % Restore warnings status
  params.LinearCoef = lincoef;
    params.OutputOffset = ymean - regmean*lincoef; % lincoef(regdim+1);
    covmat = nv*pinv([regmat ones(nobs,1)]'*[regmat ones(nobs,1)]);
end

nlobj.Parameters = params;

ei.LossFcn = nv*(nobs-regdim-1);
if ~isempty(ei.LossFcn) && ei.LossFcn<0
    ei.LossFcn = [];
end

% Oct2009
% FILE END
