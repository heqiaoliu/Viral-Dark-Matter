function [x0,dxlo,dxup] = invpred(x,y,y0,varargin)
%INVPRED Inverse prediction for simple linear regression.
%   X0 = INVPRED(X,Y,Y0) accepts vectors X and Y of the same length,
%   fits a simple regression, and returns the estimated value X0 for
%   which the height of the line is Y0.  Y0 can be an array of any
%   size, and the output X0 has the same size as Y0.
%
%   [X0,DXLO,DXUP] = INVPRED(X,Y,Y0) also computes 95% inverse prediction
%   intervals.  DXLO and DXUP define intervals with lower bound X0-DXLO
%   and upper bound X0+DXUP.  Both DXLO and DXUP have the same size as Y0.
%
%   The intervals are not simultaneous and are not necessarily finite.
%   Some intervals may extend from a finite value to -Inf or +Inf, and some
%   may extend over the entire real line.
%
%   [X0,DXLO,DXUP] = INVPRED(X,Y,Y0,'NAME1',VALUE1,'NAME2',VALUE2,...)
%   specifies optional argument name/value pairs chosen from the
%   following list.  Argument names are case insensitive and partial
%   matches are allowed.
%
%      Name       Value
%     'alpha'     A value between 0 and 1 specifying a confidence level of
%                 100*(1-alpha)%.  Default is alpha=0.05 for 95% confidence.
%     'predopt'   Either 'observation' (the default) to compute intervals
%                 for the X0 value at which a new observation could equal
%                 Y0, or 'curve' to compute intervals for the X0 value at
%                 which the curve is equal to Y0.
%
%   INVPRED treats NaNs in X or Y as missing values, and removes them.
%
%    Example:
%        x = 4*rand(25,1);
%        y = 10 + 5*x + randn(size(x));
%        scatter(x,y)
%        x0 = invpred(x,y,20)
%
%   See also POLYFIT, POLYTOOL, POLYCONF.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:14:53 $

error(nargchk(3,Inf,nargin,'struct'));

% Check data inputs
if ~isvector(x) || ~isreal(x)
    error('stats:invpred:BadX','X must be a vector of real values.')
end
if ~isvector(y) || ~isreal(y)
    error('stats:invpred:BadY','Y must be a vector of real values.')
end
if numel(x) ~= numel(y)
    error('stats:invpred:InputSizeMismatch',...
          'X and Y must have the same length.');
end
x = x(:);
y = y(:);
t = isnan(x) | isnan(y);
if any(t)
    x(t) = [];
    y(t) = [];
end
if ~isreal(y0)
    error('stats:invpred:BadY0','Y0 must be an array of real values.')
end

% Process optional inputs and check them
okargs =   {'alpha' 'predopt'};
defaults = {0.05    'obs'};
[eid emsg alpha predopt] = internal.stats.getargs(okargs,defaults,varargin{:});
if ~isempty(eid)
    error(sprintf('stats:invpred:%s',eid),emsg);
end

if ~isscalar(alpha) || ~isnumeric(alpha) || ~isreal(alpha) ...
                    || alpha<=0          || alpha>=1
    error('stats:invpred:BadAlpha',...
          'ALPHA must be a scalar between 0 and 1.');
end
i = find(strncmpi(predopt,{'curve';'observation'},length(predopt)));
if ~isscalar(i)
    error('stats:invpred:BadPredOpt', ...
   'PREDOPT must be one of the strings ''curve'' or ''observation''.');
end
doobs = (i==2);

% Fit a straight line and get inverse prediction
mx = mean(x);
x = x-mx;
normx = norm(x)^2;
if normx==0
    error('stats:invpred:ConstantX',...
          'Cannot compute inverse predictions if X is constant.')
end

[p,S] = polyfit(x,y,1);
if p(1) == 0
    x0 = NaN(size(y0));
else
    x0 = (y0 - p(2)) / p(1);
end

if nargout>1
    % Compute the coefficients of a quadratic equation whose
    % roots lead to the inverse prediction bounds
    n = length(y);
    df = n - length(p);
    tquant = -tinv(alpha/2,df);
    if df>0
        s = S.normr / sqrt(df);
    else
        s = NaN;
    end
    if doobs
        varfact = 1 + 1/n;
    else
        varfact = 1/n;
    end
    my = mean(y);
    A = (p(1)^2 - tquant^2 * s^2 / norm(x)^2) * ones(size(y0));
    B = -2*p(1)*(y0-my);
    C = (y0-my).^2 - tquant^2 * s^2 * varfact;

    Bsq = B.^2;
    discr = Bsq - 4*A.*C;
    discr(discr<0 & discr>-100*eps(Bsq)) = 0;
    q = -.5*(B + sign(B).*sqrt(discr));
    d1 = q./A;
    d2 = C./q;
    
    t = isreal(d1) & abs(d1-d2) <= eps(normx);
    d1(t) = x0(t);
    d2(t) = x0(t);    

    % Put the interval end points in order with d1<d2
    t = d1>d2;
    temp = d1(t);
    d1(t) = d2(t);
    d2(t) = temp;

    % Some intervals are bounded by d1 and d2
    xlo = real(d1);
    xup = real(d2);

    % Some intervals are unbounded in either direction
    dreal = (imag(d1) == 0);
    t = ~dreal;
    xlo(t) = -Inf;
    xup(t) = Inf;

    % Some intervals are bounded above by d1
    t = dreal & (x0<d1);
    xup(t) = d1(t);
    xlo(t) = -Inf;

    % Some intervals are bounded below by d2
    t = dreal & (x0>d2);
    xlo(t) = d2(t);
    xup(t) = Inf;
end

% Remove centering
if nargout>1
   dxlo = x0 - xlo;
   dxup = xup - x0;
end
x0 = x0 + mx;
