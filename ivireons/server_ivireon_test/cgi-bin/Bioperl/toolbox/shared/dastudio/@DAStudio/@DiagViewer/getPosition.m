function pos = getPosition(h)
%  getPosition
%
%  Returns the diagnostic viewer's position as a vector:
%
%    [x y width height]
%
%  where (x, y) are the coordinates of the viewer's upper
%  left corner.
%
%  Copyright 2008 The MathWorks, Inc.

  pos = [];
  
  if isa(h.Explorer, 'DAStudio.Explorer')
    pos = h.Explorer.position;
  end

  
end