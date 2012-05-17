function [varargout] = grpstats(x,group,whichstats,varargin)
%GRPSTATS Summary statistics by group.
%   GRPSTATS computes groupwise summary statistics, for data in a matrix or
%   dataset array.
%
%   MEANS = GRPSTATS(X,GROUP), when X is a matrix of observations, returns the
%   MEANS of each column of X by GROUP.  GROUP is a grouping variable defined
%   as a categorical variable, vector, string array, or cell array of strings.
%   GROUP can also be a cell array of several grouping variables (such as {G1
%   G2 G3}) to group the values in X by each unique combination of grouping
%   variable values.  GROUP can be [] or omitted to compute the mean of the
%   entire sample without grouping.  When there is a single grouping variable,
%   groups are sorted by order of appearance (if GROUP is character), sorted
%   numeric value (if GROUP is numeric), or order of the levels property (if
%   GROUP is categorical).
%
%   GRPSTATS(X,GROUP,ALPHA) displays a plot of the means versus index with
%   100(1 - ALPHA)%  confidence intervals around each mean.
%
%   DSSTATS = GRPSTATS(DS,GROUPVARS), when DS is a dataset array, returns a
%   dataset DSSTATS that contains the mean, computed by group, for variables
%   in DS.  GROUPVARS specifies the grouping variables in DS that define the
%   groups, and is a positive integer, a vector of positive integers, the name
%   of a dataset variable, a cell array containing one or more dataset
%   variable names, or a logical vector.  A grouping variable may be a vector
%   of categorical, logical, or numeric values, a character array of strings,
%   or a cell vector of strings. DSSTATS contains those grouping variables, plus
%   one variable giving the number of observations in DS for each group, as
%   well as one variable for each of the remaining dataset variables in DS.
%   These variables must be numeric or logical.  DSSTATS contains one
%   observation for each group of observations in DS.  GROUPVARS can be [] or
%   omitted to compute the mean of each variable across the entire dataset
%   without grouping.
%
%   GRPSTATS treats NaNs as missing values, and removes them.
%
%   [A,B,...] = GRPSTATS(X,GROUP,WHICHSTATS), for a numeric matrix X, or
%   DSSTATS = GRPSTATS(DS,GROUPVARS,WHICHSTATS), for a dataset array DS,
%   returns the statistics specified by WHICHSTATS, either as separate arrays
%   A, B, ..., or as a single dataset array DSSTATS.  WHICHSTATS can be a
%   single function handle or name, or a cell array containing multiple
%   function handles or names.  The number of outputs [A,B,...] must match the
%   number function handles and names in WHICHSTATS.  Names in WHICHSTATS can
%   be chosen from among the following:
%
%      'mean'     mean
%      'sem'      standard error of the mean
%      'numel'    count, or number of elements
%      'gname'    group name
%      'std'      standard deviation
%      'var'      variance
%      'min'      minimum
%      'max'      maximum
%      'range'    maximum - minimum
%      'meanci'   95% confidence interval for the mean
%      'predci'   95% prediction interval for a new observation
%
%   Each function included in WHICHSTATS must accept a subset of the rows
%   from a column of X or a variable in DS, and compute column-wise
%   descriptive statistics for it.  A function should typically return a
%   value that has one row but is otherwise the same size as its input
%   data.  For example, @median and @skewness are suitable functions to
%   apply to a numeric input.  A function must return the same size output
%   each time GRPSTATS calls it, even if the input for some groups is empty.
%
%   A summary statistic function may also return values with more than one
%   row, if the descriptive statistic is not a scalar (a confidence interval,
%   for example), provided the return values have the same number of rows each
%   time GRPSTATS applies the function to different subsets of the data.  For
%   an input that is NOBS-by-M-by-..., if a summary statistic function returns
%   values that are NVALS-by-M-by-..., then the corresponding output array or
%   dataset variable is NGROUPS-by-M-by-...-by-NVALS, where NGROUPS is the
%   number of groups.
%
%   For the case when data are contained in a numeric matrix X, a function
%   specified in WHICHSTATS may also be written to accept a matrix of data and
%   compute a descriptive statistic for each column.  The function should
%   return either a row vector, or an NVALS-by-NCOLS matrix if the descriptive
%   statistic is not a scalar.
%
%   [...] = GRPSTATS(...,WHICHSTATS,'Param1',VAL1,'Param2',VAL2,...) specifies
%   additional parameter name/value pairs chosen from the following:
%
%      'Alpha'      A value between 0 and 1 that specifies the confidence
%                   level as 100(1-ALPHA)% for the 'meanci' and 'predci'
%                   options.  Default is 0.05.
%      'DataVars'   The names of the variables in DS to which the functions
%                   in WHICHSTATS should be applied.  DSSTATS contains one
%                   summary statistic variable for each of these data
%                   variables.  DATAVARS is a positive integer, a vector of
%                   positive integers, a variable name, a cell array
%                   containing one or more variable names, or a logical vector.
%      'VarNames'   The names of the variables in DSSTATS.  By default,
%                   GRPSTATS uses the names from DS for the grouping variable
%                   names, and constructs names for the summary statistic
%                   variables based on the function name and the data variable
%                   names from DS.
%
%   DSSTATS contains NGROUPVARS + 1 + NDATAVARS*NFUNS variables, where
%   NGROUPVARS is the number of variables specified in GROUPVARS, NDATAVARS is
%   the number of variables specified in DATAVARS, and NFUNS is the number of
%   summary statistics specified in WHICHSTATS.
%
%   Examples:  
%      load carsmall
%      [m,p,g] = grpstats(Weight,Model_Year,{'mean','predci','gname'})
%      n = length(m)
%      errorbar((1:n)',m,p(:,2)-m)
%      set(gca,'xtick',1:n,'xticklabel',g)
%      title('95% prediction intervals for mean weight by year')
%
%      load hospital
%      meanWgts = grpstats(hospital,{'Sex' 'Smoker'},{'mean','sem'},'datavars','Weight')
%
%   See also GSCATTER, GRP2IDX.

%   Older syntaxes still supported:
%
%   [MEANS,SEM,COUNTS,GNAME] = GRPSTATS(X,GROUP) returns the standard error
%   of the mean in SEM, the number of elements in each group in COUNTS,
%   and the name of each group in GNAME.
%
%   [...] = GRPSTATS(X,GROUP,WHICHSTATS,ALPHA) specifies the confidence
%   level as 100(1-ALPHA)% for the 'meanci' and 'predci' options.  It does
%   not display a plot.

%   Copyright 1993-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:14:33 $

if (nargin<1)
   error('stats:grpstats:TooFewInputs',...
         'GRPSTATS requires at least one argument.')
elseif isa(x,'dataset')
    if nargin<2, group=[]; end
    if nargin<3, whichstats=[]; end
    [varargout{1:nargout}] = dsgrpstats(x,group,whichstats,varargin{:});
    return
end
if ndims(x)>2 || ~(isnumeric(x) || islogical(x))
    error('stats:grpstats:BadData',...
          'X must be a numeric or logical vector or matrix, or a dataset array.');
elseif isvector(x)
    x = x(:);
end
[rows,cols] = size(x);

doplot = false;

% Distinguish name/value pairs from grpstats(x,group,whichstats,alpha)
if nargin>3
    arg4 = varargin{1};
    if nargin==4 && (isnumeric(arg4) && isscalar(arg4))
        alpha = arg4;
    else
        pnames = {'alpha'};
        dflts =  {    .05};
        [eid,errmsg,alpha] ...
            = internal.stats.getargs(pnames, dflts, varargin{:});
        if ~isempty(eid)
            error(sprintf('stats:grpstats:%s',eid),errmsg);
        end
    end
    
% Recognize plotting syntax with alpha in 3rd position
elseif nargin==3
    if isnumeric(whichstats) && isscalar(whichstats)
        alpha = whichstats;
        whichstats = {};
        doplot = true;
    else
        alpha = 0.05;
    end
    
elseif nargin<=2
    alpha = 0.05;   % used in nested functions
    whichstats = {};
end

if alpha<=0 || alpha>=1
    error('stats:grpstats:BadAlpha',...
          'ALPHA must be a number larger than 0 and smaller than 1.');
end

% Get list of statistics functions to call
if isempty(whichstats)
    % Default list
    whichstats = {@(x) mean(x,1), @(x) std(x,0,1) / sqrt(size(x,1)), @(x) size(x,1), 'gname'};
    if doplot
        minargs = 3;
    else
        minargs = 1;
    end
    whichstats = whichstats(1:max(minargs,nargout));
else
    if ~iscell(whichstats)
        whichstats = {whichstats};
    end

    % Convert keywords to function handles
    for j=1:numel(whichstats)
        hfun = whichstats{j};
        if ischar(hfun)
            switch(hfun)
              case 'mean',  hfun = @(x) mean(x,1);
              case 'sem',   hfun = @(x) std(x,0,1) / sqrt(size(x,1));
              case 'std',   hfun = @(x) std(x,0,1);
              case 'var',   hfun = @(x) var(x,0,1);
              case 'min',   hfun = @(x) empty2NaN(min(x,[],1));
              case 'max',   hfun = @(x) empty2NaN(max(x,[],1));
              case 'range', hfun = @(x) empty2NaN(range(x,1));
              case 'numel', hfun = @(x) size(x,1);
              case 'meanci',hfun = @meanci;
              case 'predci',hfun = @predci;
              %otherwise, may be a function name or 'gname'
            end
        whichstats{j} = hfun;
        end
    end
    
    % Warn if they won't get some of what's listed in whichstats; they will get an
    % error if not enough is listed in whichstats
    if max(1,nargout) < numel(whichstats)
        warning('stats:grpstats:ArgumentMismatch',...
                ['GRPSTATS called with %d output arguments to compute %d\n', ...
                 'summary statistics.'],nargout,numel(whichstats));
    end
end

% Get grouping variable information
if (nargin<2) || isempty(group)
   group = ones(rows,1);
end
[group,glabel,groupname,multigroup,ngroups] = mgrp2idx(group,rows);
if length(group) ~= rows
    error('stats:grpstats:InputSizeMismatch',...
          'Must have one GROUP for each row of X.');
end

% Collect group information
groups = cell(1,ngroups);
for gnum = 1:ngroups
    groups{gnum} = find(group==gnum);
end

nfuns = numel(whichstats);
varargout = cell(1,max(1,nfuns));

for nfun = 1:nfuns
    hfun = whichstats{nfun};   % get function handle or name
    if isequal(hfun,'gname')
        % special case for gname, not applied separately to each column
        varargout{nfun} = groupname;
        continue
    end

    % Should we try to apply the function to an entire matrix or just a column?
    trymatrix = (cols~=1) && ~any(isnan(x(:)));

    % Test the function to see what we get
    if isempty(groups)
        rowidx = [];
    else
        rowidx = groups{1};
    end

    if trymatrix
        % Attempt to call the function on a data matrix
        try
            t = feval(hfun,x(rowidx,:));
            if size(t,2)~=cols
                trymatrix = false;
            end
        catch
            trymatrix = false;
        end
    end
    if trymatrix
        % Success, put results for this group into an array
        nstatvals = size(t,1);
        t1 = reshape(t',[1,cols,nstatvals]);   % 1st dim for groups
        z = repmat(t1,[ngroups,1,1]);          % one per group
        tsize = [nstatvals,cols];
    else    
        % Call the function on one column
        if size(x,2)>=1
            y = x(rowidx,1);
        else
            y = x(rowidx,[]);
        end
        if ngroups > 0
            t = tryeval(hfun,y(~isnan(y),:),glabel{1});
        else
            t = tryeval(hfun,y(~isnan(y),:));
        end
        nstatvals = size(t,1);
        t1 = reshape(t,[1,1,nstatvals]);       % dims 1-2 for group,col
        z = repmat(t1,[ngroups,cols,1]);       % one per group and col
        tsize = size(t);
        if ngroups>0 && cols>0
            for colnum = 2:cols
                % Now do the rest of the columns
                y = x(rowidx,colnum);
                z(1,colnum,:) = tryeval(hfun,y(~isnan(y),:),glabel{1},tsize);
            end
        end
    end

    % Now do the rest of the groups
    for gnum = 2:ngroups
        idx = groups{gnum};

        if trymatrix
            z(gnum,:,:) = tryeval(hfun,x(idx,:),glabel{gnum},tsize)';
        else
            for colnum = 1:cols
                y = x(idx,colnum);
                z(gnum,colnum,:) = tryeval(hfun,y(~isnan(y),:),glabel{gnum},tsize);
            end
        end
    end
    
    % Special case:  don't add 3rd dimension of there is just one column
    if cols==1
        z = reshape(z,ngroups,nstatvals);
    end
    varargout{nfun} = z;
end

if doplot
   means = varargout{1};
   sems = varargout{2};
   counts = varargout{3};
   p = 1 - alpha/2;
   xd = repmat((1:ngroups)',1,cols);
   h = errorbar(xd,means,tinv(p,counts-1) .* sems);
   set(h,'Marker','o','MarkerSize',2);
   set(gca,'Xlim',[0.5 ngroups+0.5],'Xtick',(1:ngroups));
   xlabel('Group');
   ylabel('Mean');
   if (multigroup)
      % Turn off tick labels and axis label
      set(gca, 'XTickLabel','','UserData',size(groupname,2));
      xlabel('');
      ylim = get(gca, 'YLim');
      
      % Place multi-line text approximately where tick labels belong
      for j=1:ngroups
         text(j,ylim(1),glabel{j,1},'HorizontalAlignment','center',...
              'VerticalAlignment','top', 'UserData','xtick');
      end

      % Resize function will position text more accurately
      set(gcf, 'ResizeFcn', @resizefcn, 'Interruptible','off');
      doresize(gcf);
   else
      set(gca, 'XTickLabel',glabel);
   end
   title('Means and Confidence Intervals for Each Group');
   set(gca, 'YGrid', 'on');
end

% Nested functions below here; they use alpha from caller
    function ci = meanci(y,m,s,n,d) % m,s,n,d are local variables
    n = size(y,1);
    m = mean(y,1);
    s = std(y,0,1) / sqrt(n);
    d = s * -tinv(alpha/2, max(0,n-1));
    ci = [m-d; m+d];
    end

    % ----------------------------
    function ci = predci(y,m,s,n,d) % m,s,n,d are local variables
    n = size(y,1);
    m = mean(y,1);
    s = std(y,0,1) * sqrt(1 + 1/n);
    d = s * -tinv(alpha/2, max(0,n-1));
    ci = [m-d; m+d];
    end

    % ----------------------------
    function m = empty2NaN(m) % convert 0xm empty to NaN(1,m)
    if size(m,1) == 0
        m = NaN(1,size(m,2));
    end
    end
end


% ----------------------------
function t = tryeval(f,y,glabel,tsize)
sizeerr = false;
me = '';           % MException so use outside try/catch
try
    t = feval(f,y);
    if nargin>=4
        if ~isequal(size(t),tsize)
            sizeerr = true;
        end
    else
        if ~(isvector(t) && isequal(size(t,2),1))
            sizeerr = true;
        end
    end
catch ME
    me = ME;
end
if sizeerr || ~isempty(me)
    if ischar(f)
        fname = f;
    else
        fname = func2str(f);
    end
    % When there are no data, we don't have a group name
    if nargin >= 3
        glabel(glabel==sprintf('\n')) = '_';
        gtext = sprintf(' for group ''%s''',glabel);
    else
        gtext = '';
    end
    if ~isempty(me)
        throw(addCause(MException('stats:grpstats:FunctionError', ...
                'Error evaluating the function ''%s''%s.',...
                fname,gtext),me));
    elseif nargin==4
        error('stats:grpstats:BadFunctionResult', ...
              ['Function ''%s'' returned a result of size [%s]%s, ', ...
               'expected size [%s].'],fname,num2str(size(t)),gtext,num2str(tsize));
    else
        error('stats:grpstats:BadFunctionResult', ...
              ['Function ''%s'' returned a result of size [%s]%s, ', ...
               'expected a scalar or column vector.'],fname,num2str(size(t)),gtext);
    end
end

end

% ----------------
function resizefcn(varargin)
% Resize callback
doresize(gcbf);
end

% -------------------------
function doresize(f)
% Adjust figure layout to make sure labels remain visible
h = findobj(f, 'UserData','xtick');
if (isempty(h))
   set(f, 'ResizeFcn', '');
   return;
end
ax = get(f, 'CurrentAxes');
nlines = get(ax, 'UserData');

% Position the axes so that the fake X tick labels have room to display
set(ax, 'Units', 'characters');
p = get(ax, 'Position');
ptop = p(2) + p(4);
if (p(4) < nlines+1.5)
   p(2) = ptop/2;
else
   p(2) = nlines + 1;
end
p(4) = ptop - p(2);
set(ax, 'Position', p);
set(ax, 'Units', 'normalized');

% Position the labels at the proper place
xl = get(gca, 'XLabel');
set(xl, 'Units', 'data');
p = get(xl, 'Position');
ylim = get(gca, 'YLim');
p2 = (p(2)+ylim(1))/2;
for j=1:length(h)
   p = get(h(j), 'Position') ;
   p(2) = p2;
   set(h(j), 'Position', p);
end
end
