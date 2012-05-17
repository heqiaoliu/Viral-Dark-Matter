function [nlogL,avar] = betalike(params,data)
%BETALIKE Negative beta log-likelihood function.
%   NLOGL = BETALIKE(PARAMS,DATA) returns the negative of beta log-likelihood  
%   function for the parameters PARAMS(1) = A and PARAMS(2) = B, given DATA.
%
%   [NLOGL, AVAR] = BETALIKE(PARAMS,DATA) returns the inverse of Fisher's
%   information matrix, AVAR.  If the input parameter values in PARAMS
%   are the maximum likelihood estimates, the diagonal elements of AVAR
%   are their asymptotic variances.
%
%   The beta distribution is defined on the open interval (0,1).  However, it
%   is sometimes also necessary to fit a beta distribution to data that
%   include exact zeros or ones.  For such data, the beta likelihood function
%   is unbounded, and standard maximum likelihood estimation is not possible.
%   In that case, BETALIKE computes a modified likelihood that incorporates the
%   zeros or ones by treating them as if they were values that have been
%   left-censored at SQRT(REALMIN) or right-censored at 1-EPS/2, respectively.
%
%   See also BETAFIT, GAMLIKE, MLE, NORMLIKE, WBLLIKE.

%   Copyright 1993-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2010/03/16 00:12:18 $

if nargin < 2
    error('stats:betalike:TooFewInputs','Requires two input arguments.');
elseif ~isvector(data)
    error('stats:betalike:VectorRequired','DATA must be a vector.');
end
x = data(:);

a = params(1);
b = params(2);

% Return NaN for out of range parameters or data.
a(a <= 0) = NaN;
b(b <= 0) = NaN;
xmin = min(x); xmax = max(x);
x(~(0<=x & x<=1)) = NaN;

% Separate data into zeros, interior values, and ones. 
xl = sqrt(realmin(class(x))); % some tolerance above zero
xu = 1 - eps(class(x))/2;
if (xl <= xmin) && (xmax <= xu)
    n0 = 0;
    n1 = 0;
    x2 = x;
    n2 = length(x);
else
    i0 = (x < xl);
    n0 = sum(i0);
    i1 = (x > xu);
    n1 = sum(i1);
    i2 = ~(i0 | i1);
    x2 = x(i2);
    n2 = length(x2);
end
    
% Compute the usual continuous log-likelihood using values that are
% strictly within the interval (0,1),
logx2 = log(x2);
log1mx2 = log1p(-x2);
sumlogx2 = sum(logx2);
sumlog1mx2 = sum(log1mx2);
nlogL = n2*betaln(a,b) - (a-1)*sumlogx2 - (b-1)*sumlog1mx2;

% If some values are zero or one, compute a mixed likelihood that includes
% discrete probabilities for those values.  Note that the asymmetry in xl
% and xu (relative to 0 and 1, respectively) means that when the vector x
% contains exact zeros or ones, betalike([a,b],x) is typically not equal
% to betalike([b,a],1-x).  But that's true even without exact ones and
% zeros, because of floating point's differing precision at 0 and 1.
%
% Include F(xl) = Pr(X <= xl) for data that are zeros.
if n0 > 0
    nlogL = nlogL - n0*log(betainc(xl,a,b,'lower'));
end

% Include 1-F(xu) = Pr(X >= xu) for data that are ones.
if n1 > 0
    nlogL = nlogL - n1*log(betainc(xu,a,b,'upper'));
end

if nargout > 1
    if numel(data) < 2
        error('stats:betalike:NotEnoughData',...
              'To compute AVAR, DATA must have at least two elements.');
    end
    
    % Compute the Jacobian of the likelihood for values strictly within the
    % interval (0,1).
    J = [logx2+psi(a+b)-psi(a) log1mx2+psi(a+b)-psi(b)];

    % Add terms into the Jacobian for the zero and one values.
    if n0>0 | n1>0
        delta = eps(superiorfloat(class(a),class(b)))^(1/2);
        aa = a + a*delta*[1 -1];
        bb = b + b*delta*[1 -1];
        if n0 > 0
            % Finite central difference approximation to the scores
            % d(F(xl))/d(a,b) for zeros.
            da = diff(log(betainc(xl,aa,b,'lower'))) / (2*a*delta);
            db = diff(log(betainc(xl,a,bb,'lower'))) / (2*b*delta);
            J = [J; repmat([da db],n0,1)];
        end
        if n1 > 0
            % Finite central difference approximation to the scores
            % d(1-F(xu))/d(a,b) for ones.
            da = diff(log(betainc(xu,aa,b,'upper'))) / (2*a*delta);
            db = diff(log(betainc(xu,a,bb,'upper'))) / (2*b*delta);
            J = [J; repmat([da db],n1,1)];
        end
    end
    
    % Invert the inner product of the Jacobian to get the asymptotic covariance.
    [Q,R] = qr(J,0);
    if any(isnan(R(:)))
        avar = [NaN NaN; NaN NaN];
    else
        Rinv = R \ eye(2);
        avar = Rinv*Rinv';
    end
end
