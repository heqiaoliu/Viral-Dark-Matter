function [figh,axesh] = maineffectsplot(y,group,varargin)
%MAINEFFECTSPLOT Main effects plot for grouped data
%   MAINEFFECTSPLOT(Y,GROUP) displays main effects plots for the group
%   means of matrix Y with groups defined by entries in the cell array
%   GROUP.  Y is a numeric matrix or vector.  If Y is a matrix, the rows
%   represent different observations and the columns represent replications 
%   of each observation.  Each cell of GROUP must contain a grouping 
%   variable that can be a categorical variable, numeric vector, character
%   matrix, or single-column cell array of strings.  GROUP can also be a
%   matrix whose columns represent different grouping variables.  Each
%   grouping variable must have the same number of rows as Y.  The number
%   of grouping variables must be greater than 1.
%
%   The display has one subplot per grouping variable, with each subplot 
%   showing the group means of Y as a function of one grouping variable.
%
%   MAINEFFECTSPLOT(Y,GROUP,'PARAM1',val1,'PARAM2',val2,...) specifies one 
%   or more of the following parameter name/value pairs:
%
%       Parameter    Value
%
%       'varnames'   Grouping variable names in a character matrix or
%                    a cell array of strings, one per grouping variable.
%                    Default names are 'X1', 'X2', ... .
%
%       'statistics' String values which indicate whether the group mean or
%                    the group standard deviation should be plotted. Use 
%                    'mean' or 'std'. The default is 'mean'. If the value 
%                    is 'std', Y is required to have multiple columns.
%
%       'parent'     A handle to the figure window for the plots. The 
%                    default is the current figure window.
%
%   [FIGH, AXESH] = MAINEFFECTSPLOT(...) returns the handle FIGH to the
%   figure window and an array of handles AXESH to the subplot axes.
%
%   Example:
%    Display main effects plots for car weight with two grouping variables,
%    model year and number of cylinders:
%       load carsmall;
%       maineffectsplot(Weight,{Model_Year,Cylinders}, ...
%                  'varnames',{'Model Year', '# of Cylinders'})
%
%   See also: INTERACTIONPLOT, MULTIVARICHART

% Copyright 2006-2009 The MathWorks, Inc.
 

if nargin <2
    error('stats:maineffectsplot:FewInput',...
        'Y and GROUP are required for main effects plot.')
end
 
% Parse parameter/value pairs
args =   {'varnames','statistics','parent'};
defaults = {'','mean',[]};
[eid emsg varnames,statistics,parent] =  internal.stats.getargs(args,defaults,varargin{:});
if ~isempty(eid)
    error(sprintf('stats:maineffectsplot:%s',eid),emsg);
end
 
if ~iscell(varnames) && ~ischar(varnames)
    error('stats:maineffectsplot:BadVarnames', 'VARNAMES must be a character matrix or cell array of strings.')
end
if (~(ischar(varnames) || iscellstr(varnames)))
      error('stats:maineffectsplot:BadVarnames',...
            'VARNAMES must be a character matrix or cell array of strings.');
end

needvarnames = isempty(varnames);  %  whether we need default group variable names
% Character matrix grouping variable names are converted into cell array
if ischar(varnames) && ~needvarnames 
    varnames = cellstr(varnames);
end

if ~ischar(statistics)||(~strcmp(statistics,'mean') && ~strcmp(statistics,'std'))
    error('stats:maineffectsplot:BadStatistics', 'STATISTICS must be ''mean'' or ''std''.')
end
plotstddev = strcmp(statistics,'std');  % determine whether we plot standard deviations
if plotstddev && size(y,2)==1
    error('stats:maineffectsplot:BadYstatistics', 'MAINEFFECTSPLOT for standard deviations requires Y to have multiple columns. ')
end;
 
% Convert the GROUP to cell arrays
if isnumeric(group)      % numerical arrays
    group = num2cell(group,1);
elseif ischar(group)     % character matrix
    group = {cellstr(group)};
elseif ~iscell(group)
    group = {group};     % possible categorical variable
end
 
group = group(:);
ng = length(group);  % number of grouping factors
% Convert numeric cells or character matrix to string cell array
for i = 1:ng
    if ischar(group{i})
        group{i} = cellstr(group{i});
    end
end

% Grouping variable should have the same number of items as Y
if  any(cellfun(@length,group)~=size(y,1))
    error('stats:maineffectsplot:BadGroup',...
        'GROUP must be a cell array or matrix of grouping variables with the same length as Y.')
end;

% Generate default varnames
if  needvarnames
    varnames = strcat({'X'},num2str((1:ng)','%d'));
end;

% The length of varnames should be the same as the number of groups
if ng ~= length(varnames)
    error('stats:maineffectsplot:MismatchVarnameGroup',...
        'The size of VARNAMES mismatches the size of GROUP.')
end;

if plotstddev
    y = nanstd(y,0,2);
end;

if size(y,2) ~= 1 
    y = nanmean(y,2);
end;

% start plotting
H = zeros(ng,1);
if isempty(parent)
    parent = clf;
end;
ylim = zeros(ng,2);
for i = 1:ng
    [maineffect, gname] = grpstats(y,group{i},{'mean','gname'});
    maineffect = nanmean(maineffect,2);
    H(i) = subplot(1,ng,i,'parent',parent);
    plot(H(i),1:length(maineffect),maineffect,'-')
    set(H(i),'xtick',1:length(maineffect))
    set(H(i),'xticklabel',gname)
    xlabel(H(i),varnames{i})
    axis(H(i),'tight');
    % get the y axis limit and find the extreme through the loop
    xlim(H(i),[0.5, length(maineffect)+.5]);
    ylim(i,:) = get(H(i),'ylim');
    xlim([0.5, length(maineffect)+.5]);
end;
% rescale y axis limit and leave some gaps between data and axes
ylimmin = min(ylim(:,1)); ylimmax = max(ylim(:,2));
df = .05*(ylimmax-ylimmin);
set(H,'YLim',[ylimmin-df ylimmax+df]);
 
% only the yticklabel of the left axes is kept
set(H(2:end),'yticklabel','');
if plotstddev
    ylabel(H(1),'standard deviation')
else
    ylabel(H(1), 'mean')
end;
 
 
if nargout>0
    figh  = parent;
end;
 
if nargout>1
    axesh  = H;
end;



