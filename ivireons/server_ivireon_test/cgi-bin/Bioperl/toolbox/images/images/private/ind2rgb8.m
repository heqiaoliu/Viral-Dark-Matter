function RGB = ind2rgb8(X, CMAP)
%IND2RGB8 Convert an indexed image to a uint8 RGB image.
%
%   RGB = IND2RGB8(X,CMAP) creates a truecolor (RGB) image of class uint8.  X
%   must be uint8, uint16, uint32, or double, and CMAP must be a valid MATLAB
%   colormap.
%
%   Example 
%   -------
%  
%      % Convert the clown image to RGB.
%      load clown
%      RGB = ind2rgb8(X, cmap);
%      image(RGB);
%
%   See also IND2RGB.

%   Copyright 1996-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/09/13 06:55:51 $ 

RGB = ind2rgb8c(X, CMAP);
