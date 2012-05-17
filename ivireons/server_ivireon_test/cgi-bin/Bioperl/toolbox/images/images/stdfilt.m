function J = stdfilt(varargin)
%STDFILT Local standard deviation of image.
%   J = STDFILT(I) returns the array J, where each output pixel contains the
%   standard deviation value of the 3-by-3 neighborhood around the corresponding
%   pixel in the input image I. I can have any dimension.  The output image J is
%   the same size as the input image I.
%
%   For pixels on the borders of I, STDFILT uses symmetric padding.  In
%   symmetric padding, the values of padding pixels are a mirror reflection
%   of the border pixels in I.
%  
%   J = STDFILT(I,NHOOD) performs standard deviation filtering of the input
%   image I where you specify the neighborhood in NHOOD.  NHOOD is a
%   multidimensional array of zeros and ones where the nonzero elements specify
%   the neighbors.  NHOOD's size must be odd in each dimension. 
%
%   By default, STDFILT uses the neighborhood ones(3). STDFILT determines the
%   center element of the neighborhood by FLOOR((SIZE(NHOOD) + 1)/2). For
%   information about specifying neighborhoods, see Notes.
%
%   Class Support
%   -------------    
%   I can be logical or numeric and must be real and nonsparse.  NHOOD can be
%   logical or numeric and must contain zeros and/or ones.  I and NHOOD can have
%   any dimension. J is double.
%
%   Notes
%   -----    
%   To specify the neighborhoods of various shapes, such as a disk, use the
%   STREL function to create a structuring element object and then use the
%   GETNHOOD function to extract the neighborhood from the structuring element
%   object.
%
%   Examples
%   --------      
%       I = imread('circuit.tif');
%       J = stdfilt(I);
%       imshow(I);
%       figure, imshow(J,[]);
%  
%   See also STD2, RANGEFILT, ENTROPYFILT, STREL, GETNHOOD.

%   Copyright 1993-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2009/11/09 16:24:28 $

[I, h] = ParseInputs(varargin{:});

if (~isa(I,'double'))
    I = double(I);
end


n = sum(h(:));

% If n = 1 then return default J (all zeros).
% Otherwise, calculate standard deviation. The formula for standard deviation
% can be rewritten in terms of the theoretical definition of
% convolution. However, in practise, use correlation in IMFILTER to avoid a
% flipped answer when NHOOD is asymmetric.
% conv1 = imfilter(I.^2,h,'symmetric') / (n-1); 
% conv2 = imfilter(I,h,'symmetric').^2 / (n*(n-1));
% std = sqrt(conv1-conv2).  
% These equations can be further optimized for speed.

n1 = n - 1;
if n ~= 1
  conv1 = imfilter(I.^2, h/n1 , 'symmetric');
  conv2 = imfilter(I, h, 'symmetric').^2 / (n*n1);
  J = sqrt(max((conv1 - conv2),0));
else
  J = zeros(size(I));
end

%%%%%%%%%%%%%%%ParseInputs%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [I,H] = ParseInputs(varargin)

iptchecknargin(1,2,nargin,mfilename);

iptcheckinput(varargin{1},{'numeric','logical'},{'real','nonsparse'}, ...
              mfilename, 'I',1);
I = varargin{1};

if nargin == 2
  iptcheckinput(varargin{2},{'logical','numeric'},{'nonsparse'}, ...
                mfilename,'NHOOD',2);
  H = varargin{2};
  
  eid = sprintf('Images:%s:invalidNeighborhood',mfilename);
  
  % H must contain zeros and/or ones.
  bad_elements = (H ~= 0) & (H ~= 1);
  if any(bad_elements(:))
    msg = 'NHOOD must be a matrix that contains zeros and/or ones.';
    error(eid,'%s',msg);
  end
  
  % H's size must be a factor of 2n-1 (odd).
  sizeH = size(H);
  if any(floor(sizeH/2) == (sizeH/2) )
    msg = 'NHOOD must have a size that is odd in each dimension.';
    error(eid,'%s',msg);
  end

  if ~isa(H,'double')
    H = double(H);
  end

else
  H = ones(3);
end
