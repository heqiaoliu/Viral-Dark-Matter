function Z = imsubtract(X,Y)
%IMSUBTRACT Subtract two images or subtract constant from image.
%   Z = IMSUBTRACT(X,Y) subtracts each element in array Y from the
%   corresponding element in array X and returns the difference in the
%   corresponding element of the output array Z.  X and Y are real,
%   nonsparse, numeric or logical arrays of the same size and class, or Y
%   is a double scalar.  The output array, Z, has the same size and class
%   as X unless X is logical, in which case Z is double. 
%
%   If X is an integer array, then elements of the output that exceed the
%   range of the integer type are truncated, and fractional values are
%   rounded.
%
%   You can use the expression X-Y instead of IMSUBTRACT.
%
%   Example
%   -------
%   Estimate and subtract the background of the rice image:
%       I = imread('rice.png');
%       background = imopen(I,strel('disk',15));
%       Ip = imsubtract(I,background);
%       imshow(I), figure, imshow(Ip,[])
%
%   Subtract a constant value from the rice image:
%       I = imread('rice.png');
%       Iq = imsubtract(I,50);
%       imshow(I), figure, imshow(Iq)
%
%   See also IMADD, IMCOMPLEMENT, IMDIVIDE, IMLINCOMB, IMMULTIPLY.

%   Copyright 1993-2006 The MathWorks, Inc. 
%   $Revision: 1.9.4.9 $  $Date: 2006/05/24 03:31:19 $

iptchecknargin(2, 2, nargin, mfilename);

scalarDoubleY = strcmp(class(Y),'double') && numel(Y) == 1;

if ~islogical(X)
    xAndYSameSizeAndClass = isequal(size(X),size(Y)) && ...
        strcmp(class(X), class(Y));

    if scalarDoubleY || xAndYSameSizeAndClass
        iptcheckinput(X, {'numeric','logical'}, {'real', 'nonsparse'}, ...
            mfilename, 'X', 1);
        if scalarDoubleY
            iptcheckinput(Y, {'double'}, {'real', 'nonsparse'}, ...
                mfilename, 'Y', 2);
        else
            iptcheckinput(Y, {'numeric','logical'}, {'real', 'nonsparse'}, ...
                mfilename, 'Y', 2);
        end
        Z = X - Y;
    else
        eid = sprintf('Images:%s:invalidInput', mfilename);
        error(eid,'X and Y must have the same size and %s', ...
            'class or Y must be a scalar double.');
    end

elseif scalarDoubleY
    Z = imlincomb(1.0, X, -Y, 'double');

else
    Z = imlincomb(1.0, X, -1.0, Y, 'double');
end

