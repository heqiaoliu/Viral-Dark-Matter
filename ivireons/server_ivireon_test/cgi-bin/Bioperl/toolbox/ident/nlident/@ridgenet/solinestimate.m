function  nlobj = solinestimate(nlobj, yvec, regmat)
%SOLINESTIMATE estimates the linear coeffients of a single RIDGENET
%
%  nlobj = solinestimate(nlobj, yvec, regmat)
%
%The parameters OutputCoef, OutputOffset, LinearCoef are estimated,
%while the other parameters are kept inchanged.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/31 06:14:51 $

% Author(s): Qinghua Zhang

param = nlobj.Parameters;
%[nlregdim, nbunits] = size(param.Dilation);
%linregdim = size(param.LinearCoef,1);
[nobs, regdim] = size(regmat);

error(mdlddchk(param, regdim));

% utype = pvget(sys, 'RidgeUnit');

iw = param.Dilation;

regmean = param.RegressorMean;
pct = param.NonLinearSubspace;
lct = param.LinearSubspace;

%plw = param.LinearCoef;
ib = param.Translation;
%ow = param.OutputCoef;
%ob = param.OutputOffset;

numunits = length(ib);

regmat = regmat - regmean(ones(nobs,1), :);  %  regressor mean removal
xnl = regmat * pct;
xlin = regmat * lct;

% check first for unit fcn validity if nlobj in customnet

if isa(nlobj,'customnet')
    try
        [fsigtry, dfsigtry, atry] = unitfcn(nlobj, (xnl(1,:)*iw + ib(1,:)));       
    catch E
        msg = 'Check that the unit function of the CUSTOMNET nonlinearity estimator has been properly defined.';
        msg = sprintf('%s The following error occurred during its evaluation:\n%s',msg,E.message);
        error('Ident:idnlfun:evaluationError',msg) %#ok<SPERR>
    end
    
    if ~isequal(size(fsigtry),size(ib(1,:))) || ~isequal(size(fsigtry),size(dfsigtry)) || ~isscalar(atry)
        ctrlMsgUtils.error('Ident:idnlfun:inconsistentUnitFcn',func2str(nlobj.UnitFcn))
    end
    
end
fsig = unitfcn(nlobj, (xnl*iw + ib(ones(nobs,1),:)));

R1=triu(qr([fsig, ones(nobs,1), xlin, yvec]));
[rows, n1]= size(R1);
n1 = n1-1;
mn1 = min(n1,rows);
R=R1(1:mn1,1:n1);
Re=R1(1:mn1,n1+1);

was = warning('off'); [lw,lwid] = lastwarn;
if rank(R)==n1
  wandb = R\Re;
else
  wandb = pinv(R)*Re;
end
warning(was), lastwarn(lw,lwid)

param.OutputCoef = wandb(1:numunits);
param.OutputOffset = wandb(numunits+1);
param.LinearCoef = wandb(numunits+2:n1);

nlobj.Parameters = param;

% FILE END
