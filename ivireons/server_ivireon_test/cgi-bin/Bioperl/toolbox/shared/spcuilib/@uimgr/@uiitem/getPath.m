function s = getPath(h)
%GETPATH Returns path string relative to top node of hierarchy.
%  NOTE: Path does NOT include the name of the very first node
%  in the hierarchy.  That is because the path name is relative
%  to the first node itself; including the name of that node
%  is a mistake and will cause failure.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2007/05/23 19:07:38 $

s=h.Name;
h=h.up; % get parent, if any
while ~isempty(h) && isa(h, 'uimgr.uiitem')
    % If hUp is empty, then h is the "top" node
    % We don't want to add the first name in the path name
    s=sprintf('%s/%s',h.Name,s);
    h=h.up;
end

%{
% Return path NOT including the name of the first node.
s=h.Name;
h=h.up; % get parent, if any
while ~isempty(h)
    % If hUp is empty, then h is the "top" node
    % We don't want to add the first name in the path name
    hUp=h.up;
    if isempty(hUp), break; end
    s=sprintf('%s/%s',h.Name,s);
    h=hUp;
end
%}

% [EOF]
