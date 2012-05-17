function [X,map] = readbmp(filename)
%READBMP Read image data from a BMP file.
%   [X,MAP] = READBMP(FILENAME) reads image data from a BMP file.
%   X is a uint8 array that is 2-D for 1-bit, 4-bit, and 8-bit
%   image data.  X is M-by-N-by-3 for 16-bit, 24-bit and 32-bit image data.  
%   MAP is normally an M-by-3 MATLAB colormap, but it may be empty if the
%   BMP file does not contain a colormap.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Steven L. Eddins, June 1996
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/11/15 01:12:59 $

info = imbmpinfo(filename);

map = info.Colormap;
X = readbmpdata(info);
return;





