function pos = getAbsoluteHandlePosition(h,ref)
%Return absolute position of specified HG handle object, in pixels.
%  Returns the position of an HG handle object, in pixel units, relative
%  to the top-level figure coordinate reference frame.  The handle can be
%  a deeply-nested descendant of the figure.
%
%  getAbsoluteHandlePosition(h,'figure') returns the same result, while
%  getAbsoluteHandlePosition(h,'screen') returns pixel coordinate relative
%  to the screen.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:39:16 $

% Determine reference frame for return result
if nargin<2
    refIdx = 1; % figure
else
    refIdx = find(strncmpi(ref,{'figure','screen'},numel(ref)));
end

fig = ancestor(h,'figure');
pos = [1 1 0 0];
siz = [];
while 1
    parent = get(h,'Parent');
    pos = pos - [1 1 0 0] + ...
        hgconvertunits(fig,get(h,'Position'),get(h,'Units'), ...
        'pixels',parent);
    if isempty(siz)
        siz = pos(3:4); % record size on first iteration
    end
    if (parent==0) || ((refIdx==1)&&(parent==fig))
        break
    end
    h = parent;
end
pos(3:4) = siz; % copy size from first iteration
if refIdx==2
    pos(1:2)=pos(1:2)+[0 0];
end

