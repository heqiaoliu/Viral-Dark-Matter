function postserialize(this,olddata)
%POSTSERIALIZE Restore object after serialization

%   Copyright 1984-2007 The MathWorks, Inc.

methods(this,'set_contextmenu','on');
rmappdata(double(this),'PlotChildren');
rmappdata(double(this),'PeerAxes');
if isappdata(double(this),'PlotChildrenProxy')
    rmappdata(double(this),'PlotChildrenProxy');
end
if isappdata(double(this),'PeerAxesProxy')
    rmappdata(double(this),'PeerAxesProxy');
end
