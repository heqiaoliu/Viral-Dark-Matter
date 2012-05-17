function B = applylut(varargin)
%APPLYLUT Neighborhood operations using lookup tables.
%   A = APPLYLUT(BW,LUT) performs a 2-by-2 or 3-by-3 neighborhood
%   operation on binary image BW by using a lookup table (LUT).  LUT is
%   either a 16-element or 512-element vector returned by MAKELUT.  The
%   vector consists of the output values for all possible 2-by-2 or
%   3-by-3 neighborhoods.
%
%   Class Support
%   -------------
%   BW can be numeric or logical, and it must be real,
%   two-dimensional, and nonsparse.
%
%   LUT can be numeric or logical, and it must be a real vector with 16
%   or 512 elements.
%
%   If all the elements of LUT are 0 or 1, then A is logical; otherwise,
%   if all the elements of LUT are integers between 0 and 255, then A is
%   uint8; otherwise, A is double.
%
%   Example
%   -------
%   In this example, you perform erosion using a 2-by-2 neighborhood. An
%   output pixel is "on" only if all four of the input pixel's
%   neighborhood pixels are "on." 
%
%       lut = makelut('sum(x(:)) == 4', 2);
%       BW1 = imread('text.png');
%       BW2 = applylut(BW1,lut);
%       figure, imshow(BW1)
%       figure, imshow(BW2)
%
%   See also MAKELUT.

%   Copyright 1993-2010 The MathWorks, Inc.
%   $Revision: 1.19.4.7 $  $Date: 2010/05/13 17:36:08 $

[A,lut] = ParseInputs(varargin{:});
B = applylutc(A,lut);

%---------------------------------
function [A,LUT] = ParseInputs(varargin)

iptchecknargin(2,2,nargin,mfilename);
iptcheckinput(varargin{1}, {'numeric','logical'},{'real','nonsparse','2d'}, ...
              mfilename, 'A', 1);
iptcheckinput(varargin{2}, {'numeric','logical'},{'real','vector'}, ...
              mfilename, 'LUT', 2); 

% force A to be logical
A = varargin{1};
if ~islogical(A)
    A = A ~= 0;
end

% force LUT to be double
LUT = varargin{2};
if ~isa(LUT,'double')
  LUT = double(LUT);
end


