function setAxesPanMotion(hThis,hAx,style)
% Given an axes, determine the style of pan allowed

% Copyright 2006-2009 The MathWorks, Inc.

if ~all(ishghandle(hAx,'axes'))
    error('MATLAB:graphics:pan:invalidinput','Input must be an axes handle');
end
for i = 1:length(hAx)
    hFig = ancestor(hAx(i),'figure');
    if ~isequal(handle(hThis.FigureHandle),handle(hFig))
        error('MATLAB:graphics:pan:invalidaxes',...
            'Axes must be resident in the same figure as the mode');
    end
end
for i = 1:length(hAx)
    hBehavior = hggetbehavior(hAx(i),'pan');
    hBehavior.Style = style;
end