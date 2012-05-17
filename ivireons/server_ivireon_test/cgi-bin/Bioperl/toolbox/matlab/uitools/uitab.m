function h = uitab(varargin)
% This function is undocumented and will change in a future release

%UITAB Container that will be hosted by a UITABGROUP.
%   UITAB(parent, 'PropertyName1', Value1, 'PropertyName2', Value2, ...) or
%   UITAB('Parent', parent, 'PropertyName1', Value1, 'PropertyName2', Value2, ...)
%   creates a container and adds it to the parent uitabgroup.  A UITAB
%   cannot be created without specifying its parent.  The uitab can have
%   the same child objects as a uipanel.
%
%   HANDLE = UITAB(parent, ...) or
%   HANDLE = UITAB('Parent', parent, ...)
%   creates a tab and returns a handle to it in HANDLE.
%
%   Run GET(HANDLE) to see a list of properties and their current values.
%   Execute SET(HANDLE) to see a list of object properties and their legal
%   values.  
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
%   See also UITABGROUP, UIPANEL.

%   Copyright 2004-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.14 $  $Date: 2010/03/31 18:26:25 $

%   Release: R14SP2. This feature will not work in MATLAB R13 and before.

h = usev0tab(varargin{:});
if isempty(h)
    if (usev0dialog(varargin{:}))
         warning('MATLAB:uitab:MigratingFunction', ...
            'v0 flag is obsoleted for the uitab. To continue using this function, remove v0 as the first argument');
        h = uitab_deprecated(varargin{2:end});
    else
        % Replace this with a call to the documented uitab when ready.
        h = uitab_deprecated(varargin{:});
    end
end
