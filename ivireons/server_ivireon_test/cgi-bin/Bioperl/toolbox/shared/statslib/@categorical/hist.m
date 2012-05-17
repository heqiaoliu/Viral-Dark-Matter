function [no,xo] = hist(ax,y,x)
%HIST  Histogram.
%   HIST(Y) with no output arguments produces a histogram bar plot of the
%   counts for each level of the categorical vector Y.  If Y is an M-by-N
%   categorical matrix, HIST computes counts for each column of Y, and plots
%   a group of N bars for each categorical level.
%
%   HIST(Y,X) plots bars only for the levels specified by X.  X is a
%   categorical vector or a cell array of strings.
%
%   HIST(AX,...) plots into AX instead of GCA.
%
%   N = HIST(...) returns the counts for each categorical level.  If Y is a
%   matrix, HIST works down the columns of Y and returns a matrix of counts
%   with one column for each coluimn of Y and one row for each cetegorical
%   level.
%
%   [N,X] = HIST(...) also returns the categorical levels to corresponding
%   each count in N, or corresponding to each column of N if Y is a matrix.
%
%   See also CATEGORICAL/LEVELCOUNTS, CATEGORICAL/GETLEVELS.

%   Copyright 2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2009/10/10 20:10:52 $

% Shift inputs if necessary.
if ishandle(ax) % hist(ax,y) or hist(ax,y,x)
    if nargin < 3
        x = [];
    end
elseif isa(ax,'categorical') % hist(y) or hist(y,x)
    if nargin > 1
        if nargin > 2
            error('stats:categorical:hist:TooManyInputs', ...
                  'Too many input arguments.');
        end
        x = y;
    else
        x = [];
    end
    y = ax;
    ax = [];
else
    error('stats:categorical:hist:InvalidInput', ...
          'Y must be a categorical array.');
end

% If N-D, force to a matrix to be consistent with hist function.
if ndims(y) > 2, y = y(:,:); end

labels = y.labels;

% Figure out what levels to use for the bars.
useAllLevels = isempty(x);
if useAllLevels
    x = getlevels(y);
else
    if isequal(class(x),class(y))
        [tf,loc] = ismember(cellstr(x),labels);
    elseif iscellstr(x)
        [tf,loc] = ismember(x,labels);
    else
        error('stats:categorical:hist:InvalidLevels', ...
              'X must be a cell array of strings, or the same class as Y.');
    end
    if ~all(tf)
        error('stats:categorical:hist:UnknownLevels', ...
              'X contains levels not present in Y.');
    end
    % Give x the same set of levels as y, but values from the input arg.
    x = getlevels(y); x.codes = x.codes(loc);
end

% Create double data for hist from the internal codes.
yd = double(y);
xd = double(x);
if ~useAllLevels
    % Convert the internal codes to consecutive ints, NaN for the unused levels
    convert = nan(length(labels),1); convert(xd) = 1:length(xd);
    yd = convert(yd);
    labels = labels(loc);
end

if nargout == 0
    if isempty(ax), ax = gca; end
    hist(ax,yd,1:length(xd));
    set(ax,'XTickLabel',labels);
    
    % Disable linking and brushing
    ph = get(ax,'Children');
    for i = 1:length(ph) % mutiple patches for grouped bars 
        set(hggetbehavior(ph(i),'linked'),'Enable',false);
        set(hggetbehavior(ph(i),'brush'),'Enable',false);
    end
else
    no = hist(yd,1:length(xd));
    if nargout > 1
        xo = x;
    end
end
