function addBinding(hGroup,varargin)
%ADDBINDING Add a key handler help object to the key handler binding.
%   ADDBINDING(G,B1,B2,...) adds a KeyBinding objects B1, B2, ...,  to the
%   KeyGroup object G.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:47:59 $

N = numel(varargin);
for i=1:N
    if ~isa(varargin{i},'spcwidgets.KeyBinding')
        error('spcwidgets:KeyGroup:InvalidBindingObject', ...
            ['Key binding object must be specified as a handle to ' ...
            'an object of type spcwidgets.KeyBinding'])
    end

    % Connect binding object to parent
    % hGroup is 'up' from hBinding,
    %  must keep new object (hBinding) as 1st arg
    connect(varargin{i},hGroup,'up');
end
if N>0
    % Only reset cache if one or more key bindings added.
    resetCache(hGroup);
end

% Update key help dialog if open (false=do not create if not open)
hKeyMgr = hGroup.up;  % key mgr object is parent of group object
if ~isempty(hKeyMgr)  % empty if hGroup not yet connected to a parent
    show(hKeyMgr,false);
end

% [EOF]
