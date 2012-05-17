function removeGroup(hKeyMgr,name)
%REMOVEGROUP Remove a key group object from key manager object.
%   REMOVEGROUP(H,NAME) removes key group object with NAME from key
%   manager object H. If named group object is not found in H, no error
%   occurs. If help dialog is open, it is updated.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:48:14 $

% Name of group object is unique - and is checked by addGroup
%
% This is done so removeBinding can rely on Name as a unique index
% into all KeyGroup children.
%
hGroup = find(hKeyMgr,'Name',name);
if ~isempty(hGroup)
    % Remove group object from parent key handler
    disconnect(hGroup);
    
    % Update key-help dialog if open (false=do not create if not open)
    show(hKeyMgr,false);
end

% [EOF]
