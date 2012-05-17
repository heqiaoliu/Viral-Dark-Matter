function  nlobj = solinestimate(nlobj, yvec, regmat)
%SOLINESTIMATE estimates the linear coeffients of a single PWLINEAR
%
%  nlobj = solinestimate(nlobj, yvec, regmat)
%
%The parameters OutputCoef, OutputOffset, LinearCoef are estimated,
%while the other parameters are kept inchanged.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:55:15 $

% Author(s): Qinghua Zhang

param = nlobj.internalParameter;
% nlregdim = 1;
% linregdim = size(param.LinearCoef,1);
[nobs, regdim] = size(regmat);

if regdim~=1
  ctrlMsgUtils.error('Ident:idnlfun:scalarInputOnly','PWLINEAR')
end

plw = param.LinearCoef;
ib = param.Translation;
%ow = param.OutputCoef;
%ob = param.OutputOffset;

numunits = length(ib);

xnl = regmat;
if size(plw, 1)==1
  xlin = regmat;
else
  xlin = zeros(nobs,0);
end

fsig = unitfcn(nlobj, (xnl(:,ones(1,numunits)) + ib(ones(nobs,1),:)));

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
warning(was), lastwarn(lw,lwid);

param.OutputCoef = wandb(1:numunits);
param.OutputOffset = wandb(numunits+1);
param.LinearCoef = wandb(numunits+2:n1);

nlobj.internalParameter = param;

% Erase last assignedBreakPoints.
nlobj.assignedBreakPoints = [];

% FILE END
