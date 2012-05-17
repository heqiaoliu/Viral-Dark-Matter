function varargout = FreqScope(MaskType,DlgPos,varargin) 
% FREQSCOPE  launch a frequency domain scope
%

% Author(s): A. Stothert 03-Nov-2009
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:53:45 $

hCfg = slctrlguis.checkblkviews.FreqScopeCfg(MaskType, DlgPos, ...
   varargin, uiservices.cacheFcnArgNames);
hScope = uiscopes.new(hCfg);

%Configure extensions for frequency domain scope
localConfigureScope(hScope)

if nargout > 0
    varargout = {hScope};
end
end

function localConfigureScope(hScope)
% Helper function to configure generic extensions used by frequency domain
% scopes
%

uiMgr = hScope.getGUI;

%Hide new, fileset, and configuration related menus, as not applicable for linearization
%scopes
hWidget = [...
   uiMgr.findchild('Base/Menus/File/New'); ...
   uiMgr.findchild('Base/Toolbars/Main/New'); ...
   uiMgr.findchild('Base/Menus/View/ViewBars'); ...
   uiMgr.findchild('Base/Menus/View/BringFwd'); ...
   uiMgr.findchild('Base/Toolbars/Main'); ...
   uiMgr.findchild('Base/Menus/File/FileSets'); ...
   uiMgr.findchild('Base/Menus/File/FileSets/Configs')];

%Hide the status bar frame-rate widget
hWidget = [hWidget; ...
   uiMgr.findchild('Base/StatusBar/StdOpts/Rate')];

%Hide simulation step fwd playback and snapshot as not relevant for 
%linearization scopes
hWidget = [hWidget; ...
   uiMgr.findchild('Base/Menus/Playback/SimMenus/SimControls/StepFwd'); ...
   uiMgr.findchild('Base/Toolbars/Playback/SimButtons/SimControls/StepFwd'); ...
   uiMgr.findchild('Base/Menus/Playback/SimMenus/PlaybackModes/Snapshot'); ...
   uiMgr.findchild('Base/Toolbars/Playback/SimButtons/PlaybackModes/Snapshot')];

%Hide the message and keyboard command help menus
hWidget = [hWidget; ...
   uiMgr.findchild('Base/Menus/Help/Main')];

%Disable and hide the widgets
set(hWidget,'Enable','off','Visible','off');
end
