function setHandlesAndStrings(this,items,strs)
%SETHANDLESANDSTRINGS Set plot handles and string for a legend
%  SetHandlesAndStrings(LEGH,ITEM,STR) replaces the current legend
%  contents with the specified handles and strings.
%
%  See also LEGEND

%   Copyright 1984-2005 The MathWorks, Inc.

enabled = get(this.PropertyListeners,'enable');
set(this.PropertyListeners,'enable','off'); % for string listener
this.PlotChildren = items;
if ~iscell(strs)
  strs = cellstr(strs);
end
this.String = strs;
set(this.PropertyListeners,{'enable'},enabled);

% remove old text and token items
delete(this.ItemText);
delete(this.ItemTokens);

methods(this,'create_legend_items',this.PlotChildren);
legendcolorbarlayout(double(this.Axes),'objectChanged',this);
% update user data
methods(this,'update_userdata');

% add listeners for new plotchild
for k=1:length(items)
  methods(this,'create_plotchild_listeners',handle(items(k)),double(items(k)));
end