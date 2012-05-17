function hWidget = findwidget(h,varargin)
%FINDWIDGET Return handle to rendered widget of named child.
%   FINDWIDGET(H,NAME) returns the widget handle of the named child.
%   If name is not found, empty is returned.
%   See FINDCHILD for specification of NAME.
%
% See also FINDCHILD

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/05/09 23:40:08 $

% Note: if hChild is empty, hWidget must be empty without error
%  hChild may be empty if child is not found.

hChild = findchild(h,varargin{:});
if isempty(hChild)
    hWidget=[];
else
    hWidget = hChild.hWidget;
end

% [EOF]
