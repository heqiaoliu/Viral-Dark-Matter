function engageConnection_SourceSpecific(this)
%engageConnection_SourceSpecific Called by Source::enable method when a source is enabled.
%   Overload for SrcSL.

% xxx this is also "connectSource", that is, it attempts to establish a
% data connection.  Not what we want when we "enable" a source.  We just
% want it to appear as an opportunity in the GUI, etc.  So we need to
% consider splitting this into "connectSource" and "enableSource".

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2010/02/17 18:59:08 $

% Instantiate Simulink-based playback control handler
%   - menus, buttons, status bar, keyboard controls
%   - maintains source state
%
% For Simulink, we need these controls instantiated before
% the dcsObj ... dcsObj needs to look at these widgets
% during instantiation for floating/persistent modes
%this.controls = extensions.PlaybackControlsSimulink(this.Application, this);

success = installDataHandler(this);
if success
    
    % Connect to the simulink blocks/lines specified by DataConnectArgs
    connectState(this);
    
    % Update GUI controls now that source is connected
    if strcmp(this.ErrorStatus, 'success')
        update(this.controls);
        hGUI = getGUI(this.Application);
        set(findchild(hGUI, 'Base/StatusBar/StdOpts/Rate'), 'Visible', 'off');
    end
    
end

% [EOF]
