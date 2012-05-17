function plotEditBehavior = getPlotEditBehavior(type)
%GETPLOTEDITBEHAVIOR Get the plotEditBehavior.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/01/25 22:47:58 $

persistent behaviorObjects;

if isempty(behaviorObjects) || ~isfield(behaviorObjects, type)
    behaviorObjects.(type) = createPlotEditBehavior(type);
end

plotEditBehavior = behaviorObjects.(type);

% -------------------------------------------------------------------------
function h = createPlotEditBehavior(type)

h = hgbehaviorfactory('plotedit');

switch type
    case 'disabled'
        h.EnableMove = false;
        h.EnableSelect = false;
        h.EnableCopy = false;
        h.EnablePaste = false;
        h.EnableDelete = false;
    case 'select'
        h.EnableCopy = false;
        h.EnablePaste = false;
        h.EnableDelete = false;
end

% [EOF]
