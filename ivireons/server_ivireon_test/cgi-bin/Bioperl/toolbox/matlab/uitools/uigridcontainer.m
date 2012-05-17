function ghandle = uigridcontainer(varargin)
% This function is undocumented and will change in a future release
    
%UIGRIDCONTAINER   UIGRIDCONTAINER layout container object.
%
%   UIGRIDCONTAINER adds a UIGRIDCONTAINER container object to the
%   current figure.  If no figure exists, one will be
%   created. UIGRIDCONTAINER objects can have the same child objects
%   as UICONTAINER.  In addition, UIGRIDCONTAINER objects can have
%   additional instances of UIGRIDCONTAINER as children. This allows a
%   multiple nested tree of objects rooted at the figure.
%
%   UIGRIDCONTAINER have properties to control child layout in new ways.
%
%   Execute GET(H), where H is a UIGRIDCONTAINER handle, to see a list
%   of UIGRIDCONTAINER object properties and their current
%   values. Execute SET(H) to see a list of UIGRIDCONTAINER object
%   properties and legal property values.
%
%   NOTICE: UIGRIDCONTAINER is experimental and interfaces will probably
%           change in future versions of MATLAB.
% 
%   Example:
%         f = figure;
%         h = uigridcontainer('v0', 'gridsize',[2 1],'parent',f); drawnow;
%         uicontrol('string','OK','callback','disp(''OK'')','parent',h);
%         uicontrol('string','Cancel','callback','disp(''Cancel'')','parent',h);
%
%   See also UICONTAINER, UIPANEL, UIFLOWCONTAINER.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision $  $Date: 2008/06/24 17:15:19 $
%   Built-in function.

% If using the 'v0' switch, use the undocumented uigridcontainer explicitly.
if (usev0dialog(varargin{:}))
    ghandle = builtin('uigridcontainer', varargin{2:end});
else
    % Replace this with a call to the documented uigridcontainer when ready.
    warning('MATLAB:uigridcontainer:MigratingFunction', ...
            ['This undocumented function will be replaced in a future release.\n', ... 
            'To continue to use it, add ''v0'' as its first argument, followed by its normal calling sequence.']);
    ghandle = builtin('uigridcontainer', varargin{:});
end

