function out = getFigureChildrenList (varargin)
% Arguments:  1. figure handle

out = {};
fig = handle (varargin{1});
if ~ishghandle (fig)
    % out = showErrorDialog (xlate('The first argument must be a figure handle!'));
    out = {{}};
    return;
end
allAxes = findDataAxes (fig);
for i = length(allAxes):-1:1
    out{end+1} = java (handle (allAxes(i)));
    allChildren = graph2dhelper ('get_legendable_children', allAxes(i));
    legendableChildren = getLegendableImages(allAxes(i));
    allChildren = [allChildren(:);legendableChildren(:)];

    for j = 1:length(allChildren)
        out{end+1} = java (handle (allChildren(j)));
    end
    if i > 1
        out{end+1} = 'separator';
    end
end
out = {out};