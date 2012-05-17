function res = isAllowAxesRotate(hThis,hAx)
% Given an axes, determine whether panning is allowed

% Copyright 2006-2009 The MathWorks, Inc.

res = true(length(hAx),1);
if ~all(ishghandle(hAx,'axes'))
    error('MATLAB:graphics:rotate3d:invalidinput','Input must be an axes handle');
end
for i = 1:length(hAx)
    hFig = ancestor(hAx(i),'figure');
    if ~isequal(handle(hThis.FigureHandle),handle(hFig))
        error('MATLAB:graphics:rotate3d:invalidaxes',...
            'Axes must be resident in the same figure as the mode');
    end
end
for i = 1:length(hAx)
    hBehavior = hggetbehavior(hAx(i),'Rotate3d','-peek');
    if ~isempty(hBehavior)
        res(i) = hBehavior.Enable;
    end
end