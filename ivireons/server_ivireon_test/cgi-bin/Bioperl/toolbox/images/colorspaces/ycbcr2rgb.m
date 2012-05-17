function rgb = ycbcr2rgb(varargin)
%YCBCR2RGB Convert YCbCr color values to RGB color space.
%   RGBMAP = YCBCR2RGB(YCBCRMAP) converts the YCbCr values in the colormap
%   YCBCRMAP to the RGB color space. If YCBCRMAP is M-by-3 and contains the
%   YCbCr luminance (Y) and chrominance (Cb and Cr) color values as columns,
%   then RGBMAP is an M-by-3 matrix that contains the red, green, and blue
%   values equivalent to those colors.
%
%   RGB = YCBCR2RGB(YCBCR) converts the YCbCr image to the equivalent
%   truecolor image RGB.
%
%   Class Support
%   -------------
%   If the input is a YCbCr image, it can be of class uint8, uint16, or
%   double; the output image is of the same class as the input image.  If the
%   input is a colormap, the input and output colormaps are both of class
%   double.
%
%   Example
%   -------
%   Convert image from RGB space to YCbCr space and back.
%
%       rgb = imread('board.tif');
%       ycbcr = rgb2ycbcr(rgb);
%       rgb2 = ycbcr2rgb(ycbcr);
%
%   See also NTSC2RGB, RGB2NTSC, RGB2YCBCR.

%   Copyright 1993-2005 The MathWorks, Inc.  
%   $Revision: 1.1.6.1 $  $Date: 2008/04/03 03:09:43 $

%   References:
%     Charles A. Poynton, "A Technical Introduction to Digital Video",
%     John Wiley & Sons, Inc., 1996, p. 175-176
% 
%     Rec. ITU-R BT.601-5, "STUDIO ENCODING PARAMETERS OF DIGITAL TELEVISION
%     FOR STANDARD 4:3 AND WIDE-SCREEN 16:9 ASPECT RATIOS",
%     (1982-1986-1990-1992-1994-1995), Section 3.5.

ycbcr = parse_inputs(varargin{:});

isColormap = false;

%must reshape colormap to be m x n x 3 for transformation
if ndims(ycbcr) == 2 
  isColormap = true;
  colors = size(ycbcr,1);
  ycbcr = reshape(ycbcr, [colors 1 3]);
end

% This matrix comes from a formula in Poynton's, "Introduction to
% Digital Video" (p. 176, equations 9.6 and 9.7). 

% T is from equation 9.6: ycbcr = T * rgb + offset;
T = [65.481 128.553 24.966;...
     -37.797 -74.203 112; ...
     112 -93.786 -18.214];
 
% We can rewrite the equation in terms of ycbcr which is 
% T ^-1 * (ycbcr - offset) = rgb.  This is equation 9.7 in the book.

Tinv = T^-1;
% Tinv = [0.00456621  0.          0.00625893;...
%          0.00456621 -0.00153632 -0.00318811;...
%          0.00456621  0.00791071  0.]
offset = [16;128;128];

% The formula Tinv * (ycbcr - offset) = rgb converts 8-bit YCbCr data to a RGB
% image that is scaled between 0 and one. For each class type (double,uint8,
% uint16), we must calculate scaling factors for Tinv and offset so that
% the input image is scaled between 0 and 255, and so that the output image is
% in the range of the respective class type.

scaleFactor.double.T = 255;       % scale input so it is in range [0 255].
scaleFactor.double.offset = 1;    % output already in range [0 1].
scaleFactor.uint8.T = 255;        % scale output so it is in range [0 255].
scaleFactor.uint8.offset = 255;   % scale output so it is in range [0 255].
scaleFactor.uint16.T = 65535/257; % scale input so it is in range [0 255] 
                                  % (65535/257 = 255), 
                                  % and scale output so it is in range 
                                  % [0 65535].
scaleFactor.uint16.offset = 65535; % scale output so it is in range [0 65535].

% The formula Tinv * (ycbcr - offset) = rgb is rewritten as 
% scaleFactorForT*Tinv*ycbcr - scaleFactorForOffset*Tinv*offset = rgb.  
% To use imlincomb, we rewrite the formula as T * ycbcr - offset, where 
% T and offset are defined below.
classIn = class(ycbcr);
T = scaleFactor.(classIn).T * Tinv;
offset = scaleFactor.(classIn).offset * Tinv * offset;

rgb = zeros(size(ycbcr),classIn);
for p = 1:3
  rgb(:,:,p) = imlincomb(T(p,1),ycbcr(:,:,1),T(p,2),ycbcr(:,:,2), ...
                         T(p,3),ycbcr(:,:,3),-offset(p));
end  

if isColormap
   rgb = reshape(rgb, [colors 3 1]);
end

if isa(rgb,'double')
  rgb = min(max(rgb,0.0),1.0);
end

%%%
%Parse Inputs
%%%
function X = parse_inputs(varargin)

iptchecknargin(1,1,nargin,mfilename);
X = varargin{1};

if ndims(X) == 2
  iptcheckinput(X,{'uint8','uint16','double'},{'real' 'nonempty'}, ...
                mfilename,'MAP',1);
  if (size(X,2) ~=3 || size(X,1) < 1)
    eid = sprintf('Images:%s:invalidSizeForColormap',mfilename);
    error(eid,'MAP must be a m x 3 array.');
  end
elseif ndims(X) == 3
  iptcheckinput(X,{'uint8','uint16','double'},{'real'},mfilename,'RGB',1);
  if (size(X,3) ~=3)
    eid = sprintf('Images:%s:invalidTruecolorImage',mfilename);
    error(eid,'RGB must a m x n x 3 array.');
  end
else
  eid = sprintf('Images:%s:invalidInputSize',mfilename);
  error(eid,'%s only accepts two-dimensional or three-dimensional inputs.', ...
        upper(mfilename));
end
