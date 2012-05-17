function u = im2uint16(img, typestr)
%IM2UINT16 Convert image to 16-bit unsigned integers.  
%   IM2UINT16 takes an image as input, and returns an image of class uint16. If
%   the input image is of class uint16, the output image is identical to it. If
%   the input image is not uint16, IM2UINT16 returns the equivalent image of
%   class uint16, rescaling or offsetting the data as necessary.
%
%   I2 = IM2UINT16(I1) converts the intensity image I1 to uint16, rescaling the
%   data if necessary.
%
%   RGB2 = IM2UINT16(RGB1) converts the truecolor image RGB1 to uint16,
%   rescaling the data if necessary.
%
%   X2 = IM2UINT16(X1,'indexed') converts the indexed image X1 to uint16,
%   offsetting the data if necessary.  If X1 is double, then the maximum value
%   of X1 must be 65536 or less.
%
%   I = IM2UINT16(BW) converts the binary image BW to a uint16 intensity image,
%   changing one-valued elements to 65535.
%
%   Class Support
%   -------------
%   Intensity and truecolor images can be uint8, uint16, double, logical,
%   single, or int16. Indexed images can be uint8, uint16, double or
%   logical. Binary input images must be logical. The output image is uint16.
% 
%   Example
%   -------
%       I1 = reshape(linspace(0,1,20),[5 4])
%       I2 = im2uint16(I1)
%
%   See also IM2DOUBLE, IM2INT16, IM2SINGLE, IM2UINT8, UINT16.

%   Copyright 1993-2004 The MathWorks, Inc.  
%   $Revision: 1.12.4.4 $  $Date: 2004/08/10 01:39:56 $

iptchecknargin(1,2,nargin,mfilename);
iptcheckinput(img,{'double','logical','uint8','uint16','int16','single'}, ...
              {'nonsparse'}, mfilename,'IMG', 1);

if nargin == 2
  iptcheckstrs(typestr, {'indexed'}, mfilename, 'type', 2);
end
  
if isa(img, 'uint16')
    u = img; 
   
elseif islogical(img)
    u = uint16(img);
    u(img) = 65535;

elseif isa(img,'int16')
  if nargin == 1
    u = int16touint16(img);
  else
    eid = sprintf('Images:%s:invalidIndexedImage',mfilename);
    msg1 = 'An indexed image can be uint8, uint16, double, single, or ';
    msg2 = 'logical.';
    error(eid,'%s %s',msg1, msg2);
  end

else %double, single, or uint8
    if nargin==1
        % intensity image; call MEX-file
        u = grayto16(img);
        
    else
      if (isa(img, 'uint8'))
        u = uint16(img);
        
      else
        % img is double or single
        if max(img(:)) >= 65537 
          eid = 'Images:im2uint16:tooManyColors';
          msg = 'Too many colors for 16-bit integer storage.';
          error(eid,'%s',msg);
        elseif min(img(:)) < 1
          eid = 'Images:im2uint16:invalidIndex';
          msg = 'Invalid indexed image: an index was less than 1.';
          error(eid,'%s',msg);
        else
          u = uint16(img-1);
        end
      end
    end
end
