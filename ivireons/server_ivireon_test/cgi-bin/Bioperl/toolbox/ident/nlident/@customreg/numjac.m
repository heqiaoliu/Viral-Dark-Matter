function dydx = numjac(obj,x,tol,varargin)
%NUMJAC calculates numerical Jacobian of a custom regressor
%
%  See also idnlfun/numjac

% todo:
%   1. introduce perturbation size related algorithm property in
%   idnlmodel/idmodel.
%   2. introduce a differencing scheme property ('central', 'fwd', 'back')

% Written by: Rajiv Singh
% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:52:42 $

if nargin<3
    % tol is not defined, use default
    % dx = tol*(|x| + 1)
    tol = 1e-7;
end

[NumRows, DimInp] = size(x);

if ~isequal(DimInp,numel(obj.Arguments))
    ctrlMsgUtils.error('Ident:analysis:numJacInputDim',numel(obj.Arguments))
end

dydx = zeros(NumRows,DimInp);

for k = 1:NumRows
    xk = x(k,:); %one set of regressor values
    Xp = repmat(xk,DimInp,1);
    del = tol*(abs(xk)+1);
    Xmat = [Xp-diag(del);Xp+diag(del)]; % central diff
    Yk = LocalEvaluate(obj,Xmat);
    dYk = diff(reshape(Yk,DimInp,2),1,2);
    dydx(k,:) = dYk.'./del/2;
end

%--------------------------------------------------------------------------
function y = LocalEvaluate(obj,X)
% evaluate custom regressor for given input matrix X

[M,N] = size(X);
if obj.Vectorized
    c = mat2cell(X,M,ones(1,N));
    y = obj.Function(c{:});
else
    y = zeros(M,1);
    for k = 1:M
        c = mat2cell(X(k,:),1,ones(1,N));
        y(k) = obj.Function(c{:});
    end
end
