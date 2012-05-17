function javasend(h,eventname,eventData)

% Author(s): 
% Revised:
% Copyright 1986-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:26:39 $

% (workaround) fire event with an eventData object set to the java String eventData


eventDatain = ctrluis.dataevent(h,eventname,eventData);
h.send(eventname,eventDatain);
