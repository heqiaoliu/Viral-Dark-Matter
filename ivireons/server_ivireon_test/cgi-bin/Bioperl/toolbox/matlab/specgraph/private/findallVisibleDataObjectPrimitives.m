function allVisPrims = findallVisibleDataObjectPrimitives(hList)
% returns a list of all visible primitives that are descendants of DataObjects
%under (and including) the given handles.  

% NOTE:
%   * In general, axes decorations are ignored.  To obtain these primitives
%   you must provide the handle to the DecorationContainer directly.
%   * For text, the composite text object is returned, not the primitive
%   within it because only the composite provides Extent information,

%   Copyright 2010 The MathWorks, Inc.

allVisPrims = hg2.Group.empty;
if isempty(hList)
    return
end

hList = hList(:);

% extract visible primitives from input list
isPrim = isPrimitive(hList);
isVis = isVisible(hList);
allVisPrims = hList(isPrim & isVis);

nonPrimList = hList(~isPrim);
trueChildren = hg2.Group.empty;
for i = 1:length(nonPrimList)
    % if object is an axes, only look in the ChildContainer
    if isa(nonPrimList(i),'matlab.graphics.axis.Axes')
        nonPrimList(i) = nonPrimList(i).ChildContainer;
    end
    
    % get true children and recurse
    trueChildren = [trueChildren; hgGetTrueChildren(nonPrimList(i))]; %#ok<AGROW>
end

allVisPrims = [allVisPrims; findallVisibleDataObjectPrimitives(trueChildren)];

function tf = isPrimitive(h)

tf = false(size(h));
primClasses = {'matlab.graphics.primitive.world.Line',...
                       'matlab.graphics.primitive.world.Marker',...
                       'matlab.graphics.primitive.world.Quadrilateral',...
                       'matlab.graphics.primitive.world.Triangle',...
                       'hg2.Text'};
for i = 1:length(h)
    tf(i) = ismember(class(h(i)),primClasses);
end

function tf = isVisible(h)

tf = false(size(h));
for i = 1:length(h)
    tf(i) = isprop(h(i),'Visible') && strcmp(h(i).Visible,'on');
end
