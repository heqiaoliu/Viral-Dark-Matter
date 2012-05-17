function h = dataevent(hSrc,eventName,data)
%DATAEVENT  Subclass of EVENTDATA to handle mxArray-valued event data.

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:32:39 $

% Create class instance
h = nlutilspack.dataevent(hSrc,eventName);
h.Data = data;
