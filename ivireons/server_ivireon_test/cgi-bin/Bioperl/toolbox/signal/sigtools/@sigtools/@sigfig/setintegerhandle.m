function out = setintegerhandle(hObj, out)
%SETINTEGERHANDLE Set the integer handle of the contained figure

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2009/01/05 18:02:12 $

hFig = get(hObj, 'FigureHandle');

if ~isempty(hFig) && ishghandle(hFig,'figure')
    
    % Convert the figure to a handle so that when we change the
    % IntegerHandle to off we know we will not lose track of it.
    hFig = handle(hFig);
    set(hFig, 'IntegerHandle', out);
    set(hObj, 'FigureHandle', double(hFig));
end

% [EOF]
