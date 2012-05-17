function [y, der_d, der_t] = basisfun(fnb, x, D, T)
%BASISFUN: basis functions (scaling and wavelet functions) and their derivatives
%
%[y, der_d, der_t] = basisfun(fnb, x, D, T)
%
%fnb: function selector fnb=1 for scaling, fnb=2 for wavelet
%x: input variable, N*dimx matrix
%D: dilation parameters, nbbf*1 vector
%T: translation parameters, nbbf*dimx matrix
%
%y: value of scaling or wavelet function, N*nbbf matrix
%der_d: derivative of y in D, N*nbbf matrix
%der_t: derivative of y in T, N*(nbbf*dimx) matrix
%
%The derivatives are computed only if nargout>1

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:56:00 $

% Author(s): Qinghua Zhang


nbbf = size(T,1);    % number of basis functions
[N, dimx] = size(x);

% if any input is empty, return empty matrix
if isempty(x) || isempty(D)
    y = zeros(N,nbbf); der_d=y; der_t=zeros(N,nbbf*dimx);
    return;
end

onesN1 = ones(N,1);

xsq = sum(x .* x, 2);    % N*1
tsq = sum(T .* T, 2)';   % 1*nbbf
dsq = (D.*D)';           % 1*nbbf

% In principle the evaluation of y = |(x-T)|^2 requires memory size N*nbbf*dimx
% Here it is done as (|x|^2+|T|^2-2x.T) requiring memory size N*nbbf

y = (xsq(:,ones(1,nbbf)) + tsq(onesN1,:) - 2*x*T');

if nargout>1
    x_t_sq = y;   % save |(x-T)|^2 for later use
    
    %xx=[x_1...x_1  x_2...x_2 ... x_dimx...x_dimx] (repeat each colomn nbbf times)
    ind = 1:dimx;
    ind = ind(ones(nbbf,1),:);
    xx = x(:,ind(:));
    %xx = reshape(repmat(x, nbbf,1), N, nbbf*dimx);
    
    T = T(:)'; % Attention: shape of T changed
    xx = xx - T(ones(N,1),:); % xx=x-T
    %xx = xx - repmat(T(:)', N,1); % xx=x-T
    
    % this calculates xx=-2D*D*(x-T)
    dum = -2*reshape(dsq(ones(dimx,1), :), 1,nbbf*dimx);
    xx =  xx .* dum(ones(N,1),:);
    %xx = xx .* repmat(-2*reshape(dsq(ones(dimx,1), :), 1,nbbf*dimx), N,1);
end

y = y .* dsq(onesN1,:);    % y=D*D|(x-T)|^2


if nargout<2  % only evaluate basis function (no derivative)
    
    if fnb==1 % Scaling function
        y = LocalScalingFunctionDef(y);
    elseif fnb==2
        y = LocalWaveletFunctionDef(y, dimx);
    else
        ctrlMsgUtils.error('Ident:idnlfun:wavenetBasisfun1')
    end
    
else          % Compute also the derivatives
    
    if fnb==1 % Scaling function
        [y, dy] = LocalScalingFunctionDef(y);
    elseif fnb==2
        [y, dy] = LocalWaveletFunctionDef(y, dimx);
    else
        ctrlMsgUtils.error('Ident:idnlfun:wavenetBasisfun1')
    end
    
    der_d = 2*D(:,onesN1)' .* x_t_sq .* dy;
    
    ind = 1:nbbf;
    ind = ind(ones(dimx,1),:);
    %xx = x(:,ind(:));
    der_t = dy(:,ind(:)) .* xx;
    %der_t = reshape(repmat(dy, dimx,1), N, nbbf*dimx) .* xx;
    
end


%================ Local functions ==========================================

%the scaling function is the Gaussian function,
%the wavelet function is the Mexican hat.

%------------------------------------------------------------------------
function [y, dy] = LocalScalingFunctionDef(x2)
%This functions is phidef(|x|^2) defining the scaling function phi(|x|)
%
%x2 is |x|^2

y = exp(-0.5*x2);

if nargout>1   % Compute derivative of y
    dy = -0.5 * y;
end


%------------------------------------------------------------------------
function [y, dy] = LocalWaveletFunctionDef(x2, dimx)
%This functions is psidef(|x|^2) defining the scaling function psi(|x|)
%
%x2 is |x|^2

y = exp(-0.5*x2);

if nargout>1 % Compute derivative of y
    dy = (-1 - 0.5*(dimx-x2)) .* y;
end

y = (dimx-x2) .* y;
%y = (dimx-x2) .* exp(-0.5*x2);

% FILE END
