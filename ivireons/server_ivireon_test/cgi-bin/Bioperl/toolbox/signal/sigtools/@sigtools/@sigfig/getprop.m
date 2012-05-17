function out = getprop(hObj, prop, out)
%GETFCN Get the property from the contained figure

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2009/01/05 18:02:10 $

hFig = get(hObj, 'FigureHandle');

if ~isempty(hFig) && ishghandle(hFig, 'figure')
    out = get(hFig, prop);
end

% [EOF]
