function javasend(h,eventname,eventData)

% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:33:32 $

% (workaround) fire event with an eventData object set to the java String eventData


eventDatain = nlutilspack.dataevent(h,eventname,eventData);
h.send(eventname,eventDatain);
