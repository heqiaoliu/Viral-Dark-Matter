function varargout = interp1(varargin)
%INTERP1 1-D interpolation (table lookup)
%   YI = INTERP1(X,Y,XI) interpolates to find YI, the values of the
%   underlying function Y at the points in the array XI. X must be a
%   vector of length N.
%   If Y is a vector, then it must also have length N, and YI is the
%   same size as XI.  If Y is an array of size [N,D1,D2,...,Dk], then
%   the interpolation is performed for each D1-by-D2-by-...-Dk value
%   in Y(i,:,:,...,:).
%   If XI is a vector of length M, then YI has size [M,D1,D2,...,Dk].
%   If XI is an array of size [M1,M2,...,Mj], then YI is of size
%   [M1,M2,...,Mj,D1,D2,...,Dk].
%
%   YI = INTERP1(Y,XI) assumes X = 1:N, where N is LENGTH(Y)
%   for vector Y or SIZE(Y,1) for array Y.
%
%   Interpolation is the same operation as "table lookup".  Described in
%   "table lookup" terms, the "table" is [X,Y] and INTERP1 "looks-up"
%   the elements of XI in X, and, based upon their location, returns
%   values YI interpolated within the elements of Y.
%
%   YI = INTERP1(X,Y,XI,METHOD) specifies alternate methods.
%   The default is linear interpolation. Use an empty matrix [] to specify
%   the default. Available methods are:
%
%     'nearest'  - nearest neighbor interpolation
%     'linear'   - linear interpolation
%     'spline'   - piecewise cubic spline interpolation (SPLINE)
%     'pchip'    - shape-preserving piecewise cubic interpolation
%     'cubic'    - same as 'pchip'
%     'v5cubic'  - the cubic interpolation from MATLAB 5, which does not
%                  extrapolate and uses 'spline' if X is not equally
%                  spaced.
%
%   YI = INTERP1(X,Y,XI,METHOD,'extrap') uses the interpolation algorithm
%   specified by METHOD to perform extrapolation for elements of XI outside the
%   interval spanned by X. YI = INTERP1(X,Y,XI,METHOD,EXTRAPVAL) replaces the
%   values outside of the interval spanned by X with EXTRAPVAL.  NaN and 0 are
%   often used for EXTRAPVAL.  The default extrapolation behavior with four
%   input arguments is 'extrap' for 'spline' and 'pchip' and EXTRAPVAL = NaN for
%   the other methods.
%
%   PP = INTERP1(X,Y,METHOD,'pp') will use the interpolation algorithm specified
%   by METHOD to generate the ppform (piecewise polynomial form) of Y. The
%   method may be any of the above METHOD except for 'v5cubic'. PP may then be
%   evaluated via PPVAL. PPVAL(PP,XI) is the same as
%   INTERP1(X,Y,XI,METHOD,'extrap').
%
%   For example, generate a coarse sine curve and interpolate over a
%   finer abscissa:
%       x = 0:10; y = sin(x); xi = 0:.25:10;
%       yi = interp1(x,y,xi); plot(x,y,'o',xi,yi)
%
%   For a multi-dimensional example, we construct a table of functional
%   values:
%       x = [1:10]'; y = [ x.^2, x.^3, x.^4 ];
%       xi = [ 1.5, 1.75; 7.5, 7.75]; yi = interp1(x,y,xi);
%
%   creates 2-by-2 matrices of interpolated function values, one matrix for
%   each of the 3 functions. yi will be of size 2-by-2-by-3.
%
%   Class support for inputs X, Y, XI, EXTRAPVAL:
%      float: double, single
%
%   See also INTERP1Q, INTERPFT, SPLINE, PCHIP, INTERP2, INTERP3, INTERPN, PPVAL.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 5.41.4.14 $  $Date: 2010/03/31 18:24:27 $
%
% Determine input arguments.

% The following syntaxes do not have X as the first input:
% INTERP1(Y,XI)
% INTERP1(Y,XI,METHOD)
% INTERP1(Y,XI,METHOD,'extrap')
% INTERP1(Y,XI,METHOD,EXTRAPVAL)
xOffset = 1;
if (nargin==2) || ...
   (nargin==3 && ischar(varargin{3}))  || ...
   (nargin==4 && ~(ischar(varargin{4}) || isempty(varargin{4})) || ...
   (nargin==4 && strcmp(varargin{4}, 'extrap')));
    xOffset = 0;
end

ppOutput = false;
% PP = INTERP1(X,Y,METHOD,'pp')
if nargin>=4 && ischar(varargin{3}) && isequal('pp',varargin{4})
    ppOutput = true;
    if (nargin > 4)
        error('MATLAB:interp1:ppOutput', ...
            'Use 4 inputs for PP=INTERP1(X,Y,METHOD,''pp'').')
    end
end

% Process Y in INTERP1(Y,...) and INTERP1(X,Y,...)
y = varargin{1+xOffset};
siz_y = size(y);
% y may be an ND array, but collapse it down to a 2D yMat. If yMat is
% a vector, it is a column vector.
if isvector(y)
    if isrow(y)
        % Prefer column vectors for y
        yMat = y.';
        n = siz_y(2);
    else
        yMat = y;
        n = siz_y(1);
    end
    ds = 1;
    prodDs = 1;
else
    n = siz_y(1);
    ds = siz_y(2:end);
    prodDs = prod(ds);
    yMat = reshape(y,[n prodDs]);
end

% Process X in INTERP1(X,Y,...), or supply default for INTERP1(Y,...)
if xOffset
    x = varargin{xOffset};
    if ~isvector(x)
        error('MATLAB:interp1:Xvector','X must be a vector.');
    end
    if length(x) ~= n
        if isvector(y)
            error('MATLAB:interp1:YInvalidNumRows', ...
                'X and Y must be of the same length.')
        else
            error('MATLAB:interp1:YInvalidNumRows', ...
                'LENGTH(X) and SIZE(Y,1) must be the same.');
        end
    end
    % Prefer column vectors for x
    xCol = x(:);
else
    xCol = (1:n)';
end

% Process XI in INTERP1(Y,XI,...) and INTERP1(X,Y,XI,...)
% Avoid syntax PP = INTERP1(X,Y,METHOD,'pp')
if ~ppOutput
    xi = varargin{2+xOffset};
    siz_xi = size(xi);
    % xi may be an ND array, but flatten it to a column vector xiCol
    xiCol = xi(:);
    % The size of the output YI
    if isvector(y)
        % Y is a vector so size(YI) == size(XI)
        siz_yi = siz_xi;
    else
        if isvector(xi)
            % Y is not a vector but XI is
            siz_yi = [length(xi) ds];
        else
            % Both Y and XI are non-vectors
            siz_yi = [siz_xi ds];
        end
    end
end

if xOffset && ~isreal(x)
    error('MATLAB:interp1:ComplexX','X should be a real vector.')
end

if ~ppOutput && ~isreal(xi)
    error('MATLAB:interp1:ComplexInterpPts', ...
        'The interpolation points XI should be real.')
end

% Error check for NaN values in X and Y
% check for NaN's
if xOffset && (any(isnan(xCol)))
    error('MATLAB:interp1:NaNinX','NaN is not an appropriate value for X.');
end

% NANS are allowed as a value for F(X), since a function may be undefined
% for a given value.
if any(isnan(yMat(:)))
    warning('MATLAB:interp1:NaNinY', ...
        ['NaN found in Y, interpolation at undefined values \n\t',...
        ' will result in undefined values.']);
end

if (n < 2)
    if ppOutput || ~isempty(xi)
        error('MATLAB:interp1:NotEnoughPts', ...
            'There should be at least two data points.')
    else
        yi = zeros(siz_yi,superiorfloat(x,y,xi));
        varargout{1} = yi;
        return
    end
end

% Process METHOD in
% PP = INTERP1(X,Y,METHOD,'pp')
% YI = INTERP1(Y,XI,METHOD,...)
% YI = INTERP1(X,Y,XI,METHOD,...)
% including explicit specification of the default by an empty input.
if ppOutput
    if isempty(varargin{3})
        method = 'linear';
    else
        method = varargin{3};
    end
else
    if nargin >= 3+xOffset && ~isempty(varargin{3+xOffset})
        method = varargin{3+xOffset};
    else
        method = 'linear';
    end
end
    
% The v5 option, '*method', asserts that x is equally spaced.
eqsp = (method(1) == '*');
if eqsp
    method(1) = [];
end

% INTERP1([X,]Y,XI,METHOD,'extrap') and INTERP1([X,]Y,Xi,METHOD,EXTRAPVAL)
if ~ppOutput
    if nargin >= 4+xOffset
        extrapval = varargin{4+xOffset};
    else
        switch method(1)
            case {'s','p','c'}
                extrapval = 'extrap';
            otherwise
                extrapval = NaN;
        end
    end
end

% Start the algorithm
% We now have column vector xCol, column vector or 2D matrix yMat and
% column vector xiCol.
if xOffset
    if ~eqsp
        h = diff(xCol);
        eqsp = (norm(diff(h),Inf) <= eps(norm(xCol,Inf)));
        if any(~isfinite(xCol))
            eqsp = 0; % if an INF in x, x is not equally spaced
        end
    end
    if eqsp
        h = (xCol(n)-xCol(1))/(n-1);
    end
else
    h = 1;
    eqsp = 1;
end
if any(h < 0)
    [xCol,p] = sort(xCol);
    yMat = yMat(p,:);
    if eqsp
        h = -h;
    else
        h = diff(xCol);
    end
end
if any(h == 0)
    error('MATLAB:interp1:RepeatedValuesX', ...
        'The values of X should be distinct.');
end

% PP = INTERP1(X,Y,METHOD,'pp')
if nargin==4 && ischar(varargin{3}) && isequal('pp',varargin{4}) 
    % obtain pp form of output
    pp = ppinterp;
    varargout{1} = pp;
    return
end

% Interpolate
numelXi = length(xiCol);
p = [];
switch method(1)
    case 's'  % 'spline'
        % spline is oriented opposite to interp1
        yiMat = spline(xCol.',yMat.',xiCol.').';

    case {'c','p'}  % 'cubic' or 'pchip'
        % pchip is oriented opposite to interp1
        yiMat = pchip(xCol.',yMat.',xiCol.').';

    otherwise % 'nearest', 'linear', 'v5cubic'
        yiMat = zeros(numelXi,prodDs,superiorfloat(xCol,yMat,xiCol));
        if ~eqsp && any(diff(xiCol) < 0)
            [xiCol,p] = sort(xiCol);
        else
            p = 1:numelXi;
        end

        % Find indices of subintervals, x(k) <= u < x(k+1),
        % or u < x(1) or u >= x(m-1).
        if isempty(xiCol)
            k = xiCol;
        elseif eqsp
            k = min(max(1+floor((xiCol-xCol(1))/h),1),n-1);
        else
            [~,k] = histc(xiCol,xCol);
            k(xiCol<xCol(1) | ~isfinite(xiCol)) = 1;
            k(xiCol>=xCol(n)) = n-1;
        end

        switch method(1)
            case 'n'  % 'nearest'
                i = find(xiCol >= (xCol(k)+xCol(k+1))/2);
                k(i) = k(i)+1;
                yiMat(p,:) = yMat(k,:);

            case 'l'  % 'linear'
                if eqsp
                    s = (xiCol - xCol(k))/h;
                else
                    s = (xiCol - xCol(k))./h(k);
                end
                for j = 1:prodDs
                    yiMat(p,j) = yMat(k,j) + s.*(yMat(k+1,j)-yMat(k,j));
                end

            case 'v'  % 'v5cubic'
                extrapval = NaN;
                if eqsp
                    % Data are equally spaced
                    s = (xiCol - xCol(k))/h;
                    s2 = s.*s;
                    s3 = s.*s2;
                    % Add extra points for first and last interval
                    yMat = [3*yMat(1,:)-3*yMat(2,:)+yMat(3,:); ...
                        yMat; ...
                        3*yMat(n,:)-3*yMat(n-1,:)+yMat(n-2,:)];
                    for j = 1:prodDs
                        yiMat(p,j) = (yMat(k,j).*(-s3+2*s2-s) + ...
                            yMat(k+1,j).*(3*s3-5*s2+2) + ...
                            yMat(k+2,j).*(-3*s3+4*s2+s) + ...
                            yMat(k+3,j).*(s3-s2))/2;
                    end
                else
                    % Data are not equally spaced
                    % spline is oriented opposite to interp1
                    yiMat = spline(xCol.',yMat.',xiCol.').';
                end
            otherwise
                error('MATLAB:interp1:InvalidMethod','Invalid method.')
        end
end

% Override extrapolation
if ~isequal(extrapval,'extrap')
    if ischar(extrapval)
        error('MATLAB:interp1:InvalidExtrap', 'Invalid extrap option.')
    elseif ~isscalar(extrapval)
        error('MATLAB:interp1:NonScalarExtrapValue',...
            'EXTRAP option must be a scalar.')
    end
    if isempty(p)
        p = 1 : numelXi;
    end
     outOfBounds = xiCol<xCol(1) | xiCol>xCol(n);
     yiMat(p(outOfBounds),:) = extrapval;
end

% Reshape result, possibly to an ND array
yi = reshape(yiMat,siz_yi);
varargout{1} = yi;

%-------------------------------------------------------------------------%
    function pp = ppinterp
        %PPINTERP ppform interpretation.

        switch method(1)
            case 'n' % nearest
                breaks = [xCol(1); ...
                    (xCol(1:end-1)+xCol(2:end))/2; ...
                    xCol(end)].';
                coefs = yMat.';
                pp = mkpp(breaks,coefs,ds);
            case 'l' % linear
                breaks = xCol.';
                page1 = (diff(yMat)./repmat(diff(xCol),[1, prodDs])).';
                page2 = (reshape(yMat(1:end-1,:),[n-1, prodDs])).';
                coefs = cat(3,page1,page2);
                pp = mkpp(breaks,coefs,ds);
            case {'p', 'c'} % pchip and cubic
                pp = pchip(xCol.',reshape(yMat.',[ds, n]));
            case 's' % spline
                pp = spline(xCol.',reshape(yMat.',[ds, n]));
            case 'v' % v5cubic
                b = diff(xCol);
                if norm(diff(b),Inf) <= eps(norm(xCol,Inf))
                    % data are equally spaced
                    a = repmat(b,[1 prodDs]).';
                    yReorg = [3*yMat(1,:)-3*yMat(2,:)+yMat(3,:); ...
                        yMat; ...
                        3*yMat(n,:)-3*yMat(n-1,:)+yMat(n-2,:)];
                    y1 = yReorg(1:end-3,:).';
                    y2 = yReorg(2:end-2,:).';
                    y3 = yReorg(3:end-1,:).';
                    y4 = yReorg(4:end,:).';
                    breaks = xCol.';
                    page1 = (-y1+3*y2-3*y3+y4)./(2*a.^3);
                    page2 = (2*y1-5*y2+4*y3-y4)./(2*a.^2);
                    page3 = (-y1+y3)./(2*a);
                    page4 = y2;
                    coefs = cat(3,page1,page2,page3,page4);
                    pp = mkpp(breaks,coefs,ds);
                else
                    % data are not equally spaced
                    pp = spline(xCol.',reshape(yMat.',[ds, n]));
                end
            otherwise
                error('MATLAB:interp1:ppinterp:UnknownMethod', ...
                    'Unrecognized method.');
        end

        % Even if method is 'spline' or 'pchip', we still need to record that the
        % input data Y was oriented according to INTERP1's rules.
        % Thus PPVAL will return YI oriented according to INTERP1's rules and
        % YI = INTERP1(X,Y,XI,METHOD) will be the same as
        % YI = PPVAL(INTERP1(X,Y,METHOD,'pp'),XI)
        pp.orient = 'first';
    end % PPINTERP

end % INTERP1
