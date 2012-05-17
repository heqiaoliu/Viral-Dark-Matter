function [allOnIdx,v] = findOnItems(h)
% Find index of all 'on' items in group
% Returns with empty if no property is 'on'

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $  $Date: 2009/03/09 19:34:06 $

v_requested = nargout>1;
if v_requested, v={}; end

allOnIdx = []; % all child indices that have prop turned 'on'
i=1;
hChild = h.down; % get first child
while ~isempty(hChild)
    theWidget = hChild.hWidget;  % could be empty if not rendered
    val = get(theWidget,hChild.StateName);
    if strcmp(val,'on')
        allOnIdx(end+1) = i; %#ok
    end
    if v_requested, v{end+1}=val; end %#ok
    hChild = hChild.right;  % get next sibling
    i=i+1;
end

% [EOF]
