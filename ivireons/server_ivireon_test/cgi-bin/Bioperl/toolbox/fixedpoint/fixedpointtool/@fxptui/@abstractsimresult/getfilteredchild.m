function child = getfilteredchild(h)
%GETFILTEREDCHILD returns child with name tree node name filtered from
%FxptFullName. returns []if H does not belong to NODE

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/05/23 08:01:48 $

child = [];
try
    parent = handle(h.PropertyBag.get('parent'));
    parentName = fxptds.getpath([parent.daobject.getFullName '/']);
catch fpt_exception %#ok<NASGU> % we do not want to throw this error
    % no parent can be found, child would be empty
    % consumes the error
    return;
end

%strip out parent name
displayName = strrep(h.FxptFullName, parentName, '');
if(isequal(h.FxptFullName, displayName)); return; end
blkNameIdx = findstr(displayName, fxptds.getpath(h.daobject.Name));
blkName = displayName(blkNameIdx:end);
%<strip out single port index>
%if pathitem is non-numeric it is not a port index, ignore this case
%if displayname is a ':' this is not a child, ignore this case
%if the blk represents only one result strip the ':' and pathitem
% Find occurrences of digits at the end of the PathItem string. This is
% the port number.
idx = regexp(h.PathItem,'^\d+$'); 
pathItem = h.PathItem(idx:end);
if(~isempty(str2num(pathItem)) && ...
    ~isempty(findstr(displayName, ':'))) %#ok<ST2NM>
  idx = findstr(blkName, ':');
  if(~isempty(idx) && h.has1output)
    displayName = displayName(1:(end - 3));
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
