function child = getfilteredchild(h, node)
%GETFILTEREDNAME returns child with name tree node name filtered from
%FxptFullName. returns []if H does not belong to NODE

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/05/20 02:18:30 $

child = [];
parent = handle(h.PropertyBag.get('parent'));
if(isempty(parent)); return; end

parentName{1} = [fxptds.getpath(parent.daobject.getFullName) '/'];
parentName{2} = [fxptds.getpath(parent.daobject.getFullName) '.'];

childName = h.FxptFullName;

%strip out parent name
displayName = strrep(childName, parentName{1}, '');
if(isequal(displayName, childName))
  displayName = strrep(childName, parentName{2}, '');
end
if(isequal(childName, displayName)); return; end
%strip out ' : 1' if only one outport exists
if h.has1output
  displayName = displayName(1:findstr(displayName, ':') - 2);
end
%if there is a non-empty name this result belongs to the selected system 
if(~isempty(displayName))
  child = h;
  child.Name = displayName;
end