function u = im2uint8(varargin)
%IM2UINT8 Convert image to 8-bit unsigned integers.
%   IM2UINT8 takes an image as input, and returns an image of class uint8.  If
%   the input image is of class uint8, the output image is identical to it.  If
%   the input image is not uint8, IM2UINT8 returns the equivalent image of class
%   uint8, rescaling or offsetting the data as necessary.
%
%   I2 = IM2UINT8(I1) converts the intensity image I1 to uint8, rescaling the
%   data if necessary.
%
%   RGB2 = IM2UINT8(RGB1) converts the truecolor image RGB1 to uint8, rescaling
%   the data if necessary.
%
%   I = IM2UINT8(BW) converts the binary image BW to a uint8 intensity image,
%   changing one-valued elements to 255.
%
%   X2 = IM2UINT8(X1,'indexed') converts the indexed image X1 to uint8,
%   offsetting the data if necessary. Note that it is not always possible to
%   convert an indexed image to uint8. If X1 is double, then the maximum value
%   of X1 must be 256 or less.  If X1 is uint16, the maximum value of X1 must be
%   255 or less.
%
%   Class Support
%   -------------
%   Intensity and truecolor images can be uint8, uint16, double, logical,
%   single, or int16. Indexed images can be uint8, uint16, double or
%   logical. Binary input images must be logical. The output image is uint8.
%
%   Example
%   -------
%       I1 = reshape(uint16(linspace(0,65535,25)),[5 5])
%       I2 = im2uint8(I1)
%
%   See also IM2DOUBLE, IM2INT16, IM2SINGLE, IM2UINT16, UINT8.

%   Copyright 1993-2004 The MathWorks, Inc.
%   $Revision: 1.20.4.5 $  $Date: 2005/11/15 00:58:23 $

iptchecknargin(1,2,nargin,mfilename);

img = varargin{1};
iptcheckinput(img,{'double','logical','uint8','uint16','single','int16'}, ...
              {'nonsparse'},mfilename,'Image',1);

if nargin == 2
  typestr = varargin{2};
  iptcheckstrs(typestr,{'indexed'},mfilename,'type',2);
end

if isa(img, 'uint8')
    u = img; 
    
elseif isa(img, 'logical')
    u=uint8(img);
    u(img)=255;

else %double, single, uint16, or int16
  if nargin == 1
    if isa(img, 'int16')
      img = int16touint16(img);
    end
  
    % intensity image; call MEX-file
    u = grayto8(img);
  
  else
    if isa(img, 'int16')
      eid = sprintf('Images:%s:invalidIndexedImage',mfilename);
      msg1 = 'An indexed image can be uint8, uint16, double, single, or ';
      msg2 = 'logical.';
      error(eid,'%s %s',msg1, msg2);
    
    elseif isa(img, 'uint16')
      if (max(img(:)) > 255)
        msg = 'Too many colors for 8-bit integer storage.';
        eid = sprintf('Images:%s:tooManyColorsFor8bitStorage',mfilename);
        error(eid,msg);
      else
        u = uint8(img);
      end
    
    else %double or single
      if max(img(:)) >= 257 
        msg = 'Too many colors for 8-bit integer storage.';
        eid = sprintf('Images:%s:tooManyColorsFor8bitStorage',mfilename);
        error(eid,msg);
      elseif min(img(:)) < 1
        msg = 'Invalid indexed image: an index was less than 1.';
        eid = sprintf('Images:%s:invalidIndexedImage',mfilename);
        error(eid,msg);
      else
        u = uint8(img-1);
      end
    end
  end
end
