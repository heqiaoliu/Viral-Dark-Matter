function map = prism(m)
%PRISM  Prism color map
%   PRISM(M) returns an M-by-3 matrix containing repeated use
%   of six colors: red, orange, yellow, green, blue, violet.
%   PRISM, by itself, is the same length as the current figure's
%   colormap. If no figure exists, MATLAB creates one.
%
%   PRISM, with no input or output arguments, changes the colors
%   of any line objects in the current axes to the prism colors.
%
%   The colors in the PRISM map are also present, in the same order,
%   in the HSV map.  However, PRISM uses repeated copies of its six
%   colors, whereas HSV varies its colors smoothly.
%
%   See also HSV, FLAG, HOT, COOL, COLORMAP, RGBPLOT, CONTOUR.

%   C. Moler, 8-11-92.
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.9.4.2 $  $Date: 2005/06/21 19:31:42 $

if nargin + nargout == 0
   h = get(gca,'child');
   m = length(h);
elseif nargin == 0
   m = size(get(gcf,'colormap'),1);
end

% R = [red; orange; yellow; green; blue; violet]
R = [1 0 0; 1 1/2 0; 1 1 0; 0 1 0; 0 0 1; 2/3 0 1];

% Generate m/6 vertically stacked copies of r with Kronecker product.
e = ones(ceil(m/6),1);
R = kron(e,R);
R = R(1:m,:);

if nargin + nargout == 0
   % Apply to lines in current axes.
   for k = 1:m
      if strcmp(get(h(k),'type'),'line')
         set(h(k),'color',R(k,:))
      end
   end
else
   map = R;
end
