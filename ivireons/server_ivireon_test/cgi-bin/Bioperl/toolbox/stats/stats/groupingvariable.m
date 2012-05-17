%GROUPINGVARIABLE Grouping variable
%  A grouping variable G is used to define groups in a data set. Each
%  element of G specifies the group to which the corresponding row in the
%  data set belongs. G can be a categorical vector, a numeric vector, a
%  logical vector, a cell vector of strings, or a character matrix with
%  each row representing a group label.
%  
%  Each level of a grouping variable defines a group, the levels and the
%  order of levels are decided as follows:
%
%  * For a categorical vector G, the set of group levels and their order
%    match the output of the GETLABELS(G) method. 
%  * For a numeric vector or a logical vector G, the set of group levels is
%    the distinct values of G. The order is the sorted order of the unique
%    values.
%  * For a cell vector of strings or a character matrix G, the set of group
%    levels is the distinct strings of G. The order for strings is the
%    order of their first appearance in G.
%
%  Some functions such as GRPSTATS, can take a cell array of several
%  grouping variables (such as {G1 G2 G3}) to group the observations in the
%  data set by each combination of the grouping variable levels. The order
%  is decided first by the order of the first grouping variables, then by
%  the order of the second grouping variable, and so on.
%  
%  Examples:
%      % Group data according the combinations of two grouping variables
%      % and compute the mean for each group. 
%      load carsmall;
%      [gn,m] = grpstats(Weight,{Origin,Model_Year},{'gname','mean'});
% 
% See also grp2idx, grpstats.