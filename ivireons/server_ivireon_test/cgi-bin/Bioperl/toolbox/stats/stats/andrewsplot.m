function h = andrewsplot(X,varargin)
%ANDREWSPLOT Andrews plot for multivariate data.
%   ANDREWSPLOT(X) creates an Andrews plot of the multivariate data in the
%   matrix X.  Rows of X correspond to observations, columns to variables.
%   An Andrews plot is a tool for visualizing high dimensional data, where
%   each observation is represented by a function, f(t), of a continuous
%   dummy variable, t, over the interval [0,1].  f(t) is defined for the
%   i-th observation in X as
%
%      f(t) = X(i,1)/sqrt(2) + X(i,2)*sin(2*pi*t) + X(i,3)*cos(2*pi*t) + ...
%
%   Use the data cursor to read precise values and observation numbers 
%   from the plot.
%
%   ANDREWSPLOT treats NaNs in X as missing values, and ignores the
%   corresponding rows. 
%
%   ANDREWSPLOT(X, ..., 'Standardize','on') scales each column of X to have
%   zero mean and unit standard deviation before making the plot.
%
%   ANDREWSPLOT(X, ..., 'Standardize','PCA') creates an Andrews plot from
%   the principal component scores of X, in order of decreasing eigenvalue.
%   ANDREWSPLOT(X, ..., 'Standardize','PCAStd') uses the standardized
%   principal component scores.
%
%   ANDREWSPLOT(X, ..., 'Quantile',ALPHA) plots only the median and the
%   ALPHA and (1-ALPHA) quantiles of f(t) at each value of t.  This is
%   useful if X contains many observations.
%
%   ANDREWSPLOT(X, ..., 'Group',GROUP) plots the data in different groups
%   with different colors.  GROUP is a grouping variable defined as a
%   categorical variable, numeric array, character matrix, or cell array of
%   strings.
%
%   ANDREWSPLOT(X, ..., 'PropertyName',PropertyValue, ...) sets properties
%   to the specified property values for all line graphics objects created
%   by ANDREWSPLOT.
%
%   H = ANDREWSPLOT(X, ...) returns a column vector of handles to the line
%   objects created by ANDREWSPLOT, one handle per row of X.  If you use
%   the 'Quantile' input parameter, H contains one handle for each of the
%   three lines objects created.  If you use both the 'Quantile' and the
%   'Group' input parameters, H contains three handles for each group.
%
%   Examples:
%
%      % make a grouped plot of the raw data
%      load fisheriris
%      andrewsplot(meas, 'group',species);
%
%      % plot only the median and quartiles of each group
%      andrewsplot(meas, 'group',species, 'quantile',.25);
%
%   See also PARALLELCOORDS, GLYPHPLOT.

%   References:
%     [1] Gnanadesikan, R. (1977) Methods for Statistical Dara Analysis
%         of Multivariate Observations, Wiley.

%   Copyright 1993-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2010/03/16 00:12:06 $

if nargin < 1
    error('stats:andrewsplot:TooFewInputs', ...
          'At least one input argument required.');
end
[n,p] = size(X);

% Process input parameter name/value pairs, assume unrecognized ones are
% graphics properties for PLOT
pnames = {'quantile' 'standardize' 'group'};
dflts =  {       []          'off'     []};
[errid,errmsg,quantile,stdize,group,plotArgs] = ...
                       internal.stats.getargs(pnames, dflts, varargin{:});
if ~isempty(errid)
    error(sprintf('stats:andrewsplot:%s',errid), errmsg);
end

if ~isempty(quantile)
    if ~isnumeric(quantile) || ~isscalar(quantile) || ~(0 < quantile && quantile < 1)
        error('stats:andrewsplot:InvalidQuantileParam', ...
              'The ''quantile'' parameter value must be a scalar between 0 and 1.');
    end
    quantile = min(quantile,1-quantile);
end

% Grouping vector was not given, or it is empty to match an empty X.  Fake
% a group index vector.
if isempty(group)
    gidx = ones(n,1);
    ngroups = 1;
    gnames = [];
% Get the group index for each observation
else
    [gidx,gnames] = grp2idx(group);
    ngroups = length(gnames);
    if length(gidx) ~= n
        error('stats:andrewsplot:InputSizeMismatch', ...
              'The ''group'' parameter value must have one row for each row of X.');
    end
end
obsinds = 1:n;
% Remove NaNs from data
nans = find(isnan(gidx) | any(isnan(X),2));
if ~isempty(nans)
    X(nans,:) = [];
    gidx(nans) = [];
    obsinds(nans) = [];
    n = size(X,1);
end

% Transform data if requested
if ischar(stdize)
    switch lower(stdize)
    case 'off'
        % leave X alone
        
    % Standardize each coordinate to unit variance
    case 'on'
        if n > 1
            X = (X - repmat(mean(X,1),n,1))./ repmat(std(X,[],1),n,1);
        elseif n == 1
            X = zeros(size(X)); % prevent divide by zero
        else
            % leave empty X alone
        end
        
    % Transform the data to PC scores
    case {'pca' 'pcastd'}
        if ~isempty(X)
            [dum,X,variance] = princomp(X); %#ok<ASGLU>
            if strcmpi(stdize,'pcastd')
                % Leave columns of X with zero variance alone.
                tol = max(n,p)*eps(max(variance));
                variance(variance<tol) = 1;
                X = X ./ repmat(sqrt(variance(:)'),n,1);
            end
        end
        
    otherwise
        error('stats:andrewsplot:InvalidStandardizeParam', ...
              'The ''standardize'' parameter must be ''off'', ''on'', ''pca'', or ''pcastd''.');
    end
else
    error('stats:andrewsplot:InvalidStandardizeParam', ...
          'The ''standardize'' parameter value be a string.');
end

% Compute the terms for the curves.  The constant term goes with the first
% column of X, the lowest freq sin with the 2nd, the lowest freq cos with
% the third, and so on.
t = 0:.001:1;
omega = 2*pi*(1:floor(p/2));
omegaSin = omega(1:floor(p/2));
omegaCos = omega(1:floor((p-1)/2));
A = [ones(1,length(t))./sqrt(2); sin(omegaSin' * t); cos(omegaCos' * t)];
F = X(:,[1 (2:2:p) (3:2:p)])*A;

cax = newplot;
dataCursorBehaviorObj = hgbehaviorfactory('DataCursor');
set(dataCursorBehaviorObj,'UpdateFcn',@andrewsplotDatatipCallback);
colors = get(cax,'ColorOrder');
ncolors = size(colors,1);

hh = zeros(ngroups,1);
lgndh = zeros(ngroups,1);
for grp = 1:ngroups
    color = colors(mod(grp-1,ncolors)+1,:);
    mbrs = find(gidx == grp);
    
    % Make an empty plot if no data.
    if isempty(mbrs)
        line(t,NaN(size(t)), 'LineStyle','-', 'Color',color, plotArgs{:});
        
    % Plot the individual observations, or the median and the upper and
    % lower ALPHA-quantiles of the data.  Any unused input args are passed
    % to plot as graphics properties.
    elseif isempty(quantile)
        % Plot rows of F against t.  If a group has p members, plot would
        % try to use columns of F, prevent that by always using F'.
        lineh = line(t,F(mbrs,:)', 'LineStyle','-', 'Color',color, plotArgs{:});
        
        % Attach metadata and datacursor behavior object to each line.
        hgaddbehavior(lineh,dataCursorBehaviorObj);
        for i=1:length(mbrs)
            setappdata(lineh(i),'Observation',obsinds(mbrs(i)))
            if ~isempty(gnames)
                setappdata(lineh(i),'Group',gnames(grp));
            end
        end
      
        % Save line handles ordered by observation, one per row of X
        set(lineh,'Tag','data');
        hh(mbrs) = lineh;
    else
        if length(mbrs) == 1
            per = [.5 .5 .5];
            q = repmat(F(mbrs,:),3,1); % no dim arg for prctile
        else
            per = [.50 quantile 1-quantile];
            q = prctile(F(mbrs,:), 100*per);
        end
        lineh = [line(t,q(1,:), 'LineStyle','-', 'Color',color, plotArgs{:}); ...
                 line(t,q(2:3,:), 'LineStyle',':', 'Color',color, plotArgs{:})];

        % Attach metadata and datacursor behavior object to each line.
        hgaddbehavior(lineh,dataCursorBehaviorObj);
        for i=1:3
            setappdata(lineh(i),'Quantile',per(i));
            if ~isempty(gnames)
                setappdata(lineh(i),'Group',gnames(grp));
            end
        end
        
        % Save line handles ordered by group, three for each group
        set(lineh(1),'Tag','median');
        set(lineh(2),'Tag','lower quantile');
        set(lineh(3),'Tag','upper quantile');
        hh((grp-1)*3 + (1:3)) = lineh;
    end
    
    % Save line handles for the legend if the data are grouped
    if ~isempty(group) && ~isempty(mbrs)
        lgndh(grp) = lineh(1);
    end
end

if nargout > 0
    h = hh(:);
end

% Label the axes
if ~ishold
    xlabel('t'); ylabel('f(t)');
end

% If the data are grouped, put up a legend
if ~isempty(group)
    t = find(lgndh>0);  % use find because length may not match
    legend(lgndh(t),gnames(t,:));
end

% -----------------------------
function datatipTxt = andrewsplotDatatipCallback(obj,evt)

target = get(evt,'Target');
pos = get(evt,'Position');

datatipTxt = {
    ['t: ',num2str(pos(1))],...
    ['f(t): ',num2str(pos(2))],...
    '',...
    };

observation = getappdata(target,'Observation');
if ~isempty(observation)
    datatipTxt{end+1} =  ['Observation: ',num2str(observation)];
end

quantile = getappdata(target,'Quantile');
if ~isempty(quantile)
    datatipTxt{end+1} = ['Quantile: ',num2str(quantile)];
end

group = getappdata(target,'Group');
if ~isempty(group)
    datatipTxt{end+1} = ['Group: ',char(group)];
end



