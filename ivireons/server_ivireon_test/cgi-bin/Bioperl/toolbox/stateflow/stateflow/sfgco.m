function currentObjects = sfgco
%SFGCO Returns the object handles for most recently selected objects
%     on a Stateflow diagram. If there are multiple selected objects
%     in the diagram, a vector of handles is returned. If there are
%     multiple diagrams with selected objects, the most recent 
%     selection list is returned. If there is no selection list, 
%     then the handle of the diagram most recently clicked is returned.
%     If there is no open diagram which was touched (edited, opened, 
%     pan-zoomed, or clicked-on), then an empty matrix is returned.

% Copyright 2005 The MathWorks, Inc.


currentObjectIds = sf('GetCurrentObject');
if(~isempty(currentObjectIds))
    rt = sfroot;
    currentObjects  = rt.idToHandle(currentObjectIds);
else
    currentObjects = [];
end