function im=dither(varargin)
%DITHER Convert image using dithering.
%   X = DITHER(RGB,MAP) creates an indexed image approximation of the RGB image
%   in the array RGB by dithering the colors in colormap MAP.  MAP cannot have
%   more than 65536 colors.
%
%   X = DITHER(RGB,MAP,Qm,Qe) creates an indexed image from RGB, specifying the
%   parameters Qm and Qe. Qm specifies the number of quantization bits to use
%   along each color axis for the inverse color map, and Qe specifies the number
%   of quantization bits to use for the color space error calculations.  If Qe <
%   Qm, dithering cannot be performed and an undithered indexed image is
%   returned in X.  If you omit these parameters, DITHER uses the default values
%   Qm = 5, Qe = 8.
%
%   BW = DITHER(I) converts the intensity image in the matrix I to the binary
%   image BW by dithering.
%
%   Class Support
%   -------------        
%   RGB can be uint8, uint16, single, or double. I can be uint8, uint16, int16,
%   single, or double. All other input arguments must be double. BW is
%   logical. X is uint8 if it is an indexed image with 256 or fewer colors;
%   otherwise, it is uint16.
%
%   Example
%   -------
%   Convert intensity image to binary using dithering.
%
%       RGB = imread('street1.jpg');
%       G = RGB(:,:,2);
%       BW = dither(G);
%       figure, imagesc(G), colormap(gray)
%       figure, image(BW), colormap(gray(2))  
%
%   See also RGB2IND.

%   Copyright 1993-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/26 14:28:57 $

%   References: 
%      R. W. Floyd and L. Steinberg, "An Adaptive Algorithm for
%         Spatial Gray Scale," International Symposium Digest of Technical
%         Papers, Society for Information Displays, 36.  1975.
%      Spencer W. Thomas, "Efficient Inverse Color Map Computation",
%         Graphics Gems II, (ed. James Arvo), Academic Press: Boston.
%         1991. (includes source code)

[X,m,qm,qe] = parse_inputs(varargin{:});

if ndims(X)==2,% Convert intensity image to binary by dithering
  im = logical(ditherc(X,m,qm,qe));
  map = 2;
else % Create an indexed image from RGB 
  im = ditherc(X,m,qm,qe);
  map = m;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs
%

function [X,m,qm,qe] = parse_inputs(varargin)
% Outputs:  X  the input RGB (3D) or intensity image (2D)
%           m  colormap (:,3)
%           qm number of quantization bits for colormap
%           qe number of quantization bits for errors, qe>qm

error(nargchk(1,4,nargin,'struct'));

% Default values:
qm = 5;
qe = 8;

switch nargin
case 1,                        % dither(I)
  X = varargin{1};
  m = gray(2); 
case 2,                        % dither(RGB,m)
  X = varargin{1};
  m = varargin{2};
case 4,                        % dither(RGB,m,qm,qe)
  X = varargin{1};
  m = varargin{2};
  qm = varargin{3};
  qe = varargin{4};
otherwise,
  eid = sprintf('MATLAB:%s:invalidInput',mfilename);
  error(eid,'Invalid input arguments in function %s.',mfilename);
end

% Check validity of the input parameters 
if ((ndims(X)==3) && (nargin==1))
  eid = sprintf('MATLAB:%s:imageMustBe2D',mfilename);  
  error(eid,'DITHER(I): the intensity image I has to be a two-dimensional array.');
elseif ((ndims(X)==2) && (nargin==2))
  eid = sprintf('MATLAB:%s:imageMustBe3D',mfilename);  
  error(eid,'DITHER(RGB,map): the RGB image has to be a three-dimensional array.');
end

if isa(X,'uint16') || isfloat(X)
    X = grayto8(X);    
elseif isa(X,'int16')
    
    % equivalent to int16touint16
    X = reshape(typecast(X(:),'uint16'),size(X));
    X = bitxor(X,2^15);
    
    X = grayto8(X);
end
 
if ((size(m,2) ~= 3) || (size(m,1)==1) || (ndims(m)>2))
  eid = sprintf('MATLAB:%s:colormapMustBe2D',mfilename);  
  error(eid,['In function %s, input colormap has to be a ',...
             '2D array with at least 2 rows and exactly 3 columns.'], mfilename);
end
