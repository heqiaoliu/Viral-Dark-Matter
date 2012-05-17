function h = uimenugroup(varargin)
%UIMENUGROUP Construct a uimenugroup object.
%   UIMENUGROUP(NAME,PLACE,FCN,M1,M2,...) sets the group name, the
%   menu group rendering placement, the user widget creation function,
%   and adds child uimenu objects M1, M2, etc.  Specifying uimenu
%   objects is optional.  If omitted, the placement is set to 0.
%
%   A uimenugroup is a named menu region, within a menu panel,
%   at the top of an HG figure window.
%   Unlike the standard uimenu, the uimenugroup allows definition of
%   named groups of menus, and an order to those named groups.
%
%   With both FCN and child menus M1, M2, ..., specified, the child
%   menus will appear in a new submenu under the group menu created by
%   FCN.  If FCN is not specified, the child menus will appear as a
%   separated group in the existing parent menu.
%
%    FCN may be optionally replaced by a string, indicating the text
%    for the menu label.  In this case, a default menu function is
%    is automatically provided, and the FCN string is used as follows:
%
%         @(hParent,state)uimenu(hParent,'label',FCN)
%
%    This is especially convenient for quickly specifying menu labels
%    on parent submenu, where typically just a label and no callback
%    functions are to be specified.
%
%   Supported constructor arguments:
%    UIMENUGROUP(NAME)
%    UIMENUGROUP(NAME,        C1,C2,...)
%    UIMENUGROUP(NAME,PLACE)
%    UIMENUGROUP(NAME,    FCN)
%    UIMENUGROUP(NAME,PLACE,    C1,C2,...)
%    UIMENUGROUP(NAME,    FCN,C1,C2,...)
%    UIMENUGROUP(NAME,PLACE,FCN)
%    UIMENUGROUP(NAME,PLACE,FCN,C1,C2,...)
%
%   % Example:
%
%       File = uimgr.uimenugroup('File','&File');
%
%     % where the first argument is the name to use for the new UIMgr node,
%     % and the second argument is the string to display on the rendered 
%     % item. 

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2010/01/25 22:47:13 $

% Allow subclass to invoke this directly
h = uimgr.uimenugroup;

h.uigroup(varargin{:});

% [EOF]
