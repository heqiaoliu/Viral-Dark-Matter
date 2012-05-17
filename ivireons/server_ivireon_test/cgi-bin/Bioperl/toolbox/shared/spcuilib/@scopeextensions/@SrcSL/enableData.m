function enableData(this, varargin)
%EnableData Enable Simulink data connection to start firing events.
%    Generally opens the "Simulink data valve"
%
%    Enables simulation state listeners
%    Enables run-time object execution events

% Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/04/27 19:54:19 $

% If the SimulinkMode of the model is set to "normal" we can add listeners
% to the RunTimeObject of the target block.  If it is set to anything else,
% the events are not sent properly.  Warn the user via the screenMsg that
% they will not be getting data.
if strcmpi(get(getSystemHandle(this.SLConnectMgr), 'SimulationMode'), 'normal')
    % Enable data events
    enableRuntimeData(this.SLConnectMgr, varargin{:});
else
    hApp = get(this, 'Application');
    hApp.screenMsg(sprintf('%s can only show data when the Simulink simulation mode is set to Normal.', ...
        hApp.getAppName(true)));
end

% [EOF]
