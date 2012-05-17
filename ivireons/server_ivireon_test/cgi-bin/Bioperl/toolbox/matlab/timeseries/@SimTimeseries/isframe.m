function frameflag = isframe(h)
%ISFRAME
%
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2006/06/27 23:06:11 $

% Checks the timeInfo class to see if it defined frames
frameflag = isa(h.TimeInfo,'Simulink.FrameInfo');
