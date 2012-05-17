function c = summer(m)
%SUMMER Shades of green and yellow colormap
%   SUMMER(M) returns an M-by-3 matrix containing a "summer" colormap.
%   SUMMER, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB creates one.
%
%   For example, to reset the colormap of the current figure:
%
%       colormap(summer)
%
%   See also HSV, GRAY, HOT, BONE, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2005/06/21 19:31:45 $

if nargin < 1, m = size(get(gcf,'colormap'),1); end
r = (0:m-1)'/max(m-1,1); 
c = [r .5+r/2 .4*ones(m,1)];
