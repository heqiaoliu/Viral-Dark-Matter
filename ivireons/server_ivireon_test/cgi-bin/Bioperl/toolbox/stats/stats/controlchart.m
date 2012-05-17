function [outstats,plotdata] = controlchart(X,varargin)
%CONTROLCHART Shewhart control chart.
%   CONTROLCHART(X) produces an xbar chart of the data in X.  If X is a
%   matrix, its rows should be in time order and should contain replicate
%   observations taken at the same time.  If X is a timeseries object,
%   the sample at each time should contain replicate observations.  The
%   plot displays the means of each subgroup, or collection of replicate
%   observations, along with a center line (CL) and lower and upper control
%   limits (LCL and UCL) to determine if the process is in control.  The
%   control limits are three-sigma limits, with sigma estimated from the
%   average of the subgroup standard deviations.
%
%   CONTROLCHART(X,G) accepts a vector X of measurements, and a grouping
%   variable G that is a categorical variable, vector, string array, or
%   cell array of strings.  Consecutive values of X sharing the same value
%   of G are defined to be a subgroup.  The xbar chart plots the subgroup
%   means.  Subgroups can have different numbers of observations.  (G is
%   also accepted if X is a matrix, but it is used only to label the axis,
%   not to change the grouping.)
%
%   In the plot, points out of control are drawn with a red circle.  Data
%   cursor mode is enabled, so clicking on any data point displays
%   information about that point.
%
%   [STATS,PLOTDATA]=CONTROLCHART(...) returns a structure STATS of
%   subgroup statistics and parameter estimates, and a structure PLOTDATA
%   of plotted values.  PLOTDATA is a structure array, with one element for
%   each chart.  The fields in STATS and PLOTDATA depend on the chart type.
%
%   CONTROLCHART(..., 'PARAM1',val1,'PARAM2',val2,...) specifies one or
%   more of the following parameter name/value pairs:
%
%      'charttype'  The name of a chart type chosen from among the
%                   following:
%              'xbar'  X-bar or mean
%              's'     Standard deviation
%              'r'     Range
%              'ewma'  Exponentially weighted moving average
%              'i'     Individual observation
%              'mr'    Moving range of individual observations
%              'ma'    Moving average of individual observations
%              'p'     Proportion defective
%              'np'    Number of defectives
%              'u'     Defects per unit
%              'c'     Count of defects
%                   Alternatively this parameter can be a cell array listing
%                   multiple compatible chart types.  There are four sets
%                   of compatible types:  XBAR, S, R, and EWMA;
%                   I, MR, and MA; P and NP; U and C.
%      'display'    Either 'on' (default) to display the control chart, or
%                   'off' to omit the display.
%      'label'      A string array or cell array of strings, one per
%                   subgroup.  This label is displayed as part of the
%                   data cursor for a point on the plot.
%      'lambda'     A parameter between 0 and 1 controlling how much the
%                   current prediction is influenced by past observations in
%                   an EWMA plot.  Higher values of LAMBDA give less weight
%                   to past observations and more weight to the current
%                   observation.  The default is 0.4.
%      'limits'     A three-element vector specifying the values of the
%                   lower control limit, center line, and upper control
%                   limits.  Default is to estimate the center line and to
%                   compute control limits based on the estimated value of
%                   sigma.  Not permitted if there are multiple chart types.
%      'mean'       Value for the process mean, or an empty value (default)
%                   to estimate the mean from X.  This is the P parameter
%                   for P and NP charts, the mean defects per unit for U and
%                   C charts, and the normal MU parameter for other charts.
%      'nsigma'     The number of sigma multiples from the center line
%                   to a control limit.  Default is 3.
%      'parent'     The handle of the axes to receive the control chart
%                   plot.  Default is to create axes in a new figure.
%                   Not permitted if there are multiple chart types.
%      'rules'      The name of a control rule, or a cell array containing
%                   multiple control rule names.  These rules, together
%                   with the control limits, determine if a point is marked
%                   as out of control.  The default is not to apply any
%                   control rules, and to use only the control limits to
%                   decide if a point is out of control.  See "help
%                   controlrules" for more information.  Control rules are
%                   applied to charts that measure the process level
%                   ('xbar','i','c', 'u','p', and 'np') rather than the
%                   variability ('r','s'), and they are not applied to
%                   charts based on moving statistics ('ma','mr','ewma').
%      'sigma'      Either a value for sigma, or a method of estimating
%                   sigma chosen from among 'std' (the default) to use the
%                   average within-subgroup standard deviation, 'range' to
%                   use the average subgroup range, and 'variance' to use
%                   the square root of the pooled variance.  When creating
%                   I, MR, or MA charts for data not in subgroups, the
%                   estimate is always based on a moving range.
%      'specs'      A vector specifying specification limits.  Typically
%                   this is a two-element vector of lower and upper
%                   specification limits.  Since specification limits
%                   typically apply to individual measurements, this
%                   parameter is primarily suitable for 'i' charts.  These
%                   limits are not plotted on 'r', 's', or 'mr' charts.
%      'unit'       The total number of inspected items for P and NP charts,
%                   and the size of the inspected unit for U and C charts.
%                   In both cases X must be the count of the number of defects
%                   or defectives found.  Default is 1 for U and C charts.
%                   This argument is required (no default) for P and NP charts.
%      'width'      The width of the window used for computing the moving
%                   ranges and averages in MR and MA charts, and for computing
%                   the sigma estimate in I, MR, and MA charts.  Default is 5.
%
%   Example:  Create X-bar and R control charts for the PARTS data.
%       load parts
%       st = controlchart(runout,'chart',{'xbar' 'r'});
%       fprintf('Parameter estimates:  mu=%g, sigma=%g\n',st.mu,st.sigma);
%
%   See also CONTROLRULES.

%   The fields in STATS are selected from the following:
%       mean   subgroup means
%       std    subgroup standard deviations
%       range  subgroup ranges
%       n      subgroup size, or total inspection size or area
%       i      individual data values
%       ma     moving averages
%       mr     moving ranges
%       count  count of defects or defective items
%       mu     estimated process mean
%       sigma  estimated process standard deviation
%       p      estimated proportion defective
%       m      estimated mean defects per unit
%
%   The fields in PLOTDATA are the following:
%       pts    plotted point values
%       cl     center line
%       lcl    lower control limit
%       ucl    upper control limit
%       se     standard error of plotted point
%       n      subgroup size
%       ooc    logical that is true for points that are out of control

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/05/10 17:58:42 $

error(nargchk(1,inf,nargin,'struct'));

% For convenience allow true/false X as might be used with P/NP charts
if islogical(X)
    X = double(X);
end

% For time series data, get raw data and times
[X,ts,samples] = statts2data(X);

if isempty(X)
    error('stats:controlchart:BadX','X must not be empty.');
end

% Get grouping information
if nargin>=2 && ~(ischar(varargin{1}) && size(varargin{1},1)==1)
    G = varargin{1};
    varargin(1) = [];
else
    G = [];
end
origG = G;
if isvector(X)
    X = X(:);
end
if isnumeric(X) && isvector(X) && ~isempty(G)
    % Convert to grouping variable, but groups must be consecutive rows
    [Gnums,Gnames] = mgrp2idx(G,size(X,1),'\n');
    G = [true; diff(Gnums)~=0];
    Gnames = Gnames(Gnums(G));
    G = cumsum(G);
    ngroups = G(end);
elseif isnumeric(X) && ndims(X)==2
    % For a matrix or a vector with no group specified,
    % the row number is the grouping variable
    ngroups = size(X,1);
    Gnames = [];
    if ~isempty(G)
        if ischar(G)
            G = cellstr(G);
        end
        Gnames = G(:);
    end
else
    error('stats:controlchart:BadData','X must be a vector or matrix.');
end
if ~isempty(G) && (numel(G) ~= size(X,1))
     error('stats:controlchart:InputSizeMismatch',...
           'G must have one group value for each row of X.')
end

if isempty(G) && ~isempty(ts)
    G = samples;
elseif isnumeric(origG) && ~isempty(origG)
    t = (1:ngroups)';
    if isequal(Gnames,t) || ...
          isequal(Gnames, cellstr(strjust(num2str(t), 'left')))
        Gnames = []; % revert to default tick marks in this case
    end
end
grouped = (ngroups < numel(X));

% Read optional arguments
okargs =   {'charttype'  'label' 'lambda' 'limits' 'parent' 'rules' 'mean' ...
            'nsigma'     'sigma' 'specs'  'unit'   'width'  'display'};
defaults = {'xbar'       ''      0.4      []       []       []      [] ...
            3            'std'   []       []       5        'on'};
[eid emsg charttype  label lambda limits parent rules meanval ...
          nsigma     sigma specs  unit   width  dodisp] = ...
             internal.stats.getargs(okargs,defaults,varargin{:});
if ~isempty(eid)
   error(sprintf('stats:controlchart:%s',eid),emsg);
end

% Get information about which control charts to create, including the
% distribution used with this chart
[cctypes,distn] = getctypeinfo(charttype, grouped);

if ~isnumeric(sigma)
    sigma = statgetkeyword(sigma, {'range' 'std' 'variance'},false,...
                           'SIGMA','stats:controlchart:BadSigma');
end

if ~(isscalar(dodisp) && islogical(dodisp))
    dodisp = statgetkeyword(dodisp, {'on' 'off'}, false, 'DISPLAY',...
                            'stats:controlchart:BadDisplay');
    dodisp = isequal(dodisp,'on');
end

% Most error checking is done here
if ismember('i',cctypes)
    ngroups = numel(X);
end
errorcheck(X,ngroups,label,lambda,limits,parent,cctypes,nsigma,...
           meanval,sigma,specs,unit,width);

% Estimate sigma via moving range if there are no subgroups
if ~grouped && ~isnumeric(sigma)
    sigma = 'mr';
end

% Compute all required subgroup statistics from the data
if ~grouped
    G = [];
end
stats = getstats(X,G,cctypes,distn,unit,width);

% Make sure we're not using moving statistics on subgrouped data
if grouped && any(ismember({'ma' 'mr'},cctypes))
    error('stats:controlchart:NoSubgroups',...
          'MA and MR charts are not allowed with subgrouped data.');
end

% Estimate distribution parameters
stats = getparams(stats,distn,meanval,sigma,width);

% For two charts, the stats.n value has until now indicated the n used for
% the sigma estimate rather than the n represented by points on the chart.
% Fix that before continuing.
if ismember('i',cctypes) || (~grouped && ismember('ewma',cctypes))
    stats.n(:) = 1;
    stats.n(isnan(stats.i)) = 0;
end

% Begin creating control charts
nplots = length(cctypes);
allax = zeros(1,nplots);
if dodisp && isempty(parent)
    clf;
end
for jplot=1:nplots
    % Get data (points and lines) for this plot
    cctype = cctypes{jplot};
    [pts,cl,lcl,ucl,se,ngrp,ooc] = getplotdata(stats,cctype,nsigma,...
                                  lambda,limits,~isempty(rules));

    % Apply control rules, if any
    ruletxt = '';
    if ~isempty(rules) && ismember(cctype,{'xbar' 'i' 'c' 'u' 'p' 'np'})
        ruletxt = cell(length(pts),1);
        [rulemat,rulenames] = controlrules(rules,pts,cl,se);
        ptsout = find(any(rulemat,2))';
        ooc(ptsout) = true;
        for j=ptsout
            txt = sprintf('%s,',rulenames{rulemat(j,:)});
            ruletxt{j} = txt(1:end-1);
        end
    end
    
    % Return plot data if requested
    if nargout>=2
        plotdata(jplot).pts = pts;
        plotdata(jplot).cl  = cl;
        plotdata(jplot).lcl = lcl;
        plotdata(jplot).ucl = ucl;
        plotdata(jplot).se  = se;
        plotdata(jplot).n   = ngrp;
        plotdata(jplot).ooc = ooc;
    end

    if ~dodisp
        continue
    end

    % Get axes for this plot
    if ~isempty(ts) && ~isempty(samples) && numel(samples)==numel(pts)
        ind = samples(:);
    else
        ind = (1:numel(pts))';
    end
    if isempty(parent)
        ax = subplot(nplots,1,jplot);
    else
        ax = parent;
    end
    allax(jplot) = ax;
    
    % Create plot
    h = plotalldata(ax,ind,pts,cl,lcl,ucl,ooc,cctype,specs);

    % Store information to create data cursor text
    setdatacursorinfo(h(1),ind,label,pts<lcl,pts>ucl,ruletxt);

    % Legend and title for the first plot only
    if jplot==1
        displaynames = {'Data' 'Violation' 'Center' 'LCL/UCL' 'Specs'};
        legend(h,displaynames{1:length(h)},'Location','NorthEastOutside');
        if nplots>1
            title(ax,'Control charts');
        else
            title(ax,sprintf('%s control chart',upper(cctype)));
        end
    end
end

if dodisp
    % Label bottom axes, using time series information if any
    set(allax(1:end-1),'xticklabel','');
    if ~isempty(ts)
        % Use ts information to choose X tick labels, but save and
        % restore the title and y axis label -- we don't want the
        % ones that stattslabelaxes may create.
        ytxt = get(get(allax(end),'ylabel'),'string');
        ttxt = get(get(allax(end),'title'),'string');
        stattslabelaxes(allax(end),ts,'','');
        set(get(allax(end),'ylabel'),'string',ytxt);
        set(get(allax(end),'title'),'string',ttxt);
    elseif ~isempty(Gnames) && ~ismember('i',cctypes)
        set(allax(end),'xtick',1:ngroups,'xticklabel',Gnames);
    end

    % Fix x axis limits and tie x axes together
    dx = 0.5 * (ind(end) - ind(1)) / max(1,numel(ind)-1);
    set(allax,'xlim',[ind(1)-dx, ind(end)+dx]);

    % Align axes in figure, link x axes together, and define resize function
    if nplots>1
        resizer;
        linkaxes(allax,'x');
        set(get(allax(1),'parent'),'resizefcn',@resizer);
    end

    % Enable the data cursor
    dcm = datacursormode(get(ax,'parent'));
    set(dcm,'Enable','on','UpdateFcn',@makedcursor);
end

if nargout>0
    outstats = stats;
end

    % ---- nested functions (share parent name space)
    % variable "allax" comes from parent name space
    function resizer(varargin)
        % Resize all axes to same width as 1st (it has the legend)
        if ~isempty(allax) && ishghandle(allax(1))
            nestedpos1 = get(allax(1),'position');
            for nestedj=2:length(allax)
                nestedpos = get(allax(nestedj),'position');
                nestedpos([1 3]) = max(0.0001, nestedpos1([1 3]));
                set(allax(nestedj),'position',nestedpos);
            end
        end
    end
end

% --------------------------------------
function txt = makedcursor(ignore,event)
%MAKEDCURSOR Make data cursor text
nestedobj = get(event,'target');   % this is the hg line handle
nestedpos = get(event,'position'); % this is the
nestedstr = getappdata(nestedobj,'ccinfo');
txt = '';
if isempty(nestedstr)
    return  % unexpected, selected object is missing ccinfo data
end
nestedj = find(nestedstr.x == nestedpos(1));
if isempty(nestedj)
    return  % unexpected, position appears to be bad
end
if isempty(nestedstr.label) % use label if provided
    nestedlbl = '';
else
    nestedlbl = [nestedstr.label{nestedj},sprintf('\n')];
end
if ~isempty(nestedstr.rv{nestedj}) % create appropriate cursor text
    txt = sprintf('Subgroup %d\n%sOut of control\n%s',...
        nestedj,nestedlbl,nestedstr.rv{nestedj});
else
    txt = sprintf('Subgroup %d\n%sIn control',nestedj,nestedlbl);
end
end


% -----------------------------------
function [cctypes,distn] = getctypeinfo(charttype,grouped)
%GETCTYPEINFO Get information about the selected chart types

% Define information about all types
cclist  = {'xbar' 's' 'r' 'ewma' 'i' 'mr' 'ma' 'p' 'np'   'u' 'c'};
ccgroup = [1      1   1   1      2   2    2    3   3      4   4];
distn   = {'normal'              'normal'      'binomial' 'poisson'};
if ~grouped
    ccgroup(4) = 2;  % ewma goes with i/mr/ma for ungrouped data
end

% Determine which were requested
[cctypes,locs] = statgetkeyword(charttype,cclist,true,'CHARTTYPE',...
                                'stats:controlchart:BadChartType');

% In order to be plotted together, they must be compatible
ccgroupnum = unique(ccgroup(locs));
if ~grouped && any(ccgroupnum==1)
   error('stats:controlchart:GroupRequired',...
         'XBAR, S, and R charts required grouped data.');
elseif length(ccgroupnum)~=1
    error('stats:controlchart:BadChartType',...
          'The selected chart types are not compatible.');
end

% Get distribution
distn = distn{ccgroupnum};

end

% -----------------------------------
function stats = getstats(X,G,cctypes,distn,unit,width)
%GETSTATS Compute statistics from data

switch(distn)
    case 'normal'
        % For the normal distribution with subgroups we need the sample
        % size, means, standard deviations, and ranges.  Without subgroups
        % we need the moving range and anything else being plotted.
        if isvector(X)
            if ~isempty(G) && ~any(ismember({'ma' 'mr'},cctypes))
                % Subgroups defined by grouping variable
                [stats.mean,stats.std,stats.n,stats.range] = ...
                    grpstats(X,G,{'mean' 'std' 'numel' @localrange});
                if ismember('i',cctypes)
                    stats.i = X;
                end
            else
                % Moving statistics for data not in subgroups
                t = X;
                B = ones(1,width);
                stats.n = filter(B,1,~isnan(t));
                t(isnan(t)) = 0;
                ngt0 = (stats.n>0);
                if ismember('ma',cctypes)
                    msum = filter(B,1,t);
                    stats.ma = nan(size(stats.n));
                    stats.ma(ngt0) = msum(ngt0) ./ stats.n(ngt0);
                end
                stats.mean = X;
                stats.i = X;
                mr = zeros(size(X));
                for j=1:width
                    v = X(1:j);
                    mr(j) = max(v) - min(v);
                end
                for j=width+1:length(X)
                    v = X(j-width+1:j);
                    mr(j) = max(v) - min(v);
                end
                stats.mr = mr;
            end
        else
            % Subgroups defined by rows
            stats.mean = nanmean(X,2);
            stats.std = nanstd(X,0,2);
            stats.n = sum(~isnan(X),2);
            stats.range = range(X,2);
            if ismember('i', cctypes);
                stats.i = X';
                stats.i = stats.i(:);
            end
        end

    case {'binomial', 'poisson'}
        % For the count-based distributions we need the total count, as
        % well as the total unit size (number of items sampled for
        % binomial, and something like "area sampled" for Poisson)
        if isempty(unit)
            unit = 1;
        end
        if isvector(X) && ~isempty(G)
            [count,nx] = grpstats(X,G,{'sum' 'numel'});
            if isscalar(unit)
                n = unit * nx;
            else
                n = grpstats(unit,G,{'sum'});
            end
        else
            count = nansum(X,2);
            if isscalar(unit)
                n = unit * sum(~isnan(X),2);
            else
                n = nansum(unit.*~isnan(X),2);
            end
        end
        stats.count = count;
        stats.n = n;
end
end

% ------------------------------------
function t = localrange(y)
n = size(y,1);
if n==0
    t = nan(1,size(y,2));
else
    t = range(y,1);
end
end

% ------------------------------------
function stats = getparams(stats,distn,meanval,sigmamethod,width)
%GETSIGMA Get distribution estimates from sample statistics

n = stats.n;

switch(distn )
    case 'normal'
        % Get estimates of normal mu and sigma parameters
        if ~isempty(meanval)
            mu = meanval;
        elseif isfield(stats,'i')
            mu = nanmean(stats.i);                       % individuals
        else
            t = (n>0);
            mu = sum(n(t) .* stats.mean(t)) / sum(n(t)); % use group means
        end

        if isnumeric(sigmamethod)
            sigma = sigmamethod;   % sigma value is given
        else
            switch(sigmamethod)    % estimate sigma using requested method
                case 'range'
                    d2 = statccconst('d2',n);
                    d3 = statccconst('d3',n);
                    f = (d2./d3).^2;
                    sigma = sum(f .* stats.range ./ d2) / sum(f);

                case 'std'
                    c4 = statccconst('c4',n);
                    h = c4.^2 ./ (1 - c4.^2);
                    t = (c4>0);
                    sigma = sum(h(t) .* stats.std(t) ./ c4(t)) / sum(h(t));

                case 'variance'
                    sigma = sqrt(sum((n-1) .* stats.std.^2) / sum(n-1));
                    
                case 'mr'
                    t = min(width,length(n)):numel(n);
                    t(n(t)<2) = [];
                    d2 = statccconst('d2',n(t));
                    d3 = statccconst('d3',n(t));
                    f = (d2./d3).^2;
                    sigma = sum(f .* stats.mr(t) ./ d2) / sum(f);
            end
        end
        stats.mu = mu;
        stats.sigma = sigma;

    case 'binomial'
        % Get estimate of binomial p parameters
        if ~isempty(meanval)
            p = meanval;
        else
            t = (n>0);
            p = sum(stats.count(t)) ./ sum(n(t));
        end
        stats.p = p;

    case 'poisson'
        % Get estimate of Poisson mean parameter m
        if ~isempty(meanval)
            m = meanval;
        else
            t = (n>0);
            m = sum(stats.count(t)) ./ sum(n(t));
        end
        stats.m = m;
end
end

% ------------------------------------
function [pts,cl,lcl,ucl,se,n,ooc] = getplotdata(stats,cctype,k,lambda,...
                                               limits,needse)
%GETPLOTDATA Get data for control chart
%    STATS is structure of statistics, CCTYPE is a control chart type, and
%    K is a multiple of sigma to use in computing control limit values

n = stats.n;

% Get data points to plot (see comments with limit calculations)
switch(cctype)
    case 'xbar'
        pts = stats.mean;
    case 'r'
        pts = stats.range;
    case 's'
        pts = stats.std;
    case 'mr'
        pts = stats.mr;
    case 'ma'
        pts = stats.ma;
    case 'i'
        pts = stats.i;
    case 'ewma'
        t = (n>0);
        pts = nan(size(t));
        pts(t) = filter(lambda,[1,(lambda-1)],stats.mean(t),(1-lambda)*stats.mu);
    case 'np'
        pts = stats.count;
    case 'p'
        t = (n>0);
        pts = nan(size(n));
        pts(t) = stats.count(t) ./ n(t);
    case 'c'
        pts = stats.count;
    case 'u'
        t = (n>0);
        pts = nan(size(n));
        pts(t) = stats.count(t) ./ n(t);
end

% Use specified limits or compute them
lowlim = -Inf;   % lowest possible value for data or control limit
uplim = Inf;

if ~isempty(limits)
    lcl = repmat(limits(1),size(n));
    cl  = repmat(limits(2),size(n));
    ucl = repmat(limits(3),size(n));
    se = 0;
end
if isempty(limits) || needse
    switch(cctype)
        case 'xbar'
            % Normal distribution.  Plot subgroup means, center line at
            % distribution mean, standard error sigma/sqrt(n).
            cl = repmat(stats.mu,size(pts));

            se = stats.sigma ./ sqrt(max(1,n));
            se(n<1) = NaN;

        case 'r'
            % Normal distribution.  Plot subgroup ranges, center line
            % computed using d2, standard error computed using d3
            d2 = statccconst('d2',n);
            d3 = statccconst('d3',n);
            cl = stats.sigma * d2;

            se = stats.sigma * d3;
            lowlim = 0;

        case 's'
            % Normal distribution.  Plot subgroup standard deviations,
            % center line computed using c4, standard error also computed
            % using d3
            c4 = statccconst('c4',n);
            cl = c4 .* stats.sigma;

            se = stats.sigma * sqrt(1 - c4.^2);
            se(n<2) = NaN;
            lowlim = 0;
            
        case 'mr'
            % Normal distribution.  Plot moving ranges, center line
            % computed using d2, standard error using d3
            d2 = statccconst('d2',n);
            d3 = statccconst('d3',n);
            cl = stats.sigma * d2;
            
            se = stats.sigma * d3;
            se(n<=1) = NaN;
            lowlim = 0;

        case 'ma'
            % Normal distribution.  Plot moving averages, center line
            % is mu, standard error is sigma/sqrt(n)
            cl = repmat(stats.mu,size(pts));

            se = stats.sigma ./ sqrt(max(1,n));
            se(n<1) = NaN;

        case 'i'
            % Normal distribution.  Plot individual measurements, center
            % line is mu, standard error is sigma
            cl = repmat(stats.mu,size(pts));

            se = repmat(stats.sigma, size(pts));
            se(n<1) = NaN;
            
        case 'ewma'
            % Normal distribution.  Plot weighted moving averages, 
            cl = repmat(stats.mu,size(pts));

            t = (n>0);
            se = nan(size(t));
            se(t) = stats.sigma * ...
                 sqrt(filter(lambda^2, [1,-(1-lambda)^2], 1./n(t), 0));

        case 'np'
            % Binomial distribution.  For NP charts, plot total subgroup
            % counts, center line at mean, standard errors sqrt(n*p*(1-p)).
            cl = stats.p * n;
            se = sqrt(n * stats.p * (1-stats.p));
            se(n==0) = NaN;
            lowlim = 0;
            uplim = n;

        case 'p'
            % As for NP charts but normalized by N.
            cl = repmat(stats.p, size(n));
            t = (n>0);
            se = nan(size(n));
            se(t) = sqrt(stats.p * (1-stats.p) ./ stats.n(t));
            lowlim = 0;
            uplim = 1;

        case 'c'
            % Poisson distribution.  For C charts, plot total subgroup
            % counts, center line at mean, standard errors are sqrt(mean)
            % for Poisson.
            cl = stats.m .* n;
            se = sqrt(cl);
            lowlim = 0;

        case 'u'
            % As for C charts but normalized by N.  Note that COUNT/N does
            % not have a Poisson distribution.
            cl = repmat(stats.m, size(n));
            t = (n>0);
            se = nan(size(n));
            se(t) = sqrt(stats.m ./ n(t));
            lowlim = 0;
    end
end

if isempty(limits)
    % Compute control limits and make sure they stay in bounds
    lcl = cl - k * se;
    ucl = cl + k * se;
    lcl(lcl<lowlim) = lowlim;  % avoid min() because lcl may be NaN
    if isscalar(uplim)
        ucl(ucl>uplim) = uplim;
    else
        t = (ucl>uplim);
        ucl(t) = uplim(t);
    end
end

% Which points are out of control?
ooc = (pts>ucl) | (pts<lcl);
end

% -----------------------------------
function h = plotalldata(ax,ind,pts,cl,lcl,ucl,ooc,cctype,specs)
%PLOTALLDATA Plot data, control limits, and spec limits

% First plot all the data
h = zeros(4,1);
msize = 12;
h(1) = plot(ax,ind,pts,'b.-','markersize',msize,'tag','pts');

% Next put circles around the rule violations.  We need to have this in the
% legend even if there are no violations in this plot, because there may be
% violations in other subplots.  To insure that we create the line with
% some data, then replace the data.  Otherwise, if we tried to plot the
% empty data directly, we might not get a line.
hold(ax,'on');
h(2) = plot(ax,ind(1),pts(1),'ro','hittest','off','tag','ooc');
set(h(2),'xdata',ind(ooc),'ydata',pts(ooc));

% Now plot center line and control limits
h(3) = plotline(ind,cl,'-','color',[0 .75 0],'parent',ax,'hittest','off','tag','cl');
h(4) = plotline(ind,[lcl ucl],'r-','parent',ax,'hittest','off','tag','lclucl');
ylabel(ax,upper(cctype));
ymin = min(min(pts),min(lcl));
ymax = min(max(pts),max(ucl));

% Add spec limits if requested
if ~isempty(specs) && ~ismember(cctype,{'r' 's' 'mr'})
    h(5) = plotline(ind,specs(:)','r:','parent',ax,'hittest','off','tag','specs');
    ymin = min(ymin,min(specs));
    ymax = max(ymax,max(specs));
end
hold(ax,'off');

% Avoid lines right along the top or bottom
dy = (ymax - ymin) / 20;
ylim = get(ax,'ylim');
set(ax,'ylim',[min(ylim(1),ymin-dy), max(ylim(2),ymax+dy)]);
end

% -----------------------------------
function h=plotline(x,y,varargin)
%PLOTLINE Plot line for control chart
if numel(x)>1
    dx = min(diff(x))/2;
else
    dx = 1/2;
end
nlines = size(y,2);
nx = length(x);

if all(all(diff(y,1,1)==0))
    % Reduce data if constant, and plot horizontal lines
    x = repmat([x(1)-dx; x(end)+dx; NaN],nlines,1);
    y = [y(1,:); y(1,:); NaN(1,nlines)];
    x = x(1:end-1);
    y = y(1:end-1);
else
    % If not constant, plot as step functions
    xx = [x(1)-dx; (x(2:end)+x(1:end-1))/2; x(end)+dx];
    x = [xx(1:end-1)'; xx(2:end)'];
    x = [x(:); NaN];
    x = repmat(x,nlines,1);
    x = x(1:end-1);

    t = ceil((1:2*nx)/2);
    y = [y(t,:); NaN(1,nlines)];
    y = y(1:end-1);
end

h = plot(x,y,varargin{:});
end

% ------------------------------------
function setdatacursorinfo(h,ind,label,toolow,toohigh,ruletxt)
%SETDATACURSORINFO Put info into axes appdata for creating data cursor text

if ~iscell(label) && ~isempty(label)
    label = cellstr(label);
end
str.x = ind;                  % index (x value)
str.label = label;            % optional label
str.rv = cell(length(ind),1); % rule violations
if ~isempty(ruletxt)
    haverv = ~cellfun('isempty',ruletxt);  % true if we have a rule violation
else
    haverv = false;
end

% Determine which labels go with which points
t = toolow & haverv;
if any(t)
    str.rv(t) = strcat('< LCL,', ruletxt(t));
end
t = toolow & ~haverv;
if any(t)
    str.rv(t) = {'< LCL'};
end
t = toohigh & haverv;
if any(t)
    str.rv(t) = strcat('> UCL,', ruletxt(t));
end
t = toohigh & ~haverv;
if any(t)
    str.rv(t) = {'> UCL'};
end
t = haverv & ~(toohigh | toolow);
if any(t)
    str.rv(t) = ruletxt(t);
end
    
setappdata(h,'ccinfo',str); % used by data cursor function to create text
end
    
% ------------------------------------
function errorcheck(X,ngroups,label,lambda,limits,parent,cctypes,nsigma,...
                    meanval,sigma,specs,unit,width)
%ERRORCHECK Error checking function, self-explanatory
if ~isempty(label)
    if ~(ischar(label) && size(label,1)==ngroups) && ...
       ~(iscellstr(label) && numel(label)==ngroups)
        error('stats:controlchart:BadLabel',...
              'LABEL must be character or cell array with %d labels.',ngroups);
    end
end

if ~isempty(lambda) && ...
   ~(isnumeric(lambda) && isscalar(lambda) && lambda>0 && lambda<1)
    error('stats:controlchart:BadLambda','LAMBDA must be a number between 0 and 1.');
end

if ~isempty(limits) && ~(isnumeric(limits) && numel(limits)==3 && ...
                         limits(2)>limits(1) && limits(3)>limits(2))
    error('stats:controlchart:BadLimits',...
          'LIMITS must be a three-element vector of sorted limit values.')
end

if ~isempty(parent)
    if ~(isscalar(parent) && ishghandle(parent) && ...
         isequal(get(parent,'type'),'axes'))
        error('stats:controlchart:BadParent',...
              'The PARENT value must be a valid axes handle.');
    end
    if length(cctypes)>1
        error('stats:controlchart:BadParent',...
              'The PARENT argument is not allowed with multiple control charts.');
    end
end

if ~(isnumeric(nsigma) && isscalar(nsigma) && nsigma>0)
    error('stats:controlchart:BadNSigma',...
          'NSIGMA must be a positive number.');
end

if ~isempty(meanval)
    if ~(isnumeric(meanval) && isscalar(meanval))
        error('stats:controlchart:BadMean',...
              'MEAN must be a single value for the process mean.');
    elseif any(ismember({'p' 'np'},cctypes)) && (meanval<=0 || meanval>=1) 
        error('stats:controlchart:BadMean',...
              'MEAN for P and NP charts must be between 0 and 1.');
    elseif any(ismember({'c' 'u'},cctypes)) && meanval<=0
        error('stats:controlchart:BadMean',...
              'MEAN for C and U charts must be positive.');
    end
end

if ~(isequal(sigma,'std')      || isequal(sigma,'range') || ...
     isequal(sigma,'variance') || ...
     (isnumeric(sigma) && isscalar(sigma) && sigma>0))
    error('stats:controlchart:BadSigma',...
          'SIGMA must be a positive value or an estimation method.');
end

if ~isempty(specs) && ~(isnumeric(specs) && isvector(specs))
    error('stats:controlchart:BadSpecs',...
          'SPECS must be a vector of numeric specification limits.')
end

if ~isempty(unit) && (~isnumeric(unit) || any(unit(:)<=0) || ...
                      ~(isscalar(unit) || isequal(size(unit),size(X))))
    error('stats:controlchart:BadUnit',...
          'UNIT must be an array of positive unit values of the same size as X.');
end
if isempty(unit) && any(ismember({'p' 'np'},cctypes))
    error('stats:controlchart:BadUnit',...
          'UNIT is required for P and NP charts.');
end

if ~isnumeric(width) || ~isscalar(width) || width<=0 || width~=round(width)
    error('stats:controlchart:BadWidth',...
          'WIDTH must be a positive integer.')
elseif width>size(X,1)
    error('stats:controlchart:BadWidth',...
          'WIDTH cannot be larger than the number of points.')
end
end
