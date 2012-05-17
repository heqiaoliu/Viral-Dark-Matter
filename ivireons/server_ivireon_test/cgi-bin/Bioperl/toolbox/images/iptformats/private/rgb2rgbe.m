function rgbe = rgb2rgbe(rgb)
%rgb2rgbe  Convert RGB HDR pixels to 8-bit RGBE components.
%
% See Reinhard, et al. "High Dynamic Range Imaging." 2006, p. 92 for
% implementation details.

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:23:00 $

% Reshape the m-by-n-by-3 RGB array into a m*n-by-3 array and find the
% maximum value of each RGB triple.
rgb = reshape(rgb, numel(rgb)/3, 3);
maxRGB = max(rgb, [], 2);

% Encode the pixels.
E = ceil(log2(maxRGB) + 128);
rgbe = uint8([floor((256 * rgb) ./ repmat(2 .^ (E - 128), [1 3])), E]);

% Pixels where max(rgb) < 1e-38 must become (0,0,0,0).
mask = find(maxRGB < 1e-38);
rgbe(mask, :) = repmat([0 0 0 0], [numel(mask), 1]);
