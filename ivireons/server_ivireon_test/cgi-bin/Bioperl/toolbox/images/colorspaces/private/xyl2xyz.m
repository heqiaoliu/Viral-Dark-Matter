function xyz = xyl2xyz(xyl)
%XYL2XYZ Converts CIE Chromaticity and Luminance to CIEXYZ.
%   xyz = XYL2XYZ(xyl) converts to 1931 CIE Chromaticity and Luminance
%   1931 CIEXYZ tristimulus values scaled to 1.0
%   Both xyz and xyl are n x 3 vectors
%
%   Example:
%       xyz = xyl2xyz([0.3457    0.3585    1.0000])
%       xyz =
%           0.9643    1.0000    0.8251

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision.2 $  $Date: 2008/04/03 03:10:39 $
%   Author:  Scott Gregory, 10/18/02
%   Revised: Toshia McCabe, 12/06/02

% Check input arguments
iptchecknargin(1,1,nargin,'xyl2xyz');
iptcheckinput(xyl,{'double'},{'real','2d','nonsparse','finite'},...
              'xyl2xyz','XYL',1);
if size(xyl,2) ~= 3
    eid = 'Images:xyl2xyz:invalidXylData';
    msg = 'Incorrect number of columns in XYL data.';
    error(eid,'%s',msg);
end

xyz = zeros(size(xyl));
xyz(:,1) = clipdivide(xyl(:,1), xyl(:,2)) .* xyl(:,3);
xyz(:,2) = xyl(:,3);
xyz(:,3) = clipdivide(1 - xyl(:,1) - xyl(:,2), xyl(:,2)) .* xyl(:,3);
