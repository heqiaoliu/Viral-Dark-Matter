function setplotcolors(h, hp);
%SETPLOTCOLORS  Set colors of plots within axes.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:21:38 $

if (nargin==1)
    hp = h.PlotHandles;
end
c = h.PlotColorOrder;
N = length(hp);
ci = round(linspace(1, size(c, 1), N));
for n = 1:N
    set(hp(n), 'color', c(ci(n), :));
end
