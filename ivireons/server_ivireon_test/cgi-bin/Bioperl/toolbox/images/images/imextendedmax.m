function BW = imextendedmax(varargin)
%IMEXTENDEDMAX Extended-maxima transform.
%   BW = IMEXTENDEDMAX(I,H) computes the extended-maxima transform, which
%   is the regional maxima of the H-maxima transform.  H is a nonnegative
%   scalar.
%
%   Regional maxima are connected components of pixels with the same
%   intensity value, t, whose external boundary pixels all have a value
%   less than t.
%
%   By default, IMEXTENDEDMAX uses 8-connected neighborhoods for 2-D
%   images and 26-connected neighborhoods for 3-D neighborhoods.  For
%   higher dimensions, IMEXTENDEDMAX uses CONNDEF(NDIMS(I),'maximal'). 
%
%   BW = IMEXTENDEDMAX(I,H,CONN) computes the extended maxima transform,
%   where CONN specifies the connectivity.  CONN may have the following
%   scalar values:   
%
%       4     two-dimensional four-connected neighborhood
%       8     two-dimensional eight-connected neighborhood
%       6     three-dimensional six-connected neighborhood
%       18    three-dimensional 18-connected neighborhood
%       26    three-dimensional 26-connected neighborhood
%
%   Connectivity may be defined in a more general way for any dimension by
%   using for CONN a 3-by-3-by- ... -by-3 matrix of 0s and 1s.  The 1-valued
%   elements define neighborhood locations relative to the center element of
%   CONN.  CONN must be symmetric about its center element.
%   
%   Class support
%   -------------
%   I can be of any nonsparse numeric class and any dimension.  BW has
%   the same size as I and is always logical.
%
%   Example
%   -------
%       I = imread('glass.png');
%       BW = imextendedmax(I,80);
%       figure, imshow(I), figure, imshow(BW)
%   
%   See also CONNDEF, IMEXTENDEDMIN, IMHMAX, IMRECONSTRUCT,
%   IMREGIONALMAX.

%   Copyright 1993-2005 The MathWorks, Inc.
%   $Revision: 1.7.4.5 $  $Date: 2005/03/31 16:31:25 $

% Testing notes
% -------------
% I       - N-D, real, full
%         - empty ok
%         - Inf ok
%         - NaNs not allowed
%
% h       - Numeric scalar; nonnegative; real
%         - Inf ok (doesn't make much sense, though)
%         - NaNs not allowed
%
% conn    - valid connectivity specifier

[I,h,conn] = ParseInputs(varargin{:});

BW = imregionalmax(imhmax(I,h,conn),conn);

%%%
%%% ParseInputs
%%%
function [I,h,conn] = ParseInputs(varargin)

iptchecknargin(2,3,nargin,mfilename);

I = varargin{1};
iptcheckinput(I, {'numeric'}, {'real' 'nonsparse'}, mfilename, 'I', 1);

h = varargin{2};
iptcheckinput(h, {'numeric'}, {'real' 'scalar' 'nonnegative'}, mfilename, 'H', 2);
h = double(h);

if nargin < 3
    conn = conndef(ndims(I),'maximal');
else
    conn = varargin{3};
    iptcheckconn(conn, mfilename, 'CONN', 3);
end
