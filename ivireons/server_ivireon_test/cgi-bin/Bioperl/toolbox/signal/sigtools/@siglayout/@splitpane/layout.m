function layout(this)
%LAYOUT   Layout the container.

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/05 18:01:41 $

pos = getpanelpos(this);

divwidth = get(this, 'DividerWidth');
domwidth = get(this, 'DominantWidth');

switch lower(this.LayoutDirection)
    case 'vertical'
        isvertical = true;
        prop = 'height';
    case 'horizontal'
        isvertical = false;
        prop = 'width';
end

[northwest insetnw] = getminsize(this, 'northwest', prop);
[southeast insetse] = getminsize(this, 'southeast', prop);

if strcmpi(this.Dominant, 'northwest')
    if isvertical
        northwest = max(northwest, domwidth-insetnw(2)-insetnw(4));
        northwest = min(northwest, ...
            pos(4)-southeast-insetse(2)-insetse(4)-insetnw(2)-insetnw(2)-divwidth-1);
        northwestpos = [insetnw(1) ...
            pos(4)-northwest-insetnw(4) ...
            pos(3)-insetnw(1)-insetnw(3) ...
            northwest];
        dividerpos   = [1 ...
            northwestpos(2)-divwidth-insetnw(2) ...
            pos(3) ...
            divwidth];
        southeastpos = [insetse(1) ...
            insetse(2) ...
            pos(3)-insetse(1)-insetse(3) ...
            dividerpos(2)-insetse(2)-insetse(4)-1];
    else
        northwest = max(northwest, domwidth-insetnw(1)-insetnw(3));
        northwest = min(northwest, ...
            pos(3)-southeast-insetse(1)-insetse(3)-insetnw(1)-insetnw(3)-divwidth-1);
        northwestpos = [insetnw(1) ...
            insetnw(2) ...
            northwest ...
            pos(4)-insetnw(2)-insetnw(4)];
        dividerpos   = [northwestpos(1)+northwestpos(3)+insetnw(3)+1 ...
            1 ...
            divwidth ...
            pos(4)];
        southeastpos = [dividerpos(1)+dividerpos(3)+insetse(1) ...
            insetse(2) ...
            pos(3)-dividerpos(1)-dividerpos(3)-insetse(1)-insetse(3) ...
            pos(4)-insetse(2)-insetse(4)];
    end
else
    if isvertical
        southeast = max(southeast, domwidth-insetse(2)-insetse(4));
        southeast = min(southeast, ...
            pos(4)-northwest-insetse(2)-insetse(4)-insetnw(2)-insetnw(2)-divwidth-1);
        southeastpos = [insetse(1) ...
            insetse(2) ...
            pos(3)-insetse(1)-insetse(3) ...
            southeast];
        dividerpos   = [1 ...
            southeastpos(4)+insetse(4)+1 ...
            pos(3) ...
            divwidth];
        northwestpos = [insetnw(1) ...
            dividerpos(2)+divwidth ...
            pos(3) ...
            pos(4)-dividerpos(2)-divwidth];
    else
        southeast = max(southeast, domwidth-insetse(1)-insetse(3));
        southeast = min(southeast, ...
            pos(3)-northwest-insetse(1)-insetse(3)-insetnw(1)-insetnw(3)-divwidth-1);
        southeastpos = [pos(3)-southeast-insetse(3) ...
            insetse(2) ...
            southeast ...
            pos(4)-insetse(2)-insetse(4)];
        dividerpos   = [southeastpos(1)-divwidth-insetse(1) ...
            1 ...
            divwidth ...
            pos(4)];
        northwestpos = [insetnw(1) ...
            insetnw(2) ...
            dividerpos(1)-insetnw(3)-1 ...
            pos(4)-insetnw(2)-insetnw(4)];
    end
end

set(this.DividerHandle, 'Position', dividerpos);

% If autoupdate is off and the manager is in a "drag" condition, return
% early and do not set the component's positions.
if ~this.AutoUpdate && ~isempty(get(this.DividerHandle, 'UserData'))
    return;
end

lclupdate(this, 'northwest', northwestpos);
lclupdate(this, 'southeast', southeastpos);

% -------------------------------------------------------------------------
function lclupdate(this, loc, pos)

% Never allow any position value to be less than 1 to avoid erroring.
pos(pos < 1) = 1;

loc = get(this, loc);

if ~isempty(loc) && ishghandle(loc)
    if strcmpi(get(loc, 'Visible'), 'On')
        set(loc, 'Units', 'Pixels', getpositionproperty(this, loc), pos);
    end
end

% -------------------------------------------------------------------------
function [m i] = getminsize(this, loc, p)

i = [0 0 0 0];

loc = get(this, loc);

ctag = getconstraintstag(this);

% We can assume that whatever we hold is a handle because we have OBD
% listeners removing them from the object when they are deleted.
if isempty(loc)
    m = 0;
elseif strcmpi(get(loc, 'Visible'), 'on')
    if isappdata(loc, ctag)
        hC = getappdata(loc, ctag);
        m = hC.(['minimum' p]);
        i = [hC.LeftInset hC.BottomInset hC.RightInset hC.TopInset];
    else
        m = 0;
    end
else
    
    % If the component is invisible, give it a width/height of zero.
    m = 0;
end

% [EOF]
