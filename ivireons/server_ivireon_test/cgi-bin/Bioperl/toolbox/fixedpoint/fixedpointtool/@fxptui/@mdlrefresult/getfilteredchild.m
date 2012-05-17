function child = getfilteredchild(h)
%GETFILTEREDNAME returns child with name tree node name filtered from
%FxptFullName. returns []if H does not belong to NODE

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/05/23 08:01:56 $

child = [];
parent = handle(h.PropertyBag.get('parent'));
parentName = fxptds.getpath([parent.daobject.getFullName '/']);

childName = h.FxptFullName;

%strip out parent name
displayName = strrep(childName, parentName, '');

if(isequal(childName, displayName)); return; end
%cleanup any cruft embedded in the pathitem (mdlrefresults use this)
mdlrefname  =  ['(' fxptds.getpath(h.mdlref.Name) ')'];
displayName = strrep(displayName, mdlrefname, '');

%<strip out single port index>
%if displayname is a ':' this is not a child, ignore this case
%if the blk represents only one result and the pathitem is numeric strip the ':' and pathitem
if(~isempty(findstr(strrep(childName, parentName, ''), ':')))
  idx = findstr(displayName, ':');
  pathItem = displayName(idx+2:end);
  indx = regexp(pathItem,'^\d+$'); 
  PathItem = pathItem(indx:end);
  % str2double returns NaN on a non-numeric string which needs additional checking. We will use str2num instead. 
  % Rip out only the numeric strings (:1). Retain the other signal names.
  if(~isempty(idx) && h.has1output && ~isempty(str2num(PathItem))) %#ok<ST2NM> 
    displayName = displayName(1:idx(end) - 2);
  end
end
stringlength = numel(displayName);
displayName = strtrim(displayName);
%</strip out single port index>

%if there is a non-empty name this result belongs to the selected system
if(stringlength > 0 || (~isempty(displayName) && ~strcmp(displayName(1),  ':')))
  child = h;
  child.Name = displayName;
end

% [EOF]
