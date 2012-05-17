function val = getPropValue(this,prop)
% Gets the value of the property to display in the list view. This is a derived class implementation.
%
%   Author(s): V. Srinivasan
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/12/01 07:13:35 $

if strcmp(prop,'DTGroup')
    me = fxptui.getexplorer;
    currnode = me.imme.getCurrentTreeNode;
    grp = get(this,prop);
    if ~isa(currnode,'fxptui.blkdgmnode') && ~isempty(grp)
        ds = me.getdataset;
        % get the number of resuls that belong to the same DT group taking into consideration
        % the results that are not visible in the List View.
        numAllResWithSameGrpId = ds.getNumResWithSameGrpId(this);
        if numAllResWithSameGrpId > 1
            grp = [this.DTgroup ' '  '(' num2str(numAllResWithSameGrpId) ')'];
        end
    end
    val = grp;
    return;
else
    val = get(this,prop);
end

% Convert [] value to an empty string for proper display.
if isempty(val)
    val = '';
    return;
end

% Convert numerics and logicals to a string for display.
if isnumeric(val)
    val = num2str(val);
elseif islogical(val)
    if val
        val = 'On';
    else
        val = 'Off';
    end
end


