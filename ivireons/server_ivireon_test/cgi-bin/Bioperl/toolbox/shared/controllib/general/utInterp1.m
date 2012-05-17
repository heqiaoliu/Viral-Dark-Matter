function yi = utInterp1(x,y,xi)
%UTINTERP1 1-D interpolation (table lookup)
% 
%   YI = UTINTERP1(X,Y,XI) interpolates to find YI, the values of the
%   underlying function Y at the points in the array XI. X and Y must be a
%   vector of length N.  YI is the same size as XI.  When X contains
%   duplicate entries the pair (Yi, Xi) is retained where Xi is the last
%   unique entry of the sort(X).
%   Class support for inputs X, Y, XI:
%      float: double, single
%
%   See also INTERP1.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:11:29 $
%


% Input Error Checking
error(nargchk(3,3,nargin,'struct'))

if ~isvector(x) || ~isvector(y)
    ctrlMsgUtils.error('Controllib:utility:utInterp1')
end

% length of y
n = length(y);

% The size of the output YI should be the same as XI
siz_yi = size(xi);


% Work with column vectors
y = y(:);
x = x(:);
xi = xi(:);

% Spacing between entries of x
h = diff(x);

% Check to see if X is sorted
if any(h<0)
    % Sort X
    [x,p] = sort(x);
    y = y(p,:);
    h = diff(x);
end

% Check for uniqueness of x
% Note inf-inf is nan
duplicateXidx = find(h == 0 | isnan(h));
if ~isempty(duplicateXidx)
    % Remove duplicate entries
    % Note: length(h) = length(x) - 1
    x(duplicateXidx) = [];
    y(duplicateXidx) = [];
    h(duplicateXidx) = [];
    % Adjust n for the change in size of y and x
    n = length(y);
end

% Initialize YI with NaN (extrapolation value is NaN)
yi = nan(siz_yi,superiorfloat(x,y,xi));

% Perform interpolation
if (n < 2)
    % Handle case when size of X and Y is 1
    yi(x==xi) = y;
else
    % Interpolate
    
    % Since yi is initialized with NaN only need to work with Xi that are
    % in the range of X
    inBoundsIdx = find(xi>=x(1) & xi<=x(n));
    xi = xi(inBoundsIdx);

    % Find indices of subintervals, x(k) <= u < x(k+1),
    % or u < x(1) or u >= x(m-1).
    [ignore,k] = histc(xi,x);
    k(k==n) = n-1;

    for ct = 1:length(xi)
        bin = k(ct);
        % Special handling is performed for non finite endpoints of X
        % Recall X is sorted and unique
        if (bin == 1) && (x(bin) == -inf)
            % Case: -inf <= xi < b needs to be handled
            % if xi = -inf then yi = y(bin)
            % if xi is finite then yi = y(bin+1)
            yi(inBoundsIdx(ct)) = y(bin+~isinf(xi(ct)), 1);
        elseif (bin == (n-1)) && (x(bin+1) == inf)
            % Case: a < xi <= inf needs to be handled
            % if xi = inf then yi = y(bin+1)
            % if xi is finite then yi = y(bin)
            yi(inBoundsIdx(ct)) = y(bin+isinf(xi(ct)),1);
        else
            % x(bin), x(bin+1), xi(ct) are all finite
            s = (xi(ct) - x(bin))/h(bin);
            if (s==0) || (s==1)
                % Xi lies on a point in X
                yi(inBoundsIdx(ct)) = y(bin+s,1);
            else
                % Xi lies between two points in X and interpolate
                yi(inBoundsIdx(ct)) = (1-s)*y(bin,1) + s*y(bin+1,1);
            end

        end
    end

end
        