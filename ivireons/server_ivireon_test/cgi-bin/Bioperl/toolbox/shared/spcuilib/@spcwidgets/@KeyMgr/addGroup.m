function addGroup(hKeyMgr,hGroup)
%ADDGROUP Add a key group object to the key manager.
%   ADDGROUP(H,B) adds a KeyGroup object B to the key manager object H.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:48:09 $

if ~isa(hGroup,'spcwidgets.KeyGroup')
    error('spcwidgets:KeyMgr:InvalidGroup', ...
        ['Group must be specified as a handle to an object of type ' ...
         'spcwidgets.KeyGroup'])
end

% Make sure Name of child is unique
% This is done so removeChild can function with Name as the index
if ~isempty(find(hKeyMgr,'Name',hGroup.Name))
    error('spcwidgets:KeyHandler:DuplicateBindingName', ...
        'Name of KeyHandlerBinding object must be unique');
end

% Connect binding object to parent
% hKey is 'up' from hBinding, must keep new object (hBinding) as 1st arg
connect(hGroup,hKeyMgr,'up');

% Update key-help dialog if open (false=do not create if not open)
show(hKeyMgr,false);

% [EOF]
