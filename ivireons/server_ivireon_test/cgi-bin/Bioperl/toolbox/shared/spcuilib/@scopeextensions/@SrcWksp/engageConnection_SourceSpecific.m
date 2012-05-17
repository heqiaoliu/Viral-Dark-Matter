function engageConnection_SourceSpecific(this)
%engageConnection_SourceSpecific Called by Source::enable method when a source is enabled.
%   Overload for SrcWksp.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2009/04/27 19:54:30 $

% Get the path to the function which contains the src variable if it exists
cacheSourcePath(this);
% Data source
success = installDataHandler(this);
if success
    hGUI = getGUI(this.Application);
    set(findchild(hGUI, 'Base/StatusBar/StdOpts/Rate'), 'Visible', 'on');
end

% [EOF]
