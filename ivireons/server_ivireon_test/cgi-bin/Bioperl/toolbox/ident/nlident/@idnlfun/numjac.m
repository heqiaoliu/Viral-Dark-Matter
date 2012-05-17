function dydx = numjac(nlobj,x,tol,varargin)
%NUMJAC calculates numerical Jacobian of nonlinearity's output w.r.t
%regressors.
% 
%  See also idnlfun/getJacobian, utEvalStateJacobian.

% todo: 
%   1. introduce perturbation size related algorithm property in
%   idnlmodel/idmodel. 
%   2. introduce a differencing scheme property ('central', 'fwd', 'back')

% Written by: Rajiv Singh
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:19:19 $

if nargin<3
    % tol is not defined, use default
    % dx = tol*(|x| + 1)
    tol = 1e-7;
end

[NumRows, DimInp] = size(x);
dydx = zeros(NumRows,DimInp);

for k = 1:NumRows
    xk = x(k,:); %one set of regressor values
    Xp = repmat(xk,DimInp,1);
    del = tol*(abs(xk)+1);
    Yk = evaluate(nlobj,[Xp-diag(del);Xp+diag(del)]);
    dYk = diff(reshape(Yk,DimInp,2),1,2);
    dydx(k,:) = dYk.'./del/2;
end
