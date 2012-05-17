function updateConnectButton(this, mode)
%UpdateConnectButton Manage Simulink connection button
%   Adjusts icon and tooltip for connect and disconnect states.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2009/04/27 19:54:26 $

hUI = getGUI(this.Application);
hb  = hUI.findwidget('Toolbars', 'Main', 'Sources', 'ConnectSLButton');

switch mode
    case 'connect'

        % Make sure that the state of the button is 'on', but this will
        % fire the callback, so we must cache it, set it to '' and reset it
        % back to the original value.
        on_cb         = hb.oncallback; % cache old on-callback
        hb.oncallback = '';            % and turn it off
        hb.state      = 'on';          % turn on control
        hb.oncallback = on_cb;         % restore on-callback

        % The label and callback must not indicate they do the opposite.
        label        = 'Disconnect from &Simulink Signal';
        menuCallback = @(hco,ev) releaseData(this.Application);

    case 'disconnect'

        % Make sure that the state of the button is 'on', but this will
        % fire the callback, so we must cache it, set it to '' and reset it
        % back to the original value.
        off_cb         = hb.offcallback; % cache old off-callback
        hb.offcallback = '';             % and turn it off
        hb.state       = 'off';          % turn off control
        hb.offcallback = off_cb;         % restore off-callback

        % The label and callback must not indicate they do the opposite.
        label        = 'Connect to &Simulink Signal';
        menuCallback = @(hco,ev) connectToDataSource(this.Application, this);

    otherwise
        error(generatemsgid('InvalidConnectionMode'), ...
            'Unrecognized connection mode: %s', mode);
end

% Update menu label and callback to indicate the button will now do the
% opposite action.
set(hUI.findwidget('Menus', 'File', 'Sources', 'ConnectSLMenu'), ...
    'Label',    label, ...
    'Callback', menuCallback);

% [EOF]
