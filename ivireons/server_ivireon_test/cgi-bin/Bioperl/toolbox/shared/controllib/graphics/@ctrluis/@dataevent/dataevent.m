function h = dataevent(hSrc,eventName,data)
%DATAEVENT  Subclass of EVENTDATA to handle mxArray-valued event data.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:16:13 $


% Create class instance
h = ctrluis.dataevent(hSrc,eventName);
h.Data = data;
