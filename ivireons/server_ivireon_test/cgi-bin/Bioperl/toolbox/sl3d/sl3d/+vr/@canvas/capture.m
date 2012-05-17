function value = capture(obj)
%CAPTURE Capture a virtual reality canvas into an RGB image.
%   CAPTURE(OBJ) captures a canvas into a TrueColor RGB image that can be 
%   displayed by IMAGE.
%
%   See also IMAGE.

%   Copyright 1998-2009 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2009/12/03 19:10:05 $ $Author: batserve $

% ensure everything is rendered
drawnow;

% capture
value = typecast(obj.JCanvas.capture(vr.canvas.getNavPanelReservedHeight(obj.NavPanel)), 'uint8');
w = obj.JCanvas.getWidth(); 
h = obj.JCanvas.getHeight() - vr.canvas.getNavPanelReservedHeight(obj.NavPanel);
value = flipdim(permute(reshape(value, 3,w,h), [3 2 1]), 1);
