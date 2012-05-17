function map = lines(n)
%LINES  Color map with the line colors.
%   LINES(M) returns an M-by-3 matrix containing a "ColorOrder"
%   colormap. LINES, by itself, is the same length as the current
%   colormap.
%
%   For example, to set the colormap of the current figure:
%
%       colormap(lines)
%
%   See also HSV, GRAY, PINK, COOL, BONE, COPPER, FLAG, 
%   COLORMAP, RGBPLOT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2009/04/21 03:24:23 $

if nargin<1, n = size(get(gcf,'Colormap'),1); end

c = get(0,'defaultAxesColorOrder');

map = c(rem(0:n-1,size(c,1))+1,:);


