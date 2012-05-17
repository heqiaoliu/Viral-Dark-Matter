function  [nlobj,ei,nv,covmat] = soinitialize(nlobj, yvec, regmat, algo, hwcall)
%SOINITIALIZE: single object initialization for RIDGENET estimators.
%
%  [nlobj,ei,nv,covmat] = soinitialize(nlobj, yvec, regmat, algo)
%
%  yvec and regmat should be vector and matrix.
%
%  hwcall: optional argument of logic value, true if called from IDNLHW
%  initialization functions.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.11 $ $Date: 2009/11/09 16:24:09 $

% Author(s): Qinghua Zhang

ni=nargin;
error(nargchk(4, 5, ni,'struct'))
ei.LossFcn = NaN;
ei.Iterations = NaN;
nv = [];
covmat = [];

if ni<5
    hwcall = false;
end

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
nobsd = size(yvec, 1);
[nobs, regdim]=size(regmat);
if nobsd~=nobs
    ctrlMsgUtils.error('Ident:estimation:soinitialize2')
end

rdim = regdimension(nlobj);
if rdim>0 && rdim~=regdim
    ctrlMsgUtils.error('Ident:idnlfun:DataNLDimMismatch')
end

if nlobj.NumberOfUnits==0 && strcmpi(nlobj.LinearTerm, 'off')
    ctrlMsgUtils.error('Ident:idnlfun:NumUnitsLinearTerm')
end

% Linear Model Extension, part 1/2 
hth = nlobj.Parameters;
if ~isempty(hth.LinearCoef) && ~isinitialized(nlobj) % The 2nd condition checks empty fields.
  extlin = hth.LinearCoef;
  lthLinearCoef = length(extlin);
  if lthLinearCoef < regdim
    % Eventually fill initial customreg coefficients with zero.
    extlin = [extlin; zeros(regdim-lthLinearCoef, 1)];
  end
  LmdlExtFlag = true;
else
  LmdlExtFlag = false;
end

if hwcall
    nlobj = init1d(nlobj, yvec, regmat);
else
    nlobj = initridgenet(nlobj, yvec, regmat);
end

% Linear Model Extension, part 2/2
if LmdlExtFlag 
    pm = nlobj.Parameters;
  pm.LinearCoef =  pm.LinearSubspace \ extlin;
    pm.OutputCoef = pm.OutputCoef * 0;
  pm.OutputOffset = mean(yvec,1); % pm.RegressorMean * extlin;  
    nlobj.Parameters = pm;
end

% Oct2009
% FILE END
