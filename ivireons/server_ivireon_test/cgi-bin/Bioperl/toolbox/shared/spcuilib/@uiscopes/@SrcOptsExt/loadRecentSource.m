function loadRecentSource(this)
%LOADRECENTSOURCE Callback from selecting recently used source from
%   menu list.  
%
%   From RecentFilesList callback, the item arg is specified as
%      {itemName, itemData}
%   itemName is ignored (used for menu items in history list).
%   itemData is the Source() serialization we need for loading


%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/06/11 16:06:17 $

item = this.RecentSources.SelectedItem;

hApp = get(this, 'Application');

% ignore the name used for menu, just get command-line args
sourceArgs = item{2};
hScopeCLI = hApp.ScopeCfg.ScopeCLI;
hScopeCLI.Args = sourceArgs;

% Call with user fcn, so LoadSource does no error handling
hApp.loadSource(hScopeCLI, @(h, ev) local_LoadRecentSourceContinue(h, ev));

% --------------------------------------------
function local_LoadRecentSourceContinue(hApp, eventData)
% LoadSource completed its tasks

hNewSource = eventData.Data;

if strcmpi(hNewSource.ErrorStatus,'failure')
    errmsg = uiservices.cleanErrorMessage(hNewSource.ErrorMsg);
    if isempty(hApp.DataSource)
        screenMsg(hApp, errmsg);
    else
        uiscopes.errorHandler(errmsg,'Load Recent Source');
    end
end

% [EOF]
