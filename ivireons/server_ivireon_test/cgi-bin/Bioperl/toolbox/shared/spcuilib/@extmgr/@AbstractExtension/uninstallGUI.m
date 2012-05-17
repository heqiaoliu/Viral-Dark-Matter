function uninstallGUI(this, allowRender)
%UNINSTALLGUI If extension has a GUI, uninstall it now.
%   UNINSTALLGUI(H) uninstall the GUI if it exists.

% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/09/09 21:28:54 $

hInstall = get(this, 'UIMgrGUI');
if ~isempty(hInstall)
    
    hUIMgr = getGUI(this.Application);
    uninstall(hInstall,hUIMgr);  % un-renders as well
    set(this, 'UIMgrGUI', []);
    
    if nargin < 2 || allowRender
    
        render(hUIMgr);
    end
end

% [EOF]
