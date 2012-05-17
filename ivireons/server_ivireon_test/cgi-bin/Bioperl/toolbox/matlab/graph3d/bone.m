function b = bone(m)
%BONE   Gray-scale with a tinge of blue color map
%   BONE(M) returns an M-by-3 matrix containing a "bone" colormap.
%   BONE, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB creates one.
%
%   For example, to reset the colormap of the current figure:
%
%             colormap(bone)
%
%   See also HSV, GRAY, HOT, COOL, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT.

%   C. Moler, 5-11-91, 8-19-92.
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.7.4.2 $  $Date: 2005/06/21 19:30:24 $

if nargin < 1, m = size(get(gcf,'colormap'),1); end
b = (7*gray(m) + fliplr(hot(m)))/8;
