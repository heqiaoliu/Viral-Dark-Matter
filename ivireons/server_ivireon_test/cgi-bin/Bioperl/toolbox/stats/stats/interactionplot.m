function  [H, ax, BigAx]  = interactionplot(y,group,varargin)
%INTERACTIONPLOT Interaction plot for grouped data
%   INTERACTIONPLOT(Y,GROUP) displays the two-factor interaction plot for 
%   the group means of matrix Y with groups defined by entries in the cell 
%   array GROUP.  Y is a numeric matrix or vector.  If Y is a matrix, the 
%   rows represent different observations and the columns represent 
%   replications of each observation.  If Y is a vector, the rows give the 
%   means of each entry in the cell array GROUP.  Each cell of GROUP must 
%   contain a grouping variable that can be a categorical variable, numeric
%   vector, character matrix, or single-column cell array of strings.
%   GROUP can also be a matrix whose columns represent different grouping
%   variables.  Each grouping variable must have the same number of rows as
%   Y.  The number of grouping variables must be greater than 1.
%
%   The interaction plot is a matrix plot, with the number of rows and 
%   columns both equal to the number of grouping variables. The grouping 
%   variable names are printed on the diagonal of the plot matrix. The 
%   plot at off-diagonal position (i,j) is the interaction of the two 
%   variables whose names are given at row diagonal (i,i) and column 
%   diagonal (j,j), respectively.
%
%   INTERACTIONPLOT (...,'PARAM1',val1,'PARAM2',val2,...) specifies one or
%   more of the following parameter name/value pairs:
%
%       Parameter    Value
%       'varnames'   Grouping variables names in a character matrix or
%                    a cell array of strings, one per grouping variable
%                    (default names are 'X1', 'X2', ...)
%       'full'       A logic value true (default) or false. When full is
%                    true, the matrix plot includes interaction plots for
%                    AB and BA where A and B are any two factors in GROUP.
%                    When full is false, only interaction plot for AB is
%                    plotted.
%
%   [H,AX,BIGAX] = INTERACTIONPLOT(...) returns a handle H to the figure
%   window, a matrix AX of handles to the subplot axes, and a handle
%   BIGAX to the big (invisible) axes framing the subplots.
%
%   Example:
%     Display interaction plots for data with four 3-level factors named
%     'A', 'B','C', and 'D'.
%        y = randn(1000,1); %response
%        group = ceil(3*rand(1000,4)); %four 3-level factors
%        interactionplot(y,group,'varnames',{'A','B','C','D'})
%
%   See also MAINEFFECTSPLOT, MULTIVARICHART

% Copyright 2006-2009 The MathWorks, Inc.

if nargin <2
    error('stats:interactionplot:FewInput',...
        'Y and GROUP are required for interaction plot.')
end

% transpose y if it is row vector
if size(y,1) ==1
    y = y(:);
end;

% parse parameter/value pairs
args =   {'varnames','full'};
defaults = {'',true};
[eid emsg varnames,full] =  internal.stats.getargs(args,defaults,varargin{:});
if ~isempty(eid)
    error(sprintf('stats:interactionplot:%s',eid),emsg);
end

if ~iscell(varnames) && ~ischar(varnames)
    error('stats:interactionplot:BadVarnames', 'VARNAMES must be a character matrix or cell array of strings.')
end
if (~(ischar(varnames) || iscellstr(varnames)))
      error('stats:interactionplot:BadVarnames',...
            'VARNAMES must be a character matrix or cell array of strings.');
end

% determine whether we need default group variable names
needvarnames = isempty(varnames);

% convert the  numerical GROUP to cell arrays
if  isnumeric(group)
    group = num2cell(group,1);
end

group = group(:);
ng = length(group); % number of grouping factors

% You cannot have only one factor
if ng<2
    error('stats:interactionplot:TooFewFactors',...
        'The number of grouping variables must be more than 1.')
end

% Convert numerical cells or char cells to string cells
for i = 1:ng
    if ischar(group{i})
        group{i} = cellstr(group{i});
    end
end
% Group variable should have the same number of items as y.
if  any(cellfun(@length,group)~=size(y,1))
    error('stats:interactionplot:BadGroup',...
        'GROUP must be a cell array or matrix of grouping variables with the same number of items as  Y.')
end;

% Convert all grouping variables to integers, and remember separately their
% original names
levelnames = cell(1,ng);
for i = 1:ng
    if isnumeric(group{i})
        if ~isvector(group{i})
           error('stats:multivarichart:BadGroup',...
                 'Numeric GROUP variables must be vectors.')
        end
    end;
    [group{i},levelnames{i}] = grp2idx(group{i});
end

if  needvarnames
    % generate default varnames
    varnames = strcat({'X'},num2str((1:ng)','%d'));
end;

% Convert character matrix to cell array
if ischar(varnames)
    varnames = cellstr(varnames);
end;

% the length of varnames should be the same as the number of grouping factors
if ng ~= length(varnames)
    error('stats:interactionplot:MismatchVarnameGroup',...
        'The size of VARNAMES mismatches the size of GROUP.')
end;

% get means across replications
ybar = nanmean(y,2);

% plotting starts here
clf;
BigAx = newplot;
hold_state = ishold;
set(BigAx,'Visible','off','color','none')

% Create and plot into axes
if full % full matrix form
    % full plot is an ng by ng matrix plot.
    rows = ng;
    cols = ng;
    ax = zeros(rows,cols);
    pos = get(BigAx,'Position');
    % width and height for each individual axes
    width = pos(3)/(cols+1);
    height = pos(4)/rows;
    space = .02; % 2 percent space between axes
    % the position of the big axes is adjusted
    pos(1:2) = pos(1:2) - .05*[ng*width/2 height];
    ylim = nan(rows,cols,2);
    % this is the x coordinate for the legends
    if ng == 2
        legx = pos(1) + pos(3) - 1.6*width/ng;
    else
        legx = pos(1) + pos(3) - 2*width/ng;
    end
    for i=rows:-1:1,
        for j=cols:-1:1,
            axPos = [pos(1)+(j-1)*width pos(2)+(rows-i)*height ...
                width*(1-space) height*(1-space)];    % position of each panel axes
            ax(i,j) = axes('Position',axPos, 'visible', 'on', 'Box','on');
            if  i~=j   % off- diagonal are filled with interaction plots
                plotaninteraction(ybar,group{j},group{i},varnames{j},varnames{i},...
                    levelnames{j},levelnames{i});
                ylim(i,j,:) = get(gca, 'ylim');
            else
                % make an invisible interaction plot so that I can make a
                % legend on the diagonal.
                idx = i;          % factor to be legend
                anotheridx = mod(j,ng)+1;  % just another factor
                handles = plotaninteraction(ybar,group{anotheridx},group{idx},...
                    varnames{anotheridx},varnames{idx},...
                    levelnames{anotheridx},levelnames{idx});
                set(handles,'visible','off')
                set(gca,'xticklabel','','yticklabel','', ...
                    'xtick',[],'ytick',[])
                % make legend texts
                levels = levelnames{idx};
                left = [varnames{idx}, ' = '];
                lentext = strcat({left},levels);
                % make the legend
                legh = legend(lentext,'FontSize',8,'location','northeast');
                % place the legend to the very right
                legpos = get(legh, 'position');
                legpos(1) = legx;
                set(legh, 'position',legpos)
            end
        end
    end
    % find the best ylim
    ylimmin = min(min(ylim(:,:,1),[],2));
    ylimmax = max(max(ylim(:,:,2),[],2));

    % put the xticklabel to top in the top-row axes
    set(ax(1,:),'XAxisLocation','top');

    % put the yticklabel to top in the most right axes
    set(ax(:,cols),'YAxisLocation','right')

    % Ticks and labels on outer plots only
    set(ax(2:rows-1,:),'xticklabel','')
    set(ax(:,2:cols-1),'yticklabel','')
    set(BigAx,'XTick',get(ax(rows,1),'xtick'),'YTick',get(ax(rows,1),'ytick'), ...
        'userdata',ax)
else % compact matrix form
    % figure out how many rows and cols are needed.
    if mod(ng,2)==0
        rows = ng/2;
        cols = ng -1;
    else
        cols = ng;
        rows = (ng -1)/2;
    end;
    ax = zeros(rows,cols);
    pos = get(BigAx,'Position');
    width = pos(3)/cols;
    height = pos(4)/rows;
    % try to work out spaces between axes
    switch ng
        case 2
            space = 0;   % no space is needed if there is only a single plot
        case 3
            space = [0.02 0];  % no vertical space is needed if there is only one row
        otherwise
            space = [.02 .15]; % 2 percent space between x axes and 15 percent between y axes
            pos(1:2) = pos(1:2) + space.*[width height/2];
    end;
    ylim = nan(ng*(ng-1)/2,2);
    plotind = 0;
    for i = 1:ng-1
        for j = i+1:ng
            plotind = plotind + 1;          % plot sequence number
            rowid  = ceil(plotind/cols);    % row number
            colid = mod(plotind-1, cols)+1; % col number
            axPos = [pos(1)+(colid-1)*width pos(2)+(rows-rowid)*height ...
                [width height].*(1-space)];    % position of each panel axes
            ax(rowid, colid) = axes('Position',axPos, 'visible', 'on', 'Box','on');
            plotaninteraction(ybar,group{i},group{j},varnames{i},varnames{j},levelnames{i},levelnames{j});
            xlabel(varnames{i})
            ylim(plotind,:) = get(gca, 'ylim');
            levels = levelnames{j};
            left = [varnames{j}, ' = '];
            lentext = strcat({left},levels);
            if ng == 2
                legend(lentext,'FontSize',8,'location','best'); % special treatment for single plot
            else
                legend(lentext,'FontSize',8);
            end;
        end
    end;
    ylimmin = min(ylim(:,1));
    ylimmax = max(ylim(:,2));
    set(ax(:,2:cols),'yticklabel','')
end;

set(ax, 'xgrid','off', 'ygrid','off') % set axes grids off

% Set all the limits to be the same and leave
% just a 5% gap between data and axes.
inset = .05;
dy = (ylimmax - ylimmin)*inset;
set(ax,'ylim',[ylimmin-dy ylimmax+dy])

if full
    % place the variable names on the diagonal of the matrix
    for j=1:cols
        set(gcf,'CurrentAx',ax(j,j));
        xlims = get(gca,'xlim');
        ylims = get(gca,'ylim');
        h = text(mean(xlims), mean(ylims), ...
            varnames{j}, 'HorizontalAlignment','center','VerticalAlignment','middle');
        set(h, 'fontsize',16)
    end
end

% Make BigAx the CurrentAxes
set(gcf,'CurrentAx',BigAx)
if ~hold_state,
    set(gcf,'NextPlot','replace')
end

% Also set Title and X/YLabel visibility to on and strings to empty
set([get(BigAx,'Title'); get(BigAx,'XLabel'); get(BigAx,'YLabel')], ...
    'String','','Visible','on')

% Return the figure handle if it is asked.
if nargout>0
    H = gcf;
end;


%-----------------------------------
function   handle = plotaninteraction(y,factor1,factor2,varname1,varname2,levels1,levels2)
% plot an single interaction plot between two factors
% factor1 is for x axis
% factor2 is for y axis
[interact,num] = grpstats(y,{factor1,factor2}, {'mean','numel'});  % group means w.r.t the two factors

%number of levels in each factor
num1 = length(levels1);
num2 = length(levels2);

if  length(num) < num1*num2
    error('stats:interactionplot:UnequalLevels',...
        'Some combinations of factor levels are missing.')
end

% the means are reshaped as a matrix for the convenience of plot and legend
matrixdata = reshape(interact,num2,num1);

% plot this matrix data
linetype = {'-',':','-.','--'};  % all line types
colors = [0     0     1          % all colors
          0    .5     0
          1     0     0
          0    .75   .75
         .75    0    .75
         .75   .75    0
         .25   .25   .25];
nlinetype = length(linetype);
ncolors = size(colors,1);
hold on
handle = zeros(num2,1);
for i = 1:num2
    idxline = mod(i-1,nlinetype)+1;  %  cycle through line types
    idxcolor = mod(i-1,ncolors)+1;   %  cycle through line colors
    linespec = linetype{idxline};
    handle(i) = plot(1:num1,matrixdata(i,:),linespec,'color',colors(idxcolor,:));
end;
hold off
axis tight

% Set the x axis limit
xlim = get(gca,'xlim');
inset = .2;
df = diff(xlim)*inset;
set(gca,'xtick',1:num1, 'xticklabel',levels1,'xlim',[xlim(1)-df, xlim(2)+df]);
box on

