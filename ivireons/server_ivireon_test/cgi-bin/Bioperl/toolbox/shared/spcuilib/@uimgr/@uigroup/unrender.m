function unrender(h,varargin)
%UNRENDER Unrender UIGroup object.
%  Unrenders group widget and widgets of all children.
%   UNRENDER(H) unrenders group widget and widgets of all children.
%   UNRENDER(H,theName) unrenders the named child of H.

%   UNRENDER(H,parentRemovingAllChildren) set to TRUE if this call is
%   unrendering this group as just one child of an entire group in the
%   parent.  This is for efficiency and stops side-effects from being
%   computed.

% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2007/04/09 19:04:50 $

% Call shared method so that subclasses of uimgr.uigroup (e.g.,
% uimgr.uifigure) can call same method
uigroup_unrender(h,varargin{:});

% [EOF]
