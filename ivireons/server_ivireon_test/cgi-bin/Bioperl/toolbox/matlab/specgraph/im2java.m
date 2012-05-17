function jimage = im2java(varargin)
%IM2JAVA Convert image to Java image.
%   JIMAGE = IM2JAVA(I) converts the intensity image I to an instance of
%   the Java image class, java.awt.Image.
%
%   JIMAGE = IM2JAVA(X,MAP) converts the indexed image X with colormap
%   MAP to an instance of the Java image class, java.awt.Image.
%
%   JIMAGE = IM2JAVA(RGB) converts the RGB image RGB to an instance of
%   the Java image class, java.awt.Image.
%
%   Class Support
%   -------------
%   The input image can be of class uint8, uint16, or double.
%
%   Note
%   ----  
%   Java requires uint8 data to create an instance of java.awt.Image.  If the
%   input image is of class uint8, JIMAGE contains the same uint8 data. If the
%   input image is of class double or uint16, im2java makes an equivalent
%   image of class uint8, rescaling or offsetting the data as necessary, and 
%   then converts this uint8 representation to an instance of java.awt.Image.
%
%   Example
%   -------
%   This example reads an image into the MATLAB workspace and then uses
%   im2java to convert it into an instance of the Java image class.
%
%   I = imread('moon.tif');
%   javaImage = im2java(I);
%   icon = javax.swing.ImageIcon(javaImage);
%   label = javax.swing.JLabel(icon);
%   pSize = label.getPreferredSize;
%   f = figure('visible','off');
%   fPos = get(f,'Position');
%   fPos(3:4) = [pSize.width, pSize.height];
%   set(f,'Position',fPos);
%   hLabel= javacomponent(label,[0 0 fPos(3:4)], f);
%   figure(f)

%   Copyright 1984-2005 The MathWorks, Inc.  
%   $Revision: 1.7.4.2 $  $Date: 2005/04/28 19:56:30 $

%   Input-output specs
%   ------------------ 
%   I:    2-D, real, full matrix
%         uint8, uint16, or double
%         logical ok but ignored
%
%   RGB:  3-D, real, full matrix
%         size(RGB,3)==3
%         uint8, uint16, or double
%         logical ok but ignored
%
%   X:    2-D, real, full matrix
%         uint8 or double
%         if isa(X,'uint8'): X <= size(MAP,1)-1
%         if isa(X,'double'): 1 <= X <= size(MAP,1)
%         logical ok but ignored
%         
%   MAP:  2-D, real, full matrix
%         size(MAP,1) <= 256
%         size(MAP,2) == 3
%         double
%         logical ok but ignored
%
%   JIMAGE:  java.awt.Image

% Don't run on platforms with incomplete Java support
error(javachk('awt','IM2JAVA')); %#ok
  
[img,map,method,msg] = ParseInputs(varargin{:});
if ~isempty(msg), error(msg); end %#ok

% Assign function according to method
switch method
  case 'intensity'
    mis = im2mis_intensity(img);
  case 'rgb'
    mis = im2mis_rgb(img);
  case 'indexed'
    mis = im2mis_indexed(img,map);
end    

jimage = java.awt.Toolkit.getDefaultToolkit.createImage(mis);

%----------------------------------------------------
function mis = im2mis_intensity(I)

mis = im2mis_indexed(I,gray(256));


%----------------------------------------------------
function mis = im2mis_rgb(RGB)

mis = im2mis_packed(RGB(:,:,1),RGB(:,:,2),RGB(:,:,3));


%----------------------------------------------------
function mis = im2mis_packed(red,green,blue)

mrows = size(red,1);
ncols = size(red,2);
alpha = 255*ones(mrows,ncols);
packed = bitshift(uint32(alpha),24);
packed = bitor(packed,bitshift(uint32(red),16));
packed = bitor(packed,bitshift(uint32(green),8));
packed = bitor(packed,uint32(blue));
pixels = packed';
mis = java.awt.image.MemoryImageSource(ncols,mrows,pixels(:),0,ncols);


%----------------------------------------------------
function mis = im2mis_indexed(x,map)

[mrows,ncols] = size(x);
map8 = uint8(round(map*255)); % convert color map to uint8
% Instantiate a ColorModel with 8 bits of depth
cm = java.awt.image.IndexColorModel(8,size(map8,1),map8(:,1),map8(:,2),map8(:,3));
xt = x';
mis = java.awt.image.MemoryImageSource(ncols,mrows,cm,xt(:),0,ncols);


%-------------------------------
% Function  ParseInputs
%
function [img, map, method, msg] = ParseInputs(varargin)

% defaults
img = [];
map = [];
method = 'intensity'; 

msg = nargchk(1,2,nargin,'struct');
if ~isempty(msg);
    return;
end
msg = []; % clear out msg so we can define .identifier and .message

img = varargin{1};

if (~islogical(img) && ~isnumeric(img)) || ~isreal(img) || issparse(img) 
  msg.identifier = id('NonRealOrSparseImageData');
  msg.message = 'Image must be real and cannot be sparse.';
  return;
end


switch nargin
  case 1
    % figure out if intensity or RGB
    if ndims(img) == 2
        method = 'intensity';
    elseif ndims(img)==3 && size(img,3)==3
        method = 'rgb';
    else
      msg.identifier = id('InvalidImageData');
      msg.message = 'Image must be an intensity, RGB, or indexed image.';
      return;
    end
    
    % Convert to uint8.
    if isa(img,'double') || isa(img, 'logical')
        img = uint8(img * 255 + 0.5);
        
    elseif isa(img,'uint16')
        img = uint8(bitshift(img, -8));
        
    elseif isa(img, 'uint8')
        % Nothing to do.
        
    else
      msg.identifier = id('InvalidImageClass');
      msg.message = 'Intensity or RGB image must be uint8, uint16, or double.';
      return;
    end
    
  case 2
    
    % indexed image
    method = 'indexed';
    map = varargin{2};
    
    % validate map
    if ~isnumeric(map) || ~isreal(map) || issparse(map) || ~isa(map,'double') 
      msg.identifier = id('InvalidMapType');
      msg.message = 'MAP must be real, double, and cannot be sparse.';
      return;
    end

    if size(map,2) ~= 3
      msg.identifier = id('InvalidMapSize');
      msg.message = 'MAP must be M-by-3 colormap.';
      return;
    end
    
    ncolors = size(map,1);
    if ncolors > 256
      msg.identifier = id('InvalidMapLength');
      msg.message = 'MAP has too many colors for 8-bit integer storage.';
      return;
    end
    
    % validate img 
    if ndims(img) ~= 2
      msg.identifier = id('InvalidImageDimensions');
      msg.message = 'X must have 2 dimensions.';
      return;
    end

    index_out_msg.identifier = id('IndexOutOfRange');
    index_out_msg.message = 'Invalid indexed image: an index falls outside colormap.';
    
    if isa(img,'uint8')
      if max(img(:)) > ncolors-1
        msg = index_out_msg;
        return;
      end            
    elseif isa(img,'double')
      if max(img(:)) > ncolors
        msg = index_out_msg;
        return;
      end            
      if min(img(:)) < 1
        msg.identifier = id('IndexLessThan1');
        msg.message = 'Invalid indexed image: an index was less than 1.';
        return;
      end
      
      img = uint8(img - 1);
    else
      msg.identifier = id('InvalidImageClass');
      msg.message = 'X must be uint8 or double.';
      return;
    end
    
  otherwise
   msg.identifier = id('TooManyInputs');
   msg.message = 'Internal problem: too many input arguments.';
   return;
    
end

function str=id(str)
str = ['MATLAB:im2java:' str];
