function im2 = imcomplement(im)
%IMCOMPLEMENT Complement image.
%   IM2 = IMCOMPLEMENT(IM) computes the complement of the image IM.  IM
%   can be a binary, intensity, or truecolor image.  IM2 has the same class and
%   size as IM.
%
%   In the complement of a binary image, black becomes white and white becomes
%   black.  For example, the complement of this binary image, true(3), is
%   false(3).  In the case of a grayscale or truecolor image, dark areas
%   become lighter and light areas become darker.
%
%   Note
%   ----
%   If IM is double or single, you can use the expression 1-IM instead of this
%   function.  If IM is logical, you can use the expression ~IM instead of
%   this function.
%
%   Example
%   -------
%       I = imread('glass.png');
%       J = imcomplement(I);
%       figure, imshow(I), figure, imshow(J)
%
%   See also IMABSDIFF, IMADD, IMDIVIDE, IMLINCOMB, IMMULTIPLY, IMSUBTRACT. 

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.6 $  $Date: 2009/01/16 11:02:44 $

if isa(im, 'double') && ~isreal(im)
    % Handle double complex case for backward compatibility only.
    % Previous code version errored on complex input for all types 
    % except double.
    im2 = 1 - im;
else
    im2 = imcomplementmex(im);
end

