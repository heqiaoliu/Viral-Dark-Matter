function [Fout,x,Flo,Fup,D] = ecdf(y,varargin)
%ECDF Empirical (Kaplan-Meier) cumulative distribution function.
%   [F,X] = ECDF(Y) calculates the Kaplan-Meier estimate of the
%   cumulative distribution function (cdf), also known as the empirical
%   cdf.  Y is a vector of data values.  F is a vector of values of the
%   empirical cdf evaluated at X.
%
%   [F,X,FLO,FUP] = ECDF(Y) also returns lower and upper confidence
%   bounds for the cdf.  These bounds are calculated using Greenwood's
%   formula, and are not simultaneous confidence bounds.
%
%   ECDF(...) without output arguments produces a plot of the empirical
%   cdf. Use the data cursor to read precise values from the plot.
%
%   ECDF(AX,...) plots into axes AX instead of GCA.
%
%   [...] = ECDF(Y,'PARAM1',VALUE1,'PARAM2',VALUE2,...) specifies
%   additional parameter name/value pairs chosen from the following:
%
%      Name          Value
%      'censoring'   A boolean vector of the same size as Y that is 1 for
%                    observations that are right-censored and 0 for
%                    observations that are observed exactly.  Default is
%                    all observations observed exactly.
%      'frequency'   A vector of the same size as Y containing non-negative
%                    integer counts.  The jth element of this vector
%                    gives the number of times the jth element of Y was
%                    observed.  Default is 1 observation per Y element.
%      'alpha'       A value between 0 and 1 for a confidence level of
%                    100*(1-alpha)%.  Default is alpha=0.05 for 95% confidence.
%      'function'    The type of function returned as the F output argument,
%                    chosen from 'cdf' (the default), 'survivor', or
%                    'cumulative hazard'.
%      'bounds'      Either 'on' to include bounds or 'off' (the default)
%                    to omit them.  Used only for plotting.
%
%
%   Example:  Generate random failure times and random censoring times,
%   and compare the empirical cdf with the known true cdf:
%
%       y = exprnd(10,50,1);     % random failure times are exponential(10)
%       d = exprnd(20,50,1);     % drop-out times are exponential(20)
%       t = min(y,d);            % we observe the minimum of these times
%       censored = (y>d);        % we also observe whether the subject failed
%
%       % Calculate and plot the empirical cdf and confidence bounds
%       [f,x,flo,fup] = ecdf(t,'censoring',censored);
%       stairs(x,f);
%       hold on;
%       stairs(x,flo,'r:'); stairs(x,fup,'r:');
%
%       % Superimpose a plot of the known true cdf
%       xx = 0:.1:max(t); yy = 1-exp(-xx/10); plot(xx,yy,'g-')
%       hold off;
%
%   See also CDFPLOT, ECDFHIST.

% References:
%   [1] Cox, D.R. and D. Oakes (1984) Analysis of Survival Data,
%       Chapman & Hall.
%   [2] Lawless, J.F. (2003) Statistical Models and Methods for
%       Lifetime Data, 2nd ed., Wiley.

% Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:13:26 $

if (nargin > 0) && isscalar(y) && ishghandle(y) && isequal(get(y,'type'),'axes')
    axarg = {y};
    if nargin>1
       y = varargin{1};
       varargin(1) = [];
    else
       y = [];  % error to be dealt with below
    end
else
    axarg = {};
end 

% Require a data vector
if ~isvector(y)
    error('stats:ecdf:VectorRequired','Input Y must be a vector.');
end
x = y(:);

okargs = {'censoring' 'frequency' 'alpha' 'function' 'bounds'};
defaults = {[]        []          0.05    'cdf'      'off'};
[eid,emsg,cens,freq,alpha,fn,bounds] = internal.stats.getargs(okargs, defaults, varargin{:});
if ~isempty(eid)
    error(sprintf('stats:ecdf:%s',eid),emsg);
end
if ~isequal(bounds,'on') && ~isequal(bounds,'off')
    error('stats:ecdf:BadBounds',...
          'The BOUNDS argument must be ''on'' or ''off''.');
end

% Check arguments
if isempty(cens)
    cens = zeros(size(x));
else
    cens = cens(:);
    if ~isequal(size(x),size(cens))
        error('stats:ecdf:InputSizeMismatch',...
              'Data and censoring vectors must have the same length.');
    end
    if islogical(cens)
        cens = double(cens);
    end
end
if isempty(freq)
    freq = ones(size(x));
else
    freq = freq(:);
    if ~isequal(size(x),size(freq))
        error('stats:ecdf:InputSizeMismatch',...
              'Data and frequency vectors must have the same length.');
    end
    if islogical(freq)
        freq = double(freq);
    end
end
if numel(alpha)~=1 || ~isnumeric(alpha) || alpha<=0 || alpha>=1
    error('stats:ecdf:BadAlpha',...
          'Value of ''alpha'' parameter must be a scalar between 0 and 1.')
end

% Remove NaNs, so they will be treated as missing
[ignore1,ignore2,x,cens,freq] = statremovenan(x,cens,freq); %#ok<ASGLU>

% Check for valid function names.  Go out of the way to accept three
% possible ways to name the cumulative hazard function.
okvals = {'cdf' 'survivor' 'chf' 'cumulative hazard' 'cumhazard'};
j = strmatch(lower(fn),okvals);
if isempty(j)
    error('stats:ecdf:BadFunction','Invalid value of ''function'' parameter.');
elseif length(j)>1
    if all(ismember(j,4:5)) % 'cumulative hazard' and 'cumhazard'
        j = 3; % 'chf'
    else
        error('stats:ecdf:BadFunction',...
              'Ambiguous value of ''function'' parameter.');
    end
elseif j > 3 % 'cumulative hazard' or 'cumhazard' -> 'chf'
    j = 3;
end
fn = okvals{j};
cdf_sf = (j < 3);

% Remove missing observations indicated by NaN's.
t = ~isnan(x) & ~isnan(freq) & ~isnan(cens) & freq>0;
x = x(t);
n = length(x);
if n == 0
    error('stats:ecdf:NotEnoughData',...
          'Input sample has no valid data (all missing values).');
end
cens = cens(t);
freq = freq(t);

% Sort observation data in ascending order.
[x,t] = sort(x);
cens = cens(t);
freq = freq(t);
if isa(x,'single')
   freq = single(freq);
end

% Compute cumulative sum of frequencies
totcumfreq = cumsum(freq);
obscumfreq = cumsum(freq .* ~cens);
t = (diff(x) == 0);
if any(t)
    x(t) = [];
    totcumfreq(t) = [];
    obscumfreq(t) = [];
end
totalcount = totcumfreq(end);

% Get number of deaths and number at risk at each unique X
D = [obscumfreq(1); diff(obscumfreq)];
N = totalcount - [0; totcumfreq(1:end-1)];

% No change in function except at a death, so remove other points
t = (D>0);
x = x(t);
D = D(t);
N = N(t);

if cdf_sf % 'cdf' or 'survivor'
    % Use the product-limit (Kaplan-Meier) estimate of the survivor
    % function, transform to the CDF.
    S = cumprod(1 - D./N);
    if strcmp(fn, 'cdf')
        Func = 1 - S;
        F0 = 0;       % starting value of this function (at x=-Inf)
        funcdisplayname = 'F(x)';
    else % 'survivor'
        Func = S;
        F0 = 1;
        funcdisplayname = 'S(x)';
    end
else % 'cumhazard'
    % Use the Nelson-Aalen estimate of the cumulative hazard function.
    Func = cumsum(D./N);
    F0 = 0;
    funcdisplayname = 'H(x)';
end

% Include a starting value; required for accurate staircase plot
x = [min(y); x];
F = [F0; Func];

if nargout>2 || (nargout==0 && isequal(bounds,'on'))
    % Get standard error of requested function
    if cdf_sf % 'cdf' or 'survivor'
        se = NaN(size(D));
        if N(end)==D(end)
            t = 1:length(N)-1;
        else
            t = 1:length(N);
        end
        se(t) = S(t) .* sqrt(cumsum(D(t) ./ (N(t) .* (N(t)-D(t)))));
    else % 'cumhazard'
        se = sqrt(cumsum(D ./ (N .* N)));
    end

    % Get confidence limits
    zalpha = -norminv(alpha/2);
    halfwidth = zalpha*se;
    Flo = max(0, Func-halfwidth);
    Flo(isnan(halfwidth)) = NaN; % max drops NaNs, put them back
    if cdf_sf % 'cdf' or 'survivor'
        Fup = min(1, Func+halfwidth);
        Fup(isnan(halfwidth)) = NaN; % max drops NaNs
    else % 'cumhazard'
        Fup = Func+halfwidth; % no restriction on upper limit
    end
    Flo = [NaN; Flo];
    Fup = [NaN; Fup];
else 
    Flo = [];
    Fup = [];
end

% Plot if no return values are requested
if nargout==0
    h = stairs(axarg{:},x,[F Flo Fup]);
    xlabel('x');
    ylabel(funcdisplayname);
    %Set custom data cursor text for data line.
    hB = hggetbehavior(h(1),'datacursor');
    set(hB,'UpdateFcn',@ecdfDatatipCallback);
    setappdata(h(1),'funcdisplayname',funcdisplayname);
    setappdata(h(1),'D',[0; D]);
    
    if ~isempty(Flo) && ~isempty(Fup)
        % Set confidence bounds color and linestyle.
        set(h(2:3), 'Color',get(h(1),'Color'), 'LineStyle',':');
        % Store confidence bounds data with the data line, for use in
        % data cursor tip.
        setappdata(h(1),'confbounds',[Flo Fup]);
        setappdata(h(1),'alpha',alpha);
        % Set data cursor for confidence bounds lines.
        setappdata(h(2),'hprimary',h(1))
        setappdata(h(3),'hprimary',h(1))
        hB = hggetbehavior(h(2),'datacursor');
        set(hB,'UpdateFcn',@ecdfDatatipCallback);
        hB = hggetbehavior(h(3),'datacursor');
        set(hB,'UpdateFcn',@ecdfDatatipCallback);
    end
else
    Fout = F;
end

% -----------------------------
function datatipTxt = ecdfDatatipCallback(obj,evt) %#ok<INUSL>

target = get(evt,'Target');
ind = get(evt,'DataIndex');

% If a confidence bound clicked, redirect to main line.
if isappdata(target,'hprimary');
    target = getappdata(target,'hprimary');
end

funcdisplayname = getappdata(target,'funcdisplayname');
D = getappdata(target,'D');
xdat = get(target,'XData');
ydat = get(target,'YData');
x = xdat(ind);
y = ydat(ind);
d = D(ind);
datatipTxt = {
    ['x: ',num2str(x)]...
    [funcdisplayname ': ' num2str(y)]...
    ''...
    ['Num Observations at x: ',num2str(d)]...
    };

if isappdata(target,'confbounds')
    confbounds = getappdata(target,'confbounds');
    alpha = getappdata(target,'alpha');
    bounds =  confbounds(ind,:);
    
    datatipTxt{end+1} = ...
        [num2str(100*(1-alpha)) '% Confidence Bounds: [' ...
        num2str(bounds(1)) ','  num2str(bounds(2)) ']' ];
end




