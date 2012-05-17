function J = im2single(I, typestr)
%IM2SINGLE Convert image to single precision.     
%   IM2SINGLE takes the image I as input, and returns an image of class
%   single. If I is single, then J is identical to it.  If I is not single, 
%   then IM2SINGLE returns the equivalent image J of class single, rescaling 
%   or offsetting the data as necessary.
%
%   I2 = IM2SINGLE(I1) converts the intensity image I1 to single
%   precision, rescaling the data if necessary.
%
%   RGB2 = IM2SINGLE(RGB1) converts the truecolor image RGB1 to
%   single precision, rescaling the data if necessary.
%
%   I = IM2SINGLE(BW) converts the binary image BW to a single-
%   precision intensity image.
%
%   X2 = IM2SINGLE(X1,'indexed') converts the indexed image X1 to
%   single precision, offsetting the data if necessary.
%
%   Class Support
%   -------------
%   Intensity and truecolor images can be uint8, uint16, double, logical,
%   single, or int16. Indexed images can be uint8, uint16, double or
%   logical. Binary input images must be logical. The output image is single.
% 
%   Example
%   -------
%       I1 = reshape(uint8(linspace(1,255,25)),[5 5])
%       I2 = im2single(I1)
%  
%   See also IM2DOUBLE, IM2INT16, IM2UINT8, IM2UINT16, SINGLE.  

%   Copyright 1993-2006 The MathWorks, Inc.  
%   $Revision: 1.1.8.2 $  $Date: 2006/05/24 03:31:16 $

iptchecknargin(1,2,nargin,mfilename);
iptcheckinput(I,{'double','logical','uint8','uint16','int16','single'}, ...
           {'nonsparse'},mfilename,'I',1);

if nargin == 2
  iptcheckstrs(typestr, {'indexed'}, mfilename, 'type', 2);
end

if isa(I,'double') || isa(I,'logical')
  J = single(I);
  
elseif isa(I,'uint8') || isa(I,'uint16')
  if nargin == 1
    range = getrangefromclass(I);
    J = single(I) / range(2);
  elseif nargin==2
    J = single(I) + 1;
  end
  
elseif isa(I,'int16')
  if nargin == 1
    J = (single(I) + 32768) / 65535;
  else
    eid = sprintf('Images:%s:invalidIndexedImage',mfilename);
    error(eid, 'An indexed image can be uint8, uint16, double, %s', ...
    'single, or logical.');
  end
  
else %single
  J = I;
end
