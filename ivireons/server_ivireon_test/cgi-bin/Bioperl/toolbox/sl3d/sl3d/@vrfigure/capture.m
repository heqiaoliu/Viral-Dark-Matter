function x = capture(f)
%CAPTURE Capture a virtual reality figure into an RGB image.
%   CAPTURE(F) captures a figure into a TrueColor RGB image that can be 
%   displayed by IMAGE.
%
%   See also IMAGE.

%   Copyright 1998-2009 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2009/12/03 19:10:06 $ $Author: batserve $

% return empty on an empty figure
x = [];
if isempty(f)
  return;
end

% bring the window to front
set(f,'WindowCommand','raise');

% legacy viewer
if f.handle ~= 0
  vrdrawnow;
  xraw = vrsfunc('CaptureFigure', f.handle);
  x = permute(xraw(:,:,end:-1:1), [3 2 1]);

% v5 viewer
else
  vrfig = get(f, 'figure');
  x = capture(vrfig);
end
