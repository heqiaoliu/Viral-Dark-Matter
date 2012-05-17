function [Nout,Cout] = ecdfhist(F,X,varargin)
%ECDFHIST Create histogram from ecdf output.
%   N = ECDFHIST(F,X) takes a vector F of empirical cdf values and a vector
%   X of evaluation points, and returns a vector N containing the heights of
%   histogram bars for 10 equally spaced bins.  The bar heights are computed
%   from the increases in the empirical cdf, and are normalized so the area
%   for each bar represents the probability for the corresponding interval.
%   If F is computed from a censored sample, the total probability may be less
%   than 1.  In contrast, HIST produces bars whose heights are bin counts and
%   whose areas do not represent probabilities.
%
%   N = ECDFHIST(F,X,M), where M is a scalar, uses M bins.
%
%   N = ECDFHIST(F,X,C), where C is a vector, uses bins with centers
%   specified by C.
%
%   [N,C] = ECDFHIST(...) also returns the position of the bin centers in C.
%
%   ECDFHIST(...) without output arguments produces a histogram bar plot of
%   the results.
%
%   Example:  Generate random failure times and random censoring times,
%   and compare the empirical pdf with the known true pdf:
%
%       y = exprnd(10,50,1);     % random failure times are exponential(10)
%       d = exprnd(20,50,1);     % drop-out times are exponential(20)
%       t = min(y,d);            % we observe the minimum of these times
%       censored = (y>d);        % we also observe whether the subject failed
%
%       % Calculate the empirical cdf and plot a histogram from it
%       [f,x] = ecdf(t,'censoring',censored);
%       ecdfhist(f,x);
%
%       % Superimpose a plot of the known true pdf
%       hold on;
%       xx = 0:.1:max(t); yy = exp(-xx/10)/10; plot(xx,yy,'g-');
%       hold off;
%
%   See also ECDF, HIST, HISTC.

%   Copyright 1993-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:13:27 $

error(nargchk(2,Inf,nargin,'struct'));

% Accept an axes as the first arg, and plot into it.
if nargin>0 && isscalar(F) && ishghandle(F)
    % Get the axes, and shift the remaining args down by one.
    cax = F;
    F = X;
    if nargin > 2
        X = varargin{1};
        varargin = varargin(2:end);
    end
    nargs = nargin - 1;
else
    cax = [];
    nargs = nargin;
end

if nargs<2
    error('stats:ecdfhist:TooFewInputs','Requires both F and X.');
end

% Inputs should look like they came from ecdf.
if ischar(F) || ischar(X)
    error('stats:ecdfhist:NotNumeric',...
          'Input arguments must be numeric.')
end
if numel(F)~=length(F) || numel(X)~=length(X)
    error('stats:ecdfhist:VectorRequired',...
          'Both F and X must be vectors produced by the ecdf function.');
elseif length(F)<2 || length(X)<2
    error('stats:ecdfhist:TooFewElements',...
          'Both F and X must have two or more elements.');
elseif any(diff(X)<0)
    error('stats:ecdfhist:NotSorted','X must be non-decreasing.');
end

% For convenience, accept F as a survivor function by converting to cdf
wassurv = (F(1)==1);
if wassurv
    F = 1-F;
end
diffF = diff(F);
if any(diff(F)<0)
    if wassurv
        error('stats:ecdfhist:NotSurvivor',...
              'The survivor function F must be non-increasing')
    else
        error('stats:ecdfhist:NotCdf','The cdf F must be non-decreasing')
    end
end

% Chop off extra 1st X value
X = X(2:end);

% Get bin edges, counts, etc.
[P,edges,C,useCenters,wng] = statgetbins(X,diffF,varargin{:});
nbins = length(edges)-1;

% Convert to bar heights
binwidth = diff(edges);
N = (P ./ binwidth);

% Plot if no outputs requested
if nargout == 0
    if isempty(cax), cax = gca; end
    if useCenters
        % Make sure the first and last bars extend to full width of the data.
        h = bar(cax,C,N,[edges(1) edges(end)],'hist');
    else
        % For edges, we'll use the histc version of bar.  But we'll trick
        % it into making nbins bars instead of nbins+1, because we don't
        % want that extra last one.  We won't tell it about the (nbins+1)st
        % edge, and won't tack on a zero for the (nbins+1)st count.  It
        % will make the last bar the same size as the penultimate one.
        h = bar(cax,edges(1:end-1), N, 'histc');
        % Now make that last bar have the correct upper edge.
        v = get(h,'Vertices');
        
        if numel(edges)==2 && size(v,1)==6
           % Repair defective vertices (the bar function was unable to
           % determine even the lower edge of a single histogram bar)
           v(1:3,1) = edges(1);
        end
        v(end-2:end,1) = edges(end);
        set(h,'Vertices',v);
        % Plus if there's markers, put up another at the last edge.
        binmarker = findobj(get(h,'parent'),'type','line');
        if ~isempty(binmarker)
            set(binmarker(1),'XData',edges,'Ydata',zeros(1,nbins+1));
        end
    end
    set(cax,'xtickmode','auto');
else
    Nout = N;
    if nargout>=2
        Cout = C;
        if ~isempty(wng)
            warning('stats:ecdfhist:InconsistentEdges',wng);
        end
    end
end
