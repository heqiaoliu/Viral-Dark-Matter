function h = uirecentitemslist(varargin)
%UIRECENTITEMSLIST Constructor for RecentItemsList object.
%    UIRECENTITEMSLIST(GROUP,PREF,PLACE) specifies GROUP for the
%    RecentFilesList, and doubles as the NAME for the underlying uiitem.
%    PREF is optional and specifies the preference name for RecentFilesList
%    object.  PLACE specifies placement for uiitem.
%
%    Syntax supported include:
%    UIRECENTITEMSLIST(GROUP)
%    UIRECENTITEMSLIST(GROUP,PREF)
%    UIRECENTITEMSLIST(GROUP,PLACE)
%    UIRECENTITEMSLIST(GROUP,PREF,PLACE)
%
%   % Example:
%
%       mRecentSrcsRFL = uimgr.uirecentitemslist('MPlayNodeName',...
%       'RSPreferences');
%   
%     % where the first argument is the name to use for the new UIMgr node, 
%     % and the second argument is the preference name for RecentFilesList
%     % object.

% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2009/09/09 21:29:48 $

% Allow subclass to invoke this directly
h = uimgr.uirecentitemslist;

% State property name (none for this widget)
h.StateName = '';

[rflArgs,uiArgs] = local_ParseArgs(h,varargin);

% Fill in uiitem prop/value pairs
% uiitem takes (NAME,PLACE,FCN) as args
% We do NOT pass FCN, since we fill it in ourselves below
% We also prune out the optional 2nd name passed in to uirecentitemslist,
% since that is not what uiitem expects.
%
% Note that NAME serves the dual-role of being the unique name to the
% RecentFilesList repository, AND it is the name for the HGUI object here.
%
h.uiitem(uiArgs{:});

% Create the RecentFilesList repository object
h.recentFiles = spcwidgets.RecentFilesList(rflArgs{:});

% We set a special WidgetFcn that invokes the connect method
% on this object, which in turn invokes ConnectMenu on the
% RecentFilesList object
h.WidgetFcn = @(hThis,state)connect(hThis);

% We don't connect the menu here.
% That's done during render().

% Add a destructor to avoid the udd deletion issues
spcuddutils.addDestructor(h);



% ---------------------------------------------
function [rflArgs,uiArgs] = local_ParseArgs(h,args) %#ok
%
% rfl:RecentFilesList, ui:uiitem
%
% UI(GROUP)            -> rflArgs={GROUP},      uiArgs={GROUP}
% UI(GROUP,PREF)       -> rflArgs={GROUP,PREF}, uiArgs={GROUP}
% UI(GROUP,PLACE)      -> rflArgs={GROUP},      uiArgs={GROUP,PLACE}
% UI(GROUP,PREF,PLACE) -> rflArgs={GROUP,PREF}, uiArgs={GROUP,PLACE}
%
% where
%    GROUP is both the name of the recent files list repository,
%    and the name for the uiitem.
%
% Note that FCN is not allowed; it is automatically filled by
% the constructor above.

nargs = numel(args);
error(nargchk(1,3,nargs, 'struct'));

% UI(GROUP,...)
rflArgs = args(1);    % get/keep as cell, {GROUP,...}
uiArgs = args(1); % {NAME,...)
if nargs>1
    % UI(GROUP,PLACE)
    % UI(GROUP,PREF,...)
    if isnumeric(args{2})  % numeric arg implies PLACE passed
        uiArgs(2) = args(2); % get/keep as cell, {NAME,PLACE}
        if nargs>2
            error('uimgr:WidgetFcnNotAllowed', ...
                'Cannot pass in FCN to UIRECENTITEMSLIST');
        end
    else
        rflArgs(2) = args(2);  % {grp,pref}
        if ~ischar(args{2})
            error('uimgr:PrefsMustBeString','PREFS must be a string');
        end
        if nargs>2
            % UI(GROUP,PREF,PLACE)
            uiArgs(2) = args(3);  % (NAME,PLACE)
        end
    end
end

% [EOF]
