function varargout = rgb2ntsc(varargin)
%RGB2NTSC Convert RGB color values to NTSC color space.
%   YIQMAP = RGB2NTSC(RGBMAP) converts the M-by-3 RGB values in RGBMAP to NTSC
%   colorspace. YIQMAP is an M-by-3 matrix that contains the NTSC luminance
%   (Y) and chrominance (I and Q) color components as columns that are
%   equivalent to the colors in the RGB colormap.
%
%   YIQ = RGB2NTSC(RGB) converts the truecolor image RGB to the equivalent
%   NTSC image YIQ.
%
%   Class Support
%   -------------
%   RGB can be uint8, uint16, int16, double, or single. RGBMAP can be double.
%   The output is double.
%
%   Examples
%   --------
%      I = imread('board.tif');
%      J = rgb2ntsc(I);
%
%      map = jet(256);
%      newmap = rgb2ntsc(map);
%
%   See also NTSC2RGB, RGB2IND, IND2RGB, IND2GRAY.

%   Copyright 1992-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/04/03 03:09:36 $

A = parse_inputs(varargin{:});

T = [1.0 0.956 0.621; 1.0 -0.272 -0.647; 1.0 -1.106 1.703].';
[so(1) so(2) thirdD] = size(A);
if thirdD == 1,% A is RGBMAP, M-by-3 colormap
  A = A/T;
else % A is truecolor image RBG
  A = reshape(reshape(A,so(1)*so(2),thirdD)/T,so(1),so(2),thirdD);
end;

% Output
if nargout < 2,%              YIQMAP = RGB2NTSC(RGBMAP)
  varargout{1} = A;
else 
  eid = sprintf('Images:%s:wrongNumberOfOutputArguments', mfilename);
  msg = sprintf('RGB2NTSC cannot return %d output arguments.', nargout);
  error(eid,'%s',msg);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs
%

function A = parse_inputs(varargin)

iptchecknargin(1,1,nargin,mfilename);

% rgb2ntsc(RGB) or rgb2ntsc(RGBMAP)
A = varargin{1};

%no logical
if islogical(A)
  eid = sprintf('Images:%s:invalidType',mfilename);
  msg = 'A truecolor image cannot be logical.';
  error(eid,'%s',msg);
end


% Check validity of the input parameters. A is converted to double because YIQ
% colorspace can contain negative values.

if ndims(A)==2 
  % Check colormap 
  id = sprintf('Images:%s:invalidColormap',mfilename);
  if ( size(A,2)~=3 || size(A,1) < 1 ) 
    msg = 'RGBMAP must be an M-by-3 array.';
    error(id,'%s',msg);
  end
  if ~isa(A,'double')
    msg = ['MAP should be a double m x 3 array with values in the range [0,1].'...
           'Convert your map to double using IM2DOUBLE.'];
    warning(id,'%s',msg);
    A = im2double(A);
  end
elseif ndims(A)==3
  % Check RGB
  if size(A,3)~=3
    eid = sprintf('Images:%s:invalidTruecolorImage',mfilename);
    msg = 'RGB image must be an M-by-N-by-3 array.';
    error(eid,'%s',msg);
  end
  A = im2double(A);
else
  eid = sprintf('Images:%s:invalidSize',mfilename);
  msg = 'RGB2NTSC only accepts a Mx3 matrix for RGBMAP or a MxNx3 input for RGB.';
  error(eid,'%s',msg);
end
