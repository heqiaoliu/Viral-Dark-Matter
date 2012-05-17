function launch(this)
%LAUNCH Launch pixel region tool.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2008/12/22 23:47:46 $

% To launch PixelRegion, we first pause the scope if it's running
%
% Engage listener on PauseMethod event:
pause(this.Application, @(h,e) localPixelRegion(this));

% % -----------------------------------------
function localPixelRegion(this)

hScope = this.Application;

% Launch PixelRegion tool
h = this.PixelRegion;  % get existing PixelRegion widget handle
if ~ishghandle(h)
    
    hFig = hScope.Parent;
    
    % Create new pixel region tool
    this.PixelRegion = impixelregion(hFig);
    
    % Suppress the JavaFrame warning. g380932
    [lastWarnMsg lastWarnId] = lastwarn;
    oldstate = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

    % Set docking group for this figure
    jf = get(this.PixelRegion, 'javaframe');
    jff = get(hFig, 'javaframe');
    jf.setGroupName(jff.getGroupName);

    % Restore the JavaFrame warning and lastwarn states.
    warning(oldstate);
    lastwarn(lastWarnMsg, lastWarnId);

    % When impixelregion closes, disable the extension.  Turn off listeners.
    this.CloseListener = iptui.iptaddlistener(this.PixelRegion, ...
        'ObjectBeingDestroyed', @(h,e) disable(this));
    this.VisibleListener = iptui.iptaddlistener(hFig, 'Visible', 'PostSet', ...
        @(h,e) disable(this));
else
    % Bring existing figure to front and center the view
    figure(h);
    pixelRegionPanel = findobj(this.PixelRegion,'Tag','imscrollpanel');
    pixelRegionPanelAPI = getappdata(pixelRegionPanel,'impixelregionpanelAPI');
    pixelRegionPanelAPI.centerRectInViewport();

end

% [EOF]
