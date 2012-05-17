function installGUI(this, allowRender)
%INSTALLGUI If extension has a GUI, install and render it now.
%   INSTALLGUI(H) installs the GUI aspects of the extension as specified by
%   the uimgr.uiinstaller object returned from createGUI.
%
%   INSTALLGUI(H, false) installs the GUI but suppresses rendering until a
%   later time.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:45:27 $


% If we have already created the GUI simply return early
hUIMgr = getGUI(this.Application);

% Return early if the application does not support a UIMgr-based GUI.
if isempty(hUIMgr)
    return;
end

if isempty(this.UIMgrGUI)
    hGUI = createGUI(this);
    
    % If the extension does not wish to add GUI components, return early.
    if isempty(hGUI)
        return;
    end
    this.UIMgrGUI = hGUI;

    install(hGUI, hUIMgr);
end
    
% Must call render() manually after install() method.  This provides
% efficiency during startup phases (e.g., for our case when allowRender =
% false).
if nargin < 2 || allowRender
    render(hUIMgr);
end

% [EOF]
