function out = setprop(hObj, prop, out)
%SETFCN Set the property in the contained figure

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2009/01/05 18:02:15 $

hFig = get(hObj, 'FigureHandle');

if ~isempty(hFig) && ishghandle(hFig, 'figure')
    set(hFig, prop, out);
end

% [EOF]
