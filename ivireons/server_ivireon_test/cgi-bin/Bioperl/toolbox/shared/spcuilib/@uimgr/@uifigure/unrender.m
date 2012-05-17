function unrender(h,varargin)
%UNRENDER Unrender graphical rendering of UIMGR.UIFIGURE

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/04/09 19:04:48 $

% Call parent's (uigroup) unrender method.
uigroup_unrender(h,varargin{:});

% Remove the dynamic properties added in uimgr.uifigure/createFigure
delete(findprop(h,'hStatusParent'));
delete(findprop(h,'hVisParent'));

% [EOF]
