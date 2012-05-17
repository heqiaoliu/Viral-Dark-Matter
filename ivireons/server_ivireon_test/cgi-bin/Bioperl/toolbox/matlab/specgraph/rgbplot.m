function rgbplot(map)
%RGBPLOT Plot color map.
%   RGBPLOT(MAP) plots a color map, i.e. an m-by-3 matrix which
%   is appropriate input for COLORMAP. The three columns of the
%   colormap matrix are plotted in red, green, and blue lines.
%
%   See also COLORMAP, RGB2HSV.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 5.7.4.2 $  $Date: 2005/12/15 20:55:16 $

if size(map,2) ~= 3
    error('MATLAB:rgbplot:InvalidColormapMatrix', 'Must be a 3-column colormap matrix.');
end
m = 1:size(map,1);
plot(m,map(:,1),'r-',m,map(:,2),'g-',m,map(:,3),'b-');
