function scopext(ext)
%SCOPEXT  Register Image Processing Toolbox scope extensions.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/09/18 02:09:31 $

r = ext.add('Tools', 'Image Tool', 'iptscopes.IMToolExport', ...
    'Display the frame in Image Tool');
r.Depends = {'Visuals:Video'};
r = ext.add('Tools', 'Pixel Region', 'iptscopes.PixelRegion', ...
    'Display pixel information for a region in the frame');
r.Depends = {'Visuals:Video'};
r = ext.add('Tools', 'Image Navigation Tools', 'iptscopes.IPTPanZoom', ...
    'Pan or zoom the frame');
r.Depends = {'Visuals:Video'};

% [EOF]
