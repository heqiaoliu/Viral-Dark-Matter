function h = parallelcoords(X,varargin)
%PARALLELCOORDS Parallel coordinates plot for multivariate data.
%   PARALLELCOORDS(X) creates a parallel coordinates plot of the
%   multivariate data in the N-by-P matrix X.  Rows of X correspond to
%   observations, columns to variables.  A parallel coordinates plot is a
%   tool for visualizing high dimensional data, where each observation is
%   represented by the sequence of its coordinate values plotted against
%   their coordinate indices.  PARALLELCOORDS treats NaNs in X as missing
%   values, and those coordinate values are not plotted.
%
%   PARALLELCOORDS(X, ..., 'Standardize','on') scales each column of X to
%   have zero mean and unit standard deviation before making the plot.
%
%   PARALLELCOORDS(X, ..., 'Standardize','PCA') creates a parallel
%   coordinates plot from the principal component scores of X, in order of
%   decreasing eigenvalue.  PARALLELCOORDS(X, ..., 'Standardize','PCAStd')
%   uses the standardized principal component scores.  PARALLELCOORDS
%   removes rows of X containing missing values (NaNs) for PCA
%   standardization.
%
%   PARALLELCOORDS(X, ..., 'Quantile',ALPHA) plots only the median and the
%   ALPHA and (1-ALPHA) quantiles of f(t) at each value of t.  This is
%   useful if X contains many observations.
%
%   PARALLELCOORDS(X, ..., 'Group',GROUP) plots the data in different
%   groups with different colors.  GROUP is a grouping variable defined as
%   a categorical variable, numeric array, character matrix, or cell array
%   of strings.
%
%   PARALLELCOORDS(X, ..., 'Labels',LABS) labels the coordinate tick marks
%   along the horizontal axis using LABS, a character array or cell array
%   of strings.
%
%   PARALLELCOORDS(X, ..., 'PropertyName',PropertyValue, ...) sets
%   properties to the specified property values for all line graphics
%   objects created by PARALLELCOORDS.
%
%   H = PARALLELCOORDS(X, ...) returns a column vector of handles to the
%   line objects created by PARALLELCOORDS, one handle per row of X.  If
%   you use the 'Quantile' input parameter, H contains one handle for each
%   of the three lines objects created.  If you use both the 'Quantile' and
%   the 'Group' input parameters,  H contains three handles for each group.
%
%   PARALLELCOORDS(AX,...) plots into the axes with handle AX.
%
%   Use the data cursor to read precise values and observation numbers 
%   from the plot.  The original values of X are displayed, regardless of
%   whether standardized values are plotted.
%
%
%   Examples:
%
%      % make a grouped plot of the raw data
%      load fisheriris
%      labs = {'Sepal Length','Sepal Width','Petal Length','Petal Width'};
%      parallelcoords(meas, 'group',species, 'labels',labs);
%
%      % plot only the median and quartiles of each group
%      parallelcoords(meas, 'group',species, 'labels',labs, 'quantile',.25);
%
%   See also ANDREWSPLOT, GLYPHPLOT.

%   References:
%     [1] Gnanadesikan, R. (1977) Methods for Statistical Dara Analysis
%         of Multivariate Observations, Wiley.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2010/03/16 00:16:36 $


if isscalar(X) && ishghandle(X)
    ax = X;
    X = varargin{1};
    varargin(1) = [];
else
    ax = [];
end

if nargin < 1+length(ax)
    error('stats:parallelcoords:TooFewInputs', ...
          'At least one input argument required.');
end
[n,p] = size(X);

% Process input parameter name/value pairs, assume unrecognized ones are
% graphics properties for PLOT.
pnames = {'quantile' 'standardize' 'group' 'labels'};
dflts =  {       []          'off'     []       [] };
[errid,errmsg,quantile,stdize,group,tcklabs,plotArgs] = ...
                             internal.stats.getargs(pnames, dflts, varargin{:});
if ~isempty(errid)
    error(sprintf('stats:parallelcoords:%s',errid), errmsg);
end

if ~isempty(quantile)
    if ~isnumeric(quantile) || ~isscalar(quantile) || ~(0 < quantile && quantile < 1)
        error('stats:parallelcoords:InvalidQuantileParam', ...
              'The ''quantile'' parameter value must be a scalar between 0 and 1.');
    end
    quantile = min(quantile,1-quantile);
end

% Grouping vector was not given, or it is empty to match an empty X.  Fake
% a group index vector.
if isempty(group)
    gidx = ones(n,1);
    ngroups = 1;
    gnames = {};
% Get the group index for each observation.
else
    [gidx,gnames] = grp2idx(group);
    ngroups = length(gnames);
    if length(gidx) ~= n
        error('stats:parallelcoords:InputSizeMismatch', ...
              'The ''group'' parameter value must have one row for each row of X.');
    end
end

dfltTckLabs = isempty(tcklabs);
if dfltTckLabs
    tcklabs = 1:p;
elseif ischar(tcklabs) && size(tcklabs,1) == p
    % Ok.
elseif iscellstr(tcklabs) && length(tcklabs) == p
    % Ok.
else
    error('stats:parallelcoords:InvalidLabelParam', ...
          ['The ''labels'' parameter value must be a character array or a cell array' ...
           '\nof strings with one label for each column of X.']);
end


origrows = 1:n;
if isempty(quantile)
    % Cache a copy of original X for datatip use, but only if individual
    % observations will be plotted.
    origX = X;
    origQuantiles = [];
else
    % Compute quantiles for each group.
    origX = [];

    origQuantiles = cell(ngroups,1);
    for grp = 1:ngroups
        mbrs = find(gidx == grp);
        if length(mbrs) == 1
            q = repmat(X(mbrs,:),3,1); % No dim arg for prctile.
        else
            q = prctile(X(mbrs,:), 100*[.50 quantile 1-quantile]);
        end
        origQuantiles{grp} = q;
    end
end

% Transform data if requested.
pca = false;
rescaled = true;
if ischar(stdize)
    switch lower(stdize)
    case 'off'
        % Leave X alone.
        rescaled = false;
    % Standardize each coordinate to unit variance.
    case 'on'
        if n > 1
            X = (X - repmat(nanmean(X),n,1))./ repmat(nanstd(X),n,1);
        elseif n == 1
            X(~isnan(X)) = 0; % Prevent divide by zero, preserve NaNs.
        else
            % Leave empty X alone.
        end

    % Transform the data to PC scores.
    case {'pca' 'pcastd'}
        % Remove NaNs from the data before PCA.
        nans = find(isnan(gidx) | any(isnan(X),2));
        if ~isempty(nans) 
            X(nans,:) = [];
            gidx(nans) = [];
            origrows(nans) = [];
            n = size(X,1);
        end
        if ~isempty(X)
            [dum,X,variance] = princomp(X); %#ok<ASGLU>
            if strcmpi(stdize,'pcastd')
                % Leave columns of X with zero variance alone.
                tol = max(n,p)*eps(max(variance));
                variance(variance<tol) = 1;
                X = X ./ repmat(sqrt(variance(:)'),n,1);
            end
        end
        pca = true;

    otherwise
        error('stats:parallelcoords:InvalidStandardizeParam', ...
              'The ''standardize'' parameter must be ''off'', ''on'', ''pca'', or ''pcastd''.');
    end
else
    error('stats:parallelcoords:InvalidStandardizeParam', ...
          'The ''standardize'' parameter value be a string.');
end

icoord = 1:p;

cax = newplot(ax);
colors = get(cax,'ColorOrder');
ncolors = size(colors,1);
dataCursorBehaviorObj = hgbehaviorfactory('DataCursor');
set(dataCursorBehaviorObj,'UpdateFcn',...
    {@parallelcoordsDatatipCallback,origrows,origX,gnames,tcklabs,...
    origQuantiles,rescaled});

if isempty(quantile)
    hh=zeros(n,1);
else
    hh=zeros(3*ngroups,1);
end
lgndh=zeros(ngroups,1);
for grp = 1:ngroups
    color = colors(mod(grp-1,ncolors)+1,:);
    mbrs = find(gidx == grp);

    % Make an empty plot if no data.
    if isempty(mbrs)
        line(icoord,NaN(size(icoord)), 'LineStyle','-', 'Color',color, plotArgs{:});

    % Plot the individual observations, or the median and the upper and
    % lower ALPHA-quantiles of the data.  Any unused input args are passed
    % to plot as graphics properties.
    elseif isempty(quantile)
        % Plot rows of X against icoord.  If a group has p members, plot 
        % would try to use columns of X, prevent that by always using X'.
        lineh = line(icoord,X(mbrs,:)', 'LineStyle','-', 'Color',color, plotArgs{:});
        % Store info for datatip.
        for i=1:length(lineh)
            hgaddbehavior(lineh(i),dataCursorBehaviorObj);
            setappdata(lineh(i),'grp',grp)
            setappdata(lineh(i),'gind',mbrs(i));
        end
        % Save line handles ordered by observation, one per row of X.
        set(lineh,'Tag','coords');
        hh(mbrs) = lineh;
    else
        if length(mbrs) == 1
            per = [.5 .5 .5];
            q = repmat(X(mbrs,:),3,1); % No dim arg for prctile.
        else
            per = [.50 quantile 1-quantile];
            q = prctile(X(mbrs,:), 100*per);
        end
        lineh = [line(icoord,q(1,:), 'LineStyle','-', 'Color',color, plotArgs{:}); ...
                 line(icoord,q(2:3,:), 'LineStyle',':', 'Color',color, plotArgs{:})];

        % Store info for datatip.
        for j=1:3
            setappdata(lineh(j),'grp',grp)
            % quantile and quantilenum refer to data in both origQuantiles and
            % q.
            setappdata(lineh(j),'quantile',per(j));
            setappdata(lineh(j),'quantilenum',j);
            hgaddbehavior(lineh(j),dataCursorBehaviorObj);
        end
        
        % Save line handles, three for each group.
        set(lineh(1),'Tag','median');
        set(lineh(2),'Tag','lower quantile');
        set(lineh(3),'Tag','upper quantile');
        hh((grp-1)*3 + (1:3)) = lineh;
    end

    % Save line handles for the legend if the data are grouped.
    if ~isempty(group) && ~isempty(mbrs)
        lgndh(grp) = lineh(1);
    end
end

if nargout > 0
    h = hh;
end

% Label the axes
if ~ishold
    if pca
        if dfltTckLabs, xlabel('Principal Component'); end
        ylabel('PC Score');
    else
        if dfltTckLabs, xlabel('Coordinate'); end
        ylabel('Coordinate Value');
    end
    set(cax, 'XTick',icoord, 'XTickLabel',tcklabs);
end

% If the data are grouped, put up a legend
if ~isempty(group)
    t = find(lgndh>0);   % use find because length may not match
    legend(lgndh(t),gnames(t,:));
end

% -----------------------------
function datatipTxt = parallelcoordsDatatipCallback(obj,evt,...
    origrows,origX,gnames,tcklabs,origQuantiles,rescaled)

% If individual observations are plotted, quantile will be empty
% If quantiles are plotted, gind and origX will be empty, and origrows will
% not be useful.
% If no groups are specified, gnames will be empty.
% Regardless, tcklabs and grp will be valid.

target = get(evt,'Target');
% pos = get(evt,'Position');
ind = get(evt,'DataIndex');

grp = getappdata(target,'grp');
gind = getappdata(target,'gind'); 
quantile = getappdata(target,'quantile'); 
quantilenum = getappdata(target,'quantilenum');

% Convert variable labels to cellstr.
if isnumeric(tcklabs) % Numeric vector, default.
    varnames = cell(length(tcklabs),1);
    for i=1:length(tcklabs)
        varnames{i} = ['Variable ' num2str(tcklabs(i))];
    end
elseif ischar(tcklabs) % Char array.
    varnames = cellstr(tcklabs);
else % Cellstr.
    varnames = tcklabs;
end

if ~isempty(gnames)
    gname = gnames{grp};
else
    gname = [];
end
 
if isempty(quantile)
    % Generate text for individual observation.
    datatipTxt = {
        [varnames{ind} ': ' num2str(origX(gind,ind))]...
        ''...
        ['Observation: ' num2str(gind)]...
        };
    if ~isempty(gname)
        datatipTxt{end+1} = ['Group: ' gname];
    end
    datatipTxt{end+1} = '';
    datatip_var_txt = cell(length(varnames),1);
    for i=1:length(varnames)
        datatip_var_txt{i} = [varnames{i} ': ' num2str(origX(gind,i))];
    end
    datatipTxt = {datatipTxt{:} datatip_var_txt{:}};
    
else
    % Generate text for quantile.
    datatipTxt = {
        [varnames{ind} ': ' num2str(origQuantiles{grp}(quantilenum,ind))]...
        ''...
        ['Quantile: ' num2str(quantile)]...
        };
    if ~isempty(gname)
        datatipTxt{end+1} = ['Group: ' gname];
    end
    datatipTxt{end+1} = '';
    datatip_var_txt = cell(length(varnames),1);
    for i=1:length(varnames)
        datatip_var_txt{i} = ...
            [varnames{i} ': ' num2str(origQuantiles{grp}(quantilenum,i))];
    end
    datatipTxt = {datatipTxt{:} datatip_var_txt{:}};

end

if rescaled
    datatipTxt{end+1} = '';
    datatipTxt{end+1} = '(Untransformed Values)';
end




