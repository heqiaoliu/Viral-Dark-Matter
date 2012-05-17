function markers = getMarkers(showStem)
%GETMARKERS Get the markers.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/07/06 20:47:30 $

markers = {'+', 'o', '*', '.', 'x', 'square', 'diamond', ...
    'v', '^', '<', '>', 'pentagram', 'hexagram', 'none'};

if showStem
    markers = [markers {'stem'}];
end

% [EOF]
