function [ypred, delta] = nlpredci(model,X,beta,resid,varargin)
%NLPREDCI Confidence intervals for predictions in nonlinear regression.
%   [YPRED, DELTA] = NLPREDCI(MODELFUN,X,BETA,RESID,'covar',SIGMA) returns
%   predictions (YPRED) and 95% confidence interval half-widths (DELTA)
%   for the nonlinear regression model defined by MODELFUN, at input values X.
%   MODELFUN is a function, specified using @, that accepts two arguments,
%   a coefficient vector and the array X, and returns a vector of fitted Y
%   values.  Before calling NLPREDCI, use NLINFIT to fit MODELFUN by
%   nonlinear least squares and get estimated coefficient values BETA,
%   residuals RESID, and estimated coefficient covariance matrix SIGMA.
%
%   [YPRED, DELTA] = NLPREDCI(MODELFUN,X,BETA,RESID,'jacobian',J) is an
%   alternative syntax that also computes 95% confidence intervals.  J is
%   the Jacobian computed by NLINFIT.  You should use the 'covar' input
%   rather than the 'jacobian' input if you use a robust option with
%   NLINFIT, because the SIGMA parameter is required to take the robust
%   fitting into account.
%
%   [...] = NLPREDCI(...,'PARAM1',val1,'PARAM2',val2,...) allows you to
%   specify optional parameter name/value pairs as follows:
%
%      Name          Value
%      'alpha'       A value between 0 and 1 to specify the confidence level
%                    as 100(1-ALPHA)%.  Default is 0.05.
%      'mse'         The mean squared error returned by nlinfit.  This is
%                    required to predict new observations (see 'predopt')
%                    if you used a robust option with nlinfit; otherwise
%                    the mse is computed from the residuals and does not
%                    take the robust fitting into account.
%      'predopt'     Either 'curve' (the default) to compute confidence
%                    intervals for the estimated curve (function value) at
%                    X, or 'observation' for prediction intervals for a new
%                    observation at X.  If you specify 'observation' after
%                    using a robust option with nlinfit, you must also supply
%                    the 'mse' parameter to specify the robust estimate of
%                    the mean squared error.
%      'simopt'      Either 'on' for simultaneous bounds, or 'off' (the default)
%                    for non-simultaneous bounds.
%
%   NLPREDCI treats NaNs in RESID or J as missing values, and ignores the
%   corresponding observations.
%
%   The confidence interval calculation is valid for systems where the
%   length of RESID exceeds the length of BETA and J has full column rank
%   at BETA.  When J is ill-conditioned, predictions and confidence
%   intervals may be inaccurate.
%
%   Example:
%      load reaction;
%      [beta,resid,J,Sigma] = nlinfit(reactants,rate,@hougen,beta);
%      newX = reactants(1:2,:);
%      [ypred, delta] = nlpredci(@hougen,newX,beta,resid,'Covar',Sigma);
%
%   See also NLINFIT, NLPARCI, NLINTOOL.

% Older syntax still supported:
%   [YPRED, DELTA] = NLPREDCI(FUN,X,BETA,RESID,J,ALPHA,SIMOPT,PREDOPT)

%   References:
%      [1] Seber, G.A.F, and Wild, C.J. (1989) Nonlinear Regression, Wiley.

%   To compute confidence intervals when the parameters or data are complex,
%   you will need to split the problem into its real and imaginary parts.
%   First, define your parameter vector BETA as the concatenation of the real
%   and imaginary parts of the original parameter vector.  Then concatenate the
%   real and imaginary parts of the response vector Y as a single vector.
%   Finally, modify your model function MODELFUN to accept X and the purely
%   real parameter vector, and return a concatenation of the real and
%   imaginary parts of the fitted values.  Given this formulation of the
%   problem, NLINFIT will compute purely real estimates, and confidence
%   intervals are feasible.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:16:25 $

J = [];
Sigma = [];
alpha = 0.05;
mse = [];
simopt = 'off';
predopt = 'curve';
if nargin < 5
   error('stats:nlpredci:TooFewInputs','Requires five inputs.');
end

if nargin>=5 && ischar(varargin{1})
   % Calling sequence with named arguments
   okargs =   {'jacobian' 'covariance' 'alpha' 'mse' 'simopt' 'predopt'};
   defaults = {[]         []           0.05    []    'off'    'curve'};
   [eid emsg J Sigma alpha mse simopt predopt] = ...
                         internal.stats.getargs(okargs,defaults,varargin{:});
   if ~isempty(eid)
      error(sprintf('stats:nlpredci:%s',eid),emsg);
   end
else
    % [YPRED, DELTA] = NLPREDCI(FUN,X,BETA,RESID,J,ALPHA,SIMOPT,PREDOPT)
    if nargin>=5, J = varargin{1}; end
    if nargin>=6, alpha = varargin{2}; end
    if nargin>=7, simopt = varargin{3}; end
    if nargin>=8, predopt = varargin{4}; end
end
if isempty(alpha)
   alpha = 0.05;
elseif (~isscalar(alpha) || alpha<=0 || alpha >= 1)
   error('stats:nlpredci:BadAlpha',...
         'ALPHA must be a scalar satisfying 0<ALPHA<1.');
end
if isempty(simopt), simopt = 'off'; end
if isempty(predopt), predopt = 'curve'; end
switch(simopt)
 case 'on', dosim = 1;
 case 'off', dosim = 0;
 otherwise, error('stats:nlpredci:BadSimOpt',...
                  'SIMOPT must be ''on'' or ''off''.');
end
switch(predopt)
 case {'c' 'curve'}, newobs = 0;
 case {'o' 'observation'}, newobs = 1;
 otherwise, error('stats:nlpredci:BadPredOpt',...
                  'PREDOPT must be ''curve'' or ''observation''.');
end

% Make sure we have everything we need
if isempty(resid) || (isempty(J) && isempty(Sigma))
   error('stats:nlpredci:TooFewInputs',...
         'Requires RESID and either J or SIGMA.');
end
if ~isreal(beta) || ~isreal(J) || ~isreal(resid) || ~isreal(Sigma)
    error('stats:nlpredci:ComplexParams',...
         ['Cannot compute confidence intervals for complex parameters.  You must\n' ...
          'reparameterize the model into its real and imaginary parts.']);
end


% Remove missing values.
resid = resid(:);
missing = isnan(resid);
resid(missing) = [];
n = numel(resid);
p = numel(beta);
if n <= p
   error('stats:nlpredci:NotEnoughData',...
         'The number of observations must exceed the number of parameters.');
end
v = n-p;

% odds are, an input of length n should be a column vector
if (size(X,1)==1 && size(X,2)==n), X = X(:); end

if ~isempty(J)
   J(missing,:) = [];
   if size(J,1)~=n || size(J,2)~=p
      error('stats:nlpredci:InputSizeMismatch',...
            'The length of J does not match the sizes of BETA and RESID.');
   end

   % Approximation when a column is zero vector
   temp = find(max(abs(J)) == 0);
   if ~isempty(temp)
      J(:,temp) = sqrt(eps(class(J)));
   end
end

% Compute the predicted values at the new X.
ypred = feval(model, beta, X);
if ~isreal(ypred)
    error('stats:nlpredci:ComplexY',...
         ['Cannot compute confidence intervals for complex predicted values.  You must\n' ...
          'reparameterize the model into its real and imaginary parts.']);
end

% Approximate the Jacobian at the new X.
delta = zeros(length(ypred),numel(beta));
fdiffstep = eps(class(beta)).^(1/3);
for i = 1:length(beta)
   change = zeros(size(beta));
   if (beta(i) == 0)
      nb = sqrt(norm(beta));
      change(i) = fdiffstep * (nb + (nb==0));
   else
      change(i) = fdiffstep*beta(i);
   end
   predplus = feval(model, beta+change, X);
   delta(:,i) = (predplus - ypred)/change(i);
end

if isempty(mse) && (isempty(Sigma) || newobs)
    mse = norm(resid)^2 / v;
end

% Calculate covariance matrix
if isempty(Sigma)
   [Q,R] = qr(J,0);
   Rinv = R\eye(size(R));
   Sigma = mse * Rinv*Rinv';
end

varpred = sum((delta*Sigma) .* delta,2);
if (newobs)
   varpred = varpred + mse;
end

% Calculate confidence interval
if (dosim)
   crit = sqrt(p * finv(1-alpha, p, v));
else
   crit = tinv(1-alpha/2,v);
end
delta = sqrt(varpred) * crit;
