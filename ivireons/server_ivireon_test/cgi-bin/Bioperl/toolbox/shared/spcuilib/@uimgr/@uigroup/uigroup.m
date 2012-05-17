function h = uigroup(varargin)
%UIGROUP Constructor for uigroup object.
%   UIGROUP is the base class for uibuttongroup and uimenugroups, and it
%   contains the basic functionality that allows uimgr button and menu 
%   items to be grouped ordered and removed, added seamlessly.
%
%   UIGROUP(NAME, BUTTON1, BUTTON2,...)
%   UIGROUP(NAME, MENUITEM1, MENUITEM2,...)
%
%   % Example:
%       
%         % create 2 buttons
%         hBut1 = uimgr.uibutton('But1');  
%         hBut2 = uimgr.uibutton('But2');
%
%         % add the buttons to a group
%         hGroup = uimgr.uigroup('buttonGroup', hBut1, hBut2);
%         
%         % Where the first argument is the name of the UIMgr node, and the
%         % second and third arguments are handles to UIMgr button items

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/07/06 20:47:16 $

% Allow subclass to invoke this directly
% Verify that input is a scalar handle
% isscalar is needed in case a string is passed,
%    in which case ishandle() checks each char (!)
if (nargin>0) && isscalar(varargin{1})
    h = varargin{1};
    varargin(1) = [];
else
    h = uimgr.uigroup;
end

% Set uigroup-specific property values
h.isGroup = true;

% If we're being destroyed, disconnect any children
% Only needed if explicit handle management is required
% h.DestroyListener = handle.listener(h, ...
% 	'ObjectBeingDestroyed', @(h,e)removeChildren(h));

% Apply args via superclass constructor
% Do after .isGroup is set, so we can have knowledge of this
h.uiitem(varargin{:});

% [EOF]
