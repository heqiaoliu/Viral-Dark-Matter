function postserialize(this,olddata)
%POSTSERIALIZE Restore object after serialization

% Copyright 2003-2004 The MathWorks, Inc.

methods(this,'set_contextmenu','on');
set(this,'ButtonDownFcn',olddata);
rmappdata(double(this),'CBTitle')
rmappdata(double(this),'CBXLabel')
rmappdata(double(this),'CBYLabel')
