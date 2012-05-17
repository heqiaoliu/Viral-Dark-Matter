function setslider_gcf(h)
%SETSLIDER_GCF  Overloaded slider callback for multipath figure object.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/12/27 20:28:10 $

set(h.FigureHandle,'HandleVisibility','on')
setslider(get(gcf, 'userdata'), gco);
set(h.FigureHandle,'HandleVisibility','callback')
