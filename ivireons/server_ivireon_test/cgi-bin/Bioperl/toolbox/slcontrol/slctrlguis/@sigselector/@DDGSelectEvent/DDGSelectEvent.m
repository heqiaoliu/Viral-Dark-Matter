function h = DDGSelectEvent(hSrc,eventName,dlg,tc)
%DATAEVENT  Subclass of EVENTDATA to handle mxArray-valued event data.

%  Author(s): Erman Korkut
%  Revised:
% Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/22 04:26:18 $

% Create class instance
h = sigselector.DDGSelectEvent(hSrc,eventName);
h.Dialog = dlg;
h.TC = tc;
