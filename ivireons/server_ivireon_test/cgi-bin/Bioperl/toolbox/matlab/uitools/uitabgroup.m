function h = uitabgroup(varargin)
% This function is undocumented and will change in a future release

%UITABGROUP Container to manage tabs.
%   UITABGROUP('PropertyName1, Value1, 'PropertyName2', Value2, ...)
%   creates a container for hosting uitabs.  Tne tabgroup will display
%   and manage the tabs.
%
%   HANDLE = UITABGROUP(...)
%   creates a tabgroup component and returns a handle to it in HANDLE.
%
%   Run GET(HANDLE) to see a list of properties and their current values.
%   Execute SET(HANDLE) to see a list of object properties and their legal
%   values. See the reference guide for detailed property information.
%
%   WARNING: These APIs are subject to change in future releases.
%
%   Example:
%
%   h = uitabgroup(); drawnow;
%   t1 = uitab(h, 'title', 'Panel 1');
%   a = axes('parent', t1); surf(peaks);
%   t2 = uitab(h, 'title', 'Panel 2');
%   closeb = uicontrol(t2, 'String', 'Close Me', ...
%            'Position', [180 200 200 60], 'Call', 'close(gcbf)');
%
%   See also UITAB, UIPANEL

%   Copyright 2004-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.13 $  $Date: 2010/03/31 18:26:26 $

%   Release: R14SP2. This feature will not work in MATLAB R13 and before.

h = usev0tabgroup(varargin{:});
if isempty(h)
    if (usev0dialog(varargin{:}))
        % Replace this with a call to the documented uitabgroup when ready.
        warning('MATLAB:uitabgroup:MigratingFunction', ...
            'v0 flag is obsoleted for the uitabgroup. To continue using this function, remove v0 as the first argument');
        h = uitabgroup_deprecated(varargin{2:end});
    else
        h = uitabgroup_deprecated(varargin{:});
    end
end