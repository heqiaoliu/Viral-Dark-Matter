function data = captureForVideo()
%CAPTUREFORVIDEO Capture method to be used with VR To Video block.
%
%   Not to be called directly.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/11/22 22:22:55 $ $Author: batserve $  

ud = get(gcbh, 'UserData');
fig = get(ud.VideoFigure, 'figure');
canvas = fig.canvas;
data = canvas.JCanvas.capture(vr.canvas.getNavPanelReservedHeight(fig.canvas.NavPanel));  %;!! eliminate parameter
