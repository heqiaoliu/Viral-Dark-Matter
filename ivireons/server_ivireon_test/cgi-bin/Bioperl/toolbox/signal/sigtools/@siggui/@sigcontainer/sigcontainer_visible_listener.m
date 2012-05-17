function sigcontainer_visible_listener(hObj, varargin)
%SIGCONTAINER_VISIBLE_LISTENER

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.4 $  $Date: 2004/12/26 22:21:58 $

% Set the visible state of all HG object
siggui_visible_listener(hObj, varargin{:});

% Get the children (if any), ignore dialogs
Children = allchild(hObj);
if strcmpi(get(hObj, 'Visible'), 'on'),
    Children = find(Children, '-depth', 0, '-not', '-isa', 'siggui.dialog');
end

for indx = 1:length(Children),
    if isrendered(Children(indx))
        set(Children(indx), 'Visible', hObj.Visible);
    end
end

% [EOF]
