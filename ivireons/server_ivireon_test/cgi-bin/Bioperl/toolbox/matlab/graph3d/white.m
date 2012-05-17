function w = white(m)
%WHITE  All white color map
%   WHITE(M) returns an M-by-3 matrix containing a white colormap.
%   WHITE, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB creates one.
%
%   For example, to reset the colormap of the current figure:
%
%      colormap(white)
%
%   See also HSV, GRAY, HOT, COOL, COPPER, PINK, FLAG, 
%   COLORMAP, RGBPLOT.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 5.8.4.3 $  $Date: 2005/09/12 19:00:05 $

if nargin < 1, m = size(get(gcf,'colormap'),1); end
w = ones(m,3);
