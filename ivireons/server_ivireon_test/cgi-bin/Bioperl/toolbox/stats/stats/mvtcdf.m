function [y,err] = mvtcdf(varargin)
%MVTCDF Multivariate t cumulative distribution function (cdf).
%   Y = MVTCDF(X,C,DF) returns the cumulative probability of the multivariate
%   t distribution with correlation parameters C and degrees of freedom DF,
%   evaluated at each row of X.  Rows of the N-by-D matrix X correspond to
%   observations or points, and columns correspond to variables or
%   coordinates.  Y is an N-by-1 vector.
%
%   C is a symmetric, positive definite, D-by-D correlation matrix.  DF is a
%   scalar, or a vector with N elements.
%
%   Note: MVTCDF computes the CDF for the standard multivariate Student's t,
%   centered at the origin, with no scale parameters.  If C is a covariance
%   matrix, i.e. DIAG(C) is not all ones, MVTCDF rescales C to transform it
%   to a correlation matrix.  MVTCDF does not rescale X.
%
%   The multivariate t cumulative probability at X is defined as the
%   probability that a random vector T, distributed as multivariate t, will
%   fall within the semi-infinite rectangle with upper limits defined by X,
%   i.e., Pr{T(1)<=X(1), T(2)<=X(2), ... T(D)<=X(D)}.
%
%   Y = MVTCDF(XL,XU,C,DF) returns the multivariate t cumulative probability
%   evaluated over the rectangle with lower and upper limits defined by XL and
%   XU, respectively.
%
%   [Y,ERR] = MVTCDF(...) returns an estimate of the error in Y.  For
%   bivariate and trivariate distributions, MVTCDF uses adaptive quadrature on
%   a transformation of the t density, based on methods developed by Genz, as
%   described in the references.  The default absolute error tolerance for
%   these cases is 1e-8.  For four or more dimensions, MVTCDF uses a
%   quasi-Monte Carlo integration algorithm based on methods developed by Genz
%   and Bretz, as described in the references.  The default absolute error
%   tolerance for these cases is 1e-4.
%
%   [...] = MVTCDF(...,OPTIONS) specifies control parameters for the numerical
%   integration used to compute Y.  This argument can be created by a call to
%   STATSET.  Choices of STATSET parameters are:
%
%         'TolFun'      - Maximum absolute error tolerance.  Default is 1e-8
%                         when D < 4, or 1e-4 when D >= 4.
%         'MaxFunEvals' - Maximum number of integrand evaluations allowed when
%                         D >= 4.  Default is 1e7.  Ignored when D < 4.
%         'Display'     - Level of display output.  Choices are 'off' (the
%                         default), 'iter', and 'final'.  Ignored when D < 4.
%
%   Example:
%
%      C = [1 .4; .4 1]; df = 2;
%      [X1,X2] = meshgrid(linspace(-2,2,25)', linspace(-2,2,25)');
%      X = [X1(:) X2(:)];
%      p = mvtcdf(X, C, df);
%      surf(X1,X2,reshape(p,25,25));
%
%   See also MVNCDF, MVTPDF, MVTRND, TCDF.

%   References:
%      [1] Genz, A. (2004) "Numerical Computation of Rectangular Bivariate
%          and Trivariate Normal and t Probabilities", Statistics and
%          Computing, 14(3):251-260.
%      [2] Genz, A. and F. Bretz (1999) "Numerical Computation of Multivariate
%          t Probabilities with Application to Power Calculation of Multiple
%          Contrasts", J.Statist.Comput.Simul., 63:361-378.
%      [3] Genz, A. and F. Bretz (2002) "Comparison of Methods for the
%          Computation of Multivariate t Probabilities", J.Comp.Graph.Stat.,
%          11(4):950-971.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:15:45 $

% Strip off an options structure if it's there.
if isstruct(varargin{end})
    opts = statset(statset('mvtcdf'), varargin{end});
    nin = nargin - 1;
else
    opts = statset('mvtcdf');
    nin = nargin;
end

if nin < 3
    error('stats:mvtcdf:TooFewInputs','Requires at least three inputs.');

elseif nin < 4  % MVTCDF(X,C,DF), shift input args
    upperLimitOnly = true;
    XU = varargin{1};
    if ndims(XU)~=2
        error('stats:mvtcdf:InvalidData','X must be a matrix.');
    end
    XL = -Inf(size(XU),class(XU));
    C = varargin{2};
    df = varargin{3};

else  % MVTCDF(XL,XU,C,DF)
    upperLimitOnly = false;
    XL = varargin{1};
    XU = varargin{2};
    C = varargin{3};
    df = varargin{4};
    if ndims(XU)~=2 || ~isequal(size(XL),size(XU))
        error('stats:mvtcdf:InvalidData','XL and XU must be matrices and have the same size.');
    elseif any(any(XL > XU))
        error('stats:mvtcdf:InvalidData','XL must be less than or equal to XU.');
    end
end

% Get size of data.  Column vectors provisionally interpreted as multiple scalar data.
[n,d] = size(XU);
if d<1
    error('stats:mvtcdf:TooFewDimensions','X must have at least one column.');
end

% Special case: try to interpret X as a row vector if it was a column.
if (d == 1) && (size(C,1) == n)
    XL = XL';
    XU = XU';
    [n,d] = size(XU);
end

sz = size(C);
if sz(1) ~= sz(2)
    error('stats:mvtcdf:BadCorrelation',...
          'C must be a square matrix.');
elseif ~isequal(sz, [d d])
    error('stats:mvtcdf:InputSizeMismatch',...
          'C must be a square matrix with size equal to the number of columns in X.');
end

% Standardize C to correlation if necessary.  This does NOT standardize X.
s = sqrt(diag(C));
if (any(s~=1))
    C = C ./ (s*s');
end
% Make sure C is a valid correlation matrix
[T,err] = cholcov(C,0);
if err ~= 0
    error('stats:mvtcdf:BadCorrelation',...
          'C must be symmetric and positive definite.');
end

if isscalar(df), df = repmat(df,n,1); end
if ~(isvector(df) && length(df) == n)
    error('stats:mvtcdf:InputSizeMismatch', ...
          'DF must be a scalar or a vector with one element for each row in X.');
elseif any(df <= 0)
    error('stats:mvtcdf:InvalidDF','DF must be positive.');
end

% Call the appropriate integration routine for the umber of dimensions.
if d == 1
    y = tcdf(XU,df) - tcdf(XL,df);
    if nargout > 1
        err = NaN(size(y),class(y));
    end

elseif d <= 3
    tol = opts.TolFun; if isempty(tol), tol = 1e-8; end
    if d == 2, rho = C(2); else rho = C([2 3 6]); end
    if upperLimitOnly
        if d == 2
            y = bvtcdf(XU, rho, df, tol);
        else
            y = tvtcdf(XU, rho, df, tol);
        end
    else % lower and upper limits
        % Compute the probability over the rectangle as sums and differences
        % of integrals over semi-infinite half-rectangles.  For degenerate
        % rectangles, force an exact zero by making each piece exactly zero.
        equalLims = (XL==XU);
        XL(equalLims) = -Inf;
        XU(equalLims) = -Inf;
        y = zeros(n,1,superiorfloat(XL,XU,C,df));
        for i = 0:d
            k = nchoosek(1:d,i);
            for j = 1:size(k,1)
                X = XU; X(:,k(j,:)) = XL(:,k(j,:));
                if d == 2
                    y = y + (-1)^i * bvtcdf(X, rho, df, tol/4);
                else
                    y = y + (-1)^i * tvtcdf(X, rho, df, tol/8);
                end
            end
        end
    end
    if nargout > 1
        err = repmat(cast(tol,class(y)),size(y));
    end

elseif d <= 25
    tol = opts.TolFun; if isempty(tol), tol = 1e-4; end
    maxfunevals = opts.MaxFunEvals;
    verbose = find(strcmp(opts.Display,{'off' 'final' 'iter'})) - 1;
    y = zeros(n,1,superiorfloat(XL,XU,C,df));
    err = zeros(n,1,class(y));
    for i = 1:n
        [y(i),err(i)] = mvtcdfqmc(XL(i,:),XU(i,:),C,df(i),tol,maxfunevals,verbose);
    end

else
    error('stats:mvtcdf:DimensionTooLarge',...
          'Number of dimensions must be less than or equal to 25.');
end

y(y<0) = 0; % repair roundoff problems; max would drop NaNs
y(y>1) = 1; 
end


function p = bvtcdf(b,rho,nu,tol)
% CDF for the bivariate t
%
% Implements equation (21) in Section 4.2 of Genz (2004), integrating in terms
% of theta between asin(rho) and +/- pi/2, using adaptive quadrature.

n = size(b,1);
if rho >= 0
    p1 = T(min(b,[],2),nu);
    p1(any(isnan(b),2)) = NaN;
else
    p1 = T(b(:,1),nu)-T(-b(:,2),nu);
    p1(p1<0) = 0; % max would drop NaNs
end
if abs(rho) < 1 % possibly == 0
    loLimit = asin(rho);
    hiLimit = (sign(rho) + (rho == 0)).*pi./2;
    p2 = zeros(size(p1),class(p1));
    for i = 1:n
        b1 = b(i,1); b2 = b(i,2);
        v = nu(i);
        if isfinite(b1) && isfinite(b2)
            p2(i) = quadgk(@bvtIntegrand,loLimit,hiLimit,'AbsTol',tol,'RelTol',0);
        else
            % This piece is zero if either limit is +/- infinity.  If
            % either is NaN, p1 will already be NaN.
        end
    end
else % abs(rho) == 1
    p2 = zeros(class(p1));
end
p = cast(p1 - p2./(2.*pi), superiorfloat(b,rho,nu));

    % Functions to compute the integrand
    %
    %    (1 + (b1^2 + b2^2 - 2*b1*b2*sin(theta))/(nu*cos(theta)^2))^(-nu/2)
    %
    % and handle limits at theta = +/- pi/2 properly.
    function integrand = bvtIntegrand(theta)
        sintheta = sin(theta);
        cossqtheta = cos(theta).^2; % always positive
        integrand = (1 ./ (1 + ((b1*sintheta - b2).^2 ./ cossqtheta + b1.^2)/v)).^(v/2);
    end
end


%----------------------------------------------------------------------
function p = tvtcdf(b,rho,nu,tol)
% CDF for the trivariate t
%
% Implements equation (27) in Section 5.3 of Genz (2004), integrating each
% term in (27) separately in terms of theta between asin(rho_32) and +/- pi/2
% (first term) or between 0 and asin(rho_j1) (second and third terms), using
% adaptive quadrature.

n = size(b,1);

% Find a permutation that makes rho_32 == max(rho)
[dum,imax] = max(abs(rho));
if imax == 1 % swap 1 and 3
    rho_21 = rho(3); rho_31 = rho(2); rho_32 = rho(1);
    b = b(:,[3 2 1]);
elseif imax == 2 % swap 1 and 2
    rho_21 = rho(1); rho_31 = rho(3); rho_32 = rho(2);
    b = b(:,[2 1 3]);
else % imax == 3
    rho_21 = rho(1); rho_31 = rho(2); rho_32 = rho(3);
    % b already in correct order
end

if rho_32 >= 0
    p1 = bvtcdf([b(:,1) min(b(:,2:3),[],2)],0,nu,tol/4);
    p1(any(isnan(b),2)) = NaN;
else
    p1 = bvtcdf(b(:,1:2),0,nu,tol/4)-bvtcdf([b(:,1) -b(:,3)],0,nu,tol/4);
    p1(p1<0) = 0; % max would drop NaNs
end

if abs(rho_32) < 1 % possibly == 0
    loLimit = asin(rho_32);
    hiLimit = (sign(rho_32) + (rho_32 == 0)).*pi./2;
    p2 = zeros(size(p1),class(p1));
    for i = 1:n
        b1 = b(i,1); b2 = b(i,2); b3 = b(i,3);
        if isfinite(b2) && isfinite(b3) && ~isnan(b1)
            v = nu(i);
            p2(i) = quadgk(@tvtIntegrand1,loLimit,hiLimit,'AbsTol',tol/4,'RelTol',0);
        else
            % This piece is zero if either limit is +/- infinity.  If
            % either is NaN, p1 will already be NaN.
        end
    end
else % abs(rho_32) == 1
    p2 = zeros(class(p1));
end

if abs(rho_21) > 0
    loLimit = 0;
    hiLimit = asin(rho_21);
    rho_j1 = rho_21;
    rho_k1 = rho_31;
    p3 = zeros(size(p1),class(p1));
    for i = 1:n
        b1 = b(i,1); bj = b(i,2); bk = b(i,3);
        if isfinite(b1) && isfinite(bj) && ~isnan(bk)
            v = nu(i);
            p3(i) = quadgk(@tvtIntegrand2,loLimit,hiLimit,'AbsTol',tol/4,'RelTol',0);
        else
            % This piece is zero if either limit is +/- infinity.  If
            % either is NaN, p1 will already be NaN.
        end
    end
else
    p3 = zeros(class(p1));
end

if abs(rho_31) > 0
    loLimit = 0;
    hiLimit = asin(rho_31);
    rho_j1 = rho_31;
    rho_k1 = rho_21;
    p4 = zeros(size(p1),class(p1));
    for i = 1:n
        b1 = b(i,1); bj = b(i,3); bk = b(i,2);
        if isfinite(b1) && isfinite(bj) && ~isnan(bk)
            v = nu(i);
            p4(i) = quadgk(@tvtIntegrand2,loLimit,hiLimit,'AbsTol',tol/4,'RelTol',0);
        else
            % This piece is zero if either limit is +/- infinity.  If
            % either is NaN, p1 will already be NaN.
        end
    end
else
    p4 = zeros(class(p1));
end

p = cast(p1 + (-p2 + p3 + p4)./(2.*pi), superiorfloat(b,rho,nu));

    % Functions to compute the integrand in the first term
    %
    %    f_1(theta)^(-nu/2) * T_nu(b1/sqrt(f_1(theta)), where
    %
    %    f_1(theta) =
    %       (1 + (b2^2 + b3^2 - 2*b2*b3*sin(theta))/(nu*cos(theta)^2))
    %
    % and handle limits at theta = +/- pi/2 properly.
    function integrand = tvtIntegrand1(theta)
        sintheta = sin(theta);
        cossqtheta = cos(theta).^2; % always positive
        w = sqrt(1 ./ (1 + ((b2*sintheta - b3).^2 ./ cossqtheta + b2.^2)/v));
        integrand = w.^v .* T(b1.*w,v);
    end

    % Functions to compute the integrand in the second and third terms
    %
    %    f_k(theta)^(-nu/2) * T_nu(u_k(theta)/sqrt(f_k(theta)), where
    %
    %    f_k(theta) =
    %       (1 + (b1^2 + bj^2 - 2*b1*bj*sin(theta))/(nu*cos(theta)^2))
    %
    %    and u_k(theta) is given in Genz (2004).
    %
    % and handle limits at theta = 0 or pi/2 properly.
    function integrand = tvtIntegrand2(theta) % when b1 ~= +/- bj
        sintheta = sin(theta);
        cossqtheta = cos(theta).^2; % always positive
        w = sqrt(1 ./ (1 + ((b1*sintheta - bj).^2 ./ cossqtheta + b1.^2)/v));
        integrand = w.^v .* T(uk(sintheta,cossqtheta).*w,v);
    end
    function uk = uk(sintheta,cossqtheta)
        sinphi = sintheta .* rho_k1 ./ rho_j1;
        numeru = bk.*cossqtheta - b1.*(sinphi - rho_32.*sintheta) ...
                                - bj.*(rho_32 - sintheta.*sinphi);
        denomu = sqrt(cossqtheta.*(cossqtheta - sinphi.*sinphi ...
                                   - rho_32.*(rho_32 - 2.*sintheta.*sinphi)));
        uk = numeru ./ denomu;
    end
end


function p = T(x,nu)
% CDF for Student's t
% Compute F(-|x|) < .5, the lower tail.  Reflect for x>0.
p = betainc(nu ./ (nu + x.^2), nu/2, 0.5)/2;
reflect = (x > 0);
p(reflect) = 1 - p(reflect); % p < .5, cancellation not a problem
end
