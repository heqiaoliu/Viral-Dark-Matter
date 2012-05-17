function varargout = ntsc2rgb(varargin)
%NTSC2RGB Convert NTSC color values to RGB color space.
%   RGBMAP = NTSC2RGB(YIQMAP) converts the M-by-3 NTSC
%   (television) values in the colormap YIQMAP to RGB color
%   space. If YIQMAP is M-by-3 and contains the NTSC luminance
%   (Y) and chrominance (I and Q) color components as columns,
%   then RGBMAP is an M-by-3 matrix that contains the red, green,
%   and blue values equivalent to those colors.  Both RGBMAP and
%   YIQMAP contain intensities in the range 0.0 to 1.0. The
%   intensity 0.0 corresponds to the absence of the component,
%   while the intensity 1.0 corresponds to full saturation of the
%   component.
%
%   RGB = NTSC2RGB(YIQ) converts the NTSC image YIQ to the
%   equivalent truecolor image RGB.
%
%   Class Support
%   -------------
%   The input image or colormap must be of class double. The
%   output is of class double.
%
%   Example
%   -------
%   Convert RGB image to NTSC and back.
%
%       RGB = imread('board.tif');
%       NTSC = rgb2ntsc(RGB);
%       RGB2 = ntsc2rgb(NTSC);
%
%   See also RGB2NTSC, RGB2IND, IND2RGB, IND2GRAY.

%   Copyright 1992-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/04/03 03:09:35 $

A = parse_inputs(varargin{:});

T = [1.0 0.956 0.621; 1.0 -0.272 -0.647; 1.0 -1.106 1.703];

threeD = (ndims(A)==3); % Determine if input includes a 3-D array.

if threeD % A is YIQ, M-by-N-by-3
  m = size(A,1);
  n = size(A,2);
  A = reshape(A(:),m*n,3)*T';
  % Make sure the rgb values are between 0.0 and 1.0
  A = max(0,A);
  d = find(any(A'>1));
  A(d,:) = A(d,:)./(max(A(d,:)')'*ones(1,3));
  A = reshape(A,m,n,3);
else % A is YIQMAP, M-by-3
  A = A*T';
  % Make sure the rgb values are between 0.0 and 1.0
  A = max(0,A);
  d = find(any(A'>1));
  A(d,:) = A(d,:)./(max(A(d,:)')'*ones(1,3));
end

% Output
if nargout < 2,%              RGBMAP = NTSC2RGB(YIQMAP)
  varargout{1} = A;
else 
  eid = sprintf('Images:%s:wrongNumberOfOutputArguments', mfilename);
  msg = sprintf('NTSC2RGB cannot return %d output arguments.', nargout);
  error(eid,'%s',msg);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs
%

function A = parse_inputs(varargin)

iptchecknargin(1,1,nargin,mfilename);

% ntsc2rgb(YIQ) or ntsc2rgb(YIQMAP)
A = varargin{1};

%no logical
if islogical(A)
  eid = sprintf('Images:%s:invalidType',mfilename);
  msg = 'An NTSC image cannot be logical.';
  error(eid,'%s',msg);
end


% Check validity of the input parameters. A is converted to double because YIQ
% colorspace can contain negative values.

if ndims(A)==2 
  % Check colormap 
  id = sprintf('Images:%s:invalidYIQMAP',mfilename);
  if ( size(A,2)~=3 || size(A,1) < 1 ) 
    msg = 'YIQMAP must be a M-by-3 array.';
    error(id,'%s',msg);
  end
  if ~isa(A,'double')
    msg = ['YIQMAP should be a double Mx3 array with values in the range [0,1].'...
           'Convert your map to double using IM2DOUBLE.'];
    warning(id,'%s',msg);
    A = im2double(A);
  end
elseif ndims(A)==3 && size(A,3)==3
  % Check YIQ

  A = im2double(A);
  
else
  eid = sprintf('Images:%s:invalidSize',mfilename);
  msg = 'NTSC2RGB only accepts a Mx3 matrix for YIQMAP or a MxNx3 input for YIQ.';
  error(eid,'%s',msg);
end
