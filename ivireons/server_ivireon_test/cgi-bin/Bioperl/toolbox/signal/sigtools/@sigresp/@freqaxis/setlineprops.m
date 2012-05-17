function setlineprops(hObj)
%SETLINEPROPS Set up the properties of the lines, such as datamarkers, visibility, color, style, etc.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:29:00 $

analysisaxis_setlineprops(hObj);

hline = getline(hObj);
for indx = 1:length(hline),
    set(hline(indx), ...
        'Color', getlinecolor(hObj, indx), ...
        'LineStyle', getlinestyle(hObj, indx));
end

% [EOF]

