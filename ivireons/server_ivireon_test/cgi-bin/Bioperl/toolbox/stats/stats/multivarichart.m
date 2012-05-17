function  [charthandle,axesh] = multivarichart(y,varargin)
%MULTIVARICHART Multivari chart for grouped data
%   MULTIVARICHART(Y,GROUP) displays the multivari chart for the vector Y
%   grouped by entries in the cell array GROUP.  Each cell of GROUP must
%   contain a grouping variable that can be a categorical variable, numeric
%   vector, character matrix, or single-column cell array of strings.
%   GROUP can also be a matrix whose columns represent different grouping
%   variables.  Each grouping variable must have the same number of
%   elements as Y.  The number of grouping variables must be 2, 3, or 4. 
%
%   Each subplot of the plot matrix contains a multivari chart for the 
%   first and second grouping variables. The x-axis in each subplot 
%   indicates values of the first grouping variable. The legend at the 
%   bottom of the figure window indicates values of the second grouping 
%   variable. The subplot at position (i,j) is the multivari chart for the 
%   subset of Y at the i-th level of the third grouping variable and the
%   j-th level of the fourth grouping variable. If the third or fourth
%   grouping variable is absent, it is considered to have only one level.
%
%   MULTIVARICHART(Y) displays the multivari chart for a matrix Y. The 
%   data in different columns represent changes in one factor. The data in
%   different rows represent changes in another factor. 
%
%   MULTIVARICHART(...,'PARAM1',val1,'PARAM2',val2,...) specifies one or
%   more of the following name/value pairs:
%
%       Parameter    Value
%
%       'varnames'   Grouping variable names in a character matrix or
%                    a cell array of strings, one per grouping variable.
%                    Default names are 'X1', 'X2', ... .
%
%       'plotorder'  A string with the value 'sorted' or a vector 
%                    containing a permutation of the integers from 1 to 
%                    the number of grouping variables. 
%
%                    If plotorder is a string with value 'sorted', the 
%                    grouping variables are rearranged in descending order 
%                    according to the number of levels in each variable. 
%
%                    If plotorder is a vector, it indicates the order in 
%                    which each grouping variable should be plotted. For 
%                    example, [2,3,1,4] indicates that the second grouping 
%                    variable should be used as the x-axis of each subplot, 
%                    the third grouping variable should be used as the 
%                    legend, the first grouping variable should be used as 
%                    the columns of the plot, and the fourth grouping 
%                    variable should be used as the rows of the plot.
%
%   [CHARTHANDLE, AXESH] = MULTIVARICHART(...) returns a handle CHARTHANDLE
%   to the figure window and a matrix AXESH of handles to the subplot axes.
%
%   Example:
%      Display a multivari chart for data with two grouping variables.
%           y = randn(100,1); % response
%           group = [ceil(3*rand(100,1)) ceil(2*rand(100,1))]; 
%           multivarichart(y,group)
%
%      Display a multivari chart for data with four grouping variables.
%           y = randn(1000,1); % response
%           group = {ceil(2*rand(1000,1)),ceil(3*rand(1000,1)), ...
%                    ceil(2*rand(1000,1)),ceil(3*rand(1000,1))};
%           multivarichart(y,group)
%
%   See also MAINEFFECTSPLOT, INTERACTIONPLOT 

% Copyright 2006-2010 The MathWorks, Inc.

if nargin <2 && isvector(y)
    error('stats:multivarichart:FewInput',...
        'Y and GROUP are required for multivari chart.')
end

% Parse parameter/value pairs
args =   {'varnames','plotorder'};
defaults = {'','unsorted'};  % default grouping variable names
if mod(nargin,2)==1 && size(y,2)>1 % matrix data
    [eid emsg varnames plotorder] =  internal.stats.getargs(args,defaults,varargin{:});
else
    group = varargin{1};
    [eid emsg varnames plotorder] =  internal.stats.getargs(args,defaults,varargin{2:end});
end;
if ~isempty(eid)
    error(sprintf('stats:multivarichart:%s',eid),emsg);
end

if ischar(plotorder) % string PLOTORDER
    plotorder = lower(plotorder);
    if  ~strcmp(plotorder, 'sorted') && ~strcmp(plotorder, 'unsorted')  
        error('stats:multivarichart:BadPlotorder', ...
            'PLOTORDER must be a string with the value ''sorted'' or ''unsorted'', or a vector.')
    end
end;

if ~isvector(plotorder) && ~ischar(plotorder)
    error('stats:multivarichart:BadPlotorder', 'PLOTORDER must be either a string or a vector.')
end

if ~iscell(varnames) && ~ischar(varnames)
    error('stats:multivarichart:BadVarnames', 'VARNAMES must be either a cell array or a character matrix.')
end
if (~(ischar(varnames) || iscellstr(varnames)))
      error('stats:multivarichart:BadVarnames',...
            'VARNAMES must be a character matrix or cell array of strings.');
end

needvarnames = isempty(varnames);  %  whether we need default group variable names

% Character matrix grouping variable names are converted into cell array
if ischar(varnames) && ~needvarnames 
    varnames = cellstr(varnames);
end;

% Cannot accept a vector Y without GROUP as arguments
if mod(nargin,2)==1 && isvector(y)
    error('stats:multivarichart:BadData', 'MULTIVARICHART requires at least two grouping variables.')
end

% Matrix data Y are converted to vector Y plus GROUP
if mod(nargin,2)==1 && size(y,2)>1
    [n1,n2] = size(y);
    group = zeros(n1*n2,2);
    group(:,1) = repmat((1:n1)', n2,1);
    temp = repmat((1:n2), n1,1);
    group(:,2) = temp(:);
    y = y(:);
end

% Convert the GROUP to cell arrays
if isnumeric(group) 
    group = num2cell(group,1);
end
group = group(:);
ng = length(group);  % number of grouping factors

% Convert all grouping variables to integers, and remember separately their
% original names
levelnames = cell(1,ng);
nlevels = zeros(1,ng);
for i = 1:ng
    if isnumeric(group{i})
        if ~isvector(group{i})
           error('stats:multivarichart:BadGroup',...
                 'Numeric GROUP variables must be vectors.')
        end
    end;
    [group{i},levelnames{i}] = grp2idx(group{i});
    nlevels(i) = length(levelnames{i});
end

% Group variable should have the same number of items as y.
if  any(cellfun(@length,group)~=size(y,1))
        error('stats:multivarichart:BadGroup',...
            'GROUP must be a cell array or matrix whose number of items is the same as Y.')
end;

% Vector PLOTORDER should be a permutation of 1:ng
if isnumeric(plotorder)&& any(sort(plotorder) ~= (1:ng))
    error('stats:multivarichart:BadPlotorder',...
        'PLOTORDER should be a permutation of 1:N where N is the number of groups.')
end;

% Generate default varnames
if  needvarnames
    varnames = strcat({'X'},num2str((1:ng)','%d'));
end;

% The length of varnames should be the same as the number of groups
if ng ~= length(varnames)
    error('stats:multivarichart:MismatchVarnameGroup',...
        'The size of VARNAMES mismatches the size of GROUP.')
end;

% Sort the group factors based on the number of levels if necessary
if isequal(plotorder,'sorted')
    [ignore,plotorder] = sort(nlevels(:),1,'descend');
elseif isequal(plotorder,'unsorted')
    plotorder = 1:ng;
end
group = group(plotorder);
varnames = varnames(plotorder);
nlevels = nlevels(plotorder);
levelnames = levelnames(plotorder);

%Make the multivarichart chart
switch ng
    case 1  % only one grouping factor
        error('stats:multivarichart:TooFewFactors',...
            'The number of grouping variables must be more than 1.')
    case 2  % two grouping factors
        figh = clf;
        legendnames = twofactormultivarichart(y,group,varnames{2},levelnames,nlevels);
        H = gca;
        legend(legendnames,'location','northeastoutside');
        xlabel(varnames{1})        
    case 3  %  three grouping factors
        figh = clf;
        % create a container to hold all plots except the legend
        uic = uicontainer('units','normalized','position',[0 .1 1 .9],'clipping','off',...
            'backgroundcolor', get(figh,'color'));
        set(uic,'units','pixels')
        ylim = [0,0];    % initialize a y-axis limit
        H = zeros(nlevels(3),1);  % subplot handle holder
        for i = 1:nlevels(3)
            H(i) = subplot(1,nlevels(3),i,'parent',uic);
            
            % subsetting data that are using to draw each plot
            [ysub,groupsub] = subsetdata(y,group,group{3}==i);
            
            % subplot is drawn with returned legend names
            legendnames = twofactormultivarichart(ysub,groupsub,varnames{2},levelnames,nlevels);
            % subtitle indicates which subset data are being used
            subtitlenames = [varnames{3},' = ',levelnames{3}{i}];
            title(subtitlenames)
            % get the y axis limit and find the extremes through the loop
            axis tight
            ylim(i,:) = get(H(i),'ylim');
            xlabel(varnames{1})
        end;
        ylimmin = min(ylim(:,1)); ylimmax = max(ylim(:,2));
    case 4  % four grouping factors
        figh = clf;
        uic = uicontainer('units','normalized','position',[0 .1 1 .9],'clipping','off', ...
            'backgroundcolor', get(figh,'color'));
        set(uic,'units','pixels')
        counter = 1;
        H = zeros(nlevels(4), nlevels(3));
        ylim = zeros(nlevels(4),nlevels(3),2);
        for i = 1:nlevels(4)
            for j = 1:1:nlevels(3)
                H(i,j) = subplot(nlevels(4),nlevels(3),counter,'parent',uic);
                
                % subsetting data that are using to draw each plot
                [ysub,groupsub] = subsetdata(y,group,group{3}==j,group{4}==i);

                legendnames  = twofactormultivarichart(ysub,groupsub,varnames{2},levelnames,nlevels);
                counter = counter+1;
                if i==1
                    % subtitle indicates the combinations of the last two factors
                    subtitlenames = [varnames{3},' = ',levelnames{3}{j}];
                    title(subtitlenames)
                end
                axis tight
                ylim(i,j,:) = get(H(i,j), 'ylim');
                if i==nlevels(4)
                    xlabel(varnames{1})
                end;
                if j==1
                    ylabel([varnames{4},' = ',levelnames{4}{i}]);
                end;
            end
        end;
        ylimmin = min(min(ylim(:,:,1),[],2)); ylimmax = max(max(ylim(:,:,2),[],2));
    otherwise % no more than 4 grouping factors are allowed.
        error('stats:multivarichart:TooManyFactors',...
            'The number of grouping variables must be less than 5.')
end;

% Make a legend
if ng>2
    n1 = nlevels(1);  % number of levels for factor 1 and 2
    n2 = nlevels(2);
    % Set all the limits to be the same and leave
    % just a 5% gap between data and axes.
    inset = .05;
    dy = (ylimmax- ylimmin)*inset;
    set(H,'ylim',[ylimmin-dy ylimmax+dy],'xlim', [0.5, n1+.5])

    set(figh,'color',get(uic,'backgroundcolor'))   % make the figure window's background color the same as the container
    axes('parent',figh,'units','pixels','position',[1 1 1 1],'visible','off')
    hold on
    marks = ['o','s','d','p','h','x','v','^','<','>','+','*'];
    nmarks = length(marks);
    h = zeros(n2,1);
    for i = 1:n2
        currentmark = ['b', marks(mod(i-1,nmarks)+1)];
        h(i) = plot(ones(n1,1),ones(n1,1),currentmark);
        set(h,'visible','off')
    end
    hold off
    legh = legend(h,legendnames,'orientation','horizontal');
    dolayout = @(fig, vargin) subdolayout(fig,legh,uic);
    set(figh,'handlevisibility','callback','resizefcn',dolayout);
    dolayout(figh);
    
    % Create a listener for the figure color property
    addlistener(figh, 'Color', 'PostSet', @(src,evt) colorc(evt,uic));
end

% To avoid warning
set(figh,'PaperPositionMode','auto')

% Return the figure handle if it is asked.
if nargout>0
    charthandle  = figh;
end;
if nargout>1
    axesh  = H;
end;

%-----------------------------------------
function legendnames  = twofactormultivarichart(y,group,varname2,levelnames,nlevels)
% sub function to draw the multivari chart for a dataset with only two
% grouping factors.

ms = grpstats(y, group{1}, {'mean'}); % group means w.r.t the first factor

% Plot the means for the second factor
if nlevels(2) == 1
    error('stats:multivarichart:TooFewLevels',...
        'The number of the distinct values in the second grouping variable must be greater than 1.')
end

[ms2,num2] = grpstats(y, {group{1:2}}, {'mean','numel'});  % group means w.r.t the second factor
if  length(num2) < nlevels(1)*nlevels(2)
    error('stats:multivarichart:UnequalLevels',...
        'The combination of factor levels is not complete.')
end
% the means are reshaped as a matrix for the convenience of plot
% and legend
matrixdata = reshape(ms2,nlevels(2),nlevels(1));

% Plot the means for the first factor
plot(1:length(ms),ms,'r:','HandleVisibility','off'); % red dotted line for the main effects
set(gca,'xtick',1:length(ms),'xticklabel',levelnames{1})

% plot this matrix data
hold on
legendnames = plotsecondgroupvar(matrixdata,nlevels(1),varname2,levelnames{2});
hold off

%----------------------------------------
function   legendnames = plotsecondgroupvar(matrixdata,n1,varname,levelnames)
% plot the second groupvar

n2 = size(matrixdata,1);
% Generate legend names
leftpart = [varname,' = '];
legendnames = strcat({leftpart},levelnames);

marks = ['o','s','d','p','h','x','v','^','<','>','+','*'];  % marks to be used
nmarks = length(marks);
if n2>=2
    xoffset = linspace(-.2,.2,n2);                     % compute the offset from the x-coordinate
    xcorr = repmat(1:n1,n2,1) + repmat(xoffset',1,n1); % x-coordinates for the second variables
    objhandle = plot(xcorr,matrixdata,'b-');           % plot the solid line
    set(objhandle,'HandleVisibility','off');
    hold on
    % plot the marks
    for i = 1:n2
        currentmark = ['b', marks(mod(i-1,nmarks)+1)];  % cycle through marks
        plot(xcorr(i,:),matrixdata(i,:),currentmark,'MarkerFaceColor','w');
    end
    hold off
else
    error('stats:multivarichart:TooFewLevels',...
        'The number of the distinct values in the second grouping variable must be greater than 1.')
end;

%----------------------------------------------------
function subdolayout(figh,legh,containerh,varargin)
% layout of the figure, container, and legend

legunits = get(legh,'units');
set(legh,'units','pixels');
legpos = get(legh,'position');
legwidth = legpos(3);

figunits = get(figh,'units');
figpos = get(figh,'position');
figheight = figpos(4);

% Position legend centered at the bottom
legpos(2) = 2;
figpospixels = hgconvertunits(figh,figpos,figunits,'pixels',figh);
legpos(1) = max(0, .5*figpospixels(3) - .5*legwidth);
set(legh,'position',legpos);
set(legh,'units',legunits);

% Position container above the legend
legposfig = hgconvertunits(figh,legpos,'pixels',figunits,figh);
baseline = (legposfig(2) + legposfig(4)) / figheight;
temppos = [0 baseline 1 1-baseline];
baseposc = hgconvertunits(figh,temppos,'normalized',get(containerh,'units'),figh);
set(containerh,'position',baseposc);

%----------------------------------------------------
function [ysub,groupsub] = subsetdata(y,group,varargin)
% SUBSETDATA(Y,GROUP,I1,I2,...) finds the subset of the data selected by
% the logical index vector I1&I2&...
% Outputs are the Y subset and a cell array of all the GROUP subsets.

index = true;
for k=1:length(varargin)
    index = index & varargin{k};
end

groupsub = {group{1}(index), group{2}(index)};  % find these subsets
ysub = y(index);

%----------------------------------------------------
function colorc(evt,container)
% This function is called when the figure color changes
if ishghandle(container) && isequal(get(container,'Type'),'uicontainer')
    set(container,'BackgroundColor',evt.NewValue);
end
