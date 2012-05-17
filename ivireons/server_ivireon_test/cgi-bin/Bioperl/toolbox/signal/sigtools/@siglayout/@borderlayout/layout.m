function layout(this)
%LAYOUT   Layout the container.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/06/06 17:06:37 $

pos = getpanelpos(this);

[west  insetw] = getminsize(this, 'west',   'width');
[east  insete] = getminsize(this, 'east',   'width');
[south insets] = getminsize(this, 'south',  'height');
[north insetn] = getminsize(this, 'north',  'height');
[cent  insetc] = getminsize(this, 'center', 'height'); % Just use the insets.

hg = get(this, 'HorizontalGap');
vg = get(this, 'VerticalGap');

% Calculate the southern position based on the insets and the southern
% component's minimum height.
southpos = [...
    1+insets(1) ...
    1+insets(2) ...
    pos(3)-insets(1)-insets(3) ...
    south];

% Calculate the northern position based on the insets and the northern
% component's minimum height.
northpos = [...
    1+insetn(1) ...
    pos(4)-north-insetn(4) ...
    pos(3)-insetn(1)-insetn(3) ...
    north];

% Calculate the "common" part of the east and west components.
ewy = southpos(2)+southpos(4)+insets(4);
if southpos(4) ~= 0, ewy = ewy+vg; end

ewh = northpos(2)-ewy-insetn(2);
if northpos(4) ~= 0, ewh = ewh-vg; end

% Caculate the western position based on the insets, the western
% component's minimum width, the height of the southern component and the y
% of the northern component.
westpos = [...
    insetw(1)+1 ...
    ewy+insetw(2) ...
    west ...
    ewh-insetw(2)-insetw(4)];

% Caculate the eastern position based on the insets, the eastern
% component's minimum width, the height of the southern component and the y
% of the northern component.
eastpos = [...
    pos(3)-east-insete(3)+1 ...
    ewy+insete(2) ...
    east ...
    ewh-insete(2)-insete(4)];

% Calculate the center position based on the area that is "left over" and
% the insets.
centerpos(1) = westpos(1)+westpos(3)+insetw(3)+insetc(1);
if westpos(3) ~= 0, centerpos(1) = centerpos(1)+hg; end

centerpos(2) = southpos(2)+southpos(4)+insetc(2)+insets(4);
if southpos(4) ~= 0, centerpos(2) = centerpos(2)+vg; end

centerpos(3) = eastpos(1)-centerpos(1)-insetc(3)-insete(1);
if eastpos(3) ~= 0, centerpos(3) = centerpos(3)-hg; end

centerpos(4) = northpos(2)-centerpos(2)-insetc(4)-insetn(2);
if northpos(4) ~= 0, centerpos(4) = centerpos(4)-vg; end

lclupdate(this, 'west',   westpos);
lclupdate(this, 'north',  northpos);
lclupdate(this, 'east',   eastpos);
lclupdate(this, 'south',  southpos);
lclupdate(this, 'center', centerpos);

% -------------------------------------------------------------------------
function lclupdate(this, loc, pos)

% Never allow any position value to be less than 1 to avoid erroring.
pos(pos < 1) = 1;

loc = get(this, loc);

if strcmpi(get(loc, 'Visible'), 'On')
    set(loc, 'Units', 'Pixels', getpositionproperty(this, loc), pos);
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
        m = 20;
    end
else
    
    % If the component is invisible, give it a width/height of zero.
    m = 0;
end

% [EOF]
