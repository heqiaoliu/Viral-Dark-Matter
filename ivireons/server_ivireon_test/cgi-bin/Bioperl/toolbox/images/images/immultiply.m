function Z = immultiply(X,Y)
%IMMULTIPLY Multiply two images or multiply image by constant.
%   Z = IMMULTIPLY(X,Y) multiplies each element in the array X by the
%   corresponding element in the array Y and returns the product in the
%   corresponding element of the output array Z.
%   
%   If X and Y are real numeric arrays with the same size and class, then
%   Z has the same size and class as X.  If X is a numeric array and Y is
%   a scalar double, then Z has the same size and class as X.
%
%   If X is logical and Y is numeric, then Z has the same size and class
%   as Y.  If X is numeric and Y is logical, then Z has the same size and
%   class as X.
%
%   IMMULTIPLY computes each element of Z individually in
%   double-precision floating point.  If X is an integer array, then
%   elements of Z exceeding the range of the integer type are truncated,
%   and fractional values are rounded.
%
%   If X and Y are double arrays, you can use the expression X.*Y instead
%   of this function.
%
%   Performance Note
%   ----------------
%   This function may take advantage of hardware optimization for datatypes
%   uint8, int16, and single to run faster.  Hardware optimization requires
%   that arrays X and Y are of the same size and class.
%
%   Example
%   -------
%   Multiply two uint8 images with the result stored in a uint16 image:
%
%       I = imread('moon.tif');
%       I16 = uint16(I);
%       J = immultiply(I16,I16);
%       figure, imshow(I), figure, imshow(J)
%
%   Scale an image by a constant factor:
%
%       I = imread('moon.tif');
%       J = immultiply(I,0.5);
%       figure, imshow(I), figure, imshow(J)
%
%   See also IMADD, IMCOMPLEMENT, IMDIVIDE, IMLINCOMB, IMSUBTRACT.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.10.4.11 $  $Date: 2009/05/14 16:58:11 $

% MATLAB Compiler pragma: iptgetpref is indirectly invoked by the code that
% loads the Intel IPP library.
%#function iptgetpref

iptchecknargin(2,2,nargin,mfilename);

iptcheckinput(X, {'numeric' 'logical'}, {'real' 'nonsparse'}, mfilename, 'X', 1);
iptcheckinput(Y, {'numeric' 'logical'}, {'real' 'nonsparse'}, mfilename, 'Y', 1);

if islogical(X) || islogical(Y)
    Z = doLogicalMultiplication(X,Y);

elseif numel(Y) == 1 && strcmp(class(Y), 'double')
    Z = doScalarMultiplication(X,Y);

else
    checkForSameSizeAndClass(X, Y, mfilename);
    if isempty(Y) 
        Z = zeros(size(Y), class(Y));
    else
        Z = immultmex(X, Y);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Z = doScalarMultiplication(X,Y)

classX = class(X);
numelInX = numel(X);

useLUTfor16bit = numelInX > 65536 && ...
    (strcmp(classX, 'uint16') || strcmp(classX, 'int16'));
useLUT = strcmp(classX, 'uint8') || useLUTfor16bit;

if useLUT
    % workaround until enhancement g326706 is addressed.
    lut = intmin(classX):intmax(classX);
    lut = Y .* lut;
    Z = intlut(X, lut);

else
    Z = Y * X;
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Z = doLogicalMultiplication(X,Y)

if ~isequal(size(X), size(Y))
    eid = 'Images:immultiply:mismatchedSize';
    error(eid, 'X and Y must be the same size.');
end

if islogical(X) && islogical(Y)
    Z = X & Y;
    
elseif islogical(X) && isnumeric(Y)
    Z = Y;
    Z(~X) = 0;
    
else
    %numeric X, logical Y
    Z = X;
    Z(~Y) = 0;
end
    
