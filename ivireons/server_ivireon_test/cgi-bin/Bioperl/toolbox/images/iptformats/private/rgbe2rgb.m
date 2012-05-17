function rgb = rgbe2rgb(rgbe)
%rgbe2rgb    Convert RGBE values to floating-point RGB.
%   RGB = RGBE2RGB(RGBE) converts an arry of (R,G,B,E) encoded values to
%   an array of floating-point (R,G,B) high dynamic range values.
%
%   Reference: Reinhard, et al. "High Dynamic Range Imaging." 2006. p. 92.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/10/10 20:46:28 $

dims = size(rgbe);

% Separate the 1-D scanline into separate columns of (R,G,B,E) values.
rgbe = reshape(rgbe, dims(1), 4);

% The formula for transforming (Rm,Gm,Bm,E) into (Rw,Gw,Bw) is given by
% ((Rm + 0.5) / 256) * 2^(E - 128)
rgb = ((single(rgbe(:, 1:3)) + 0.5) ./ 256) .* ...
      repmat(2 .^ (single(rgbe(:,4)) - 128), [1,3]);

% Separate into color planes suitable for storage.
rgb = reshape(rgb, [dims(1), 1, 3]);
