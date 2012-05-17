function h = idmhit(objtype)
%IDMHIT Determines whether mouse pointer is over an object of a certain type.
%   If the pointer is over an object of type objtype, return the handle
%   to that object, else 0. If not over a figure, return empty.

%   L. Ljung 9-27-94, Adopted from Joe
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $  $Date: 2009/03/23 16:37:50 $

f = get(0,'pointerwindow');
if(f == 0)
    h = [];
    return;
end

ScrSz = get(0,'screensize');
p = get(0,'pointerloc');
% adjust for invisible portion of screen on monitor
p = p-ScrSz(1:2)+[1 1];

set(f,'units','pixels');
pos = get(f,'pos');
x = (p(1)-pos(1))/pos(3);
y = (p(2)-pos(2))/pos(4);
c = findobj(get(f,'children'),'type',objtype,'vis','on');
set(c,'units','norm');
for h = c'
    r = get(h,'pos');
    if((x > r(1)) & (x < (r(1) + r(3))) &...
            (y > r(2)) & (y < (r(2) + r(4))))
        return;
    end
end
h = [];