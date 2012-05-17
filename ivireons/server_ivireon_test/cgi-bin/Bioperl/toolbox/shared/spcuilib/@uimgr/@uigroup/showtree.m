function showtree(h)
%SHOWTREE Print uimgr tree as a textual hierarchy.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2006/06/27 23:30:49 $

% Show text description of hierarchy
fprintf('Object "%s" of class "%s"\n',h.Name,class(h));
displayEntry(h,1);

% --------------------------------------------------------
function displayEntry(hParent,level)

hChild = hParent.down; % get first child
i=1;
while ~isempty(hChild)
    printGroupInfoString(hChild,level,i);
    if hChild.isGroup
        displayEntry(hChild,level+1);  % descend
    end
    hChild = hChild.right;  % get next child
    i=i+1;
end

% [EOF]
