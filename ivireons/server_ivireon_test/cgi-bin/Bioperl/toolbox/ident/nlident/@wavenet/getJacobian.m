function  [yhat, jcb, dy_x] = getJacobian(nlobj, x, doParJac)
%getJacobian: single object WAVENET Jacobian computation
%
%[yhat, jcb, dy_x] = getJacobian(nlobj, x)
%  yhat: output
%  jcb: d yhat/d th
%  dy_x: d yhat/ d x
%
% doParJac: if false, jcb is not calculated.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2007/12/14 14:49:10 $

% Author(s): Qinghua Zhang

if nargin<3 
    doParJac = true;
end
jcb = [];

[nobs, regdim] = size(x);
onesN = ones(nobs, 1);

param = nlobj.Parameters;

coeflin = param.LinearCoef;
outoffset = param.OutputOffset;

coefsc = param.ScalingCoef(:)';
coefwl = param.WaveletCoef(:)';

dilasc = param.ScalingDilation;
transc = param.ScalingTranslation;
dilawl = param.WaveletDilation;
tranwl = param.WaveletTranslation;

% nbsc = length(coefsc);
% nbwl = length(coefwl);

regmean = param.RegressorMean;
pct = param.NonLinearSubspace;
lct = param.LinearSubspace;

x = x - regmean(ones(nobs,1), :);  %  x mean removal
xnl = x * pct;
xlin = x * lct;


[fsc, ddsc, dtsc] = basisfun(1, xnl, dilasc, transc);
[fwl, ddwl, dtwl] = basisfun(2, xnl, dilawl, tranwl);

dimxn = size(xnl,2);

yhat = xlin*coeflin + outoffset;
if ~isempty(param.ScalingCoef)
    yhat = yhat + fsc*coefsc';
end

if ~isempty(param.WaveletCoef)
    yhat = yhat + fwl*coefwl';
end

if nargout<2
    return
end

if doParJac 
    jcb = [xlin, ones(nobs,1), fsc, fwl, ...
        (ddsc .* coefsc(onesN, :)), (dtsc .* kron(ones(1,dimxn),coefsc(onesN, :))), ...
        (ddwl .* coefwl(onesN, :)), (dtwl .* kron(ones(1,dimxn),coefwl(onesN, :)))];
end


if nargout>2
    dy_x = (lct*coeflin(:,ones(1,nobs)))' ...
        - (dtsc * kron(eye(dimxn),coefsc(:))) * pct' ...
        - (dtwl * kron(eye(dimxn),coefwl(:))) * pct';
end

end %function

% FILE END
