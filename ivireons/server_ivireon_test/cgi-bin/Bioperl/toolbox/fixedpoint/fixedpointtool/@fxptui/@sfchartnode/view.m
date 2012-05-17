function view(h)
%OPENSYSTEM 

%   Author(s): V. Srinivasan
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/20 02:18:29 $

daobj = h.daobject;
if(~isempty(daobj))
    sfobj = fxptui.sfchartnode.getSFChartObject(h.daobject);
    sfobj.view;
end

% [EOF]
