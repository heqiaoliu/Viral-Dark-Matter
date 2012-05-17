function showOutOfRangeBins(ntx)
% Display out-of-range bin indicators when relevant

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:21:53 $

h = ntx.hXRangeIndicators;

% Update out-of-range underflow
xUnder = (ntx.BinEdges(1) < ntx.XAxisDisplayMin);
if xUnder
    cdata = zeros(1,2,3); % 2 polygons, one RGB triple each
    clr = ntx.ColorUnderflowBar;
    cdata(1,1,:) = clr;
    cdata(1,2,:) = clr;
    set(h(1),'vis','on','cdata',cdata);
else
    set(h(1),'vis','off');
end

% Update out-of-range overflow
xOver = (ntx.BinEdges(end) > ntx.XAxisDisplayMax);
if xOver
    clr = ntx.ColorOverflowBar;
    cdata(1,1,:) = clr;
    cdata(1,2,:) = clr;
    set(h(2),'vis','on','cdata',cdata);
else
    set(h(2),'vis','off');
end
