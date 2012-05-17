function Z = imdivide(X,Y)
%IMDIVIDE Divide two images or divide image by constant.
%   Z = IMDIVIDE(X,Y) divides each element in the array X by the
%   corresponding element in array Y and returns the result in the
%   corresponding element of the output array Z.  X and Y are real,
%   nonsparse, numeric or logical arrays with the same size and class, or
%   Y can be a scalar double.  Z has the same size and class as X and Y
%   unless X is logical, in which case Z is double.
%
%   If X is an integer array, elements in the output that exceed the
%   range of integer type are truncated, and fractional values are
%   rounded.
%
%   If X and Y are both double arrays or if one of them is double and the 
%   other is logical, you can use the expression X ./ Y instead of this 
%   function.
%
%   Performance Note
%   ----------------
%   This function may take advantage of hardware optimization for datatypes
%   uint8, int16, and single to run faster.  Hardware optimization requires
%   that arrays X and Y are of the same size and class.
%
%   Example
%   -------
%   Estimate and divide out the background of the rice image:
%
%       I = imread('rice.png');
%       background = imopen(I,strel('disk',15));
%       Ip = imdivide(I,background);
%       figure, imshow(Ip,[])
%
%   Divide an image by a constant factor:
%
%       I = imread('rice.png');
%       J = imdivide(I,2);
%       figure, imshow(I)
%       figure, imshow(J)
%
%   See also IMADD, IMCOMPLEMENT, IMLINCOMB, IMMULTIPLY, IMSUBTRACT. 

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.8.4.13 $  $Date: 2009/05/14 16:58:09 $

% MATLAB Compiler pragma: iptgetpref is indirectly invoked by the code that
% loads the Intel IPP library.
%#function iptgetpref

iptchecknargin(2,2,nargin,mfilename);

if numel(Y) == 1 && strcmp(class(Y),'double')
    Z = doScalarDivision(X,Y);
else
  iptcheckinput(X, {'numeric','logical'}, {'real'}, mfilename, 'X', 1);
  iptcheckinput(Y, {'numeric','logical'}, {'real'}, mfilename, 'Y', 2);
  checkForSameSizeAndClass(X, Y, mfilename);
  
  if isempty(Y)
      Z = zeros(size(Y), class(Y));
  else
      Z = imdivmex(X, Y);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Z = doScalarDivision(X,Y)

classX = class(X);
numelInX = numel(X);

useLUTfor16bit = numelInX > 65536 && ...
    (strcmp(classX, 'uint16') || strcmp(classX, 'int16'));
useLUT = strcmp(classX, 'uint8') || useLUTfor16bit;

if useLUT
     % workaround until enhancement g326706 is addressed.
    lut = intmin(classX):intmax(classX);
    lut = lut / Y;
    Z = intlut(X, lut);

else
    Z = imlincomb(1/Y, X);
end
 
