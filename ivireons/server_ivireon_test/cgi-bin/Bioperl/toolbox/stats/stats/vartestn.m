function [p,stats] = vartestn(x,group,displayopt,testtype)
%VARTESTN Test for equal variances across multiple groups.
%   VARTESTN(X) performs Bartlett's test for equal variances for the
%   columns of the matrix X.  This is a test of the null hypothesis
%   that the columns of X come from normal distributions with the same
%   variance, against the alternative that they come from normal
%   distributions with different variances.  The result is a display
%   of a box plot of the groups, and a summary table of statistics.
%
%   VARTESTN(X,GROUP) requires a vector X, and a GROUP argument that is a
%   categorical variable, vector, string array, or cell array of strings
%   with one row for each element of X.  X values corresponding to the same
%   value of GROUP are placed in the same group.  The function tests for
%   equal variances across groups.
%
%   VARTESTN treats NaNs as missing values, and ignores them.
%
%   P = VARTESTN(...) returns the p-value, i.e., the probability of
%   observing the given result, or one more extreme, by chance if the null
%   hypothesis of equal variances is true.  Small values of P cast doubt
%   on the validity of the null hypothesis.
%
%   [P,STATS] = VARTESTN(...) returns a structure with the following
%   fields:
%      'chistat' -- the value of the test statistic
%      'df'      -- the degrees of freedom of the test
%
%   [...] = VARTESTN(X,GROUP,DISPLAYOPT) with DISPLAYOPT='on' (the default)
%   displays the box plot and table.  DISPLAYOPT='off' omits these displays.
%
%   [...] = VARTESTN(X,GROUP,DISPLAYOPT,TESTTYPE) with TESTTYPE='robust'
%   performs Levene's test in place of Bartlett's test.  This is a robust
%   alternative useful when the sample distributions are not normal, and
%   especially when they are prone to outliers.  For this test the STATS
%   output structure has a field named 'fstat' containing the test
%   statistic, and 'df1' and 'df2' containing its numerator and denominator
%   degrees of freedom.  Setting TESTTYPE='classical' performs Bartlett's test.
%
%   Example:  Does the variance of mileage measurements differ
%             significantly from one model year to another?
%      load carsmall
%      vartestn(MPG,Model_Year)
%
%   See also VARTEST, VARTEST2, ANOVA1.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:18:12 $

error(nargchk(1,4,nargin,'struct'));

if (nargin < 2), group = []; end
if (nargin < 3) || isempty(displayopt)
   displayopt = 'on';
elseif ~isequal(displayopt,'on') && ~isequal(displayopt,'off')
   error('stats:vartestn:BadDisplayOpt',...
         'DISPLAYOPT must be ''on'' or ''off''.');
end
dodisplay = isequal(displayopt,'on');
 
if nargin < 4 || isempty(testtype)
   dorobust = false;
else
   if ischar(testtype)
       i = find(strncmpi(testtype,{'robust';'classical'},length(testtype)));
   else
       i = [];
   end
   if isempty(i)
       error('stats:vartestn:BadTestType', ...
           'TESTTYPE must be one of the strings ''robust'' or ''classical''.');
   end       
   dorobust = (i==1);
end

% Error if no data
if isempty(x)
   error('stats:vartestn:NoData','X must not be empty');
end

% Convert group to cell array from character array, make it a column
if (ischar(group) && ~isempty(group)), group = cellstr(group); end
if (size(group, 1) == 1), group = group'; end

% If x is a matrix, convert to vector form.
[n,m] = size(x);
if isempty(group)
   x = x(:);
   group = reshape(repmat((1:m), n, 1), n*m, 1);
elseif isvector(x)
   if numel(group) ~= n
       error('stats:vartestn:InputSizeMismatch',...
             'X and GROUP must have the same length.');
   end
else
   error('stats:vartestn:BadGroup',...
         'Cannot specify a GROUP argument unless X is a vector.');
end

% Get rid of NaN
t = isnan(x);
if any(t)
   x(t) = [];
   group(t,:) = [];
end

% Compute group summary statistics
[igroup,gname] = grp2idx(group);
[gmean,gsem,gcount] = grpstats(x,igroup);
df = gcount-1;                  % group degrees of freedom
gvar = gcount .* gsem.^2;       % group variances
sumdf = sum(df);
if sumdf>0
   vp = sum(df.*gvar) / sumdf;  % pooled variance
else
   vp = NaN;
end
k = length(df);

if dorobust
   % Robust Levene's test
   
   % Remove single-point groups and center each group
   spgroups = find(gcount<2);
   t = ~ismember(igroup,spgroups);
   xc = x(t) - gmean(igroup(t));
   ngroups = length(gcount) - length(spgroups);

   % Now do the anova and extract results from the anova table
   if ngroups>1
      [p,atab] = anova1(xc.^2, igroup,'off');
      B = atab{2,5};                             % F statistic
      Bdf = [atab{2,3}, atab{3,3}];              % both d.f.
   else
      p = NaN;
      B = NaN;
      Bdf = [0, length(xc)-ngroups];
   end
   Bdftable = sprintf('%d, %d',Bdf(1),Bdf(2));   % as text for display
   testname = 'Levene''s statistic';
   statname = 'fstat';
else
   % Classical Bartlett's test
   Bdf = max(0, sum(df>0)-1);
   t = df>0;
   if Bdf>0 && sumdf>0
      B = log(vp) * sum(df) - sum(df(t).*log(gvar(t)));
      C = 1 + (sum(1./df(t)) - 1/sum(df))/(3*Bdf);
      B = B/C;
   else
      B = NaN;
   end
    
   p = chi2pval(B,Bdf);
   Bdftable = Bdf;
   testname = 'Bartlett''s statistic';
   statname = 'chisqstat';
end

if dodisplay
   Table = cell(k+6,4);
   Table(1,:) = {'Group' 'Count' 'Mean' 'Std Dev'};
   Table(2:k+1,1) = gname;
   Table(2:k+1,2) = num2cell(gcount);
   Table(2:k+1,3) = num2cell(gmean);
   Table(2:k+1,4) = num2cell(sqrt(gvar));

   Table{k+2,1} = 'Pooled';
   Table{k+2,2} = sum(gcount);
   Table{k+2,3} = sum(gcount.*gmean) / sum(gcount);
   Table{k+2,4} = sqrt(vp);

   Table{k+3,1} = ' ';
   Table{k+4,1} = testname;
   Table{k+4,2} = B;
   Table{k+5,1} = 'Degrees of freedom';
   Table{k+5,2} = Bdftable;
   Table{k+6,1} = 'p-value';
   Table{k+6,2} = p;

   tblfig = statdisptable(Table, 'Variance Test','Group Summary Table');
   set(tblfig,'tag','table');
end

% Create output stats structure if requested, used by MULTCOMPARE
if (nargout > 1)
   stats = struct(statname,B,'df',Bdf);
end

if ~dodisplay
   return;
end

% Make a new figure, and draw into it explicitly
f1 = figure('pos',get(gcf,'pos') + [0,-200,0,0],'tag','boxplot');
ax = axes('Parent',f1);
boxplot(ax,x,group);
